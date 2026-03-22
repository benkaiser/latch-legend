import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/latch_legend_game.dart';
import 'ui/game_over_overlay.dart';
import 'ui/level_complete_overlay.dart';
import 'ui/menu_overlay.dart';
import 'ui/pause_overlay.dart';
import 'ui/touch_controls_overlay.dart';

void main() {
  runApp(const LatchLegendApp());
}

class LatchLegendApp extends StatelessWidget {
  const LatchLegendApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = LatchLegendGame();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: game,
          overlayBuilderMap: {
            'menu': (context, _) => MenuOverlay(
                  onPlay: () => game.startGame(level: 0),
                  onSelectLevel: (level) => game.startGame(level: level),
                ),
            'gameOver': (context, _) => GameOverOverlay(
                  coins: game.coinsCollected,
                  levelName: game.currentLevelName,
                  onRetry: () => game.startGame(),
                ),
            'levelComplete': (context, _) => LevelCompleteOverlay(
                  coins: game.coinsCollected,
                  time: game.playTime,
                  levelName: game.currentLevelName,
                  hasNextLevel: game.hasNextLevel,
                  onNextLevel: () => game.nextLevel(),
                  onRetry: () => game.startGame(),
                ),
            'pause': (context, _) => PauseOverlay(
                  onResume: () => game.resumeGame(),
                  onRetry: () => game.startGame(),
                  onQuit: () => game.quitToMenu(),
                ),
            'touchControls': (context, _) => TouchControlsOverlay(
                  onLeftDown: () => game.setLeftHeld(true),
                  onLeftUp: () => game.setLeftHeld(false),
                  onRightDown: () => game.setRightHeld(true),
                  onRightUp: () => game.setRightHeld(false),
                  onJumpGrapple: () => game.handleJumpAndGrapple(),
                  onPause: () => game.pauseGame(),
                ),
          },
        ),
      ),
    );
  }
}
