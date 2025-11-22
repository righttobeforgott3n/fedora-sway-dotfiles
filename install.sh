#!/bin/bash

# Fedora Sway Dotfiles Installer by Claude Haiku 4.5
# This script copies configuration files from staging to ~/.config

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directories
REQUIRED_DIRS=("fnott" "foot" "sway" "waybar")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGING_DIR="${SCRIPT_DIR}/staging"
CONFIG_DIR="${HOME}/.config"

echo -e "${YELLOW}=== Fedora Sway Dotfiles Installer ===${NC}"
echo ""

# Check if staging directory exists
if [ ! -d "$STAGING_DIR" ]; then
    echo -e "${RED}Error: staging directory not found at ${STAGING_DIR}${NC}"
    exit 1
fi

# Create ~/.config if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating ~/.config directory..."
    mkdir -p "$CONFIG_DIR"
fi

# Copy required configuration directories
echo "Copying configuration directories..."
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "${STAGING_DIR}/${dir}" ]; then
        cp -r "${STAGING_DIR}/${dir}" "$CONFIG_DIR/"
        echo -e "${GREEN}✓ ${dir} copied${NC}"
    fi
done

# Verify required directories exist in staging
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "${STAGING_DIR}/${dir}" ]; then
        echo -e "${YELLOW}Warning: ${dir} not found in staging directory${NC}"
    fi
done

# Copy staging files to ~/.config
echo "Installing configuration files..."
for dir in "$STAGING_DIR"/*; do
    if [ -d "$dir" ]; then
        dir_name=$(basename "$dir")
        dest_dir="${CONFIG_DIR}/${dir_name}"
        
        if [ -d "$dest_dir" ]; then
            echo -e "${YELLOW}Backing up existing ${dir_name} to ${dir_name}.bak${NC}"
            [ ! -d "${CONFIG_DIR}/${dir_name}.bak" ] && mv "$dest_dir" "${CONFIG_DIR}/${dir_name}.bak"
        fi
        
        echo "Installing ${dir_name}..."
        cp -r "$dir" "$CONFIG_DIR/"
        echo -e "${GREEN}✓ ${dir_name} installed${NC}"
    fi
done

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo "Configuration files have been installed to ${CONFIG_DIR}/"
echo ""
echo "Installed directories:"
for dir in "$STAGING_DIR"/*; do
    if [ -d "$dir" ]; then
        echo "  • $(basename "$dir")"
    fi
done
echo ""
echo -e "${YELLOW}Note: To activate changes, reload your Sway configuration with:${NC}"
echo "  \$mod+Shift+c"
