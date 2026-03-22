/// Tile types in the cave grid.
enum TileType {
  empty,  // air — player can move through
  solid,  // cave wall/rock — blocks movement, hook can attach to bottom
  coin,   // collectible coin (placed in empty space)
  exit,   // level exit
  spike,  // deadly spikes — kills player on contact
}

/// A level is a 2D grid of tiles.
/// Grid coordinates: (col, row) where row 0 is the top.
/// World coordinates: (col * tileSize, row * tileSize).
class LevelData {
  final int width;  // columns
  final int height; // rows
  final List<List<TileType>> grid; // grid[row][col]
  final int startCol;
  final int startRow;

  const LevelData({
    required this.width,
    required this.height,
    required this.grid,
    required this.startCol,
    required this.startRow,
  });

  TileType getTile(int col, int row) {
    if (row < 0 || row >= height || col < 0 || col >= width) {
      return TileType.solid; // out of bounds = wall
    }
    return grid[row][col];
  }

  bool isSolid(int col, int row) {
    final t = getTile(col, row);
    return t == TileType.solid || t == TileType.spike;
  }
}
