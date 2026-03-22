import 'package:flutter/material.dart';

/// On-screen touch controls.
/// Top half: HOLD to grapple (tap position aims hook), RELEASE to drop.
/// Bottom: left arrow (left), pause (center), right arrow (right).
class TouchControlsOverlay extends StatelessWidget {
  final VoidCallback onLeftDown;
  final VoidCallback onLeftUp;
  final VoidCallback onRightDown;
  final VoidCallback onRightUp;
  final void Function(Offset screenPos) onGrappleStart;
  final VoidCallback onGrappleRelease;
  final VoidCallback onPause;

  const TouchControlsOverlay({
    super.key,
    required this.onLeftDown,
    required this.onLeftUp,
    required this.onRightDown,
    required this.onRightUp,
    required this.onGrappleStart,
    required this.onGrappleRelease,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: [
          // Top area: HOLD to grapple, RELEASE to drop — full width
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 100,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) => onGrappleStart(details.globalPosition),
              onTapUp: (_) => onGrappleRelease(),
              onTapCancel: () => onGrappleRelease(),
            ),
          ),

          // Left arrow — bottom-left
          Positioned(
            bottom: 40,
            left: 50,
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

          // Pause button — bottom-center
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onPause,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x44FFFFFF), width: 1),
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: Color(0x88FFFFFF),
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          // Right arrow — bottom-right
          Positioned(
            bottom: 40,
            right: 50,
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
        ],
      ),
    );
  }
}
