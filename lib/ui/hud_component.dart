import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

class HudComponent extends PositionComponent with HasGameReference {
  int coins = 0;
  double distanceTraveled = 0;

  final TextPaint _coinPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFD700),
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
    ),
  );

  final TextPaint _distPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 16,
      fontFamily: 'monospace',
    ),
  );

  HudComponent() : super(priority: 100);

  @override
  void render(Canvas canvas) {
    // Coin count top-left
    _coinPaint.render(
      canvas,
      'Coins: $coins',
      Vector2(16, 16),
    );

    // Distance top-right
    final distText = '${distanceTraveled.toInt()}m';
    _distPaint.render(
      canvas,
      distText,
      Vector2(game.size.x - 100, 16),
    );
  }
}
