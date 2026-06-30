#!/usr/bin/env bash
# generate-rio-bg.sh — create a Catppuccin Mocha rounded rectangle PNG
# with proper RGBA alpha channel. Run from WSL.
#
# IMPORTANT: the PNG must be RGBA. A solid sRGB PNG without alpha
# drawn as Rio's background-image will HIDE the terminal text,
# because Rio paints the image ON TOP of the text in some
# configurations. Use Pillow for proper RGBA control.
#
# Output: /home/wesley/nix-config/dotfiles/rio-bg.png
#         1280x820, 32px corner radius, RGBA

set -euo pipefail

OUT="/home/wesley/nix-config/dotfiles/rio-bg.png"

# Run Pillow in a nix-shell so PIL is available.
PATH=/etc/profiles/per-user/wesley/bin:$PATH \
    nix-shell -p python3Packages.pillow --run "python3 $REPO_DIR/dotfiles/config/rio/generate-rio-bg.py" \
    || true

echo ""
echo "Verify alpha:"
PATH=/etc/profiles/per-user/wesley/bin:$PATH magick identify -format '  channels=%[channels]\n' "$OUT"
PATH=/etc/profiles/per-user/wesley/bin:$PATH magick "$OUT" -crop 1x1+0+0 txt: | tail -1
echo ""
echo "In Rio config:"
echo "  background-image = 'C:\\\\Users\\\\parac\\\\nix-config\\\\dotfiles\\\\rio-bg.png'"
echo "  background-image-opacity = 0.95"
echo "  background-image-fit = \"Cover\""