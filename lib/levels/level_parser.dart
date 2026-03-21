import '../models/level_data.dart';

/// Parse an ASCII map into LevelData.
/// Legend: # = solid, . = air, c = coin, E = exit, S = start
LevelData parseLevelMap(List<String> map) {
  final rows = map.map((row) => row.split('')).toList();
  final height = rows.length;
  final width = rows.fold<int>(0, (max, row) => row.length > max ? row.length : max);

  int startCol = 3;
  int startRow = 14;

  final grid = <List<TileType>>[];
  for (int r = 0; r < height; r++) {
    final row = <TileType>[];
    for (int c = 0; c < width; c++) {
      final ch = (c < rows[r].length) ? rows[r][c] : '#';
      switch (ch) {
        case '#':
          row.add(TileType.solid);
        case 'c':
          row.add(TileType.coin);
        case 'E':
          row.add(TileType.exit);
        case 'S':
          startCol = c;
          startRow = r;
          row.add(TileType.empty);
        default:
          row.add(TileType.empty);
      }
    }
    grid.add(row);
  }

  return LevelData(
    width: width,
    height: height,
    grid: grid,
    startCol: startCol,
    startRow: startRow,
  );
}
