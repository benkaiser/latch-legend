# Latch Legend

A fast-paced grapple-and-swing cave platformer built with Flutter and the Flame engine. Inspired by classic hook-based action games.

## Gameplay

Swing through treacherous underground caves using your grappling hook. Time your swings, dodge spike pits, and race to the exit before the wall of death catches you.

**Controls:**
- **Touch (mobile):** Tap and hold the top of the screen to fire your hook — tap position aims it. Release to detach and launch. Left/right arrows to walk on ground.
- **Keyboard:** Hold Space or Up to grapple, release to detach. Left/Right arrows to walk.

**Mechanics:**
- Hold to grapple, release to swing-jump — timing your release is key
- Rope wraps around corners for physically plausible swing arcs
- Spikes are instant death — don't fall in the pits
- Coins are scattered throughout — grab them for bonus points
- The wall of death chases you from behind — keep moving!

## Levels

5 handcrafted cave levels with progressive difficulty:

1. **Cave Escape** — Learn the basics with forgiving spike pits
2. **The Deep Descent** — Multi-layer caves with wider hazards
3. **Crystal Caverns** — Two-layer descent with tight pillar spacing
4. **The Gauntlet** — Three layers, ceiling gaps force momentum carries
5. **The Final Chamber** — Four-layer epic with spike floors everywhere

## Building

```bash
# Run in debug mode
flutter run

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Build for macOS
flutter build macos
```

## Tech Stack

- **Flutter** — Cross-platform UI framework
- **Flame** — 2D game engine for Flutter
- **Dart** — Programming language

## License

MIT
