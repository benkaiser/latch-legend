import 'dart:ui';

class GameConstants {
  // World — tile grid
  static const double tileSize = 32.0;
  static const double gravity = 980.0;
  static const double cameraZoom = 1.5;  // zoom in for cozy mobile feel

  // Grid dimensions (tiles)
  static const int gridHeight = 18; // 18 tiles tall = 576px viewable area

  // Player
  static const double playerWidth = 24.0;
  static const double playerHeight = 28.0;
  static const double playerRunSpeed = 200.0;
  static const double playerMaxSpeed = 450.0;       // max horizontal speed (with momentum)
  static const double playerJumpForce = -420.0;
  static const double playerMaxFallSpeed = 600.0;
  static const double playerMomentumDecay = 80.0;    // px/s² decay back toward run speed
  static const double groundFriction = 300.0;         // px/s² deceleration on ground with no input

  // Hook / Grapple
  static const double hookRange = 220.0;
  static const double hookShootSpeed = 900.0;
  static const double hookWhiffDuration = 0.3;
  static const double ropeReelSpeed = 80.0;
  static const double ropeMinLength = 20.0;
  static const double swingBoostMultiplier = 1.05;
  static const double swingForwardBias = 300.0;

  // Wall of Death
  static const double wallOfDeathStartSpeed = 60.0;
  static const double wallOfDeathAcceleration = 2.0;
  static const double wallOfDeathMaxSpeed = 250.0;
  static const double wallOfDeathStartDelay = 3.0;

  // Coins
  static const double coinSize = 10.0;
  static const double coinCollectRadius = 20.0;
  static const double coinBobAmplitude = 3.0;
  static const double coinBobSpeed = 3.0;

  // Speed trail
  static const double speedTrailThreshold = 250.0;  // min speed to show trail
  static const double speedTrailInterval = 0.03;     // seconds between trail particles

  // Camera — tighter look-ahead for zoomed view, offset down so player is lower on screen
  static const double cameraLookAheadX = 120.0;
  static const double cameraLookAheadY = 0.0;
  static const double cameraSmoothSpeed = 6.0;

  // Colors — DARK cave theme
  // Background: near-black
  static const Color caveBackground = Color(0xFF050404);
  static const Color caveBgMid = Color(0xFF0a0806);
  // Parallax rock streaks: very dark gray
  static const Color caveWallDark = Color(0xFF0f0c0a);
  static const Color caveWallMid = Color(0xFF161210);
  // Tiles: dark brown, much darker than before
  static const Color tileColor = Color(0xFF2a1c12);
  static const Color tileBorder = Color(0xFF1a1008);
  static const Color tileHighlight = Color(0xFF3a2818);
  // Edge highlights: reddish-brown "crust" at ceiling
  static const Color tileFloorTop = Color(0xFF4a3828);
  static const Color tileCeilBottom = Color(0xFF5a3020);  // reddish-brown crust
  // Hook/rope: thin white
  static const Color grappleColor = Color(0xFFCCCCCC);
  static const Color grappleActiveColor = Color(0xFFFFD700);
  static const Color ropeColor = Color(0xFFDDDDDD);       // near-white, thin
  // Coins: bright gold that pops against dark background
  static const Color coinColor = Color(0xFFFFD700);
  static const Color coinHighlight = Color(0xFFFFF8DC);
  // Player
  static const Color playerShirt = Color(0xFF4488CC);
  static const Color playerPants = Color(0xFF5C4033);
  static const Color playerSkin = Color(0xFFFFCCA0);
  static const Color playerHat = Color(0xFF8B6914);
  // Wall of death
  static const Color wallOfDeathColor = Color(0xFF220000);
  static const Color wallOfDeathEye = Color(0xFFFF0000);
  // Exit
  static const Color exitColor = Color(0xFFDDCCAA);
}
