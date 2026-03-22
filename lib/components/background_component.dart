import 'dart:math';
import 'package:flame/components.dart';
import 'dart:ui';
import '../config/game_constants.dart';

/// Dark cave background with vertical rock streaks (Hook Champ style).
/// Parallax driven by cameraX set externally.
class BackgroundComponent extends PositionComponent with HasGameReference {
  double cameraX = 0;

  static const _seed = 42;

  @override
  int get priority => -1;

  @override
  void render(Canvas canvas) {
    final sz = game.size;

    // Near-black cave fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, sz.x, sz.y),
      Paint()..color = GameConstants.caveBackground,
    );

    // Far parallax: very subtle dark vertical streaks
    _drawRockStreaks(canvas, sz, cameraX * 0.03, GameConstants.caveWallDark, 80, 0.4);

    // Mid parallax: slightly brighter vertical streaks
    _drawRockStreaks(canvas, sz, cameraX * 0.08, GameConstants.caveWallMid, 50, 0.6);

    // Near parallax: darkest, widest streaks giving depth
    _drawRockStreaks(canvas, sz, cameraX * 0.15, GameConstants.caveWallDark, 35, 0.8);
  }

  /// Draw vertical rock face streaks — like dark stone columns in background
  void _drawRockStreaks(
      Canvas canvas, Vector2 sz, double offset, Color color, double spacing, double intensity) {
    final rng = Random(_seed);
    final numStreaks = (sz.x / spacing).ceil() + 4;
    final xStart = -(offset % spacing) - spacing * 2;

    for (int i = 0; i < numStreaks; i++) {
      final x = xStart + i * spacing;
      final w = 8.0 + rng.nextDouble() * 20 * intensity;

      // Vertical streaks from top to bottom with varying opacity
      final streakColor = color.withAlpha((40 * intensity).toInt().clamp(10, 80));
      final paint = Paint()..color = streakColor;

      // Main vertical streak
      canvas.drawRect(
        Rect.fromLTWH(x, 0, w, sz.y),
        paint,
      );

      // Some streaks have a slightly wider base or top (irregular rock face)
      if (rng.nextDouble() > 0.5) {
        final bulgeY = rng.nextDouble() * sz.y * 0.6;
        final bulgeH = sz.y * 0.3 + rng.nextDouble() * sz.y * 0.3;
        final bulgeW = w * 1.5;
        canvas.drawRect(
          Rect.fromLTWH(x - (bulgeW - w) / 2, bulgeY, bulgeW, bulgeH),
          Paint()..color = color.withAlpha((25 * intensity).toInt().clamp(5, 50)),
        );
      }
    }
  }
}
