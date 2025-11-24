#!/bin/bash

# Multi-Monitor Configuration Script for Sway
# Interactive tool to configure multiple monitors with friendly UI

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${YELLOW}Sway Multi-Monitor Configuration${NC}    ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

list_outputs() {
    echo -e "${CYAN}Detecting monitors...${NC}\n"
    local outputs=($(swaymsg -t get_outputs | grep '"name"' | sed 's/.*"name": "\([^"]*\)".*/\1/'))
    
    if [ ${#outputs[@]} -eq 0 ]; then
        echo -e "${RED}Error: No outputs found${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Available Monitors:${NC}"
    for i in "${!outputs[@]}"; do
        local output="${outputs[$i]}"
        local info=$(swaymsg -t get_outputs | grep -A 50 "\"name\": \"$output\"" | head -20)
        local make=$(echo "$info" | grep '"make"' | sed 's/.*"make": "\([^"]*\)".*/\1/')
        local model=$(echo "$info" | grep '"model"' | sed 's/.*"model": "\([^"]*\)".*/\1/')
        local current=$(echo "$info" | grep '"current_mode"' | sed 's/.*"\([^"]*\)".*/\1/')
        
        echo -e "  ${CYAN}[$((i+1))]${NC} $output (${make:-Unknown} ${model:-Unknown})"
    done
    echo ""
}

show_menu() {
    echo -e "${YELLOW}Configuration Options:${NC}"
    echo -e "  ${CYAN}[1]${NC} Mirror displays (same content on all monitors)"
    echo -e "  ${CYAN}[2]${NC} Extended layout (side by side)"
    echo -e "  ${CYAN}[3]${NC} Custom configuration"
    echo -e "  ${CYAN}[4]${NC} Disable secondary monitors"
    echo -e "  ${CYAN}[5]${NC} Refresh output information"
    echo -e "  ${CYAN}[0]${NC} Exit"
    echo ""
}

get_outputs_array() {
    swaymsg -t get_outputs | grep '"name"' | sed 's/.*"name": "\([^"]*\)".*/\1/'
}

mirror_displays() {
    echo -e "${YELLOW}Setting up mirrored display...${NC}\n"
    
    local outputs=($(get_outputs_array))
    local primary="${outputs[0]}"
    
    # Get resolution of primary
    local resolution=$(swaymsg -t get_outputs | grep -A 50 "\"name\": \"$primary\"" | grep '"current_mode"' | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
    
    echo "Primary monitor: $primary (${resolution})"
    
    for output in "${outputs[@]}"; do
        if [ "$output" != "$primary" ]; then
            echo "  Mirroring to: $output"
            swaymsg output "$output" enable resolution "$resolution"
        fi
    done
    
    echo -e "${GREEN}✓ Mirrored display enabled${NC}\n"
}

extended_layout() {
    echo -e "${YELLOW}Setting up extended layout...${NC}\n"
    
    local outputs=($(get_outputs_array))
    
    if [ ${#outputs[@]} -lt 2 ]; then
        echo -e "${RED}Error: Need at least 2 monitors${NC}\n"
        return 1
    fi
    
    # Get primary monitor
    echo -e "${YELLOW}Select primary monitor:${NC}"
    for i in "${!outputs[@]}"; do
        echo "  [$((i+1))] ${outputs[$i]}"
    done
    
    read -p "Enter selection [1-${#outputs[@]}]: " primary_choice
    primary_choice=$((primary_choice - 1))
    
    if [ $primary_choice -lt 0 ] || [ $primary_choice -ge ${#outputs[@]} ]; then
        echo -e "${RED}Invalid selection${NC}\n"
        return 1
    fi
    
    local primary="${outputs[$primary_choice]}"
    local position_x=0
    
    # Get primary resolution
    local primary_res=$(swaymsg -t get_outputs | grep -A 50 "\"name\": \"$primary\"" | grep '"current_mode"' | head -1 | sed 's/.*"\([0-9]*\)x\([0-9]*\)".*/\1/')
    
    swaymsg output "$primary" position 0 0
    echo "  Primary: $primary at position 0,0"
    
    position_x=$primary_res
    
    for output in "${outputs[@]}"; do
        if [ "$output" != "$primary" ]; then
            swaymsg output "$output" enable position "$position_x" 0
            echo "  Secondary: $output at position $position_x,0"
            position_x=$((position_x + 1920))  # Assume 1920 width, adjust as needed
        fi
    done
    
    echo -e "${GREEN}✓ Extended layout configured${NC}\n"
}

disable_secondary() {
    echo -e "${YELLOW}Disabling secondary monitors...${NC}\n"
    
    local outputs=($(get_outputs_array))
    
    if [ ${#outputs[@]} -lt 1 ]; then
        echo -e "${RED}No monitors found${NC}\n"
        return 1
    fi
    
    # Keep first monitor, disable others
    for i in "${!outputs[@]}"; do
        if [ $i -gt 0 ]; then
            echo "  Disabling: ${outputs[$i]}"
            swaymsg output "${outputs[$i]}" disable
        fi
    done
    
    echo -e "${GREEN}✓ Secondary monitors disabled${NC}\n"
}

custom_config() {
    echo -e "${YELLOW}Custom Configuration${NC}"
    echo "Example:"
    echo "  swaymsg output HDMI-1 resolution 1920x1080 position 1920,0"
    echo "  swaymsg output DP-1 resolution 2560x1440 position 0,0"
    echo ""
    read -p "Enter your swaymsg output command: " custom_cmd
    
    if [ -z "$custom_cmd" ]; then
        echo -e "${RED}No command entered${NC}\n"
        return 1
    fi
    
    eval "$custom_cmd"
    echo -e "${GREEN}✓ Configuration applied${NC}\n"
}

save_config() {
    echo -e "${YELLOW}Save configuration to file?${NC}"
    read -p "Enter filename (or press Enter to skip): " filename
    
    if [ -n "$filename" ]; then
        local output_config=$(swaymsg -t get_outputs | jq . > "$filename")
        echo -e "${GREEN}✓ Configuration saved to: $filename${NC}\n"
    fi
}

main() {
    while true; do
        print_header
        list_outputs || exit 1
        show_menu
        
        read -p "Select option: " choice
        
        case "$choice" in
            1) mirror_displays ;;
            2) extended_layout ;;
            3) custom_config ;;
            4) disable_secondary ;;
            5) continue ;;
            0) 
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}\n"
                ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Check if swaymsg is available
if ! command -v swaymsg &> /dev/null; then
    echo -e "${RED}Error: swaymsg not found. Make sure Sway is installed and running.${NC}"
    exit 1
fi

main
