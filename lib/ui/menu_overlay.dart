import 'package:flutter/material.dart';

class MenuOverlay extends StatelessWidget {
  final VoidCallback onPlay;

  const MenuOverlay({super.key, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xDD1a1a2e),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LATCH LEGEND',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: Color(0xFF800080),
                    offset: Offset(3, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Swing. Survive. Escape.',
              style: TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 18,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: const Color(0xFF1a1a2e),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              child: const Text('PLAY'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Space / Tap to hook & release • Up to jump',
              style: TextStyle(
                color: Color(0x99FFFFFF),
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
