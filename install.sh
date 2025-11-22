#!/bin/bash

# Fedora Sway Dotfiles Installer by Claude Haiku 4.5
# This script copies configuration files from staging to ~/.config

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directories
REQUIRED_DIRS=("fnott" "foot" "sway" "waybar" "swaylock")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGING_DIR="${SCRIPT_DIR}/staging"
CONFIG_DIR="${HOME}/.config"

echo -e "${YELLOW}=== Fedora Sway Dotfiles Installer ===${NC}"
echo ""

if [ ! -d "$STAGING_DIR" ]; then
    echo "Creating staging directory..."
    mkdir -p "$STAGING_DIR"
fi

if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating ~/.config directory..."
    mkdir -p "$CONFIG_DIR"
fi

echo "Copying configuration directories..."
for dir in "${REQUIRED_DIRS[@]}"; do
    cp -r "${dir}" "${STAGING_DIR}/${dir}"
    echo -e "${GREEN}✓ ${dir} copied${NC}"
done

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "${STAGING_DIR}/${dir}" ]; then
        echo -e "${YELLOW}Warning: ${dir} not found in staging directory${NC}"
    fi
done

echo "Installing configuration files..."
for dir in "${REQUIRED_DIRS[@]}"; do
    rm -rf "${CONFIG_DIR}/${dir}"
done
mv "${STAGING_DIR}/"* "$CONFIG_DIR/"
echo -e "${GREEN}✓ Configuration files installed to ${CONFIG_DIR}${NC}"

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo "Configuration files have been installed to ${CONFIG_DIR}/"
echo ""
echo -e "${YELLOW}Note: To activate changes, reload your Sway configuration with:${NC}"
echo "  \$mod+Shift+c"
