import 'package:flutter/material.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final int coins;
  final double time;
  final String levelName;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;
  final VoidCallback onRetry;

  const LevelCompleteOverlay({
    super.key,
    required this.coins,
    required this.time,
    required this.levelName,
    required this.hasNextLevel,
    required this.onNextLevel,
    required this.onRetry,
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
              'LEVEL COMPLETE!',
              style: TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 42,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              levelName,
              style: const TextStyle(
                color: Color(0xFFBBBBBB),
                fontSize: 20,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Coins: $coins',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 28,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${time.toStringAsFixed(1)}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 40),
            if (hasNextLevel)
              ElevatedButton(
                onPressed: onNextLevel,
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
                child: const Text('NEXT LEVEL'),
              ),
            if (!hasNextLevel)
              Column(
                children: [
                  const Text(
                    'ALL LEVELS COMPLETE!',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onNextLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
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
                    child: const Text('BACK TO MENU'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'REPLAY LEVEL',
                style: TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
