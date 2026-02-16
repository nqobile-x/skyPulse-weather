"""Generate SkyPulse Weather app icon programmatically using Pillow."""
from PIL import Image, ImageDraw, ImageFont
import math

SIZE = 1024
CORNER_RADIUS = 180

def create_rounded_mask(size: int, radius: int) -> Image.Image:
    """Create a rounded rectangle mask."""
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle(
        [(0, 0), (size - 1, size - 1)],
        radius=radius,
        fill=255,
    )
    return mask


def lerp_color(c1: tuple, c2: tuple, t: float) -> tuple:
    """Linearly interpolate between two RGB colors."""
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def draw_gradient(img: Image.Image, c_top: tuple, c_mid: tuple, c_bot: tuple):
    """Draw a vertical 3-stop gradient."""
    draw = ImageDraw.Draw(img)
    h = img.height
    mid = h // 2
    for y in range(h):
        if y < mid:
            t = y / mid
            color = lerp_color(c_top, c_mid, t)
        else:
            t = (y - mid) / (h - mid)
            color = lerp_color(c_mid, c_bot, t)
        draw.line([(0, y), (img.width, y)], fill=color)


def draw_sun(draw: ImageDraw.Draw, cx: int, cy: int, r: int):
    """Draw a golden sun with glow effect."""
    # Outer glow rings
    for i in range(40, 0, -1):
        alpha_factor = i / 40
        glow_r = r + i * 3
        glow_color = (
            int(255 * 0.95),
            int(200 * 0.85 + 55 * (1 - alpha_factor)),
            int(50 + 80 * (1 - alpha_factor)),
        )
        draw.ellipse(
            [cx - glow_r, cy - glow_r, cx + glow_r, cy + glow_r],
            fill=glow_color,
        )
    # Core sun
    draw.ellipse(
        [cx - r, cy - r, cx + r, cy + r],
        fill=(255, 210, 60),
    )
    # Inner highlight
    hr = int(r * 0.7)
    draw.ellipse(
        [cx - hr, cy - hr + 5, cx + hr, cy + hr + 5],
        fill=(255, 225, 100),
    )


def draw_cloud(draw: ImageDraw.Draw, cx: int, cy: int, scale: float = 1.0, color=(255, 255, 255)):
    """Draw a stylized cloud shape using overlapping ellipses."""
    s = scale
    parts = [
        # (offset_x, offset_y, rx, ry) — relative to center
        (0, 0, int(130 * s), int(80 * s)),          # main body
        (-90 * s, 10 * s, int(90 * s), int(70 * s)), # left lobe
        (90 * s, 10 * s, int(90 * s), int(65 * s)),  # right lobe
        (-30 * s, -40 * s, int(85 * s), int(65 * s)),# top-left bump
        (50 * s, -35 * s, int(75 * s), int(60 * s)), # top-right bump
        (-130 * s, 25 * s, int(60 * s), int(50 * s)),# far-left
        (130 * s, 25 * s, int(55 * s), int(45 * s)), # far-right
        (0, 30 * s, int(150 * s), int(50 * s)),      # flat bottom
    ]
    for ox, oy, rx, ry in parts:
        x = int(cx + ox)
        y = int(cy + oy)
        draw.ellipse([x - rx, y - ry, x + rx, y + ry], fill=color)


def draw_pulse_wave(draw: ImageDraw.Draw, y_center: int, width: int, amplitude: int):
    """Draw the 'pulse' wave line at the bottom."""
    points = []
    margin = 180
    for x in range(margin, width - margin):
        t = (x - margin) / (width - 2 * margin)
        # Create a smooth wave with varying amplitude
        wave = math.sin(t * math.pi * 3.5) * amplitude
        # Fade at edges
        fade = math.sin(t * math.pi)
        y = y_center + int(wave * fade)
        points.append((x, y))

    # Draw thick wave
    for i in range(len(points) - 1):
        draw.line([points[i], points[i + 1]], fill=(255, 255, 255, 220), width=12)
    # Draw thinner bright core
    for i in range(len(points) - 1):
        draw.line([points[i], points[i + 1]], fill=(220, 240, 255), width=6)


def main():
    # Create base image with gradient
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    bg = Image.new("RGB", (SIZE, SIZE))

    # Gradient: deep blue top -> vibrant blue middle -> lighter blue bottom
    draw_gradient(bg, (40, 80, 180), (55, 140, 220), (85, 175, 240))

    # Convert to RGBA and apply rounded mask
    bg_rgba = bg.convert("RGBA")
    mask = create_rounded_mask(SIZE, CORNER_RADIUS)
    img.paste(bg_rgba, (0, 0), mask)

    draw = ImageDraw.Draw(img)

    # Draw sun (upper-right area, partially behind cloud)
    sun_x, sun_y = 560, 290
    draw_sun(draw, sun_x, sun_y, 130)

    # Draw main cloud (center, overlapping the sun)
    draw_cloud(draw, 480, 400, scale=1.5, color=(255, 255, 255))

    # Subtle shadow cloud behind
    draw_cloud(draw, 490, 415, scale=1.45, color=(200, 220, 240))
    # Main white cloud on top
    draw_cloud(draw, 480, 400, scale=1.5, color=(255, 255, 255))

    # Draw pulse wave at the bottom
    draw_pulse_wave(draw, 720, SIZE, 55)

    # Apply rounded corners mask to final image
    final = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    final.paste(img, (0, 0), mask)

    # Save
    output_path = "assets/icon/app_icon.png"
    import os
    os.makedirs("assets/icon", exist_ok=True)
    final.save(output_path, "PNG")
    print(f"Icon saved to {output_path}")


if __name__ == "__main__":
    main()
