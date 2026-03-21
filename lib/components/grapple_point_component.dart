import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_constants.dart';

class GrapplePointComponent extends PositionComponent {
  bool isInRange = false;

  GrapplePointComponent({required double x, required double y})
      : super(
          position: Vector2(x, y),
          size: Vector2.all(20),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Ring mount (small rectangle above)
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy - 6), width: 6, height: 8),
      Paint()..color = const Color(0xFF666666),
    );

    // Outer ring
    final ringColor = isInRange
        ? GameConstants.grappleActiveColor
        : GameConstants.grappleColor;
    canvas.drawCircle(
      Offset(cx, cy + 2),
      8,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Highlight dot when in range
    if (isInRange) {
      canvas.drawCircle(
        Offset(cx, cy + 2),
        3,
        Paint()..color = GameConstants.grappleActiveColor.withValues(alpha: 0.5),
      );
    }
  }
}
