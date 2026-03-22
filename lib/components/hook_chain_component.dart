import 'dart:ui';
import 'package:flame/components.dart';
import '../config/game_constants.dart';

class HookChainComponent extends Component {
  Vector2 startPos = Vector2.zero();
  Vector2 endPos = Vector2.zero();
  bool isVisible = false;

  // Whiff animation: hook shoots up and retracts
  bool isWhiffing = false;
  double _whiffTime = 0;
  Vector2 _whiffStart = Vector2.zero();
  Vector2 _whiffEnd = Vector2.zero();

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

  /// Start a "miss" animation — hook shoots up from player position
  void startWhiff(Vector2 playerPos) {
    isWhiffing = true;
    _whiffTime = 0;
    _whiffStart = playerPos.clone();
    // Hook shoots straight up from player
    _whiffEnd = Vector2(playerPos.x, playerPos.y - GameConstants.hookRange * 0.6);
  }

  @override
  void update(double dt) {
    if (isWhiffing) {
      _whiffTime += dt;
      if (_whiffTime >= GameConstants.hookWhiffDuration) {
        isWhiffing = false;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw the whiff animation
    if (isWhiffing) {
      _renderWhiff(canvas);
      return; // don't draw normal rope during whiff
    }

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

  void _renderWhiff(Canvas canvas) {
    final duration = GameConstants.hookWhiffDuration;
    // First half: shoot out. Second half: retract.
    final progress = (_whiffTime / duration).clamp(0.0, 1.0);
    final double extend;
    if (progress < 0.5) {
      // Shooting out (0 -> 1)
      extend = progress * 2;
    } else {
      // Retracting (1 -> 0)
      extend = (1 - progress) * 2;
    }

    final hookTip = Vector2(
      _whiffStart.x + (_whiffEnd.x - _whiffStart.x) * extend,
      _whiffStart.y + (_whiffEnd.y - _whiffStart.y) * extend,
    );

    // Fade rope alpha as it retracts
    final alpha = ((1 - progress * 0.5) * 255).toInt().clamp(50, 255);
    final fadePaint = Paint()
      ..color = GameConstants.ropeColor.withAlpha(alpha)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(_whiffStart.x, _whiffStart.y),
      Offset(hookTip.x, hookTip.y),
      fadePaint,
    );

    // Hook at the tip
    canvas.drawCircle(
      Offset(hookTip.x, hookTip.y),
      4,
      Paint()..color = GameConstants.grappleColor.withAlpha(alpha),
    );
  }
}
