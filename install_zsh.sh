#!/bin/bash
# Zsh Installation Script with Oh My Zsh and Plugins

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${YELLOW}Zsh + Oh My Zsh Installer${NC}              ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if running on Fedora
if [ -f /etc/fedora-release ]; then
    echo -e "${YELLOW}Installing zsh on Fedora...${NC}"
    sudo dnf install -y zsh util-linux-user
    echo -e "${GREEN}✓ Zsh installed${NC}"
else
    echo -e "${YELLOW}⚠ Not running on Fedora, attempting generic install...${NC}"
    if command -v apt &> /dev/null; then
        sudo apt install -y zsh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zsh
    else
        echo -e "${RED}Please install zsh manually for your distribution${NC}"
        exit 1
    fi
fi

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo ""
    echo -e "${YELLOW}Installing Oh My Zsh...${NC}"
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo -e "${GREEN}✓ Oh My Zsh installed${NC}"
else
    echo -e "${GREEN}✓ Oh My Zsh already installed${NC}"
fi

# Create custom plugins directory
mkdir -p "$ZSH_CUSTOM/plugins"
mkdir -p "$ZSH_CUSTOM/themes"

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo ""
    echo -e "${YELLOW}Installing zsh-autosuggestions...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    echo -e "${GREEN}✓ zsh-autosuggestions installed${NC}"
else
    echo -e "${GREEN}✓ zsh-autosuggestions already installed${NC}"
fi

# Install zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo ""
    echo -e "${YELLOW}Installing zsh-syntax-highlighting...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    echo -e "${GREEN}✓ zsh-syntax-highlighting installed${NC}"
else
    echo -e "${GREEN}✓ zsh-syntax-highlighting already installed${NC}"
fi

# Install zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    echo ""
    echo -e "${YELLOW}Installing zsh-completions...${NC}"
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    echo -e "${GREEN}✓ zsh-completions installed${NC}"
else
    echo -e "${GREEN}✓ zsh-completions already installed${NC}"
fi

# Install fast-syntax-highlighting (alternative/additional to zsh-syntax-highlighting)
if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    echo ""
    echo -e "${YELLOW}Installing fast-syntax-highlighting...${NC}"
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
    echo -e "${GREEN}✓ fast-syntax-highlighting installed${NC}"
else
    echo -e "${GREEN}✓ fast-syntax-highlighting already installed${NC}"
fi

# Install zsh-history-substring-search
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
    echo ""
    echo -e "${YELLOW}Installing zsh-history-substring-search...${NC}"
    git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
    echo -e "${GREEN}✓ zsh-history-substring-search installed${NC}"
else
    echo -e "${GREEN}✓ zsh-history-substring-search already installed${NC}"
fi

# Install Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo ""
    echo -e "${YELLOW}Installing Powerlevel10k theme...${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    echo -e "${GREEN}✓ Powerlevel10k installed${NC}"
else
    echo -e "${GREEN}✓ Powerlevel10k already installed${NC}"
fi

# Backup existing .zshrc if present
if [ -f "$HOME/.zshrc" ]; then
    echo ""
    echo -e "${YELLOW}Backing up existing .zshrc...${NC}"
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✓ Backup created${NC}"
fi

# Copy new .zshrc if it exists in repo
if [ -f "$SCRIPT_DIR/zsh/.zshrc" ]; then
    echo ""
    echo -e "${YELLOW}Installing .zshrc configuration...${NC}"
    cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
    echo -e "${GREEN}✓ .zshrc installed${NC}"
else
    echo -e "${YELLOW}⚠ No .zshrc template found in repo, keeping existing${NC}"
fi

# Copy .p10k.zsh if it exists
if [ -f "$SCRIPT_DIR/zsh/.p10k.zsh" ]; then
    echo ""
    echo -e "${YELLOW}Installing Powerlevel10k configuration...${NC}"
    cp "$SCRIPT_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
    echo -e "${GREEN}✓ .p10k.zsh installed${NC}"
fi

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo -e "${BLUE}Installed plugins:${NC}"
echo "  ✓ zsh-autosuggestions"
echo "  ✓ zsh-syntax-highlighting"
echo "  ✓ zsh-completions"
echo "  ✓ fast-syntax-highlighting"
echo "  ✓ zsh-history-substring-search"
echo ""
echo -e "${BLUE}Installed theme:${NC}"
echo "  ✓ Powerlevel10k"
echo ""
echo -e "${YELLOW}To set Zsh as your default shell:${NC}"
echo "  chsh -s \$(which zsh)"
echo ""
echo -e "${YELLOW}To start using Zsh now:${NC}"
echo "  zsh"
echo ""
echo -e "${YELLOW}To configure Powerlevel10k:${NC}"
echo "  p10k configure"
echo ""
