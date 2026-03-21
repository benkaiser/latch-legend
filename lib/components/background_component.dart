import 'dart:math';
import 'package:flame/components.dart';
import 'dart:ui';
import '../config/game_constants.dart';

/// Cave background rendered in backdrop (doesn't scroll with world).
/// Parallax driven by cameraX set externally.
class BackgroundComponent extends PositionComponent with HasGameReference {
  double cameraX = 0;

  static const _seed = 42;

  @override
  int get priority => -1;

  @override
  void render(Canvas canvas) {
    final sz = game.size;

    // Dark cave fill
    final bgRect = Rect.fromLTWH(0, 0, sz.x, sz.y);
    final bgPaint = Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(0, sz.y),
        [GameConstants.caveBackground, GameConstants.caveBgMid],
      );
    canvas.drawRect(bgRect, bgPaint);

    // Far wall texture
    _drawCaveWallLayer(canvas, sz, cameraX * 0.05, GameConstants.caveWallDark, 60, 80);

    // Mid wall texture
    _drawCaveWallLayer(canvas, sz, cameraX * 0.15, GameConstants.caveWallMid, 40, 50);
  }

  void _drawCaveWallLayer(
      Canvas canvas, Vector2 sz, double offset, Color color, double spacing, double maxHeight) {
    final paint = Paint()..color = color;
    final rng = Random(_seed);
    final numBlobs = (sz.x / spacing).ceil() + 2;
    final xStart = -(offset % spacing) - spacing;

    for (int i = 0; i < numBlobs; i++) {
      final x = xStart + i * spacing;
      final h = 20.0 + rng.nextDouble() * maxHeight;
      final w = 30.0 + rng.nextDouble() * 50;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, h * 0.3), width: w, height: h),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + spacing * 0.5, sz.y - h * 0.3), width: w, height: h),
        paint,
      );
    }
  }
}
