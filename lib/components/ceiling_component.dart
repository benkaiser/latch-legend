import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_constants.dart';

/// Ceiling block — solid rock forming the cave roof.
/// Renders with a rough underside (stalactite fringe).
class CeilingBlock extends PositionComponent {
  CeilingBlock({
    required double x,
    required double y,
    required double width,
    required double height,
  }) : super(position: Vector2(x, y), size: Vector2(width, height));

  @override
  void render(Canvas canvas) {
    final body = Rect.fromLTWH(0, 0, size.x, size.y);

    // Dark rock fill
    canvas.drawRect(body, Paint()..color = GameConstants.caveWallDark);

    // Slightly lighter bottom edge
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - 4, size.x, 4),
      Paint()..color = GameConstants.caveWallMid,
    );

    // Stalactite fringe along the bottom edge
    final spikePaint = Paint()..color = GameConstants.ceilingSpike;
    final rng = Random(position.x.toInt());
    for (double sx = 0; sx < size.x; sx += 12 + rng.nextDouble() * 10) {
      final h = 6 + rng.nextDouble() * 18;
      final halfW = 3 + rng.nextDouble() * 4;
      final path = Path()
        ..moveTo(sx - halfW, size.y)
        ..lineTo(sx, size.y + h)
        ..lineTo(sx + halfW, size.y)
        ..close();
      canvas.drawPath(path, spikePaint);
    }

    // Stone texture lines
    final linePaint = Paint()
      ..color = GameConstants.caveWallMid
      ..strokeWidth = 1;
    for (double ly = 16; ly < size.y; ly += 16) {
      canvas.drawLine(Offset(0, ly), Offset(size.x, ly), linePaint);
    }
  }
}
