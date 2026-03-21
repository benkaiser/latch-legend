import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart' as flame_sprite;
import 'dart:ui';
import '../config/game_constants.dart';

class CoinComponent extends PositionComponent {
  bool isCollected = false;
  late final double _baseY;
  double _time = 0;
  flame_sprite.Sprite? _sprite;
  bool _spriteLoaded = false;

  CoinComponent({required double x, required double y})
      : super(
          position: Vector2(x, y),
          size: Vector2.all(GameConstants.coinSize),
          anchor: Anchor.center,
        ) {
    _baseY = y;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final img = await Flame.images.load('sprites/coin.png');
      _sprite = flame_sprite.Sprite(img);
      _spriteLoaded = true;
    } catch (_) {
      _spriteLoaded = false;
    }
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

    if (_spriteLoaded && _sprite != null) {
      _sprite!.render(
        canvas,
        position: Vector2.zero(),
        size: size,
      );
    } else {
      _renderFallback(canvas);
    }
  }

  void _renderFallback(Canvas canvas) {
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
