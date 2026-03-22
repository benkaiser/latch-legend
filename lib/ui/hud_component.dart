import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

/// Minimal in-game HUD — Hook Champ style: almost invisible during gameplay.
/// Only shows a tiny coin count. Level name fades out after 2 seconds.
class HudComponent extends PositionComponent with HasGameReference {
  int coins = 0;
  double distanceTraveled = 0;
  String levelName = '';
  double _levelNameTimer = 0;

  static const double _levelNameShowDuration = 3.0;

  final TextPaint _coinPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xAAFFD700),
      fontSize: 14,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
    ),
  );

  HudComponent() : super(priority: 100);

  void resetLevelNameTimer() {
    _levelNameTimer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _levelNameTimer += dt;
  }

  @override
  void render(Canvas canvas) {
    // Tiny coin count — top-left, subtle
    _coinPaint.render(
      canvas,
      '× $coins',
      Vector2(32, 8),
    );

    // Small gold circle as coin icon
    canvas.drawCircle(
      const Offset(18, 16),
      6,
      Paint()..color = const Color(0xAAFFD700),
    );

    // Level name fades out after a few seconds
    if (_levelNameTimer < _levelNameShowDuration && levelName.isNotEmpty) {
      final fadeProgress = (_levelNameTimer / _levelNameShowDuration).clamp(0.0, 1.0);
      // Fade: full opacity first 2s, then fade out in last 1s
      final alpha = fadeProgress < 0.67
          ? 1.0
          : 1.0 - ((fadeProgress - 0.67) / 0.33);

      if (alpha > 0.01) {
        final fadePaint = TextPaint(
          style: TextStyle(
            color: Color.fromARGB((alpha * 200).toInt(), 255, 255, 255),
            fontSize: 16,
            fontFamily: 'monospace',
          ),
        );
        fadePaint.render(
          canvas,
          levelName,
          Vector2(game.size.x / 2 - levelName.length * 4.5, 8),
        );
      }
    }
  }
}
