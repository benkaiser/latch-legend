import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_constants.dart';

class ExitComponent extends PositionComponent {
  double _time = 0;

  ExitComponent({required double x, required double y})
      : super(
          position: Vector2(x, y),
          size: Vector2(40, 64),
          anchor: Anchor.bottomCenter,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    // Main doorway
    final doorRect = size.toRect();
    canvas.drawRect(doorRect, Paint()..color = GameConstants.exitColor);

    // Pulsing inner glow
    final glowAlpha = (0.3 + 0.5 * ((sin(_time * 3) + 1) / 2)).clamp(0.3, 0.8);
    final glowRect = doorRect.deflate(6);
    canvas.drawRect(
      glowRect,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: glowAlpha),
    );

    // Border
    canvas.drawRect(
      doorRect,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
