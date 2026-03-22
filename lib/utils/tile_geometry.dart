import 'package:flame/components.dart';
import '../models/level_data.dart';
import '../config/game_constants.dart';

/// Which corner of a tile.
enum CornerType { topLeft, topRight, bottomLeft, bottomRight }

/// World position of a tile corner, inset by epsilon to avoid edge-on issues.
Vector2 cornerPosition(int col, int row, CornerType type) {
  const ts = GameConstants.tileSize;
  const eps = 0.5;
  switch (type) {
    case CornerType.topLeft:
      return Vector2(col * ts + eps, row * ts + eps);
    case CornerType.topRight:
      return Vector2((col + 1) * ts - eps, row * ts + eps);
    case CornerType.bottomLeft:
      return Vector2(col * ts + eps, (row + 1) * ts - eps);
    case CornerType.bottomRight:
      return Vector2((col + 1) * ts - eps, (row + 1) * ts - eps);
  }
}

/// True if the solid tile at (col, row) has an exposed convex corner
/// at [type] — meaning the two adjacent sides are both air.
bool isConvexCorner(LevelData level, int col, int row, CornerType type) {
  if (!level.isSolid(col, row)) return false;

  switch (type) {
    case CornerType.topLeft:
      return !level.isSolid(col - 1, row) && !level.isSolid(col, row - 1);
    case CornerType.topRight:
      return !level.isSolid(col + 1, row) && !level.isSolid(col, row - 1);
    case CornerType.bottomLeft:
      return !level.isSolid(col - 1, row) && !level.isSolid(col, row + 1);
    case CornerType.bottomRight:
      return !level.isSolid(col + 1, row) && !level.isSolid(col, row + 1);
  }
}
