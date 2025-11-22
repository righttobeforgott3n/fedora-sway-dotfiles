#!/bin/bash
# CPU Power Management Installation Script by Claude Haiku 4.5

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPUFREQ_SCRIPT="$SCRIPT_DIR/cpufreq.sh"
LAUNCHER_SCRIPT="$SCRIPT_DIR/cpu-power"
LOCAL_BIN="$HOME/.local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== CPU Power Management Installation ===${NC}"
echo ""

# Create ~/.local/bin if it doesn't exist
if [ ! -d "$LOCAL_BIN" ]; then
    echo "Creating $LOCAL_BIN directory..."
    mkdir -p "$LOCAL_BIN"
fi

# Install cpufreq.sh
echo "Installing cpufreq.sh..."
cp "$CPUFREQ_SCRIPT" "$LOCAL_BIN/cpufreq.sh"
chmod +x "$LOCAL_BIN/cpufreq.sh"
echo -e "${GREEN}✓ cpufreq.sh installed to $LOCAL_BIN/cpufreq.sh${NC}"

# Install launcher
echo "Installing cpu-power launcher..."
cp "$LAUNCHER_SCRIPT" "$LOCAL_BIN/cpu-power"
chmod +x "$LOCAL_BIN/cpu-power"
echo -e "${GREEN}✓ cpu-power installed to $LOCAL_BIN/cpu-power${NC}"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" == *":$LOCAL_BIN:"* ]]; then
    echo -e "${GREEN}✓ $LOCAL_BIN is in PATH${NC}"
else
    echo -e "${YELLOW}Warning: $LOCAL_BIN is not in your PATH${NC}"
    echo "Add this to ~/.bashrc or ~/.zshrc:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo -e "${YELLOW}Usage:${NC}"
echo "  cpu-power              Launch interactive menu"
echo "  cpu-power status       Show CPU status"
echo "  sudo cpu-power performance"
echo "  sudo cpu-power balanced"
echo "  sudo cpu-power powersave"
echo ""
echo -e "${YELLOW}To configure passwordless sudo access for cpufreq.sh:${NC}"
echo "  sudo visudo"
echo "  Add this line:"
echo "  %wheel ALL=(ALL) NOPASSWD: $LOCAL_BIN/cpufreq.sh"
echo ""
