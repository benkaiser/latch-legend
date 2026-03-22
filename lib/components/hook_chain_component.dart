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

  // Thin white rope like Hook Champ — 1px line, very clean
  static final Paint _ropePaint = Paint()
    ..color = GameConstants.ropeColor
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  static final Paint _hookDotPaint = Paint()
    ..color = GameConstants.grappleColor
    ..style = PaintingStyle.fill;

  /// Start a "miss" animation — hook shoots up from player position
  void startWhiff(Vector2 playerPos) {
    isWhiffing = true;
    _whiffTime = 0;
    _whiffStart = playerPos.clone();
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
    if (isWhiffing) {
      _renderWhiff(canvas);
      return;
    }

    if (!isVisible) return;

    // Simple thin line — clean like Hook Champ
    canvas.drawLine(
      Offset(startPos.x, startPos.y),
      Offset(endPos.x, endPos.y),
      _ropePaint,
    );

    // Small dot at the anchor point
    canvas.drawCircle(Offset(endPos.x, endPos.y), 3, _hookDotPaint);
  }

  void _renderWhiff(Canvas canvas) {
    final duration = GameConstants.hookWhiffDuration;
    final progress = (_whiffTime / duration).clamp(0.0, 1.0);
    final double extend;
    if (progress < 0.5) {
      extend = progress * 2;
    } else {
      extend = (1 - progress) * 2;
    }

    final hookTip = Vector2(
      _whiffStart.x + (_whiffEnd.x - _whiffStart.x) * extend,
      _whiffStart.y + (_whiffEnd.y - _whiffStart.y) * extend,
    );

    final alpha = ((1 - progress * 0.5) * 255).toInt().clamp(50, 255);
    final fadePaint = Paint()
      ..color = GameConstants.ropeColor.withAlpha(alpha)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(_whiffStart.x, _whiffStart.y),
      Offset(hookTip.x, hookTip.y),
      fadePaint,
    );

    canvas.drawCircle(
      Offset(hookTip.x, hookTip.y),
      2.5,
      Paint()..color = GameConstants.grappleColor.withAlpha(alpha),
    );
  }
}
