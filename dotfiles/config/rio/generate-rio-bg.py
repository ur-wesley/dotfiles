#!/usr/bin/env python3
"""Generate Rio's rounded background PNG using Pillow.

Pillow gives us proper RGBA control where ImageMagick's PNG32: prefix
is unreliable. The output is an RGBA PNG with:
  - transparent corners (rounded)
  - opaque Catppuccin Mocha fill (#1e1e2e) in the center

When this is set as Rio's `background-image`, the alpha corners let
the desktop wallpaper show through — creating the "rounded window"
illusion. Without proper alpha, an opaque PNG draws ON TOP of the
terminal text, hiding it.
"""
import sys
from pathlib import Path

# Pillow ships with Nix — try a few common import paths.
try:
    from PIL import Image, ImageDraw
except ImportError:
    sys.exit(
        "Pillow not importable. Install with `nix-shell -p python3Packages.pillow` "
        "or `pip install Pillow`."
    )

OUT = Path("/home/wesley/nix-config/dotfiles/rio-bg.png")
WIDTH, HEIGHT = 1280, 820
RADIUS = 32
BG = (30, 30, 46, 255)  # Catppuccin Mocha base, fully opaque


def main():
    img = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))  # transparent
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle(
        xy=[(0, 0), (WIDTH - 1, HEIGHT - 1)],
        radius=RADIUS,
        fill=BG,
    )
    img.save(OUT, format="PNG")
    print(f"Wrote {OUT} ({WIDTH}x{HEIGHT}, {RADIUS}px radius, RGBA)")


if __name__ == "__main__":
    main()