import 'dart:math';
import 'package:flame/components.dart';
import 'dart:ui';
import '../config/game_constants.dart';

class CoinComponent extends PositionComponent {
  bool isCollected = false;
  late final double _baseY;
  double _time = 0;

  CoinComponent({required double x, required double y})
      : super(
          position: Vector2(x, y),
          size: Vector2.all(GameConstants.coinSize),
          anchor: Anchor.center,
        ) {
    _baseY = y;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isCollected) return;
    _time += dt;
    position.y = _baseY + sin(_time * GameConstants.coinBobSpeed) * GameConstants.coinBobAmplitude;
  }

  @override
  void render(Canvas canvas) {
    if (isCollected) return;
    final radius = size.x / 2;
    // Main coin body
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      Paint()..color = GameConstants.coinColor,
    );
    // Highlight
    canvas.drawCircle(
      Offset(radius * 0.7, radius * 0.7),
      radius * 0.35,
      Paint()..color = GameConstants.coinHighlight,
    );
  }
}
