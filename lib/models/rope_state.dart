import 'package:flame/components.dart';

/// A point where the rope wraps around a tile corner.
class WrapPoint {
  final Vector2 position;
  /// +1 = clockwise wrap, -1 = counter-clockwise wrap
  final int wrapDirection;

  WrapPoint(this.position, this.wrapDirection);
}

/// Rope state: anchor + wrap points + total length.
/// The player pendulums around the last wrap point (or the anchor if none).
class RopeState {
  final Vector2 anchor;
  final List<WrapPoint> wrapPoints;
  double totalLength;

  RopeState({
    required this.anchor,
    required this.totalLength,
  }) : wrapPoints = [];

  /// The point the player currently swings around.
  Vector2 get activePivot =>
      wrapPoints.isNotEmpty ? wrapPoints.last.position : anchor;

  /// Length of the segment from the last pivot to the player.
  double get activeSegmentLength {
    double fixed = 0;
    Vector2 prev = anchor;
    for (final wp in wrapPoints) {
      fixed += (wp.position - prev).length;
      prev = wp.position;
    }
    return (totalLength - fixed).clamp(1.0, totalLength);
  }

  /// Returns the full polyline: [anchor, ...wrapPoints, playerPos].
  List<Vector2> getPolyline(Vector2 playerPos) {
    return [
      anchor,
      ...wrapPoints.map((wp) => wp.position),
      playerPos,
    ];
  }

  /// Shorten the rope by [amount], clamping active segment to [minLength].
  void reelIn(double amount, double minLength) {
    totalLength -= amount;
    // Ensure active segment doesn't go below minLength
    final minTotal = _fixedSegmentsLength() + minLength;
    if (totalLength < minTotal) {
      totalLength = minTotal;
    }
  }

  double _fixedSegmentsLength() {
    double fixed = 0;
    Vector2 prev = anchor;
    for (final wp in wrapPoints) {
      fixed += (wp.position - prev).length;
      prev = wp.position;
    }
    return fixed;
  }
}
