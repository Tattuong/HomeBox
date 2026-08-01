"""Generate Google Play listing screenshots for Reflectly."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT_DIR = Path(__file__).resolve().parents[1] / "store_assets"
W, H = 1080, 1920
BLUE = (37, 99, 235)
WHITE = (255, 255, 255)


def header(draw: ImageDraw.ImageDraw, title: str, subtitle: str) -> None:
    draw.rectangle((0, 0, W, 320), fill=BLUE)
    draw.text((60, 100), title, fill=WHITE, font=ImageFont.load_default(size=64))
    draw.text((60, 190), subtitle, fill=(200, 220, 255), font=ImageFont.load_default(size=36))


def make_screen(name: str, subtitle: str) -> None:
    img = Image.new("RGB", (W, H), (248, 250, 252))
    draw = ImageDraw.Draw(img)
    header(draw, "Reflectly", subtitle)
    draw.rounded_rectangle((60, 380, W - 60, H - 120), radius=40, fill=WHITE, outline=(226, 232, 240), width=3)
    draw.text((100, 440), name, fill=(15, 23, 42), font=ImageFont.load_default(size=48))
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    img.save(OUT_DIR / f"{name.lower().replace(' ', '_')}.png")


def main() -> None:
    make_screen("Journal", "Nhìn lại bản thân mỗi ngày")
    make_screen("Shop", "Earn stars & customize")
    make_screen("Mood", "Track how you feel")
    print(f"Saved screenshots to {OUT_DIR}")


if __name__ == "__main__":
    main()
