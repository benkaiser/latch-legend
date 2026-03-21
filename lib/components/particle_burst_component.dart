import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_constants.dart';

/// Lightweight particle burst for coin collection, hook events, etc.
class ParticleBurstComponent extends PositionComponent {
  final Color color;
  final double lifetime;
  double _elapsed = 0;

  final List<_Particle> _particles;

  ParticleBurstComponent({
    required Vector2 pos,
    this.color = GameConstants.coinColor,
    int count = 8,
    double speed = 100,
    this.lifetime = 0.5,
  })  : _particles = _generateParticles(count, speed),
        super(position: pos);

  static List<_Particle> _generateParticles(int count, double speed) {
    final rng = Random();
    return List.generate(count, (_) {
      final angle = rng.nextDouble() * 2 * pi;
      final spd = speed * (0.5 + rng.nextDouble() * 0.5);
      return _Particle(
        dx: cos(angle) * spd,
        dy: sin(angle) * spd,
        size: 2 + rng.nextDouble() * 3,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= lifetime) {
      removeFromParent();
      return;
    }
    for (final p in _particles) {
      p.x += p.dx * dt;
      p.y += p.dy * dt;
      p.dy += 200 * dt; // gravity on particles
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / lifetime).clamp(0.0, 1.0);
    final alpha = ((1 - progress) * 255).toInt().clamp(0, 255);
    final paint = Paint()..color = color.withAlpha(alpha);

    for (final p in _particles) {
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size * (1 - progress),
        paint,
      );
    }
  }
}

class _Particle {
  double x = 0;
  double y = 0;
  double dx;
  double dy;
  double size;

  _Particle({required this.dx, required this.dy, required this.size});
}
