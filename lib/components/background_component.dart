import 'dart:math';
import 'package:flame/components.dart';
import 'dart:ui';
import '../config/game_constants.dart';

/// Cave background rendered in viewport space (doesn't scroll with world).
/// The cameraX value is set externally each frame to drive parallax.
class BackgroundComponent extends PositionComponent with HasGameReference {
  double cameraX = 0;

  static const _seed = 42;

  @override
  int get priority => -1;

  @override
  void render(Canvas canvas) {
    final sz = game.size;

    // Dark cave gradient fill
    final bgRect = Rect.fromLTWH(0, 0, sz.x, sz.y);
    final bgPaint = Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(0, sz.y),
        [GameConstants.caveTop, GameConstants.caveBottom],
      );
    canvas.drawRect(bgRect, bgPaint);

    // Cave wall texture — far layer (slow parallax)
    _drawCaveWallLayer(canvas, sz, cameraX * 0.05, GameConstants.caveWallDark, 60, 80);

    // Cave wall texture — mid layer (medium parallax)
    _drawCaveWallLayer(canvas, sz, cameraX * 0.15, GameConstants.caveWallMid, 40, 50);

    // Ceiling stalactites
    _drawStalactites(canvas, sz, cameraX * 0.2, GameConstants.ceilingSpike);

    // Floor stalagmites
    _drawStalagmites(canvas, sz, cameraX * 0.2, GameConstants.caveMidBg);
  }

  void _drawCaveWallLayer(
      Canvas canvas, Vector2 sz, double offset, Color color, double spacing, double maxHeight) {
    final paint = Paint()..color = color;
    final rng = Random(_seed);
    final numBlobs = (sz.x / spacing).ceil() + 2;
    final xStart = -(offset % spacing) - spacing;

    for (int i = 0; i < numBlobs; i++) {
      final x = xStart + i * spacing;
      // Pseudo-random heights based on position
      final h = 20.0 + rng.nextDouble() * maxHeight;
      final w = 30.0 + rng.nextDouble() * 50;

      // Top wall blobs
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, h * 0.3), width: w, height: h),
        paint,
      );

      // Bottom wall blobs
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + spacing * 0.5, sz.y - h * 0.3), width: w, height: h),
        paint,
      );
    }
  }

  void _drawStalactites(Canvas canvas, Vector2 sz, double offset, Color color) {
    final paint = Paint()..color = color;
    final rng = Random(_seed + 1);
    const spacing = 45.0;
    final numSpikes = (sz.x / spacing).ceil() + 2;
    final xStart = -(offset % spacing) - spacing;

    for (int i = 0; i < numSpikes; i++) {
      final x = xStart + i * spacing;
      final h = 15.0 + rng.nextDouble() * 35;
      final halfW = 3.0 + rng.nextDouble() * 6;

      final path = Path()
        ..moveTo(x - halfW, 0)
        ..lineTo(x, h)
        ..lineTo(x + halfW, 0)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawStalagmites(Canvas canvas, Vector2 sz, double offset, Color color) {
    final paint = Paint()..color = color;
    final rng = Random(_seed + 2);
    const spacing = 55.0;
    final numSpikes = (sz.x / spacing).ceil() + 2;
    final xStart = -(offset % spacing) - spacing;
    final baseY = sz.y;

    for (int i = 0; i < numSpikes; i++) {
      final x = xStart + i * spacing;
      final h = 10.0 + rng.nextDouble() * 25;
      final halfW = 4.0 + rng.nextDouble() * 7;

      final path = Path()
        ..moveTo(x - halfW, baseY)
        ..lineTo(x, baseY - h)
        ..lineTo(x + halfW, baseY)
        ..close();
      canvas.drawPath(path, paint);
    }
  }
}
