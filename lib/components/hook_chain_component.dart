import 'dart:ui';
import 'package:flame/components.dart';
import '../config/game_constants.dart';

class HookChainComponent extends Component {
  Vector2 startPos = Vector2.zero();
  Vector2 endPos = Vector2.zero();
  bool isVisible = false;

  static final Paint _ropePaint = Paint()
    ..color = GameConstants.ropeColor
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  static final Paint _chainPaint = Paint()
    ..color = GameConstants.ropeColor
    ..style = PaintingStyle.fill;

  static final Paint _hookPaint = Paint()
    ..color = GameConstants.grappleColor
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;

    canvas.drawLine(
      Offset(startPos.x, startPos.y),
      Offset(endPos.x, endPos.y),
      _ropePaint,
    );

    // Draw small circles along the line for a chain-link effect
    final diff = endPos - startPos;
    final length = diff.length;
    if (length < 1) return;

    final dir = diff.normalized();

    for (double d = 20; d < length; d += 20) {
      final p = startPos + dir * d;
      canvas.drawCircle(Offset(p.x, p.y), 2.5, _chainPaint);
    }

    // Draw hook at the anchor point
    canvas.drawCircle(Offset(endPos.x, endPos.y), 5, _hookPaint);
  }

  @override
  void update(double dt) {}
}
