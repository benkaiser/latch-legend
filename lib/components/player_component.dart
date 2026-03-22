import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'dart:ui';
import '../config/game_constants.dart';

enum PlayerState { running, swinging }

class PlayerComponent extends PositionComponent with HasGameReference {
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool isSwinging = false;
  Vector2? swingAnchor;
  double ropeLength = 0;
  double swingAngle = 0;
  double swingAngularVelocity = 0;
  bool isDead = false;

  // Movement input: -1 = left, 0 = none, 1 = right
  int moveDirection = 0;

  // Animation
  double _animTime = 0;
  SpriteSheet? _runSheet;
  SpriteSheet? _swingSheet;
  SpriteSheet? _hookSpinSheet;
  bool _spritesLoaded = false;

  // Hook spin while running
  double _hookSpinAngle = 0;

  PlayerComponent()
      : super(
          size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final runImage = await Flame.images.load('sprites/player_run.png');
      _runSheet = SpriteSheet(image: runImage, srcSize: Vector2(32, 32));

      final swingImage = await Flame.images.load('sprites/player_swing.png');
      _swingSheet = SpriteSheet(image: swingImage, srcSize: Vector2(32, 32));

      final hookSpinImage = await Flame.images.load('sprites/player_hook_spin.png');
      _hookSpinSheet = SpriteSheet(image: hookSpinImage, srcSize: Vector2(32, 32));

      _spritesLoaded = true;
    } catch (_) {
      _spritesLoaded = false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) return;

    _animTime += dt;
    _hookSpinAngle += dt * 8; // spin speed

    if (!isSwinging) {
      // Gravity
      velocity.y += GameConstants.gravity * dt;
      velocity.y = min(velocity.y, GameConstants.playerMaxFallSpeed);

      // Auto-run right at base speed, with momentum on top
      // Base speed: always run right at playerRunSpeed
      // Momentum from grapple: excess speed above runSpeed decays slowly
      final baseSpeed = GameConstants.playerRunSpeed;

      if (velocity.x > baseSpeed) {
        // We have momentum above base speed — decay it slowly
        final decay = GameConstants.playerMomentumDecay * dt;
        velocity.x = max(baseSpeed, velocity.x - decay);
      } else {
        // Below base speed — accelerate back up to it
        velocity.x = min(baseSpeed, velocity.x + 400 * dt);
      }

      // Left/right input modifies speed slightly (optional)
      if (moveDirection < 0) {
        // Slow down a bit
        velocity.x = max(baseSpeed * 0.3, velocity.x - 200 * dt);
      } else if (moveDirection > 0) {
        // Speed up slightly above base
        velocity.x = min(GameConstants.playerMaxSpeed, velocity.x + 150 * dt);
      }

      // Clamp to max speed
      velocity.x = velocity.x.clamp(0, GameConstants.playerMaxSpeed);

      position += velocity * dt;
    } else if (swingAnchor != null) {
      // Rope auto-retracts
      if (ropeLength > GameConstants.ropeMinLength) {
        ropeLength -= GameConstants.ropeReelSpeed * dt;
        ropeLength = max(ropeLength, GameConstants.ropeMinLength);
      }

      // Pendulum gravity torque
      final gravityTorque =
          -(GameConstants.gravity / ropeLength) * sin(swingAngle);
      swingAngularVelocity += gravityTorque * dt;

      // Player input affects swing: pressing in the swing direction adds torque
      if (moveDirection != 0) {
        swingAngularVelocity +=
            (moveDirection * GameConstants.swingForwardBias / ropeLength) * dt;
      }

      // Light damping
      swingAngularVelocity *= pow(0.997, dt * 60).toDouble();

      swingAngle += swingAngularVelocity * dt;

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

    final diff = position - anchor;
    swingAngle = atan2(diff.x, diff.y);

    // Convert current velocity to angular velocity — this preserves momentum!
    final tangentialSpeed = velocity.x * cos(swingAngle) - velocity.y * sin(swingAngle);
    swingAngularVelocity = tangentialSpeed / ropeLength;
  }

  void detachFromGrapple() {
    if (!isSwinging) return;

    // Convert angular velocity back to linear — preserve ALL the swing momentum
    final speed = swingAngularVelocity * ropeLength;
    velocity.x = speed * cos(swingAngle);
    velocity.y = -speed * sin(swingAngle);

    // Boost if releasing during a forward swing
    if (swingAngularVelocity > 0) {
      velocity.x *= GameConstants.swingBoostMultiplier;
      velocity.y -= 80 + (swingAngularVelocity * ropeLength * 0.3).abs();
    }

    // Don't clamp to run speed anymore — let momentum carry!
    // Only ensure we're not going backwards
    if (velocity.x < 0) {
      velocity.x = 0;
    }

    isSwinging = false;
    swingAnchor = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_spritesLoaded) {
      _renderSprite(canvas);
    } else {
      _renderFallback(canvas);
    }
  }

  void _renderSprite(Canvas canvas) {
    final frameIndex = ((_animTime * 8) % 4).floor(); // 8 fps animation

    Sprite sprite;
    if (isSwinging) {
      sprite = _swingSheet!.getSpriteById(frameIndex);
    } else if (isOnGround && _runSheet != null) {
      // Use basic run sheet when on the ground
      sprite = _runSheet!.getSpriteById(frameIndex);
    } else {
      // Use hook spin sheet while airborne (shows hook spinning above head)
      sprite = (_hookSpinSheet ?? _runSheet)!.getSpriteById(frameIndex);
    }

    sprite.render(
      canvas,
      position: Vector2(-4, -2), // center the 32x32 sprite on the 24x28 component
      size: Vector2(32, 32),
    );
  }

  void _renderFallback(Canvas canvas) {
    // Boots
    canvas.drawRect(
      const Rect.fromLTWH(4, 22, 7, 6),
      Paint()..color = GameConstants.playerPants,
    );
    canvas.drawRect(
      const Rect.fromLTWH(13, 22, 7, 6),
      Paint()..color = GameConstants.playerPants,
    );

    // Pants
    canvas.drawRect(
      const Rect.fromLTWH(5, 16, 14, 8),
      Paint()..color = GameConstants.playerPants,
    );

    // Shirt
    canvas.drawRect(
      const Rect.fromLTWH(4, 8, 16, 10),
      Paint()..color = GameConstants.playerShirt,
    );

    // Head
    canvas.drawCircle(
      const Offset(12, 6),
      5,
      Paint()..color = GameConstants.playerSkin,
    );

    // Hat
    canvas.drawRect(
      const Rect.fromLTWH(3, 0, 18, 3),
      Paint()..color = GameConstants.playerHat,
    );
    canvas.drawRect(
      const Rect.fromLTWH(6, -2, 12, 4),
      Paint()..color = GameConstants.playerHat,
    );

    // Eye
    canvas.drawRect(
      const Rect.fromLTWH(14, 5, 2, 2),
      Paint()..color = const Color(0xFF000000),
    );

    // Hook spin circle while running (not swinging)
    if (!isSwinging) {
      final hookRadius = 12.0;
      final hx = 12 + cos(_hookSpinAngle) * hookRadius;
      final hy = -4 + sin(_hookSpinAngle) * hookRadius;

      // Rope line
      canvas.drawLine(
        const Offset(14, 4),
        Offset(hx, hy),
        Paint()
          ..color = GameConstants.ropeColor
          ..strokeWidth = 1,
      );

      // Hook
      canvas.drawCircle(
        Offset(hx, hy),
        3,
        Paint()..color = GameConstants.grappleColor,
      );
    }
  }
}
