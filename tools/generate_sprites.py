#!/usr/bin/env python3
"""
Sprite generator for Latch Legend — creates all game sprites as pixel art PNGs.
Uses PIL/Pillow. All art is chunky 8-bit style, no anti-aliasing.
"""

import os
import random
from PIL import Image, ImageDraw

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'sprites')
os.makedirs(OUTPUT_DIR, exist_ok=True)

random.seed(42)  # reproducible sprites


def put(img, x, y, color):
    """Set a single pixel, bounds-checked."""
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), color)


def fill_rect(img, x0, y0, w, h, color):
    """Fill a solid rectangle of pixels."""
    for yy in range(y0, y0 + h):
        for xx in range(x0, x0 + w):
            put(img, xx, yy, color)


def draw_line(img, x0, y0, x1, y1, color):
    """Bresenham line drawing."""
    dx = abs(x1 - x0)
    dy = abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx - dy
    while True:
        put(img, x0, y0, color)
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy


# ─────────────────────────────────────────────────────────
# Color palette
# ─────────────────────────────────────────────────────────
CAVE_BASE      = (58, 42, 26, 255)     # #3a2a1a
CAVE_LIGHT     = (74, 53, 32, 255)     # #4a3520
CAVE_DARK      = (46, 31, 18, 255)     # #2e1f12
CAVE_MORTAR    = (30, 20, 10, 255)
CAVE_GRIT_A    = (36, 26, 14, 255)
CAVE_GRIT_B    = (52, 38, 22, 255)
FLOOR_LIT      = (122, 96, 80, 255)    # #7a6050
FLOOR_MID      = (90, 70, 50, 255)

GOLD           = (255, 215, 0, 255)    # #FFD700
GOLD_HI        = (255, 248, 220, 255)  # #FFF8DC
GOLD_DARK      = (204, 153, 0, 255)    # #CC9900
GOLD_SHADOW    = (160, 120, 0, 255)

DOOR_TAN       = (221, 204, 170, 255)  # #DDCCAA
DOOR_GLOW      = (255, 255, 240, 255)
DOOR_BORDER    = (60, 40, 20, 255)
DOOR_INNER     = (255, 255, 255, 255)

HAT            = (139, 105, 20, 255)   # #8B6914
HAT_DARK       = (110, 80, 10, 255)
SKIN           = (255, 204, 160, 255)  # #FFCCA0
SKIN_DARK      = (220, 170, 130, 255)
EYE            = (0, 0, 0, 255)
SHIRT          = (68, 136, 204, 255)   # #4488CC
SHIRT_DARK     = (50, 110, 170, 255)
PANTS          = (92, 64, 51, 255)     # #5C4033
PANTS_DARK     = (70, 48, 35, 255)
BOOT           = (80, 55, 30, 255)
BOOT_DARK      = (55, 38, 20, 255)

HOOK_GRAY      = (153, 153, 153, 255)  # #999999
HOOK_DARK      = (120, 120, 120, 255)
ROPE_TAN       = (180, 150, 100, 255)

GHOST_BODY     = (26, 5, 5, 255)       # #1a0505
GHOST_BODY2    = (40, 10, 10, 255)
GHOST_EYE_W    = (255, 255, 255, 255)
GHOST_IRIS     = (255, 0, 0, 255)
GHOST_PUPIL    = (0, 0, 0, 255)
GHOST_MOUTH    = (10, 0, 0, 255)

TRANSPARENT    = (0, 0, 0, 0)


# ═════════════════════════════════════════════════════════
# 1. cave_tile.png  (32×32)
# ═════════════════════════════════════════════════════════
def generate_cave_tile():
    img = Image.new('RGBA', (32, 32), CAVE_BASE)

    # Stone blocks — irregular rectangles with mortar gaps
    blocks = [
        (1, 1, 14, 9),
        (16, 1, 15, 9),
        (1, 11, 10, 9),
        (12, 11, 19, 9),
        (1, 21, 16, 10),
        (18, 21, 13, 10),
    ]
    for bx, by, bw, bh in blocks:
        fill_rect(img, bx, by, bw, bh, CAVE_LIGHT)
        # inner slightly lighter highlight (top-left 2px)
        for i in range(min(2, bw)):
            for j in range(min(bh, 2)):
                c = (82, 60, 38, 255)
                put(img, bx + i, by + j, c)

    # Mortar lines (horizontal)
    for y in [0, 10, 20]:
        fill_rect(img, 0, y, 32, 1, CAVE_MORTAR)
    # Mortar lines (vertical, offset per row)
    mortar_v = [(15, 0, 10), (11, 10, 10), (17, 20, 12)]
    for mx, my, mh in mortar_v:
        fill_rect(img, mx, my, 1, mh, CAVE_MORTAR)

    # Grit / noise
    for _ in range(40):
        gx = random.randint(0, 31)
        gy = random.randint(0, 31)
        put(img, gx, gy, random.choice([CAVE_GRIT_A, CAVE_GRIT_B, CAVE_DARK]))

    img.save(os.path.join(OUTPUT_DIR, 'cave_tile.png'))
    print('  ✔ cave_tile.png')
    return img


# ═════════════════════════════════════════════════════════
# 2. cave_tile_top.png  (32×32)
# ═════════════════════════════════════════════════════════
def generate_cave_tile_top():
    img = Image.new('RGBA', (32, 32), CAVE_BASE)

    # Stone blocks (same as cave_tile upper portion)
    blocks = [
        (1, 1, 14, 9),
        (16, 1, 15, 9),
        (1, 11, 10, 9),
        (12, 11, 19, 9),
    ]
    for bx, by, bw, bh in blocks:
        fill_rect(img, bx, by, bw, bh, CAVE_LIGHT)
        for i in range(min(2, bw)):
            for j in range(min(bh, 2)):
                put(img, bx + i, by + j, (82, 60, 38, 255))

    # Mortar
    fill_rect(img, 0, 0, 32, 1, CAVE_MORTAR)
    fill_rect(img, 0, 10, 32, 1, CAVE_MORTAR)
    fill_rect(img, 0, 20, 32, 1, CAVE_MORTAR)
    fill_rect(img, 15, 0, 1, 10, CAVE_MORTAR)
    fill_rect(img, 11, 10, 1, 10, CAVE_MORTAR)

    # Bottom 6 rows — lighter edge
    lighter_edge = (90, 70, 50, 255)
    fill_rect(img, 0, 26, 32, 6, lighter_edge)

    # Stalactite triangles hanging from bottom edge
    stalactites = [(6, 3), (16, 4), (26, 3)]
    for sx, sh in stalactites:
        for row in range(sh):
            hw = sh - row  # gets narrower
            for dx in range(-hw, hw + 1):
                put(img, sx + dx, 26 + row, CAVE_DARK)
        # tip pixel
        put(img, sx, 26 + sh, (40, 28, 16, 255))

    # Grit
    for _ in range(30):
        gx = random.randint(0, 31)
        gy = random.randint(0, 25)
        put(img, gx, gy, random.choice([CAVE_GRIT_A, CAVE_GRIT_B]))

    img.save(os.path.join(OUTPUT_DIR, 'cave_tile_top.png'))
    print('  ✔ cave_tile_top.png')


# ═════════════════════════════════════════════════════════
# 3. cave_tile_floor.png  (32×32)
# ═════════════════════════════════════════════════════════
def generate_cave_tile_floor():
    img = Image.new('RGBA', (32, 32), CAVE_BASE)

    # Top 4 rows — lighter lit surface
    fill_rect(img, 0, 0, 32, 2, FLOOR_LIT)
    fill_rect(img, 0, 2, 32, 2, FLOOR_MID)

    # Stone blocks below the lit edge
    blocks = [
        (1, 5, 14, 8),
        (16, 5, 15, 8),
        (1, 14, 10, 8),
        (12, 14, 19, 8),
        (1, 23, 16, 8),
        (18, 23, 13, 8),
    ]
    for bx, by, bw, bh in blocks:
        fill_rect(img, bx, by, bw, bh, CAVE_LIGHT)
        for i in range(min(2, bw)):
            for j in range(min(bh, 2)):
                put(img, bx + i, by + j, (82, 60, 38, 255))

    # Mortar
    fill_rect(img, 0, 4, 32, 1, CAVE_MORTAR)
    fill_rect(img, 0, 13, 32, 1, CAVE_MORTAR)
    fill_rect(img, 0, 22, 32, 1, CAVE_MORTAR)
    fill_rect(img, 15, 4, 1, 9, CAVE_MORTAR)
    fill_rect(img, 11, 13, 1, 9, CAVE_MORTAR)
    fill_rect(img, 17, 22, 1, 10, CAVE_MORTAR)

    # Grit
    for _ in range(35):
        gx = random.randint(0, 31)
        gy = random.randint(4, 31)
        put(img, gx, gy, random.choice([CAVE_GRIT_A, CAVE_GRIT_B, CAVE_DARK]))

    img.save(os.path.join(OUTPUT_DIR, 'cave_tile_floor.png'))
    print('  ✔ cave_tile_floor.png')


# ═════════════════════════════════════════════════════════
# 4. coin.png  (16×16)
# ═════════════════════════════════════════════════════════
def generate_coin():
    img = Image.new('RGBA', (16, 16), TRANSPARENT)

    # Circle (filled)  — center (7,7) radius ~6
    cx, cy, r = 7, 7, 6
    for y in range(16):
        for x in range(16):
            dx, dy = x - cx, y - cy
            dist = (dx * dx + dy * dy) ** 0.5
            if dist <= r:
                # gradient: upper-left lighter, lower-right darker
                if dx + dy < -3:
                    put(img, x, y, GOLD_HI)
                elif dx + dy > 4:
                    put(img, x, y, GOLD_DARK)
                else:
                    put(img, x, y, GOLD)

    # Outer edge pixels — darken
    for y in range(16):
        for x in range(16):
            dx, dy = x - cx, y - cy
            dist = (dx * dx + dy * dy) ** 0.5
            if r - 1 < dist <= r:
                put(img, x, y, GOLD_DARK)

    # Dollar sign in center (small)
    # Vertical bar
    for dy in range(-3, 4):
        put(img, 7, 7 + dy, GOLD_SHADOW)
    # Top curve
    put(img, 6, 5, GOLD_SHADOW)
    put(img, 5, 5, GOLD_SHADOW)
    put(img, 5, 6, GOLD_SHADOW)
    # Middle
    put(img, 8, 7, GOLD_SHADOW)
    put(img, 9, 7, GOLD_SHADOW)
    # Bottom curve
    put(img, 8, 9, GOLD_SHADOW)
    put(img, 9, 9, GOLD_SHADOW)
    put(img, 9, 8, GOLD_SHADOW)
    put(img, 6, 7, GOLD_SHADOW)
    put(img, 5, 7, GOLD_SHADOW)

    img.save(os.path.join(OUTPUT_DIR, 'coin.png'))
    print('  ✔ coin.png')


# ═════════════════════════════════════════════════════════
# 5. exit_door.png  (32×64)
# ═════════════════════════════════════════════════════════
def generate_exit_door():
    img = Image.new('RGBA', (32, 64), TRANSPARENT)

    # Outer dark brown border frame
    fill_rect(img, 0, 0, 32, 64, DOOR_BORDER)

    # Inner tan rectangle
    fill_rect(img, 3, 3, 26, 58, DOOR_TAN)

    # Bright inner glow (center region)
    fill_rect(img, 6, 6, 20, 52, (240, 235, 210, 255))
    fill_rect(img, 9, 10, 14, 44, DOOR_GLOW)
    fill_rect(img, 11, 15, 10, 34, DOOR_INNER)

    # Arch at top
    arch_cx, arch_cy = 16, 12
    for y in range(3, 20):
        for x in range(3, 29):
            dx = x - arch_cx
            dy = y - arch_cy
            dist = (dx * dx + dy * dy) ** 0.5
            if dist <= 12 and y < 12:
                # inside arch — glow
                if dist <= 9:
                    put(img, x, y, DOOR_INNER)
                elif dist <= 11:
                    put(img, x, y, DOOR_GLOW)
                else:
                    put(img, x, y, DOOR_TAN)

    # Decorative top trim
    fill_rect(img, 2, 0, 28, 2, (80, 60, 30, 255))

    # Decorative side columns (darker border accents)
    for y in range(2, 64):
        put(img, 3, y, (100, 75, 40, 255))
        put(img, 4, y, (110, 85, 50, 255))
        put(img, 27, y, (110, 85, 50, 255))
        put(img, 28, y, (100, 75, 40, 255))

    # Threshold at bottom
    fill_rect(img, 3, 60, 26, 4, (80, 60, 30, 255))

    # Glow rays (subtle lighter pixels radiating from center)
    for _ in range(60):
        angle_x = random.randint(-10, 10)
        angle_y = random.randint(-25, 25)
        px = 16 + angle_x
        py = 32 + angle_y
        if 6 <= px <= 25 and 8 <= py <= 56:
            put(img, px, py, (255, 255, 250, 200))

    img.save(os.path.join(OUTPUT_DIR, 'exit_door.png'))
    print('  ✔ exit_door.png')


# ═════════════════════════════════════════════════════════
# Helper: draw the explorer character at a given offset
# ═════════════════════════════════════════════════════════
def draw_player(img, ox, oy, leg_state='neutral', arm_state='normal'):
    """
    Draw the explorer character.
    ox, oy = top-left of 32×32 frame
    leg_state: 'neutral', 'right_fwd', 'left_fwd'
    arm_state: 'normal', 'up_right', 'up', 'up_left'
    """
    # Character centered roughly: ~24px wide, 28px tall
    # Start body at ox+4, oy+2
    bx = ox + 8   # body center x
    by = oy + 2   # top of hat

    # ── Hat ──
    # Brim
    fill_rect(img, bx - 6, by + 4, 13, 2, HAT)
    # Crown
    fill_rect(img, bx - 4, by, 9, 4, HAT)
    fill_rect(img, bx - 5, by + 2, 11, 2, HAT)
    # Hat band
    fill_rect(img, bx - 4, by + 3, 9, 1, HAT_DARK)

    # ── Head / face ──
    fill_rect(img, bx - 4, by + 6, 9, 6, SKIN)
    # Darker jaw line
    fill_rect(img, bx - 3, by + 11, 7, 1, SKIN_DARK)
    # Eye
    put(img, bx - 1, by + 8, EYE)
    put(img, bx, by + 8, EYE)
    # Mouth
    put(img, bx - 1, by + 10, SKIN_DARK)
    put(img, bx, by + 10, SKIN_DARK)

    # ── Body / shirt ──
    fill_rect(img, bx - 5, by + 12, 11, 8, SHIRT)
    # Shirt shading on right side
    fill_rect(img, bx + 3, by + 12, 3, 8, SHIRT_DARK)
    # Belt
    fill_rect(img, bx - 5, by + 19, 11, 1, PANTS_DARK)

    # ── Arms ──
    if arm_state == 'normal':
        # Left arm
        fill_rect(img, bx - 7, by + 12, 2, 7, SHIRT)
        fill_rect(img, bx - 7, by + 19, 2, 2, SKIN)
        # Right arm
        fill_rect(img, bx + 6, by + 12, 2, 7, SHIRT_DARK)
        fill_rect(img, bx + 6, by + 19, 2, 2, SKIN_DARK)
    elif arm_state == 'up_right':
        # Left arm normal
        fill_rect(img, bx - 7, by + 12, 2, 7, SHIRT)
        fill_rect(img, bx - 7, by + 19, 2, 2, SKIN)
        # Right arm extended up-right
        fill_rect(img, bx + 6, by + 12, 2, 3, SHIRT_DARK)
        # Arm going up-right
        for i in range(6):
            put(img, bx + 7 + i, by + 12 - i, SKIN)
            put(img, bx + 7 + i, by + 11 - i, SKIN)
    elif arm_state == 'up':
        # Left arm normal
        fill_rect(img, bx - 7, by + 12, 2, 7, SHIRT)
        fill_rect(img, bx - 7, by + 19, 2, 2, SKIN)
        # Right arm straight up
        fill_rect(img, bx + 6, by + 12, 2, 2, SHIRT_DARK)
        for i in range(8):
            put(img, bx + 6, by + 11 - i, SKIN)
            put(img, bx + 7, by + 11 - i, SKIN)
    elif arm_state == 'up_left':
        # Left arm extended up-left
        fill_rect(img, bx - 7, by + 12, 2, 3, SHIRT)
        for i in range(6):
            put(img, bx - 8 - i, by + 12 - i, SKIN)
            put(img, bx - 8 - i, by + 11 - i, SKIN)
        # Right arm normal
        fill_rect(img, bx + 6, by + 12, 2, 7, SHIRT_DARK)
        fill_rect(img, bx + 6, by + 19, 2, 2, SKIN_DARK)

    # ── Pants ──
    if leg_state == 'neutral':
        # Legs together
        fill_rect(img, bx - 4, by + 20, 4, 5, PANTS)
        fill_rect(img, bx + 1, by + 20, 4, 5, PANTS)
        # Gap between legs
        fill_rect(img, bx, by + 22, 1, 3, TRANSPARENT)
    elif leg_state == 'right_fwd':
        # Right leg forward, left leg back
        fill_rect(img, bx - 4, by + 20, 4, 4, PANTS)       # left leg (back)
        fill_rect(img, bx + 1, by + 20, 4, 5, PANTS)       # right leg (forward)
        fill_rect(img, bx + 1, by + 25, 4, 1, PANTS_DARK)  # extended
        # Left leg shorter (behind)
        fill_rect(img, bx - 5, by + 23, 4, 2, PANTS_DARK)
    elif leg_state == 'left_fwd':
        # Left leg forward, right leg back
        fill_rect(img, bx - 4, by + 20, 4, 5, PANTS)       # left leg (forward)
        fill_rect(img, bx - 4, by + 25, 4, 1, PANTS_DARK)  # extended
        fill_rect(img, bx + 1, by + 20, 4, 4, PANTS)       # right leg (back)
        fill_rect(img, bx + 2, by + 23, 4, 2, PANTS_DARK)

    # ── Boots ──
    if leg_state == 'neutral':
        fill_rect(img, bx - 5, by + 25, 5, 2, BOOT)
        fill_rect(img, bx + 1, by + 25, 5, 2, BOOT)
        # Sole
        fill_rect(img, bx - 5, by + 27, 5, 1, BOOT_DARK)
        fill_rect(img, bx + 1, by + 27, 5, 1, BOOT_DARK)
    elif leg_state == 'right_fwd':
        fill_rect(img, bx - 5, by + 24, 5, 2, BOOT)
        fill_rect(img, bx - 5, by + 26, 5, 1, BOOT_DARK)
        fill_rect(img, bx + 1, by + 26, 5, 2, BOOT)
        fill_rect(img, bx + 1, by + 28, 5, 1, BOOT_DARK)
    elif leg_state == 'left_fwd':
        fill_rect(img, bx - 5, by + 26, 5, 2, BOOT)
        fill_rect(img, bx - 5, by + 28, 5, 1, BOOT_DARK)
        fill_rect(img, bx + 1, by + 24, 5, 2, BOOT)
        fill_rect(img, bx + 1, by + 26, 5, 1, BOOT_DARK)


# ═════════════════════════════════════════════════════════
# 6. player_run.png  (128×32, 4 frames)
# ═════════════════════════════════════════════════════════
def generate_player_run():
    img = Image.new('RGBA', (128, 32), TRANSPARENT)

    # Frame 0: neutral (standing)
    draw_player(img, 0, 0, leg_state='neutral')
    # Frame 1: right leg forward
    draw_player(img, 32, 0, leg_state='right_fwd')
    # Frame 2: neutral (slight variation — same as 0)
    draw_player(img, 64, 0, leg_state='neutral')
    # Frame 3: left leg forward
    draw_player(img, 96, 0, leg_state='left_fwd')

    img.save(os.path.join(OUTPUT_DIR, 'player_run.png'))
    print('  ✔ player_run.png')


# ═════════════════════════════════════════════════════════
# 7. player_swing.png  (128×32, 4 frames)
# ═════════════════════════════════════════════════════════
def generate_player_swing():
    img = Image.new('RGBA', (128, 32), TRANSPARENT)

    # Frame 0: body angled right, arm up-right
    draw_player(img, 0, 0, leg_state='right_fwd', arm_state='up_right')
    # Frame 1: body vertical, arm straight up
    draw_player(img, 32, 0, leg_state='neutral', arm_state='up')
    # Frame 2: body angled left, arm up-left
    draw_player(img, 64, 0, leg_state='left_fwd', arm_state='up_left')
    # Frame 3: same as frame 1
    draw_player(img, 96, 0, leg_state='neutral', arm_state='up')

    img.save(os.path.join(OUTPUT_DIR, 'player_swing.png'))
    print('  ✔ player_swing.png')


# ═════════════════════════════════════════════════════════
# 8. player_hook_spin.png  (128×32, 4 frames)
# ═════════════════════════════════════════════════════════
def draw_hook(img, cx, cy):
    """Draw a small 4×4 hook shape at center (cx,cy)."""
    # Hook shape: backwards 'J'
    put(img, cx, cy - 1, HOOK_GRAY)
    put(img, cx + 1, cy - 1, HOOK_GRAY)
    put(img, cx + 1, cy, HOOK_GRAY)
    put(img, cx + 1, cy + 1, HOOK_GRAY)
    put(img, cx, cy + 1, HOOK_GRAY)
    put(img, cx - 1, cy + 1, HOOK_DARK)
    put(img, cx - 1, cy, HOOK_DARK)
    put(img, cx, cy, HOOK_GRAY)


def generate_player_hook_spin():
    img = Image.new('RGBA', (128, 32), TRANSPARENT)

    # All frames use running animation legs with normal arms
    leg_states = ['neutral', 'right_fwd', 'neutral', 'left_fwd']

    # Hand position (right hand) — approximate for each frame
    # The player's right hand is roughly at (ox+16, oy+14) when arm is normal
    # We'll use the top of the right shoulder as the rope origin
    hand_offsets = (14, 14)  # relative to frame origin

    # Hook positions (clock positions relative to hand)
    # radius of spin ~8px
    spin_r = 8
    hook_positions = [
        (spin_r, 0),       # 3 o'clock (right)
        (0, -spin_r),      # 12 o'clock (top)
        (-spin_r, 0),      # 9 o'clock (left)
        (0, spin_r),       # 6 o'clock (bottom/forward)
    ]

    for i in range(4):
        ox = i * 32
        draw_player(img, ox, 0, leg_state=leg_states[i])

        hx = ox + hand_offsets[0]
        hy = hand_offsets[1]

        hook_dx, hook_dy = hook_positions[i]
        hook_x = hx + hook_dx
        hook_y = hy + hook_dy

        # Draw rope line from hand to hook
        draw_line(img, hx, hy, hook_x, hook_y, ROPE_TAN)

        # Draw hook
        draw_hook(img, hook_x, hook_y)

    img.save(os.path.join(OUTPUT_DIR, 'player_hook_spin.png'))
    print('  ✔ player_hook_spin.png')


# ═════════════════════════════════════════════════════════
# 9. ghost.png  (64×64)
# ═════════════════════════════════════════════════════════
def generate_ghost():
    img = Image.new('RGBA', (64, 64), TRANSPARENT)

    # Main body — large irregular dark blob
    cx, cy = 32, 30
    for y in range(64):
        for x in range(64):
            dx = x - cx
            dy = y - cy
            # Oval shape: wider than tall
            dist = ((dx / 28) ** 2 + (dy / 26) ** 2) ** 0.5
            if dist <= 1.0:
                # Slight color variation
                if random.random() < 0.3:
                    put(img, x, y, GHOST_BODY2)
                else:
                    put(img, x, y, GHOST_BODY)

    # Wavy bottom edge — tentacle-like wisps
    for wx in range(8, 56):
        wisp_len = 4 + int(3 * abs((wx % 10) - 5) / 5)
        base_y = cy + int(26 * (1 - ((wx - cx) / 28) ** 2) ** 0.5) if abs(wx - cx) < 28 else cy
        for wy in range(base_y, min(base_y + wisp_len, 64)):
            if random.random() < 0.7:
                put(img, wx, wy, GHOST_BODY)

    # Large left eye — white sclera
    eye_cx, eye_cy = 22, 24
    eye_rx, eye_ry = 9, 7
    for y in range(64):
        for x in range(64):
            dx = x - eye_cx
            dy = y - eye_cy
            dist = ((dx / eye_rx) ** 2 + (dy / eye_ry) ** 2) ** 0.5
            if dist <= 1.0:
                put(img, x, y, GHOST_EYE_W)

    # Red iris
    iris_cx, iris_cy = 24, 24
    iris_r = 4
    for y in range(iris_cy - iris_r, iris_cy + iris_r + 1):
        for x in range(iris_cx - iris_r, iris_cx + iris_r + 1):
            if (x - iris_cx) ** 2 + (y - iris_cy) ** 2 <= iris_r ** 2:
                put(img, x, y, GHOST_IRIS)

    # Black pupil
    pupil_cx, pupil_cy = 25, 24
    pupil_r = 2
    for y in range(pupil_cy - pupil_r, pupil_cy + pupil_r + 1):
        for x in range(pupil_cx - pupil_r, pupil_cx + pupil_r + 1):
            if (x - pupil_cx) ** 2 + (y - pupil_cy) ** 2 <= pupil_r ** 2:
                put(img, x, y, GHOST_PUPIL)

    # Smaller right eye
    eye2_cx, eye2_cy = 40, 22
    eye2_r = 5
    for y in range(eye2_cy - eye2_r, eye2_cy + eye2_r + 1):
        for x in range(eye2_cx - eye2_r, eye2_cx + eye2_r + 1):
            if (x - eye2_cx) ** 2 + (y - eye2_cy) ** 2 <= eye2_r ** 2:
                put(img, x, y, GHOST_EYE_W)

    # Right iris
    iris2_cx, iris2_cy = 42, 22
    iris2_r = 3
    for y in range(iris2_cy - iris2_r, iris2_cy + iris2_r + 1):
        for x in range(iris2_cx - iris2_r, iris2_cx + iris2_r + 1):
            if (x - iris2_cx) ** 2 + (y - iris2_cy) ** 2 <= iris2_r ** 2:
                put(img, x, y, GHOST_IRIS)

    # Right pupil
    p2_cx, p2_cy = 43, 22
    p2_r = 1
    for dy in range(-p2_r, p2_r + 1):
        for dx in range(-p2_r, p2_r + 1):
            if dx * dx + dy * dy <= p2_r * p2_r:
                put(img, p2_cx + dx, p2_cy + dy, GHOST_PUPIL)

    # Mouth — dark gaping hole
    mouth_cx, mouth_cy = 30, 38
    for y in range(34, 46):
        for x in range(20, 42):
            dx = x - mouth_cx
            dy = y - mouth_cy
            dist = ((dx / 10) ** 2 + (dy / 5) ** 2) ** 0.5
            if dist <= 1.0:
                put(img, x, y, GHOST_MOUTH)
            elif dist <= 1.15:
                put(img, x, y, (60, 0, 0, 255))  # reddish edge

    # Jagged teeth on top of mouth
    teeth_y = 35
    for tx in range(22, 40, 4):
        put(img, tx, teeth_y, GHOST_EYE_W)
        put(img, tx + 1, teeth_y, GHOST_EYE_W)
        put(img, tx, teeth_y + 1, GHOST_EYE_W)

    # Menacing eyebrow ridges
    for x in range(15, 30):
        slope = (x - 15) // 5
        put(img, x, 17 - slope, GHOST_BODY)
        put(img, x, 16 - slope, GHOST_BODY)

    for x in range(36, 47):
        slope = (47 - x) // 4
        put(img, x, 16 - slope, GHOST_BODY)
        put(img, x, 15 - slope, GHOST_BODY)

    # Dark aura / edge fuzz
    for _ in range(80):
        angle = random.random() * 6.28
        r = random.randint(24, 30)
        ax = int(cx + r * 0.9 * __import__('math').cos(angle))
        ay = int(cy + r * 0.85 * __import__('math').sin(angle))
        if 0 <= ax < 64 and 0 <= ay < 64:
            put(img, ax, ay, (20, 2, 2, 180))

    img.save(os.path.join(OUTPUT_DIR, 'ghost.png'))
    print('  ✔ ghost.png')


# ═════════════════════════════════════════════════════════
# Main
# ═════════════════════════════════════════════════════════
def main():
    print(f'Generating sprites in: {os.path.abspath(OUTPUT_DIR)}')
    print()
    generate_cave_tile()
    generate_cave_tile_top()
    generate_cave_tile_floor()
    generate_coin()
    generate_exit_door()
    generate_player_run()
    generate_player_swing()
    generate_player_hook_spin()
    generate_ghost()
    print()
    print('Done! All sprites generated.')


if __name__ == '__main__':
    main()
