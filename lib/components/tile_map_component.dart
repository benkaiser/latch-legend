import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../config/game_constants.dart';
import '../models/level_data.dart';

/// Renders the tile grid for the level.
/// Uses sprite tiles when available, falls back to canvas drawing.
class TileMapComponent extends PositionComponent {
  final LevelData level;
  Sprite? _tileSprite;
  Sprite? _tileTopSprite;
  Sprite? _tileFloorSprite;
  bool _spritesLoaded = false;

  TileMapComponent({required this.level})
      : super(
          size: Vector2(
            level.width * GameConstants.tileSize,
            level.height * GameConstants.tileSize,
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final tileImg = await Flame.images.load('sprites/cave_tile.png');
      _tileSprite = Sprite(tileImg);

      final topImg = await Flame.images.load('sprites/cave_tile_top.png');
      _tileTopSprite = Sprite(topImg);

      final floorImg = await Flame.images.load('sprites/cave_tile_floor.png');
      _tileFloorSprite = Sprite(floorImg);

      _spritesLoaded = true;
    } catch (_) {
      _spritesLoaded = false;
    }
  }

  @override
  void render(Canvas canvas) {
    final ts = GameConstants.tileSize;

    for (int row = 0; row < level.height; row++) {
      for (int col = 0; col < level.width; col++) {
        final tile = level.grid[row][col];
        if (tile != TileType.solid) continue;

        final x = col * ts;
        final y = row * ts;

        if (_spritesLoaded) {
          _renderSpriteAt(canvas, col, row, x, y, ts);
        } else {
          _renderFallbackAt(canvas, col, row, x, y, ts);
        }
      }
    }
  }

  void _renderSpriteAt(Canvas canvas, int col, int row, double x, double y, double ts) {
    // Choose tile variant based on neighbors
    final airBelow = !level.isSolid(col, row + 1);
    final airAbove = !level.isSolid(col, row - 1);

    Sprite sprite;
    if (airBelow) {
      // Ceiling tile (bottom face exposed — hook surface)
      sprite = _tileTopSprite ?? _tileSprite!;
    } else if (airAbove) {
      // Floor tile (top face exposed — walkable surface)
      sprite = _tileFloorSprite ?? _tileSprite!;
    } else {
      // Interior/generic tile
      sprite = _tileSprite!;
    }

    sprite.render(
      canvas,
      position: Vector2(x, y),
      size: Vector2(ts, ts),
    );

    // Add edge highlights even with sprites for visual consistency
    if (airBelow) {
      canvas.drawRect(
        Rect.fromLTWH(x, y + ts - 2, ts, 2),
        Paint()..color = GameConstants.tileCeilBottom,
      );
    }
    if (airAbove) {
      canvas.drawRect(
        Rect.fromLTWH(x, y, ts, 2),
        Paint()..color = GameConstants.tileFloorTop,
      );
    }
  }

  void _renderFallbackAt(Canvas canvas, int col, int row, double x, double y, double ts) {
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

    // Edge highlights
    if (!level.isSolid(col, row + 1)) {
      canvas.drawRect(
        Rect.fromLTWH(x, y + ts - 3, ts, 3),
        Paint()..color = GameConstants.tileCeilBottom,
      );
    }
    if (!level.isSolid(col, row - 1)) {
      canvas.drawRect(
        Rect.fromLTWH(x, y, ts, 3),
        Paint()..color = GameConstants.tileFloorTop,
      );
    }
    if (!level.isSolid(col - 1, row)) {
      canvas.drawRect(
        Rect.fromLTWH(x, y, 2, ts),
        Paint()..color = GameConstants.tileHighlight,
      );
    }
    if (!level.isSolid(col + 1, row)) {
      canvas.drawRect(
        Rect.fromLTWH(x + ts - 2, y, 2, ts),
        Paint()..color = GameConstants.tileBorder,
      );
    }
  }
}
