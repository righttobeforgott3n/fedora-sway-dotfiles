#!/bin/bash

# Swaylock Wallpaper Setup Script
# Creates a minimalist Catppuccin Frappe wallpaper for swaylock

set -e

SWAYLOCK_DIR="$HOME/.config/swaylock"
WALLPAPER_PATH="$SWAYLOCK_DIR/wallpaper.png"

echo "Setting up swaylock wallpaper..."

# Create swaylock directory if it doesn't exist
mkdir -p "$SWAYLOCK_DIR"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is required to create the wallpaper."
    echo "Install it with: sudo dnf install -y ImageMagick"
    exit 1
fi

# Create a simple minimalist Catppuccin Frappe wallpaper (1920x1080)
# Base color: #303446
convert -size 1920x1080 xc:'#303446' "$WALLPAPER_PATH"

echo "✓ Wallpaper created at: $WALLPAPER_PATH"
echo "✓ Swaylock is configured in: $SWAYLOCK_DIR/config"
echo ""
echo "Configuration:"
echo "  - Color scheme: Catppuccin Frappe"
echo "  - Font: FiraCode Nerd Font"
echo "  - Lock triggered by: \$mod+l or after 5 minutes of inactivity"
