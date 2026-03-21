import '../models/level_data.dart';

/// Level 1: An enclosed cave tunnel.
///
/// Continuous ceiling + floor form a tunnel. Hooks fire upward and
/// attach to the ceiling wherever you are. Gaps in the floor create
/// pits you must swing over.
LevelData buildLevelOne() {
  return LevelData(
    levelWidth: 8000.0,
    startX: 120.0,
    startY: 460.0,
    exitX: 7700.0,
    exitY: 500.0,

    // ===== CEILING (cave roof — continuous, varying height) =====
    ceilings: const [
      PlatformData(x: 0,    y: 0,  width: 800,  height: 100),
      PlatformData(x: 800,  y: 0,  width: 600,  height: 120),
      PlatformData(x: 1400, y: 0,  width: 500,  height: 90),
      PlatformData(x: 1900, y: 0,  width: 700,  height: 140), // low ceiling
      PlatformData(x: 2600, y: 0,  width: 600,  height: 100),
      PlatformData(x: 3200, y: 0,  width: 800,  height: 80),  // tall chamber
      PlatformData(x: 4000, y: 0,  width: 600,  height: 130),
      PlatformData(x: 4600, y: 0,  width: 800,  height: 90),
      PlatformData(x: 5400, y: 0,  width: 600,  height: 110),
      PlatformData(x: 6000, y: 0,  width: 700,  height: 80),  // tallest
      PlatformData(x: 6700, y: 0,  width: 600,  height: 120),
      PlatformData(x: 7300, y: 0,  width: 700,  height: 100),
    ],

    // ===== FLOOR (cave ground — mostly continuous, pits to swing over) =====
    platforms: const [
      // Starting corridor
      PlatformData(x: 0,    y: 500, width: 500,  height: 60),
      // Small pit (500-600)
      PlatformData(x: 600,  y: 500, width: 400,  height: 60),
      // Raised section
      PlatformData(x: 1000, y: 460, width: 300,  height: 100),
      PlatformData(x: 1300, y: 500, width: 400,  height: 60),
      // Big pit (1700-1900) — swing required
      PlatformData(x: 1900, y: 480, width: 200,  height: 80),
      PlatformData(x: 2100, y: 500, width: 500,  height: 60),
      // Lower section
      PlatformData(x: 2600, y: 520, width: 300,  height: 40),
      PlatformData(x: 2900, y: 500, width: 500,  height: 60),
      // Pit before tall chamber (3400-3600)
      PlatformData(x: 3400, y: 500, width: 200,  height: 60),
      // Big gap — multiple swings in tall chamber (3600-3900)
      PlatformData(x: 3900, y: 480, width: 200,  height: 80),
      PlatformData(x: 4100, y: 500, width: 500,  height: 60),
      // Pit (4600-4800)
      PlatformData(x: 4800, y: 500, width: 200,  height: 60),
      PlatformData(x: 5200, y: 500, width: 600,  height: 60),
      // Raised approach
      PlatformData(x: 5800, y: 460, width: 300,  height: 100),
      // Final pit (6100-6300)
      PlatformData(x: 6300, y: 490, width: 150,  height: 70),
      PlatformData(x: 6600, y: 500, width: 400,  height: 60),
      PlatformData(x: 7000, y: 480, width: 300,  height: 80),
      // Exit platform
      PlatformData(x: 7300, y: 500, width: 700,  height: 60),
    ],

    // Grapple points no longer needed — hooks attach to ceiling dynamically
    grapplePoints: const [],

    // ===== COINS =====
    coins: const [
      // Starting corridor
      CoinData(x: 200, y: 470),
      CoinData(x: 300, y: 470),
      // First pit swing path
      CoinData(x: 530, y: 300),
      CoinData(x: 560, y: 280),
      // After landing
      CoinData(x: 700, y: 470),
      CoinData(x: 780, y: 470),
      // Raised section
      CoinData(x: 1100, y: 420),
      CoinData(x: 1200, y: 420),
      // Big pit swing
      CoinData(x: 1750, y: 320),
      CoinData(x: 1820, y: 300),
      CoinData(x: 1880, y: 320),
      // Mid corridor
      CoinData(x: 2200, y: 470),
      CoinData(x: 2400, y: 470),
      // Lower area
      CoinData(x: 2700, y: 490),
      // Before tall chamber
      CoinData(x: 3100, y: 460),
      CoinData(x: 3200, y: 460),
      // Tall chamber swings
      CoinData(x: 3650, y: 250),
      CoinData(x: 3750, y: 220),
      CoinData(x: 3850, y: 250),
      // After chamber
      CoinData(x: 4200, y: 470),
      CoinData(x: 4400, y: 470),
      // Pit swing
      CoinData(x: 4650, y: 280),
      CoinData(x: 4750, y: 260),
      // Post pit
      CoinData(x: 5000, y: 470),
      CoinData(x: 5300, y: 470),
      CoinData(x: 5500, y: 470),
      // Final pit swings
      CoinData(x: 6120, y: 280),
      CoinData(x: 6200, y: 260),
      // Near exit
      CoinData(x: 7400, y: 470),
      CoinData(x: 7500, y: 470),
      CoinData(x: 7600, y: 470),
      CoinData(x: 7700, y: 470),
    ],
  );
}
