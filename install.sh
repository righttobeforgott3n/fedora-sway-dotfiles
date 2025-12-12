#!/bin/bash

# Fedora Sway Dotfiles Installer
# This script copies configuration files from staging to ~/.config with backup support

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
REQUIRED_DIRS=("fnott" "foot" "sway" "waybar" "swaylock" "rofi" "gtk-3.0")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGING_DIR="${SCRIPT_DIR}/staging"
CONFIG_DIR="${HOME}/.config"
BACKUP_DIR="${HOME}/.config.backup"
FONTS_DIR="${HOME}/.local/share/fonts"
FONTS_SOURCE="${SCRIPT_DIR}/fonts"

# Functions
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${YELLOW}Fedora Sway Dotfiles Installer${NC}        ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

populate_staging() {
    echo -e "${YELLOW}Populating staging directory...${NC}"
    mkdir -p "$STAGING_DIR"
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ -d "${SCRIPT_DIR}/${dir}" ]; then
            # Remove old staging copy if exists
            rm -rf "${STAGING_DIR}/${dir}"
            # Copy from repo to staging
            cp -r "${SCRIPT_DIR}/${dir}" "${STAGING_DIR}/${dir}"
            echo "  ✓ Staged ${dir}"
        else
            echo -e "${YELLOW}  ⚠ ${dir} not found in repo (skipping)${NC}"
        fi
    done
    echo ""
}

backup_current_config() {
    local dirs_to_backup=()
    
    # Check which directories exist and need backup
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ -d "${CONFIG_DIR}/${dir}" ]; then
            dirs_to_backup+=("${dir}")
        fi
    done
    
    if [ ${#dirs_to_backup[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ No existing configuration to backup${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Creating backup of current configuration...${NC}"
    
    # Remove previous backup if it exists
    if [ -d "$BACKUP_DIR" ]; then
        echo "  Removing previous backup..."
        rm -rf "$BACKUP_DIR"
    fi
    
    # Create new backup directory
    mkdir -p "$BACKUP_DIR"
    
    for dir in "${dirs_to_backup[@]}"; do
        echo "  Backing up ${dir}..."
        cp -r "${CONFIG_DIR}/${dir}" "${BACKUP_DIR}/${dir}"
    done
    
    echo -e "${GREEN}✓ Backup created at: ${BACKUP_DIR}${NC}"
    echo ""
}

restore_from_backup() {
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${RED}Error: Backup directory not found${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Restoring from backup...${NC}"
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ -d "${BACKUP_DIR}/${dir}" ]; then
            rm -rf "${CONFIG_DIR}/${dir}"
            cp -r "${BACKUP_DIR}/${dir}" "${CONFIG_DIR}/${dir}"
            echo -e "${GREEN}✓ Restored ${dir}${NC}"
        fi
    done
    
    echo -e "${GREEN}✓ Configuration restored from backup${NC}"
    echo ""
}

install_fonts() {
    echo -e "${YELLOW}Installing fonts...${NC}"
    
    # Check if fonts source directory exists
    if [ ! -d "$FONTS_SOURCE" ]; then
        echo -e "${YELLOW}⚠ Fonts directory not found (skipping)${NC}"
        echo ""
        return 0
    fi
    
    # Create fonts directory if it doesn't exist
    mkdir -p "$FONTS_DIR"
    
    # Count font files
    local font_count=$(find "$FONTS_SOURCE" -type f \( -name "*.ttf" -o -name "*.otf" \) | wc -l)
    
    if [ "$font_count" -eq 0 ]; then
        echo -e "${YELLOW}⚠ No font files found in fonts directory${NC}"
        echo ""
        return 0
    fi
    
    # Copy font files
    find "$FONTS_SOURCE" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONTS_DIR/" \;
    
    # Update font cache
    echo "  Updating font cache..."
    fc-cache -f "$FONTS_DIR" 2>/dev/null || true
    
    echo -e "${GREEN}✓ Installed $font_count font files${NC}"
    echo ""
}

# Main installation
main() {
    print_header
    
    # Populate staging directory from repo
    populate_staging
    
    # Check if staging directory exists
    if [ ! -d "$STAGING_DIR" ]; then
        echo -e "${RED}Error: staging directory not found at ${STAGING_DIR}${NC}"
        echo "Make sure you're running this script from the project root directory."
        exit 1
    fi
    
    # Create ~/.config if needed
    if [ ! -d "$CONFIG_DIR" ]; then
        echo "Creating ~/.config directory..."
        mkdir -p "$CONFIG_DIR"
    fi
    
    # Backup existing configuration
    backup_current_config
    
    # Install fonts
    install_fonts
    
    # Install new configuration from staging
    echo -e "${YELLOW}Installing configuration files from staging...${NC}"
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ -d "${STAGING_DIR}/${dir}" ]; then
            rm -rf "${CONFIG_DIR}/${dir}" 2>/dev/null || true
            cp -r "${STAGING_DIR}/${dir}" "${CONFIG_DIR}/${dir}"
            echo -e "${GREEN}✓ ${dir} installed${NC}"
        else
            echo -e "${YELLOW}⚠ ${dir} not found in staging (skipping)${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}=== Installation Complete ===${NC}"
    echo ""
    echo "Configuration files installed to: ${CONFIG_DIR}/"
    echo ""
    echo -e "${BLUE}Installed directories:${NC}"
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ -d "${CONFIG_DIR}/${dir}" ]; then
            echo "  ✓ ${dir}"
        fi
    done
    
    # Show font installation status
    local font_count=$(find "$FONTS_DIR" -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | wc -l)
    if [ "$font_count" -gt 0 ]; then
        echo "  ✓ fonts ($font_count files)"
    fi
    echo ""
    echo -e "${YELLOW}Backup information:${NC}"
    echo "  Location: ${BACKUP_DIR}"
    echo ""
    echo -e "${YELLOW}To restore previous configuration if needed:${NC}"
    echo "  cp -r ${BACKUP_DIR}/* ~/.config/"
    echo ""
    echo -e "${YELLOW}To activate Sway changes, reload with:${NC}"
    echo "  \$mod+Shift+c  (Win+Shift+C)"
    echo ""
}

# Show usage
usage() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  (no args)   Install with automatic backup"
    echo "  --help      Show this help message"
    echo "  --restore   Restore from last backup"
    echo ""
    echo "Examples:"
    echo "  ./$0              # Install with backup"
    echo "  ./$0 --restore    # Restore previous config"
}

# Handle arguments
case "${1:-}" in
    --help|-h)
        usage
        ;;
    --restore)
        echo -e "${BLUE}=== Configuration Restore ===${NC}"
        echo ""
        if [ -d "$BACKUP_DIR" ]; then
            echo -e "${YELLOW}Backup found:${NC}"
            echo "  Location: ${BACKUP_DIR}"
            echo ""
            read -p "Restore from backup? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                restore_from_backup
            else
                echo "Restore cancelled."
            fi
        else
            echo -e "${YELLOW}⚠ No backup found at ${BACKUP_DIR}${NC}"
            echo "Make sure you've run the installer first to create a backup."
        fi
        ;;
    "")
        main
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        usage
        exit 1
        ;;
esac
