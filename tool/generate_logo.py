"""Generate DayPlanner Pro app icon — navy & white, square, no rounded corners."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

SIZE = 1024
ROOT = Path(__file__).resolve().parents[1]
LOGO = ROOT / "assets" / "logo.png"

NAVY = (10, 36, 99)
NAVY_LIGHT = (30, 58, 138)
WHITE = (255, 255, 255)
ACCENT = (59, 130, 246)


def _draw_icon(draw: ImageDraw.ImageDraw, ox: int, oy: int, scale: float) -> None:
    s = scale

    body = [ox + int(180 * s), oy + int(220 * s), ox + int(844 * s), oy + int(820 * s)]
    draw.rounded_rectangle(body, radius=int(80 * s), fill=NAVY)

    header = [body[0], body[1], body[2], body[1] + int(160 * s)]
    draw.rounded_rectangle(
        [header[0], header[1], header[2], header[3] + int(40 * s)],
        radius=int(80 * s),
        fill=NAVY_LIGHT,
    )

    for cx in (ox + int(320 * s), ox + int(704 * s)):
        draw.rounded_rectangle(
            [cx - int(28 * s), oy + int(170 * s), cx + int(28 * s), oy + int(290 * s)],
            radius=int(20 * s),
            fill=NAVY_LIGHT,
        )

    cx, cy = ox + int(512 * s), oy + int(560 * s)
    r = int(130 * s)
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=ACCENT)

    pts = [
        (cx - int(55 * s), cy + int(5 * s)),
        (cx - int(10 * s), cy + int(55 * s)),
        (cx + int(70 * s), cy - int(45 * s)),
    ]
    draw.line(pts[:2], fill=WHITE, width=int(28 * s))
    draw.line(pts[1:], fill=WHITE, width=int(28 * s))

    line_y = oy + int(380 * s)
    for i, w in enumerate((420, 320, 360)):
        y = line_y + i * int(55 * s)
        draw.rounded_rectangle(
            [ox + int(260 * s), y, ox + int(260 * s) + int(w * s), y + int(22 * s)],
            radius=int(11 * s),
            fill=WHITE,
        )


def main() -> None:
    LOGO.parent.mkdir(parents=True, exist_ok=True)
    canvas = Image.new("RGB", (SIZE, SIZE), WHITE)
    draw = ImageDraw.Draw(canvas)
    _draw_icon(draw, 0, 0, 1.0)
    canvas.save(LOGO, format="PNG", optimize=True)
    print(f"Saved {LOGO} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    main()
