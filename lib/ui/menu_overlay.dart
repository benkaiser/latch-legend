import 'package:flutter/material.dart';

class MenuOverlay extends StatelessWidget {
  final VoidCallback onPlay;
  final void Function(int level) onSelectLevel;
  final int unlockedLevels;

  const MenuOverlay({
    super.key,
    required this.onPlay,
    required this.onSelectLevel,
    this.unlockedLevels = 5,
  });

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
            // Level select buttons
            const Text(
              'SELECT LEVEL',
              style: TextStyle(
                color: Color(0x99FFFFFF),
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final unlocked = i < unlockedLevels;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: unlocked ? () => onSelectLevel(i) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: unlocked
                            ? const Color(0xFF4488CC)
                            : const Color(0xFF333333),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      child: Text('${i + 1}'),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text(
              'Space / Tap to hook & release',
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
