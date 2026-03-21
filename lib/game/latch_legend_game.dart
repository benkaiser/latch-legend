import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../components/background_component.dart';
import '../components/coin_component.dart';
import '../components/exit_component.dart';
import '../components/hook_chain_component.dart';
import '../components/player_component.dart';
import '../components/tile_map_component.dart';
import '../components/wall_of_death_component.dart';
import '../config/game_constants.dart';
import '../levels/level_one.dart';
import '../models/level_data.dart';
import '../ui/hud_component.dart';

enum GameState { menu, playing, gameOver, levelComplete }

class LatchLegendGame extends FlameGame with TapCallbacks, KeyboardEvents {
  late PlayerComponent player;
  late WallOfDeathComponent wallOfDeath;
  late HookChainComponent hookChain;
  late BackgroundComponent background;
  late HudComponent hud;
  late TileMapComponent tileMap;

  final List<CoinComponent> coins = [];

  GameState state = GameState.menu;
  int coinsCollected = 0;
  double playTime = 0;
  late LevelData levelData;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    overlays.add('menu');
  }

  void startGame() {
    overlays.remove('menu');
    overlays.remove('gameOver');
    overlays.remove('levelComplete');

    // Clear everything
    world.removeAll(world.children);
    camera.viewport.removeAll(camera.viewport.children);
    camera.backdrop.removeAll(camera.backdrop.children);

    coins.clear();
    coinsCollected = 0;
    playTime = 0;

    // Load level
    levelData = buildLevelOne();
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
    wallOfDeath = WallOfDeathComponent();
    world.add(wallOfDeath);

    // HUD
    hud = HudComponent();
    camera.viewport.add(hud);

    // Camera
    camera.follow(player);

    state = GameState.playing;
  }

  // --- Update ---

  @override
  void update(double dt) {
    super.update(dt);
    if (state != GameState.playing) return;

    playTime += dt;

    _handleTileCollisions();
    _updateHookChain();
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

  // --- HUD ---

  void _updateHud() {
    hud.coins = coinsCollected;
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
    overlays.add('gameOver');
  }

  void _levelComplete() {
    state = GameState.levelComplete;
    player.isDead = true;
    overlays.add('levelComplete');
  }

  // --- Ceiling hook: raycast upward to find solid tile above player ---

  Vector2? _findCeilingHookPoint() {
    final ts = GameConstants.tileSize;
    final px = player.position.x;
    final py = player.position.y;

    // Aim slightly ahead
    final hookX = px + 30;
    final col = (hookX / ts).floor();

    // Scan upward from player's row
    final startRow = (py / ts).floor();
    for (int row = startRow - 1; row >= 0; row--) {
      if (levelData.isSolid(col, row)) {
        // Found ceiling — hook attaches to the bottom center of this tile
        final hookPoint = Vector2(
          col * ts + ts / 2,
          (row + 1) * ts.toDouble(), // bottom edge of solid tile
        );

        // Check range
        final dist = (player.position - hookPoint).length;
        if (dist > GameConstants.hookRange) return null;
        if (dist < 20) return null; // too close

        return hookPoint;
      }
    }

    return null; // no ceiling found
  }

  // --- Input ---

  void _handleGrappleOrJump() {
    if (state != GameState.playing) return;

    if (player.isSwinging) {
      player.detachFromGrapple();
      return;
    }

    final hookPoint = _findCeilingHookPoint();
    if (hookPoint != null) {
      player.attachToGrapple(hookPoint);
    } else {
      player.jump();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _handleGrappleOrJump();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _handleGrappleOrJump();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
