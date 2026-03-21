import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../components/background_component.dart';
import '../components/ceiling_component.dart';
import '../components/coin_component.dart';
import '../components/exit_component.dart';
import '../components/hook_chain_component.dart';
import '../components/platform_component.dart';
import '../components/player_component.dart';
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
  late ExitComponent exit;

  final List<PlatformBlock> platforms = [];
  final List<CeilingBlock> ceilings = [];
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

    platforms.clear();
    ceilings.clear();
    coins.clear();
    coinsCollected = 0;
    playTime = 0;

    // Load level
    levelData = buildLevelOne();

    // Background
    background = BackgroundComponent();
    camera.backdrop.add(background);

    // Floor platforms
    for (final p in levelData.platforms) {
      final block = PlatformBlock(
        x: p.x, y: p.y, width: p.width, height: p.height,
      );
      platforms.add(block);
      world.add(block);
    }

    // Ceiling blocks
    for (final c in levelData.ceilings) {
      final block = CeilingBlock(
        x: c.x, y: c.y, width: c.width, height: c.height,
      );
      ceilings.add(block);
      world.add(block);
    }

    // Coins
    for (final c in levelData.coins) {
      final coin = CoinComponent(x: c.x, y: c.y);
      coins.add(coin);
      world.add(coin);
    }

    // Exit
    exit = ExitComponent(x: levelData.exitX, y: levelData.exitY);
    world.add(exit);

    // Player
    player = PlayerComponent();
    player.position = Vector2(levelData.startX, levelData.startY);
    world.add(player);

    // Hook chain (visual rope)
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

  // --- Update loop ---

  @override
  void update(double dt) {
    super.update(dt);
    if (state != GameState.playing) return;

    playTime += dt;

    _handleCollisions();
    _updateHookChain();
    _updateHud();
    _updateBackground();
    _checkWallOfDeath();
    _checkExit();
    _checkFellOff();
  }

  // --- Collisions ---

  void _handleCollisions() {
    player.isOnGround = false;

    if (!player.isSwinging) {
      // Floor
      for (final p in platforms) {
        if (_playerOnPlatform(p)) {
          player.position.y = p.position.y;
          player.velocity.y = 0;
          player.isOnGround = true;
          break;
        }
      }

      // Ceiling
      for (final c in ceilings) {
        if (_playerHitCeiling(c)) {
          player.position.y = c.position.y + c.size.y + player.size.y / 2;
          if (player.velocity.y < 0) player.velocity.y = 0;
          break;
        }
      }
    }

    // Coins
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

  bool _playerOnPlatform(PlatformBlock p) {
    final px = player.position.x;
    final py = player.position.y;
    final prevY = py - player.velocity.y * 0.016;

    return px > p.position.x - 8 &&
        px < p.position.x + p.size.x + 8 &&
        py >= p.position.y &&
        prevY <= p.position.y + 16 &&
        player.velocity.y >= 0;
  }

  bool _playerHitCeiling(CeilingBlock c) {
    final px = player.position.x;
    final playerTop = player.position.y - player.size.y / 2;
    final cBottom = c.position.y + c.size.y;

    return px > c.position.x &&
        px < c.position.x + c.size.x &&
        playerTop < cBottom + 10 &&
        playerTop > c.position.y &&
        player.velocity.y < 0;
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
    hud.distanceTraveled = max(0, player.position.x - levelData.startX) / 50;
  }

  void _updateBackground() {
    background.cameraX = camera.viewfinder.position.x;
  }

  // --- Win/lose checks ---

  void _checkWallOfDeath() {
    if (wallOfDeath.active &&
        wallOfDeath.rightEdge > player.position.x - 16) {
      _gameOver();
    }
  }

  void _checkExit() {
    final dist = (player.position - Vector2(exit.position.x, exit.position.y)).length;
    if (dist < 50) {
      _levelComplete();
    }
  }

  void _checkFellOff() {
    if (player.position.y > GameConstants.levelHeight + 100) {
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

  // --- Ceiling hook: find where the hook hits the ceiling above the player ---

  Vector2? _findCeilingHookPoint() {
    final px = player.position.x;
    final py = player.position.y;

    // Look slightly ahead of the player (hook fires up and forward)
    final hookTargetX = px + 40;

    // Find the ceiling block above the player
    CeilingBlock? hitCeiling;
    for (final c in ceilings) {
      if (hookTargetX >= c.position.x &&
          hookTargetX <= c.position.x + c.size.x) {
        // This ceiling is above us
        final cBottom = c.position.y + c.size.y;
        if (cBottom < py) {
          hitCeiling = c;
          break;
        }
      }
    }

    if (hitCeiling == null) return null;

    // Hook point is on the underside of the ceiling
    final hookY = hitCeiling.position.y + hitCeiling.size.y;
    final hookPos = Vector2(hookTargetX, hookY);

    // Check range
    final dist = (player.position - hookPos).length;
    if (dist > GameConstants.hookRange) return null;

    return hookPos;
  }

  // --- Input ---

  void _handleGrappleOrJump() {
    if (state != GameState.playing) return;

    if (player.isSwinging) {
      // Release hook
      player.detachFromGrapple();
      return;
    }

    // Try to hook onto the ceiling above
    final hookPoint = _findCeilingHookPoint();
    if (hookPoint != null) {
      player.attachToGrapple(hookPoint);
    } else {
      // No ceiling in range — jump instead
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
