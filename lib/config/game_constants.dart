import 'dart:ui';

class GameConstants {
  // World — tile grid
  static const double tileSize = 32.0;
  static const double gravity = 980.0;

  // Grid dimensions (tiles)
  static const int gridHeight = 18; // 18 tiles tall = 576px viewable area

  // Player
  static const double playerWidth = 24.0;
  static const double playerHeight = 28.0;
  static const double playerRunSpeed = 200.0;
  static const double playerJumpForce = -420.0;
  static const double playerMaxFallSpeed = 600.0;

  // Hook / Grapple
  static const double hookRange = 350.0;
  static const double ropeReelSpeed = 120.0;
  static const double ropeMinLength = 40.0;
  static const double swingBoostMultiplier = 1.4;
  static const double swingForwardBias = 300.0;

  // Wall of Death
  static const double wallOfDeathStartSpeed = 60.0;
  static const double wallOfDeathAcceleration = 2.0;
  static const double wallOfDeathMaxSpeed = 250.0;
  static const double wallOfDeathStartDelay = 3.0;

  // Coins
  static const double coinSize = 16.0;
  static const double coinCollectRadius = 24.0;
  static const double coinBobAmplitude = 4.0;
  static const double coinBobSpeed = 3.0;

  // Camera
  static const double cameraLookAheadX = 150.0;
  static const double cameraLookAheadY = 50.0;
  static const double cameraSmoothSpeed = 5.0;

  // Colors — dark cave theme
  static const Color caveBackground = Color(0xFF0e0a06);
  static const Color caveBgMid = Color(0xFF1a1209);
  static const Color caveWallDark = Color(0xFF1e1409);
  static const Color caveWallMid = Color(0xFF2a1c10);
  static const Color tileColor = Color(0xFF4a3520);
  static const Color tileBorder = Color(0xFF2e1f12);
  static const Color tileHighlight = Color(0xFF6a5040);
  static const Color tileFloorTop = Color(0xFF7a6050);
  static const Color tileCeilBottom = Color(0xFF5a4535);
  static const Color grappleColor = Color(0xFF999999);
  static const Color grappleActiveColor = Color(0xFFFFD700);
  static const Color coinColor = Color(0xFFFFD700);
  static const Color coinHighlight = Color(0xFFFFF8DC);
  static const Color playerShirt = Color(0xFF4488CC);
  static const Color playerPants = Color(0xFF5C4033);
  static const Color playerSkin = Color(0xFFFFCCA0);
  static const Color playerHat = Color(0xFF8B6914);
  static const Color ropeColor = Color(0xFFCCBB88);
  static const Color wallOfDeathColor = Color(0xFF330000);
  static const Color wallOfDeathEye = Color(0xFFFF0000);
  static const Color exitColor = Color(0xFFDDCCAA);
}
