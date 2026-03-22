import 'dart:math';
import 'package:flame/components.dart';
import '../config/game_constants.dart';
import '../models/level_data.dart';
import '../models/rope_state.dart';
import '../utils/tile_geometry.dart';

// --- Geometry helpers ---

double cross2(Vector2 a, Vector2 b) => a.x * b.y - a.y * b.x;

double side(Vector2 a, Vector2 b, Vector2 p) {
  return cross2(b - a, p - a);
}

bool _pointInTriangle(Vector2 p, Vector2 a, Vector2 b, Vector2 c) {
  final d1 = side(a, b, p);
  final d2 = side(b, c, p);
  final d3 = side(c, a, p);
  final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
  final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
  return !(hasNeg && hasPos);
}

// --- Line of sight (DDA tile walk) ---

/// Returns true if no solid tile blocks the straight line from [a] to [b].
bool hasLineOfSight(Vector2 a, Vector2 b, LevelData level) {
  const ts = GameConstants.tileSize;
  final dx = b.x - a.x;
  final dy = b.y - a.y;
  final dist = sqrt(dx * dx + dy * dy);
  if (dist < 1) return true;

  // Step size: half a tile for reasonable precision
  final steps = (dist / (ts * 0.5)).ceil();
  for (int i = 1; i < steps; i++) {
    final t = i / steps;
    final x = a.x + dx * t;
    final y = a.y + dy * t;
    final col = (x / ts).floor();
    final row = (y / ts).floor();
    if (level.isSolid(col, row)) return false;
  }
  return true;
}

// --- Wrap detection ---

/// Scan convex corners in the sweep triangle (pivot, oldPos, newPos).
/// Return the closest WrapPoint to pivot, or null if none found.
WrapPoint? findWrapPoint(
  Vector2 pivot,
  Vector2 oldPos,
  Vector2 newPos,
  double segLen,
  LevelData level,
) {
  const ts = GameConstants.tileSize;

  // Bounding box of the triangle (pivot, oldPos, newPos) expanded slightly
  final minX = min(pivot.x, min(oldPos.x, newPos.x)) - ts;
  final maxX = max(pivot.x, max(oldPos.x, newPos.x)) + ts;
  final minY = min(pivot.y, min(oldPos.y, newPos.y)) - ts;
  final maxY = max(pivot.y, max(oldPos.y, newPos.y)) + ts;

  final colMin = (minX / ts).floor();
  final colMax = (maxX / ts).floor();
  final rowMin = (minY / ts).floor();
  final rowMax = (maxY / ts).floor();

  WrapPoint? best;
  double bestDist = double.infinity;

  for (int row = rowMin; row <= rowMax; row++) {
    for (int col = colMin; col <= colMax; col++) {
      for (final ct in CornerType.values) {
        if (!isConvexCorner(level, col, row, ct)) continue;

        final cp = cornerPosition(col, row, ct);

        // Must be within the rope segment length from pivot
        final distToPivot = (cp - pivot).length;
        if (distToPivot > segLen - 2 || distToPivot < 2) continue;

        // Must not be too close to the player (avoids grabbing adjacent wall corners)
        final distToNew = (cp - newPos).length;
        if (distToNew < GameConstants.tileSize * 1.5) continue;

        // Must be inside the sweep triangle
        if (!_pointInTriangle(cp, pivot, oldPos, newPos)) continue;

        // Pick the closest to pivot (wraps tightest)
        if (distToPivot < bestDist) {
          bestDist = distToPivot;
          // Determine wrap direction from the cross product of the sweep
          final sweepDir = side(pivot, oldPos, newPos);
          final dir = sweepDir > 0 ? 1 : -1;
          best = WrapPoint(cp, dir);
        }
      }
    }
  }

  return best;
}

// --- Unwrap detection ---

/// Returns true if the last wrap point should be removed (player swung back past it).
bool shouldUnwrap(RopeState rope, Vector2 playerPos) {
  if (rope.wrapPoints.isEmpty) return false;

  final lastWP = rope.wrapPoints.last;
  final prevPivot = rope.wrapPoints.length > 1
      ? rope.wrapPoints[rope.wrapPoints.length - 2].position
      : rope.anchor;

  // Cross product of (prevPivot → wrapPoint) × (wrapPoint → player)
  final edge = lastWP.position - prevPivot;
  final toPlayer = playerPos - lastWP.position;
  final cross = cross2(edge, toPlayer);

  // If the sign of the cross product matches the wrap direction,
  // the player is still on the wrapped side. If it flips, unwrap.
  // wrapDirection: +1 means the cross should be positive to stay wrapped.
  if (lastWP.wrapDirection > 0 && cross < 0) return true;
  if (lastWP.wrapDirection < 0 && cross > 0) return true;

  return false;
}
