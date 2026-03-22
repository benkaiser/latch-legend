import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../components/background_component.dart';
import '../components/coin_component.dart';
import '../components/exit_component.dart';
import '../components/hook_chain_component.dart';
import '../components/particle_burst_component.dart';
import '../components/player_component.dart';
import '../components/speed_trail_component.dart';
import '../components/tile_map_component.dart';
import '../components/wall_of_death_component.dart';
import '../config/game_constants.dart';
import '../levels/level_registry.dart';
import '../models/level_data.dart';
import '../ui/hud_component.dart';
import '../utils/rope_physics.dart';

enum GameState { menu, playing, paused, gameOver, levelComplete }

class LatchLegendGame extends FlameGame with KeyboardEvents {
  late PlayerComponent player;
  late WallOfDeathComponent wallOfDeath;
  late HookChainComponent hookChain;
  late BackgroundComponent background;
  late HudComponent hud;
  late TileMapComponent tileMap;

  final List<CoinComponent> coins = [];

  // Held keys tracking for continuous movement
  bool _leftHeld = false;
  bool _rightHeld = false;

  // Speed trail
  double _speedTrailTimer = 0;

  GameState state = GameState.menu;
  int coinsCollected = 0;
  double playTime = 0;
  int currentLevel = 0;
  late LevelData levelData;

  String get currentLevelName => levels[currentLevel].name;
  bool get hasNextLevel => currentLevel < levelCount - 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    overlays.add('menu');
  }

  void startGame({int? level}) {
    overlays.remove('menu');
    overlays.remove('gameOver');
    overlays.remove('levelComplete');
    overlays.remove('touchControls');
    overlays.remove('pause');

    if (level != null) {
      currentLevel = level.clamp(0, levelCount - 1);
    }

    // Clear everything
    world.removeAll(world.children);
    camera.viewport.removeAll(camera.viewport.children);
    camera.backdrop.removeAll(camera.backdrop.children);

    coins.clear();
    coinsCollected = 0;
    playTime = 0;
    _leftHeld = false;
    _rightHeld = false;

    // Load level
    levelData = levels[currentLevel].builder();
    final ts = GameConstants.tileSize;

    // Background
    background = BackgroundComponent();
    camera.backdrop.add(background);

    // Tile map (renders all solid tiles)
    tileMap = TileMapComponent(level: levelData);
    world.add(tileMap);

    // Spawn coins and find exit from the grid
    for (int row = 0; row < levelData.height; row++) {
      for (int col = 0; col < levelData.width; col++) {
        final tile = levelData.grid[row][col];
        if (tile == TileType.coin) {
          final coin = CoinComponent(
            x: col * ts + ts / 2,
            y: row * ts + ts / 2,
          );
          coins.add(coin);
          world.add(coin);
        } else if (tile == TileType.exit) {
          final exit = ExitComponent(
            x: col * ts + ts / 2,
            y: (row + 1) * ts,
          );
          world.add(exit);
        }
      }
    }

    // Player
    player = PlayerComponent();
    player.position = Vector2(
      levelData.startCol * ts + ts / 2,
      levelData.startRow * ts + ts / 2,
    );
    world.add(player);

    // Hook chain
    hookChain = HookChainComponent();
    world.add(hookChain);

    // Wall of Death
    wallOfDeath = WallOfDeathComponent(
      mapHeight: levelData.height * GameConstants.tileSize,
    );
    world.add(wallOfDeath);

    // HUD
    hud = HudComponent();
    camera.viewport.add(hud);

    // Camera — manual follow with look-ahead (set in update)
    camera.viewfinder.zoom = GameConstants.cameraZoom;
    camera.viewfinder.position = Vector2(
      player.position.x + GameConstants.cameraLookAheadX,
      player.position.y + GameConstants.cameraLookAheadY,
    );

    state = GameState.playing;

    // Show touch controls
    overlays.add('touchControls');
  }

  // --- Update ---

  @override
  void update(double dt) {
    if (state != GameState.playing) return;
    super.update(dt);

    playTime += dt;

    // Update player move direction from held keys
    if (_leftHeld && !_rightHeld) {
      player.moveDirection = -1;
    } else if (_rightHeld && !_leftHeld) {
      player.moveDirection = 1;
    } else {
      player.moveDirection = 0;
    }

    _handleRopeWrapping();
    _checkSpikes();
    _handleTileCollisions();
    _updateHookChain();
    _updateCamera(dt);
    _updateHud();
    _updateSpeedTrail(dt);
    _updateBackground();
    _checkWallOfDeath();
    _checkExit();
    _checkFellOff();
  }

  // --- Tile-based collision ---

  void _handleTileCollisions() {
    final ts = GameConstants.tileSize;
    player.isOnGround = false;

    // Check if player is inside a solid tile while swinging — push out without detaching
    if (player.isSwinging) {
      final halfW = player.size.x / 2 - 2;
      final halfH = player.size.y / 2 - 2;

      // If the player's center is inside a solid tile, they've been swung
      // deep into geometry — snap back to previous position and shorten rope.
      final centerCol = (player.position.x / ts).floor();
      final centerRow = (player.position.y / ts).floor();
      if (levelData.isSolid(centerCol, centerRow)) {
        if (player.prevSwingPos != null) {
          player.position.setFrom(player.prevSwingPos!);
        }
        _shortenRopeToPlayer();
      }

      if (player.isSwinging) {
        // Floor check while swinging (most common: swinging into ground)
        // Re-read position fresh for each axis check
        var py = player.position.y;
        var px = player.position.x;
        final feetRow = ((py + halfH) / ts).floor();
        final colL = ((px - halfW) / ts).floor();
        final colR = ((px + halfW) / ts).floor();
        for (int c = colL; c <= colR; c++) {
          if (levelData.isSolid(c, feetRow)) {
            player.position.y = feetRow * ts - halfH;
            _shortenRopeToPlayer();
            break;
          }
        }

        // Re-read after floor correction
        px = player.position.x;
        py = player.position.y;
        final rowT = ((py - halfH + 2) / ts).floor();
        final rowB = ((py + halfH - 2) / ts).floor();

        // Right wall check while swinging — push out, shorten rope
        final rightCol = ((px + halfW) / ts).floor();
        for (int r = rowT; r <= rowB; r++) {
          if (levelData.isSolid(rightCol, r)) {
            player.position.x = rightCol * ts - halfW;
            // Verify push destination isn't also solid — snap back if so
            final checkCol = ((player.position.x - halfW) / ts).floor();
            if (levelData.isSolid(checkCol, r)) {
              if (player.prevSwingPos != null) {
                player.position.setFrom(player.prevSwingPos!);
              }
            }
            _shortenRopeToPlayer();
            break;
          }
        }

        // Left wall check while swinging — push out, shorten rope
        px = player.position.x;
        final leftCol = ((px - halfW) / ts).floor();
        for (int r = rowT; r <= rowB; r++) {
          if (levelData.isSolid(leftCol, r)) {
            player.position.x = (leftCol + 1) * ts + halfW;
            final checkCol = ((player.position.x + halfW) / ts).floor();
            if (levelData.isSolid(checkCol, r)) {
              if (player.prevSwingPos != null) {
                player.position.setFrom(player.prevSwingPos!);
              }
            }
            _shortenRopeToPlayer();
            break;
          }
        }

        // Ceiling check while swinging
        py = player.position.y;
        px = player.position.x;
        final headRow = ((py - halfH) / ts).floor();
        final cL = ((px - halfW) / ts).floor();
        final cR = ((px + halfW) / ts).floor();
        for (int c = cL; c <= cR; c++) {
          if (levelData.isSolid(c, headRow)) {
            player.position.y = (headRow + 1) * ts + halfH;
            _shortenRopeToPlayer();
            break;
          }
        }
      }
    }

    if (!player.isSwinging) {
      player.isWallBlocked = false;  // reset each frame

      final px = player.position.x;
      final py = player.position.y;
      final halfW = player.size.x / 2 - 2;
      final halfH = player.size.y / 2;

      // Use a narrower width for floor/ceiling checks to avoid
      // wall tiles being mistaken for floor/ceiling
      final floorCheckHalfW = halfW - 4;

      // Floor collision: check tiles below player's feet
      final feetY = py + halfH;
      final feetRow = (feetY / ts).floor();
      final colL = ((px - floorCheckHalfW) / ts).floor();
      final colR = ((px + floorCheckHalfW) / ts).floor();

      for (int c = colL; c <= colR; c++) {
        if (levelData.isSolid(c, feetRow) && player.velocity.y >= 0) {
          player.position.y = feetRow * ts - halfH;
          player.velocity.y = 0;
          player.isOnGround = true;
          break;
        }
      }

      // Ceiling collision: check tiles above player's head
      final headY = py - halfH;
      final headRow = (headY / ts).floor();
      for (int c = colL; c <= colR; c++) {
        if (levelData.isSolid(c, headRow) && player.velocity.y < 0) {
          player.position.y = (headRow + 1) * ts + halfH;
          player.velocity.y = 0;
          break;
        }
      }

      // Re-read position after vertical corrections
      final px2 = player.position.x;
      final py2 = player.position.y;

      // Wall collision check rows — use a slightly inset range to avoid
      // catching floor/ceiling tiles as walls
      final rowT = ((py2 - halfH + 6) / ts).floor();
      final rowB = ((py2 + halfH - 6) / ts).floor();

      // Right wall collision
      final rightX = px2 + halfW;
      final rightCol = (rightX / ts).floor();
      for (int r = rowT; r <= rowB; r++) {
        if (levelData.isSolid(rightCol, r)) {
          player.position.x = rightCol * ts - halfW;
          player.velocity.x = 0;
          if (player.facingDirection > 0) player.isWallBlocked = true;
          break;
        }
      }

      // Left wall collision
      final leftX = px2 - halfW;
      final leftCol = (leftX / ts).floor();
      for (int r = rowT; r <= rowB; r++) {
        if (levelData.isSolid(leftCol, r)) {
          player.position.x = (leftCol + 1) * ts + halfW;
          player.velocity.x = 0;
          if (player.facingDirection < 0) player.isWallBlocked = true;
          break;
        }
      }
    }

    // Coin collection
    for (final coin in coins) {
      if (!coin.isCollected) {
        final dist = (player.position - coin.position).length;
        if (dist < GameConstants.coinCollectRadius) {
          coin.isCollected = true;
          coinsCollected++;
          // Spawn particle burst at coin position
          world.add(ParticleBurstComponent(
            pos: coin.position.clone(),
            color: GameConstants.coinColor,
            count: 10,
            speed: 120,
            lifetime: 0.4,
          ));
        }
      }
    }
  }

  // --- Rope wrapping/unwrapping ---

  /// After pushing the player out of a wall/floor during a swing,
  /// shorten the rope so the swing radius matches the new position.
  void _shortenRopeToPlayer() {
    if (player.rope == null) return;
    final pivot = player.rope!.activePivot;
    final newDist = (player.position - pivot).length;
    final fixedLen = player.rope!.totalLength - player.rope!.activeSegmentLength;
    player.rope!.totalLength = fixedLen + newDist;
  }

  void _handleRopeWrapping() {
    if (!player.isSwinging || player.rope == null || player.prevSwingPos == null) return;

    // Grace period: don't wrap for the first 0.15s after attaching,
    // so the jump has time to lift the player above nearby walls.
    if (player.swingTime < 0.15) return;

    final rope = player.rope!;
    final playerPos = player.position;
    final prevPos = player.prevSwingPos!;

    // Unwrap first (loop until stable)
    bool changed = true;
    while (changed && rope.wrapPoints.isNotEmpty) {
      changed = shouldUnwrap(rope, playerPos);
      if (changed) {
        rope.wrapPoints.removeLast();
        // Recompute swing angle from new pivot
        final newPivot = rope.activePivot;
        final diff = playerPos - newPivot;
        player.swingAngle = atan2(diff.x, diff.y);
      }
    }

    // Wrap: check if rope sweeps past a convex corner
    final pivot = rope.activePivot;
    final segLen = rope.activeSegmentLength;
    final wp = findWrapPoint(pivot, prevPos, playerPos, segLen, levelData);
    if (wp != null) {
      rope.wrapPoints.add(wp);
      // Recompute swing angle from new pivot
      final newPivot = rope.activePivot;
      final diff = playerPos - newPivot;
      player.swingAngle = atan2(diff.x, diff.y);
    }
  }

  // --- Hook chain visual ---

  void _updateHookChain() {
    if (player.isSwinging && player.rope != null) {
      hookChain.isVisible = true;
      hookChain.ropePoints = player.rope!.getPolyline(player.position);
    } else {
      hookChain.isVisible = false;
    }
  }

  // --- Camera with look-ahead ---

  void _updateCamera(double dt) {
    final targetX = player.position.x + GameConstants.cameraLookAheadX;
    final targetY = player.position.y + GameConstants.cameraLookAheadY;

    final camPos = camera.viewfinder.position;
    final smooth = GameConstants.cameraSmoothSpeed * dt;
    camPos.x += (targetX - camPos.x) * smooth;
    camPos.y += (targetY - camPos.y) * smooth;

    // Clamp vertical to keep cave in view (account for zoom)
    final mapHeight = levelData.height * GameConstants.tileSize;
    final viewHeight = size.y / camera.viewfinder.zoom;
    final minY = viewHeight / 2;
    final maxY = mapHeight - viewHeight / 2;
    // When window is taller than the map, center vertically
    if (minY > maxY) {
      camPos.y = mapHeight / 2;
    } else {
      camPos.y = camPos.y.clamp(minY, maxY);
    }

    camera.viewfinder.position = camPos;
  }

  // --- HUD ---

  void _updateHud() {
    hud.coins = coinsCollected;
    hud.levelName = currentLevelName;
    final startX = levelData.startCol * GameConstants.tileSize;
    hud.distanceTraveled = max(0, player.position.x - startX) / 50;
  }

  void _updateBackground() {
    background.cameraX = camera.viewfinder.position.x;
  }

  // --- Speed trail ---

  void _updateSpeedTrail(double dt) {
    final speed = player.velocity.length;
    if (speed < GameConstants.speedTrailThreshold) return;

    _speedTrailTimer += dt;
    if (_speedTrailTimer >= GameConstants.speedTrailInterval) {
      _speedTrailTimer = 0;
      world.add(SpeedTrailComponent(
        pos: Vector2(
          player.position.x - player.size.x / 2,
          player.position.y,
        ),
      ));
    }
  }

  // --- Win/lose ---

  void _checkWallOfDeath() {
    if (wallOfDeath.active &&
        wallOfDeath.rightEdge > player.position.x - 16) {
      _gameOver();
    }
  }

  void _checkSpikes() {
    final ts = GameConstants.tileSize;
    final halfW = player.size.x / 2 - 2;
    final halfH = player.size.y / 2 - 2;
    // Check tiles at player's feet and center
    final cols = [
      (player.position.x / ts).floor(),
      ((player.position.x - halfW) / ts).floor(),
      ((player.position.x + halfW) / ts).floor(),
    ];
    final rows = [
      (player.position.y / ts).floor(),
      ((player.position.y + halfH) / ts).floor(),
    ];
    for (final col in cols) {
      for (final row in rows) {
        if (levelData.getTile(col, row) == TileType.spike) {
          _gameOver();
          return;
        }
      }
    }
  }

  void _checkExit() {
    final ts = GameConstants.tileSize;
    // Check if player overlaps any exit tile
    final col = (player.position.x / ts).floor();
    final row = (player.position.y / ts).floor();
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (levelData.getTile(col + dc, row + dr) == TileType.exit) {
          _levelComplete();
          return;
        }
      }
    }
  }

  void _checkFellOff() {
    if (player.position.y > levelData.height * GameConstants.tileSize + 100) {
      _gameOver();
    }
  }

  void _gameOver() {
    state = GameState.gameOver;
    player.isDead = true;
    overlays.remove('touchControls');
    overlays.add('gameOver');
  }

  void _levelComplete() {
    state = GameState.levelComplete;
    player.isDead = true;
    overlays.remove('touchControls');
    overlays.add('levelComplete');
  }

  void pauseGame() {
    if (state != GameState.playing) return;
    state = GameState.paused;
    overlays.remove('touchControls');
    overlays.add('pause');
  }

  void resumeGame() {
    if (state != GameState.paused) return;
    state = GameState.playing;
    overlays.remove('pause');
    overlays.add('touchControls');
  }

  void quitToMenu() {
    state = GameState.menu;
    world.removeAll(world.children);
    camera.viewport.removeAll(camera.viewport.children);
    camera.backdrop.removeAll(camera.backdrop.children);
    coins.clear();
    currentLevel = 0;
    overlays.remove('pause');
    overlays.remove('touchControls');
    overlays.add('menu');
  }

  void nextLevel() {
    if (hasNextLevel) {
      currentLevel++;
      startGame();
    } else {
      // All levels complete — clean up and return to menu
      world.removeAll(world.children);
      camera.viewport.removeAll(camera.viewport.children);
      camera.backdrop.removeAll(camera.backdrop.children);
      coins.clear();
      currentLevel = 0;
      state = GameState.menu;
      overlays.remove('touchControls');
      overlays.add('menu');
    }
  }

  // --- Ceiling hook: raycast forward-and-up to find best hook point ---
  // Searches columns well ahead of the player to maintain momentum.
  // Strongly prefers points that are forward and diagonally up,
  // not directly overhead (which kills forward speed).

  Vector2? _findCeilingHookPoint({double? targetWorldX}) {
    final ts = GameConstants.tileSize;
    final px = player.position.x;
    final py = player.position.y;

    Vector2? bestPoint;
    double bestScore = double.negativeInfinity;

    // If we have a tap target, scan around that X position
    // Otherwise scan in facing direction (keyboard fallback)
    final dir = player.facingDirection;
    List<double> offsets;
    if (targetWorldX != null) {
      // Build offsets centered on the tap target relative to player
      final tapOffset = targetWorldX - px;
      offsets = [tapOffset, tapOffset - 30, tapOffset + 30, tapOffset - 60, tapOffset + 60];
    } else {
      offsets = [120.0 * dir, 150.0 * dir, 90.0 * dir, 180.0 * dir, 60.0 * dir, 200.0 * dir, 40.0 * dir];
    }

    for (final offsetX in offsets) {
      final hookX = px + offsetX;
      final col = (hookX / ts).floor();

      // Scan upward from player's row
      final startRow = (py / ts).floor();
      for (int row = startRow - 1; row >= 0; row--) {
        if (levelData.isSolid(col, row)) {
          // Found solid tile — hook attaches to the bottom center
          final hookRow = row + 1;
          final hookPoint = Vector2(
            col * ts + ts / 2,
            hookRow * ts.toDouble(),
          );

          // CRITICAL: hook point must be ABOVE the player's center
          if (hookPoint.y >= py) break;

          // CRITICAL: there must be enough open air below the hook point
          // to actually swing. Check that at least 3 tiles below the hook
          // point are air — if not, this is a floor surface, not a ceiling.
          int airBelow = 0;
          for (int checkRow = hookRow; checkRow < hookRow + 4 && checkRow < levelData.height; checkRow++) {
            if (!levelData.isSolid(col, checkRow)) {
              airBelow++;
            } else {
              break;
            }
          }
          if (airBelow < 3) break; // not enough room to swing — it's a floor, not a ceiling

          // Check range
          final dist = (player.position - hookPoint).length;
          if (dist > GameConstants.hookRange) break;
          if (dist < 30) break; // too close

          // Line-of-sight check — reject hooks through walls
          if (!hasLineOfSight(player.position, hookPoint, levelData)) continue;

          // Score: prefer points close to tap target, or forward if keyboard
          final double score;
          if (targetWorldX != null) {
            // Tap aiming: prefer closest to tap X
            final tapDist = (hookPoint.x - targetWorldX).abs();
            score = -tapDist - dist * 0.05;
          } else {
            final dx = (hookPoint.x - px) * dir;
            final dy = py - hookPoint.y;
            final forwardBonus = dx.clamp(0, 250).toDouble();
            final heightPenalty = (dy > dist * 0.9) ? -100.0 : 0.0;
            final distPenalty = dist * 0.1;
            score = forwardBonus - distPenalty + heightPenalty;
          }

          if (score > bestScore) {
            bestScore = score;
            bestPoint = hookPoint;
          }
          break;
        }
      }
    }

    return bestPoint;
  }

  // --- Input ---

  /// Called when the player presses/holds grapple (touch down or key down).
  /// Jumps if on ground, then shoots the hook to attach.
  void handleGrappleStart({Offset? screenPos}) {
    if (state != GameState.playing) return;

    // If already swinging, ignore (release handles detach)
    if (player.isSwinging) return;

    // Always jump if on ground
    player.jump();

    // Convert screen tap to world X for aiming
    double? targetWorldX;
    if (screenPos != null) {
      final worldPos = camera.viewfinder.position;
      final screenCenter = size / 2;
      final zoom = camera.viewfinder.zoom;
      targetWorldX = worldPos.x + (screenPos.dx - screenCenter.x) / zoom;
    }

    // Try to grapple
    final hookPoint = _findCeilingHookPoint(targetWorldX: targetWorldX);
    if (hookPoint != null) {
      player.attachToGrapple(hookPoint);
      // Spark effect at hook point
      world.add(ParticleBurstComponent(
        pos: hookPoint.clone(),
        color: GameConstants.grappleActiveColor,
        count: 6,
        speed: 80,
        lifetime: 0.3,
      ));
    } else {
      // No ceiling in range — show whiff animation toward aimed direction
      if (!hookChain.isWhiffing) {
        final Vector2 whiffDir;
        if (targetWorldX != null) {
          // Aim toward tap position (above player)
          whiffDir = Vector2(targetWorldX - player.position.x, -GameConstants.hookRange * 0.5).normalized();
        } else {
          // Keyboard: aim diagonally forward-up in facing direction
          whiffDir = Vector2(player.facingDirection.toDouble(), -1).normalized();
        }
        hookChain.startWhiff(player.position, whiffDir);
      }
    }
  }

  /// Called when the player releases grapple (touch up or key up).
  /// Detaches from the rope — timing determines the swing-jump boost.
  void handleGrappleRelease() {
    if (state != GameState.playing) return;
    if (player.isSwinging) {
      player.detachFromGrapple();
    }
  }

  /// Touch/external: set left movement
  void setLeftHeld(bool held) {
    _leftHeld = held;
  }

  /// Touch/external: set right movement
  void setRightHeld(bool held) {
    _rightHeld = held;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // Track held state for left/right
    _leftHeld = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    _rightHeld = keysPressed.contains(LogicalKeyboardKey.arrowRight);

    // Jump+grapple on space or up press, release to detach
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (state == GameState.playing) {
          pauseGame();
        } else if (state == GameState.paused) {
          resumeGame();
        }
        return KeyEventResult.handled;
      }

      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        handleGrappleStart();
        return KeyEventResult.handled;
      }
    }

    if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        handleGrappleRelease();
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
