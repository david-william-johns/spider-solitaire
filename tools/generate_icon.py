"""
Generate a 1024x1024 Spider Solitaire app icon as a PNG.
Uses only Python stdlib + the built-in zlib (for PNG encoding).
Green felt background, white card outline, black spade symbol.
"""
import struct
import zlib
import os
import math

SIZE = 1024
OUTPUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'icon.png')


def rgba(r, g, b, a=255):
    return (r, g, b, a)


def make_canvas(size, color=(0, 0, 0, 0)):
    return [[color] * size for _ in range(size)]


def blend(dst, src):
    """Alpha composite src over dst."""
    sa = src[3] / 255.0
    da = dst[3] / 255.0
    out_a = sa + da * (1 - sa)
    if out_a == 0:
        return (0, 0, 0, 0)
    r = int((src[0] * sa + dst[0] * da * (1 - sa)) / out_a)
    g = int((src[1] * sa + dst[1] * da * (1 - sa)) / out_a)
    b = int((src[2] * sa + dst[2] * da * (1 - sa)) / out_a)
    return (r, g, b, int(out_a * 255))


def fill_rect(canvas, x0, y0, x1, y1, color):
    for y in range(max(0, y0), min(SIZE, y1)):
        for x in range(max(0, x0), min(SIZE, x1)):
            canvas[y][x] = blend(canvas[y][x], color)


def fill_circle(canvas, cx, cy, r, color):
    for y in range(max(0, cy - r - 1), min(SIZE, cy + r + 2)):
        for x in range(max(0, cx - r - 1), min(SIZE, cx + r + 2)):
            dist = math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
            if dist <= r:
                canvas[y][x] = blend(canvas[y][x], color)
            elif dist <= r + 1:
                # Anti-alias
                alpha = int((r + 1 - dist) * color[3])
                canvas[y][x] = blend(canvas[y][x], (color[0], color[1], color[2], alpha))


def rounded_rect(canvas, x0, y0, x1, y1, radius, color):
    """Filled rounded rectangle."""
    # Fill main body
    fill_rect(canvas, x0 + radius, y0, x1 - radius, y1, color)
    fill_rect(canvas, x0, y0 + radius, x1, y1 - radius, color)
    # Corners
    fill_circle(canvas, x0 + radius, y0 + radius, radius, color)
    fill_circle(canvas, x1 - radius, y0 + radius, radius, color)
    fill_circle(canvas, x0 + radius, y1 - radius, radius, color)
    fill_circle(canvas, x1 - radius, y1 - radius, radius, color)


def draw_card(canvas, x0, y0, x1, y1, bg_color, border_color, border_w=6):
    """Draw a card shape with border."""
    r = 60
    rounded_rect(canvas, x0, y0, x1, y1, r, border_color)
    rounded_rect(canvas, x0 + border_w, y0 + border_w,
                 x1 - border_w, y1 - border_w, r - border_w, bg_color)


def fill_polygon(canvas, points, color):
    """Scanline fill for a polygon defined by (x,y) float points."""
    if len(points) < 3:
        return
    min_y = max(0, int(min(p[1] for p in points)))
    max_y = min(SIZE - 1, int(max(p[1] for p in points)) + 1)
    n = len(points)
    for y in range(min_y, max_y + 1):
        intersections = []
        for i in range(n):
            x0, y0 = points[i]
            x1, y1 = points[(i + 1) % n]
            if (y0 <= y < y1) or (y1 <= y < y0):
                if y1 != y0:
                    xi = x0 + (x1 - x0) * (y - y0) / (y1 - y0)
                    intersections.append(xi)
        intersections.sort()
        for i in range(0, len(intersections) - 1, 2):
            xa = max(0, int(intersections[i]))
            xb = min(SIZE - 1, int(intersections[i + 1]) + 1)
            for x in range(xa, xb):
                canvas[y][x] = blend(canvas[y][x], color)


def draw_spade(canvas, cx, cy, size, color):
    """
    Draw a classic spade symbol.
    size = half-width of the spade head.
    """
    s = size
    # The spade head: two offset circles + inverted triangle
    # Left bulge
    fill_circle(canvas, int(cx - s * 0.3), int(cy + s * 0.1), int(s * 0.62), color)
    # Right bulge
    fill_circle(canvas, int(cx + s * 0.3), int(cy + s * 0.1), int(s * 0.62), color)
    # Top point (triangle pointing up)
    tip_x, tip_y = cx, cy - s * 1.05
    left_x, left_y = cx - s * 0.85, cy + s * 0.45
    right_x, right_y = cx + s * 0.85, cy + s * 0.45
    fill_polygon(canvas, [
        (tip_x, tip_y),
        (right_x, right_y),
        (left_x, left_y),
    ], color)
    # Stem
    stem_w = int(s * 0.22)
    stem_top = int(cy + s * 0.42)
    stem_bot = int(cy + s * 1.1)
    fill_rect(canvas, int(cx - stem_w), stem_top, int(cx + stem_w), stem_bot, color)
    # Foot spread
    foot_h = int(s * 0.22)
    foot_w = int(s * 0.62)
    fill_rect(canvas, int(cx - foot_w), stem_bot - foot_h,
              int(cx + foot_w), stem_bot + foot_h, color)


def encode_png(canvas):
    """Encode canvas as PNG bytes."""
    def pack_chunk(name, data):
        c = zlib.crc32(name + data) & 0xFFFFFFFF
        return struct.pack('>I', len(data)) + name + data + struct.pack('>I', c)

    # IHDR
    ihdr_data = struct.pack('>IIBBBBB', SIZE, SIZE, 8, 2, 0, 0, 0)  # 8-bit RGB... wait, we have RGBA
    # Use colour type 6 = RGBA
    ihdr_data = struct.pack('>II', SIZE, SIZE) + bytes([8, 6, 0, 0, 0])
    ihdr = pack_chunk(b'IHDR', ihdr_data)

    # IDAT
    raw = bytearray()
    for row in canvas:
        raw.append(0)  # filter type None
        for pixel in row:
            raw += bytes(pixel)
    idat = pack_chunk(b'IDAT', zlib.compress(bytes(raw), 9))

    iend = pack_chunk(b'IEND', b'')

    return b'\x89PNG\r\n\x1a\n' + ihdr + idat + iend


def main():
    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    canvas = make_canvas(SIZE)

    # ── Background: deep green felt with rounded corners ──────────────────────
    BG = rgba(25, 100, 50)          # rich dark green
    rounded_rect(canvas, 0, 0, SIZE, SIZE, 120, BG)

    # ── Subtle radial highlight in center ─────────────────────────────────────
    for dy in range(-200, 201):
        for dx in range(-200, 201):
            dist = math.sqrt(dx * dx + dy * dy)
            if dist < 200:
                x = SIZE // 2 + dx
                y = SIZE // 2 + dy
                if 0 <= x < SIZE and 0 <= y < SIZE:
                    alpha = int(18 * (1 - dist / 200))
                    canvas[y][x] = blend(canvas[y][x], rgba(255, 255, 255, alpha))

    # ── Card ──────────────────────────────────────────────────────────────────
    # Offset card slightly up-left to give visual balance with spade
    cx0, cy0, cx1, cy1 = 175, 140, 845, 880
    CARD_BG = rgba(255, 255, 255)
    CARD_BORDER = rgba(200, 210, 200)
    draw_card(canvas, cx0, cy0, cx1, cy1, CARD_BG, CARD_BORDER, border_w=8)

    # ── Spade symbol (centered on card) ───────────────────────────────────────
    spade_cx = (cx0 + cx1) // 2
    spade_cy = (cy0 + cy1) // 2 - 20
    SPADE_COLOR = rgba(20, 20, 20)
    draw_spade(canvas, spade_cx, spade_cy, 220, SPADE_COLOR)

    # ── Small rank "K" in top-left of card ───────────────────────────────────
    # (pixel-art style — optional decorative touch via simple rectangles)
    # We'll skip the pixel font and rely on the spade being bold enough.

    # ── Encode and save ───────────────────────────────────────────────────────
    png_data = encode_png(canvas)
    with open(OUTPUT, 'wb') as f:
        f.write(png_data)
    print(f"Icon written: {OUTPUT} ({len(png_data):,} bytes, {SIZE}×{SIZE} RGBA PNG)")


if __name__ == '__main__':
    main()
