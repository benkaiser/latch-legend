import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../config/game_constants.dart';
import '../models/level_data.dart';

/// Renders the tile grid for the level.
/// Uses sprite tiles when available, falls back to canvas drawing.
/// Camera-based culling ensures only visible tiles are rendered.
class TileMapComponent extends PositionComponent with HasGameReference {
  final LevelData level;
  Sprite? _tileSprite;
  Sprite? _tileTopSprite;
  Sprite? _tileFloorSprite;
  bool _spritesLoaded = false;

  // Cached paints to avoid per-frame allocation
  static final Paint _tilePaint = Paint()..color = GameConstants.tileColor;
  static final Paint _borderPaint = Paint()..color = GameConstants.tileBorder;
  static final Paint _mortarPaint = Paint()
    ..color = GameConstants.tileBorder
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  static final Paint _ceilPaint = Paint()..color = GameConstants.tileCeilBottom;
  static final Paint _floorPaint = Paint()..color = GameConstants.tileFloorTop;
  static final Paint _highlightPaint = Paint()..color = GameConstants.tileHighlight;

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

    // Camera-based culling: only render visible tiles
    final camPos = game.camera.viewfinder.position;
    final viewSize = game.size;
    final margin = ts * 2; // extra margin to avoid pop-in

    final minX = camPos.x - viewSize.x / 2 - margin;
    final maxX = camPos.x + viewSize.x / 2 + margin;
    final minY = camPos.y - viewSize.y / 2 - margin;
    final maxY = camPos.y + viewSize.y / 2 + margin;

    final startCol = (minX / ts).floor().clamp(0, level.width - 1);
    final endCol = (maxX / ts).ceil().clamp(0, level.width - 1);
    final startRow = (minY / ts).floor().clamp(0, level.height - 1);
    final endRow = (maxY / ts).ceil().clamp(0, level.height - 1);

    for (int row = startRow; row <= endRow; row++) {
      for (int col = startCol; col <= endCol; col++) {
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
      sprite = _tileTopSprite ?? _tileSprite!;
    } else if (airAbove) {
      sprite = _tileFloorSprite ?? _tileSprite!;
    } else {
      sprite = _tileSprite!;
    }

    sprite.render(
      canvas,
      position: Vector2(x, y),
      size: Vector2(ts, ts),
    );

    // Add edge highlights even with sprites for visual consistency
    if (airBelow) {
      canvas.drawRect(Rect.fromLTWH(x, y + ts - 2, ts, 2), _ceilPaint);
    }
    if (airAbove) {
      canvas.drawRect(Rect.fromLTWH(x, y, ts, 2), _floorPaint);
    }
  }

  void _renderFallbackAt(Canvas canvas, int col, int row, double x, double y, double ts) {
    final rect = Rect.fromLTWH(x, y, ts, ts);

    // Base rock fill
    canvas.drawRect(rect, _tilePaint);

    // Stone block texture — vary slightly based on position
    // Use simple hash instead of creating Random object
    final variation = (col * 7 + row * 13) % 3;
    if (variation == 0) {
      canvas.drawRect(Rect.fromLTWH(x + 2, y + 2, ts - 4, ts - 4), _borderPaint);
      canvas.drawRect(Rect.fromLTWH(x + 4, y + 4, ts - 8, ts - 8), _tilePaint);
    }

    // Mortar lines
    canvas.drawRect(rect, _mortarPaint);

    // Edge highlights
    if (!level.isSolid(col, row + 1)) {
      canvas.drawRect(Rect.fromLTWH(x, y + ts - 3, ts, 3), _ceilPaint);
    }
    if (!level.isSolid(col, row - 1)) {
      canvas.drawRect(Rect.fromLTWH(x, y, ts, 3), _floorPaint);
    }
    if (!level.isSolid(col - 1, row)) {
      canvas.drawRect(Rect.fromLTWH(x, y, 2, ts), _highlightPaint);
    }
    if (!level.isSolid(col + 1, row)) {
      canvas.drawRect(Rect.fromLTWH(x + ts - 2, y, 2, ts), _borderPaint);
    }
  }
}
