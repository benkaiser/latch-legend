import 'package:flutter/material.dart';

/// On-screen touch controls for mobile/tablet.
/// Left/Right arrows in bottom-left, jump+grapple bottom-right,
/// pause button top-right, top area tappable for jump+grapple.
class TouchControlsOverlay extends StatelessWidget {
  final VoidCallback onLeftDown;
  final VoidCallback onLeftUp;
  final VoidCallback onRightDown;
  final VoidCallback onRightUp;
  final VoidCallback onJumpGrapple;
  final VoidCallback onPause;

  const TouchControlsOverlay({
    super.key,
    required this.onLeftDown,
    required this.onLeftUp,
    required this.onRightDown,
    required this.onRightUp,
    required this.onJumpGrapple,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: [
          // Top half: tap for jump+grapple
          Positioned(
            top: 0,
            left: 80,
            right: 80,
            height: MediaQuery.of(context).size.height * 0.5,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) => onJumpGrapple(),
            ),
          ),

          // Pause button — top-right
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onPause,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pause,
                  color: Color(0x88FFFFFF),
                  size: 22,
                ),
              ),
            ),
          ),

          // Left arrow button — bottom-left
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTapDown: (_) => onLeftDown(),
              onTapUp: (_) => onLeftUp(),
              onTapCancel: () => onLeftUp(),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0x44FFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x66FFFFFF), width: 2),
                ),
                child: const Icon(
                  Icons.arrow_left,
                  color: Color(0xAAFFFFFF),
                  size: 40,
                ),
              ),
            ),
          ),

          // Right arrow button
          Positioned(
            bottom: 20,
            left: 100,
            child: GestureDetector(
              onTapDown: (_) => onRightDown(),
              onTapUp: (_) => onRightUp(),
              onTapCancel: () => onRightUp(),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0x44FFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x66FFFFFF), width: 2),
                ),
                child: const Icon(
                  Icons.arrow_right,
                  color: Color(0xAAFFFFFF),
                  size: 40,
                ),
              ),
            ),
          ),

          // Jump/Grapple button — bottom-right
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTapDown: (_) => onJumpGrapple(),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0x44FFD700),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: const Color(0x66FFD700), width: 2),
                ),
                child: const Icon(
                  Icons.north,
                  color: Color(0xAAFFD700),
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
