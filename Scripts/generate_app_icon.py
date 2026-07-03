#!/usr/bin/env python3
"""Generate a 1024x1024 App Store icon for Gemstone Keep. Requires: pip install pillow"""

from pathlib import Path

try:
    from PIL import Image, ImageDraw
except ImportError:
    raise SystemExit("Install Pillow: pip install pillow")

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "GemstoneKeep" / "Assets.xcassets" / "AppIcon.appiconset" / "AppIcon.png"

size = 1024
img = Image.new("RGB", (size, size), (20, 18, 31))
d = ImageDraw.Draw(img)

cx, cy = size // 2, size // 2 + 40
pts = [(cx, cy - 220), (cx + 180, cy - 40), (cx, cy + 200), (cx - 180, cy - 40)]
d.polygon(pts, fill=(242, 72, 95))
d.polygon(
    [(cx, cy - 220), (cx + 180, cy - 40), (cx, cy + 20), (cx - 180, cy - 40)],
    fill=(255, 120, 140),
)
d.polygon(
    [(cx, cy - 220), (cx + 90, cy - 130), (cx, cy - 60), (cx - 90, cy - 130)],
    fill=(255, 200, 210),
)
d.rounded_rectangle([cx - 280, cy + 120, cx + 280, cy + 340], radius=40, fill=(55, 48, 72))
d.rounded_rectangle([cx - 200, cy + 60, cx + 200, cy + 180], radius=30, fill=(70, 62, 92))

OUT.parent.mkdir(parents=True, exist_ok=True)
img.save(OUT)
print(f"Wrote {OUT}")
