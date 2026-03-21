import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_constants.dart';

class PlatformBlock extends PositionComponent {
  PlatformBlock({
    required double x,
    required double y,
    required double width,
    required double height,
  }) : super(position: Vector2(x, y), size: Vector2(width, height));

  @override
  void render(Canvas canvas) {
    final body = Rect.fromLTWH(0, 0, size.x, size.y);

    // Dark stone fill
    canvas.drawRect(body, Paint()..color = GameConstants.platformColor);

    // Lighter top edge (like the screenshot shows lit stone tops)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 4),
      Paint()..color = GameConstants.platformTop,
    );

    // Border
    canvas.drawRect(
      body,
      Paint()
        ..color = GameConstants.platformBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Stone block lines — horizontal every 16px, vertical every 32px offset
    final linePaint = Paint()
      ..color = GameConstants.platformBorder
      ..strokeWidth = 1;

    for (double ly = 16; ly < size.y; ly += 16) {
      canvas.drawLine(Offset(0, ly), Offset(size.x, ly), linePaint);
    }
    // Vertical joints offset per row
    int row = 0;
    for (double ly = 0; ly < size.y; ly += 16) {
      final offsetX = (row % 2 == 0) ? 0.0 : 16.0;
      for (double lx = offsetX; lx < size.x; lx += 32) {
        canvas.drawLine(Offset(lx, ly), Offset(lx, ly + 16), linePaint);
      }
      row++;
    }
  }
}
