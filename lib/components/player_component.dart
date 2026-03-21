import 'dart:math';
import 'package:flame/components.dart';
import 'dart:ui';
import '../config/game_constants.dart';

class PlayerComponent extends PositionComponent {
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool isSwinging = false;
  Vector2? swingAnchor;
  double ropeLength = 0;
  double swingAngle = 0;
  double swingAngularVelocity = 0;
  bool isDead = false;
  bool facingRight = true;

  PlayerComponent()
      : super(
          size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    if (!isSwinging) {
      // Normal movement: gravity + auto-run
      velocity.y += GameConstants.gravity * dt;
      velocity.y = min(velocity.y, GameConstants.playerMaxFallSpeed);
      velocity.x = GameConstants.playerRunSpeed;
      position += velocity * dt;
    } else if (swingAnchor != null) {
      // --- Rope auto-retracts (pulls player toward anchor) ---
      if (ropeLength > GameConstants.ropeMinLength) {
        ropeLength -= GameConstants.ropeReelSpeed * dt;
        ropeLength = max(ropeLength, GameConstants.ropeMinLength);
      }

      // --- Pendulum gravity torque ---
      final gravityTorque =
          -(GameConstants.gravity / ropeLength) * sin(swingAngle);
      swingAngularVelocity += gravityTorque * dt;

      // --- Forward bias: gentle push in the positive (rightward) swing direction ---
      // This mimics how Hook Champ swings always feel like they propel you forward
      swingAngularVelocity +=
          (GameConstants.swingForwardBias / ropeLength) * dt;

      // Very light damping
      swingAngularVelocity *= pow(0.997, dt * 60).toDouble();

      swingAngle += swingAngularVelocity * dt;

      // Position from anchor
      position.x = swingAnchor!.x + sin(swingAngle) * ropeLength;
      position.y = swingAnchor!.y + cos(swingAngle) * ropeLength;
    }
  }

  void jump() {
    if (isOnGround) {
      velocity.y = GameConstants.playerJumpForce;
      isOnGround = false;
    }
  }

  void attachToGrapple(Vector2 anchor) {
    swingAnchor = anchor;
    ropeLength = (position - anchor).length;
    isSwinging = true;
    isOnGround = false;

    // Angle from vertical (straight down = 0, right = positive)
    final diff = position - anchor;
    swingAngle = atan2(diff.x, diff.y);

    // Convert current linear velocity into angular velocity
    // Tangential direction at this angle is (cos(angle), -sin(angle))
    // Angular velocity = tangential_speed / ropeLength
    final tangentialSpeed = velocity.x * cos(swingAngle) - velocity.y * sin(swingAngle);
    swingAngularVelocity = tangentialSpeed / ropeLength;
  }

  void detachFromGrapple() {
    if (!isSwinging) return;

    // Convert angular velocity back to linear velocity
    final speed = swingAngularVelocity * ropeLength;
    velocity.x = speed * cos(swingAngle);
    velocity.y = -speed * sin(swingAngle);

    // Momentum boost: if releasing while swinging forward (positive angular vel)
    // and on the upswing (angle > 0 means right of anchor), give a boost
    if (swingAngularVelocity > 0) {
      velocity.x *= GameConstants.swingBoostMultiplier;
      // Upward launch boost — the faster the swing, the bigger the launch
      velocity.y -= 80 + (swingAngularVelocity * ropeLength * 0.3).abs();
    }

    // Ensure we keep at least run speed going forward
    if (velocity.x < GameConstants.playerRunSpeed) {
      velocity.x = GameConstants.playerRunSpeed;
    }

    isSwinging = false;
    swingAnchor = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Boots (dark brown)
    canvas.drawRect(
      const Rect.fromLTWH(4, 26, 7, 6),
      Paint()..color = GameConstants.playerPants,
    );
    canvas.drawRect(
      const Rect.fromLTWH(13, 26, 7, 6),
      Paint()..color = GameConstants.playerPants,
    );

    // Pants
    canvas.drawRect(
      const Rect.fromLTWH(5, 20, 14, 8),
      Paint()..color = GameConstants.playerPants,
    );

    // Shirt / body
    canvas.drawRect(
      const Rect.fromLTWH(4, 12, 16, 10),
      Paint()..color = GameConstants.playerShirt,
    );

    // Head (skin)
    canvas.drawCircle(
      const Offset(12, 9),
      6,
      Paint()..color = GameConstants.playerSkin,
    );

    // Explorer hat
    canvas.drawRect(
      const Rect.fromLTWH(2, 2, 20, 4),
      Paint()..color = GameConstants.playerHat,
    );
    canvas.drawRect(
      const Rect.fromLTWH(6, 0, 12, 5),
      Paint()..color = GameConstants.playerHat,
    );

    // Eyes
    canvas.drawRect(
      const Rect.fromLTWH(14, 7, 2, 2),
      Paint()..color = const Color(0xFF000000),
    );
  }
}
