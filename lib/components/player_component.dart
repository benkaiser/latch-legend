import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'dart:ui';
import '../config/game_constants.dart';
import '../models/rope_state.dart';

enum PlayerState { running, swinging }

class PlayerComponent extends PositionComponent with HasGameReference {
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool isSwinging = false;
  bool isWallBlocked = false;  // true when pressed against a right wall
  RopeState? rope;
  double swingAngle = 0;
  double swingAngularVelocity = 0;
  bool isDead = false;
  Vector2? prevSwingPos; // track last frame position for wrap detection
  double swingTime = 0; // time since grapple attached — grace period for wrapping

  // Movement input: -1 = left, 0 = none, 1 = right
  // Changes direction of auto-run and swing torque
  int moveDirection = 0;
  int facingDirection = 1; // 1 = right, -1 = left

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

      // Update facing direction from input
      if (moveDirection != 0) {
        facingDirection = moveDirection;
      }

      if (isOnGround) {
        // Ground movement: only move when input is held, rapid deceleration otherwise
        if (moveDirection != 0) {
          final targetSpeed = GameConstants.playerRunSpeed * moveDirection;
          final diff = targetSpeed - velocity.x;
          if (diff.abs() > 5) {
            final accel = 500.0;
            if (diff > 0) {
              velocity.x = min(targetSpeed, velocity.x + accel * dt);
            } else {
              velocity.x = max(targetSpeed, velocity.x - accel * dt);
            }
          } else {
            velocity.x = targetSpeed;
          }
        } else {
          // No input — rapid ground friction
          final friction = GameConstants.groundFriction * dt;
          if (velocity.x.abs() < friction) {
            velocity.x = 0;
          } else {
            velocity.x -= velocity.x.sign * friction;
          }
        }
      } else {
        // Airborne: no horizontal control, preserve momentum fully
      }

      // Clamp to max speed
      velocity.x = velocity.x.clamp(
        -GameConstants.playerMaxSpeed,
        GameConstants.playerMaxSpeed,
      );

      position += velocity * dt;
    } else if (rope != null) {
      prevSwingPos = position.clone();
      swingTime += dt;

      final pivot = rope!.activePivot;

      // Rope auto-retracts
      rope!.reelIn(GameConstants.ropeReelSpeed * dt, GameConstants.ropeMinLength);
      final currentSegLen = rope!.activeSegmentLength;

      // --- Velocity-based rope physics ---
      // Apply gravity
      // Gravity
      velocity.y += GameConstants.gravity * dt;
      velocity.y = min(velocity.y, GameConstants.playerMaxFallSpeed);

      // Tiny nudge in movement direction so swings don't stall
      final swingDir = velocity.x >= 0 ? 1.0 : -1.0;
      velocity.x += swingDir * 30.0 * dt;

      // Move with velocity
      position += velocity * dt;

      // Constrain to rope length: remove radial velocity component
      final diff = position - pivot;
      final dist = diff.length;
      if (dist > currentSegLen) {
        // Snap position to rope length
        final dir = diff.normalized();
        position.setFrom(pivot + dir * currentSegLen);

        // Remove outward radial velocity (keep tangential)
        final radialSpeed = velocity.dot(dir);
        if (radialSpeed > 0) {
          velocity -= dir * radialSpeed;
        }
      }

      // Update swing angle for detach calculations
      final finalDiff = position - pivot;
      swingAngle = atan2(finalDiff.x, finalDiff.y);
      final tangentialSpeed = velocity.x * cos(swingAngle) - velocity.y * sin(swingAngle);
      swingAngularVelocity = tangentialSpeed / max(currentSegLen, 1);
    }
  }

  void jump() {
    if (isOnGround) {
      velocity.y = GameConstants.playerJumpForce;
      isOnGround = false;
    }
  }

  void attachToGrapple(Vector2 anchor) {
    final dist = (position - anchor).length;
    rope = RopeState(anchor: anchor, totalLength: dist);
    isSwinging = true;
    isOnGround = false;
    prevSwingPos = position.clone();
    swingTime = 0;

    // Keep existing velocity intact — the rope constraint handles the arc
    final diff = position - anchor;
    swingAngle = atan2(diff.x, diff.y);
    swingAngularVelocity = 0;
  }

  void detachFromGrapple() {
    if (!isSwinging || rope == null) return;

    // Just keep current velocity — no artificial boost
    // The swing's natural speed IS the launch speed

    isSwinging = false;
    rope = null;
    prevSwingPos = null;
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
