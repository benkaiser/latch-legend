import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart' as flame_sprite;

import '../config/game_constants.dart';

class WallOfDeathComponent extends PositionComponent {
  double speed = 0;
  double _elapsed = 0;
  bool active = false;
  flame_sprite.Sprite? _ghostSprite;
  bool _spriteLoaded = false;

  WallOfDeathComponent({double mapHeight = GameConstants.gridHeight * GameConstants.tileSize})
      : super(
          position: Vector2(-500, 0),
          size: Vector2(500, mapHeight),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final img = await Flame.images.load('sprites/ghost.png');
      _ghostSprite = flame_sprite.Sprite(img);
      _spriteLoaded = true;
    } catch (_) {
      _spriteLoaded = false;
    }
  }

  @override
  void update(double dt) {
    _elapsed += dt;
    if (_elapsed < GameConstants.wallOfDeathStartDelay) return;
    active = true;
    speed = min(
      GameConstants.wallOfDeathStartSpeed +
          _elapsed * GameConstants.wallOfDeathAcceleration,
      GameConstants.wallOfDeathMaxSpeed,
    );
    position.x += speed * dt;
  }

  @override
  void render(Canvas canvas) {
    // Dark fog/shadow fill
    final fogPaint = Paint()
      ..shader = Gradient.linear(
        Offset.zero,
        Offset(size.x, 0),
        [
          GameConstants.wallOfDeathColor,
          GameConstants.wallOfDeathColor.withValues(alpha: 0.0),
        ],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), fogPaint);

    // Ghost monster face at the right edge, vertically centered
    final faceX = size.x - 80;
    final faceY = size.y * 0.45;

    if (_spriteLoaded && _ghostSprite != null) {
      // Render ghost sprite — scale to 96x96 for intimidating size
      final ghostSize = 96.0;
      // Slight bob animation
      final bobY = sin(_elapsed * 2) * 6;
      _ghostSprite!.render(
        canvas,
        position: Vector2(faceX - ghostSize / 2, faceY - ghostSize / 2 + bobY),
        size: Vector2(ghostSize, ghostSize),
      );
    } else {
      _renderFallbackGhost(canvas, faceX, faceY);
    }
  }

  void _renderFallbackGhost(Canvas canvas, double faceX, double faceY) {
    // Dark blob body
    final blobPaint = Paint()..color = const Color(0xFF1a0505);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(faceX, faceY), width: 120, height: 100),
      blobPaint,
    );

    // White of eye
    canvas.drawOval(
      Rect.fromCenter(center: Offset(faceX + 20, faceY - 5), width: 40, height: 36),
      Paint()..color = const Color(0xFFFFFFFF),
    );

    // Red pupil
    canvas.drawCircle(
      Offset(faceX + 26, faceY - 5),
      10,
      Paint()..color = GameConstants.wallOfDeathEye,
    );

    // Dark pupil center
    canvas.drawCircle(
      Offset(faceX + 28, faceY - 5),
      4,
      Paint()..color = const Color(0xFF000000),
    );

    // Mouth
    final mouthPath = Path()
      ..moveTo(faceX - 10, faceY + 20)
      ..quadraticBezierTo(faceX + 20, faceY + 45, faceX + 50, faceY + 20);
    canvas.drawPath(
      mouthPath,
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  double get rightEdge => position.x + size.x;
}
