import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart' as flame_sprite;

import '../config/game_constants.dart';

class ExitComponent extends PositionComponent {
  double _time = 0;
  flame_sprite.Sprite? _sprite;
  bool _spriteLoaded = false;

  ExitComponent({required double x, required double y})
      : super(
          position: Vector2(x, y),
          size: Vector2(40, 64),
          anchor: Anchor.bottomCenter,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final img = await Flame.images.load('sprites/exit_door.png');
      _sprite = flame_sprite.Sprite(img);
      _spriteLoaded = true;
    } catch (_) {
      _spriteLoaded = false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    if (_spriteLoaded && _sprite != null) {
      _sprite!.render(
        canvas,
        position: Vector2.zero(),
        size: size,
      );
      // Pulsing glow overlay
      final glowAlpha = (0.1 + 0.2 * ((sin(_time * 3) + 1) / 2)).clamp(0.1, 0.3);
      canvas.drawRect(
        size.toRect().deflate(4),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: glowAlpha),
      );
    } else {
      _renderFallback(canvas);
    }
  }

  void _renderFallback(Canvas canvas) {
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
