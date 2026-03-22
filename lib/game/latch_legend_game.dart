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
import '../components/tile_map_component.dart';
import '../components/wall_of_death_component.dart';
import '../config/game_constants.dart';
import '../levels/level_registry.dart';
import '../models/level_data.dart';
import '../ui/hud_component.dart';

enum GameState { menu, playing, gameOver, levelComplete }

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

    _handleTileCollisions();
    _updateHookChain();
    _updateCamera(dt);
    _updateHud();
    _updateBackground();
    _checkWallOfDeath();
    _checkExit();
    _checkFellOff();
  }

  // --- Tile-based collision ---

  void _handleTileCollisions() {
    final ts = GameConstants.tileSize;
    player.isOnGround = false;

    // Check if player is inside a solid tile while swinging — force detach
    if (player.isSwinging) {
      final px = player.position.x;
      final py = player.position.y;
      final halfW = player.size.x / 2 - 4;
      final halfH = player.size.y / 2 - 4;

      // Check corners of the player bounding box
      final checkPoints = [
        [px, py],                   // center
        [px - halfW, py - halfH],   // top-left
        [px + halfW, py - halfH],   // top-right
        [px - halfW, py + halfH],   // bottom-left
        [px + halfW, py + halfH],   // bottom-right
      ];

      for (final pt in checkPoints) {
        final col = (pt[0] / ts).floor();
        final row = (pt[1] / ts).floor();
        if (levelData.isSolid(col, row)) {
          // Player is inside a wall while swinging — detach and push out
          player.detachFromGrapple();
          // Push player to a safe position (back to where they were before this frame)
          player.position.x = (col + 1) * ts + player.size.x / 2;
          break;
        }
      }
    }

    if (!player.isSwinging) {
      final px = player.position.x;
      final py = player.position.y;
      final halfW = player.size.x / 2 - 2;
      final halfH = player.size.y / 2;

      // Floor collision: check tiles below player's feet
      final feetY = py + halfH;
      final feetRow = (feetY / ts).floor();
      final colL = ((px - halfW) / ts).floor();
      final colR = ((px + halfW) / ts).floor();

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

      // Left wall collision
      final leftX = px - halfW;
      final leftCol = (leftX / ts).floor();
      final rowT = ((py - halfH + 4) / ts).floor();
      final rowB = ((py + halfH - 4) / ts).floor();
      for (int r = rowT; r <= rowB; r++) {
        if (levelData.isSolid(leftCol, r)) {
          player.position.x = (leftCol + 1) * ts + halfW;
          if (player.velocity.x < 0) player.velocity.x = 0;
          break;
        }
      }

      // Right wall collision
      final rightX = px + halfW;
      final rightCol = (rightX / ts).floor();
      for (int r = rowT; r <= rowB; r++) {
        if (levelData.isSolid(rightCol, r)) {
          player.position.x = rightCol * ts - halfW;
          if (player.velocity.x > 0) player.velocity.x = 0;
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

  // --- Hook chain visual ---

  void _updateHookChain() {
    if (player.isSwinging && player.swingAnchor != null) {
      hookChain.isVisible = true;
      hookChain.startPos = player.position.clone();
      hookChain.endPos = player.swingAnchor!.clone();
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

    // Clamp vertical to keep cave in view
    final mapHeight = levelData.height * GameConstants.tileSize;
    final minY = size.y / 2;
    final maxY = mapHeight - size.y / 2;
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

  // --- Win/lose ---

  void _checkWallOfDeath() {
    if (wallOfDeath.active &&
        wallOfDeath.rightEdge > player.position.x - 16) {
      _gameOver();
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

  Vector2? _findCeilingHookPoint() {
    final ts = GameConstants.tileSize;
    final px = player.position.x;
    final py = player.position.y;

    Vector2? bestPoint;
    double bestScore = double.negativeInfinity;

    // Scan columns from well ahead to slightly behind
    // Heavy bias toward forward positions (100-200px ahead)
    for (final offsetX in [120.0, 150.0, 90.0, 180.0, 60.0, 200.0, 40.0]) {
      final hookX = px + offsetX;
      final col = (hookX / ts).floor();

      // Scan upward from player's row
      final startRow = (py / ts).floor();
      for (int row = startRow - 1; row >= 0; row--) {
        if (levelData.isSolid(col, row)) {
          // Found ceiling — hook attaches to the bottom center of this tile
          final hookPoint = Vector2(
            col * ts + ts / 2,
            (row + 1) * ts.toDouble(),
          );

          // Check range
          final dist = (player.position - hookPoint).length;
          if (dist > GameConstants.hookRange) break;
          if (dist < 30) break; // too close

          // Score: prefer points that are far ahead and at a good swing angle
          // A point directly above scores poorly (no forward momentum preserved)
          // A point ahead-and-up scores best
          final dx = hookPoint.x - px;
          final dy = py - hookPoint.y; // positive = above

          // We want the hook to be ahead (dx > 0) and above (dy > 0)
          // Score by forward distance, penalize if too directly overhead
          final forwardBonus = dx.clamp(0, 250); // reward being ahead
          final heightPenalty = (dy > dist * 0.9) ? -100.0 : 0.0; // penalize nearly vertical
          final distPenalty = dist * 0.1; // slightly prefer closer
          final score = forwardBonus - distPenalty + heightPenalty;

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

  /// Combined jump + grapple: always jump first,
  /// then also grapple if a ceiling is in range.
  /// If no ceiling, the hook shoots up and whiffs visually.
  void handleJumpAndGrapple() {
    if (state != GameState.playing) return;

    if (player.isSwinging) {
      // Release from grapple
      player.detachFromGrapple();
      return;
    }

    // Always jump if on ground
    player.jump();

    // Also try to grapple
    final hookPoint = _findCeilingHookPoint();
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
      // No ceiling in range — show whiff animation (hook shoots up and misses)
      if (!hookChain.isWhiffing) {
        hookChain.startWhiff(player.position);
      }
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

    // Jump+grapple on space or up press
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        handleJumpAndGrapple();
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
