class PlatformData {
  final double x;
  final double y;
  final double width;
  final double height;

  const PlatformData({
    required this.x,
    required this.y,
    required this.width,
    this.height = 32.0,
  });
}

class GrapplePointData {
  final double x;
  final double y;

  const GrapplePointData({required this.x, required this.y});
}

class CoinData {
  final double x;
  final double y;

  const CoinData({required this.x, required this.y});
}

class LevelData {
  final List<PlatformData> platforms;  // floor pieces
  final List<PlatformData> ceilings;  // ceiling pieces
  final List<GrapplePointData> grapplePoints;
  final List<CoinData> coins;
  final double startX;
  final double startY;
  final double exitX;
  final double exitY;
  final double levelWidth;

  const LevelData({
    required this.platforms,
    this.ceilings = const [],
    required this.grapplePoints,
    required this.coins,
    required this.startX,
    required this.startY,
    required this.exitX,
    required this.exitY,
    required this.levelWidth,
  });
}
