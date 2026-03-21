import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_constants.dart';

class WallOfDeathComponent extends PositionComponent {
  double speed = 0;
  double _elapsed = 0;
  bool active = false;

  WallOfDeathComponent()
      : super(
          position: Vector2(-500, 0),
          size: Vector2(500, GameConstants.gridHeight * GameConstants.tileSize),
        );

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
