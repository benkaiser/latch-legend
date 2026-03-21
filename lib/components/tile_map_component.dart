import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../config/game_constants.dart';
import '../models/level_data.dart';

/// Renders the tile grid for the level.
/// Each solid tile is drawn as a cave rock block.
/// Exposed edges (next to air) get highlights.
class TileMapComponent extends PositionComponent {
  final LevelData level;

  TileMapComponent({required this.level})
      : super(
          size: Vector2(
            level.width * GameConstants.tileSize,
            level.height * GameConstants.tileSize,
          ),
        );

  @override
  void render(Canvas canvas) {
    final ts = GameConstants.tileSize;

    // Only render tiles visible on screen (optimization)
    // For now render all — can optimize later with camera bounds

    for (int row = 0; row < level.height; row++) {
      for (int col = 0; col < level.width; col++) {
        final tile = level.grid[row][col];
        if (tile != TileType.solid) continue;

        final x = col * ts;
        final y = row * ts;
        final rect = Rect.fromLTWH(x, y, ts, ts);

        // Base rock fill
        canvas.drawRect(rect, Paint()..color = GameConstants.tileColor);

        // Stone block texture — vary slightly based on position
        final rng = Random(col * 1000 + row);
        final variation = rng.nextInt(3);
        if (variation == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x + 2, y + 2, ts - 4, ts - 4),
            Paint()..color = GameConstants.tileBorder,
          );
          canvas.drawRect(
            Rect.fromLTWH(x + 4, y + 4, ts - 8, ts - 8),
            Paint()..color = GameConstants.tileColor,
          );
        }

        // Mortar lines
        canvas.drawRect(
          rect,
          Paint()
            ..color = GameConstants.tileBorder
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );

        // Edge highlights — if adjacent tile is air, draw a lit edge
        // Bottom edge exposed (ceiling bottom — hook attachment surface)
        if (!level.isSolid(col, row + 1)) {
          canvas.drawRect(
            Rect.fromLTWH(x, y + ts - 3, ts, 3),
            Paint()..color = GameConstants.tileCeilBottom,
          );
        }

        // Top edge exposed (floor top — walkable surface)
        if (!level.isSolid(col, row - 1)) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, ts, 3),
            Paint()..color = GameConstants.tileFloorTop,
          );
        }

        // Left edge exposed
        if (!level.isSolid(col - 1, row)) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, 2, ts),
            Paint()..color = GameConstants.tileHighlight,
          );
        }

        // Right edge exposed
        if (!level.isSolid(col + 1, row)) {
          canvas.drawRect(
            Rect.fromLTWH(x + ts - 2, y, 2, ts),
            Paint()..color = GameConstants.tileBorder,
          );
        }
      }
    }
  }
}
