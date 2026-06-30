#!/bin/bash
# generate-rio-bg.sh — create a Catppuccin Mocha rounded rectangle PNG
# for use as Rio's background-image. Run once on WSL.
#
# Output: /home/wesley/nix-config/dotfiles/rio-bg.png (1280x820, 24px radius)

set -euo pipefail

OUT="/home/wesley/nix-config/dotfiles/rio-bg.png"
WIDTH=1280
HEIGHT=820
RADIUS=32
BG="#1e1e2e"  # Catppuccin Mocha base

magick -size ${WIDTH}x${HEIGHT} xc:none \
    -fill "$BG" \
    -draw "roundrectangle 0,0 $((WIDTH-1)),$((HEIGHT-1)) $RADIUS,$RADIUS" \
    "$OUT"

echo "Wrote $OUT ($WIDTH x $HEIGHT, ${RADIUS}px corner radius)"
echo "In Rio config, uncomment:"
echo "  background-image = \"$OUT\""
echo "  background-image-opacity = 1.0"
echo "  background-image-fit = \"Cover\""