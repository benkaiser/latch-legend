import 'dart:ui';

import 'package:flame/components.dart';

/// A single speed trail particle that fades and shrinks over its lifetime.
class SpeedTrailComponent extends PositionComponent {
  double _elapsed = 0;
  static const double lifetime = 0.25;

  SpeedTrailComponent({required Vector2 pos}) : super(position: pos);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / lifetime).clamp(0.0, 1.0);
    final alpha = ((1 - progress) * 120).toInt().clamp(0, 120);
    final radius = 2.0 * (1 - progress * 0.5);

    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()..color = Color.fromARGB(alpha, 200, 200, 255),
    );
  }
}
