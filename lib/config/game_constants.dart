import 'dart:ui';

class GameConstants {
  // World
  static const double tileSize = 32.0;
  static const double gravity = 980.0;

  // Player
  static const double playerWidth = 24.0;
  static const double playerHeight = 32.0;
  static const double playerRunSpeed = 200.0;
  static const double playerJumpForce = -420.0;
  static const double playerMaxFallSpeed = 600.0;

  // Hook / Grapple
  static const double hookRange = 300.0;
  static const double hookSpeed = 800.0;
  static const double ropeReelSpeed = 120.0;     // how fast the rope pulls you up (px/s)
  static const double ropeMinLength = 40.0;       // shortest the rope can get
  static const double swingBoostMultiplier = 1.4; // momentum boost on well-timed release
  static const double swingForwardBias = 300.0;   // extra forward push during swing (like the original)

  // Wall of Death
  static const double wallOfDeathStartSpeed = 60.0;
  static const double wallOfDeathAcceleration = 2.0;
  static const double wallOfDeathMaxSpeed = 250.0;
  static const double wallOfDeathStartDelay = 3.0; // seconds before it starts

  // Coins
  static const double coinSize = 16.0;
  static const double coinCollectRadius = 24.0;
  static const double coinBobAmplitude = 4.0;
  static const double coinBobSpeed = 3.0;

  // Camera
  static const double cameraLookAheadX = 150.0;
  static const double cameraLookAheadY = 50.0;
  static const double cameraSmoothSpeed = 5.0;

  // Level
  static const double levelHeight = 600.0;
  static const double groundY = 500.0;

  // Colors — dark cave theme
  static const Color caveTop = Color(0xFF1a1209);
  static const Color caveBottom = Color(0xFF2d1f0e);
  static const Color caveMidBg = Color(0xFF3a2515);
  static const Color caveWallDark = Color(0xFF1e1409);
  static const Color caveWallMid = Color(0xFF2a1c10);
  static const Color platformColor = Color(0xFF5C4033);
  static const Color platformBorder = Color(0xFF3B2A1A);
  static const Color platformTop = Color(0xFF7A6050);
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
  static const Color ceilingSpike = Color(0xFF3a2515);
}
