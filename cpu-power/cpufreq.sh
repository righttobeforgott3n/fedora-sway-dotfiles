#!/bin/bash
# CPU Power Management Utility by Claude Haiku 4.5
# Manages CPU frequency scaling and energy performance on AMD systems with p-state driver

set -e

CPUFREQ_PATH="/sys/devices/system/cpu/cpu0/cpufreq"
EPP_PATH="/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: This script requires root privileges${NC}"
        echo "Run with: sudo $0 $@"
        exit 1
    fi
}

# Show current CPU state
show_status() {
    echo -e "${BLUE}=== CPU Frequency Scaling Status ===${NC}"
    echo ""
    
    if [ -f "$CPUFREQ_PATH/scaling_driver" ]; then
        echo -e "${YELLOW}Driver:${NC} $(cat $CPUFREQ_PATH/scaling_driver)"
    fi
    
    if [ -f "$CPUFREQ_PATH/scaling_governor" ]; then
        echo -e "${YELLOW}Governor:${NC} $(cat $CPUFREQ_PATH/scaling_governor)"
    fi
    
    if [ -f "$CPUFREQ_PATH/scaling_available_governors" ]; then
        echo -e "${YELLOW}Available Governors:${NC} $(cat $CPUFREQ_PATH/scaling_available_governors)"
    fi
    
    if [ -f "$EPP_PATH" ]; then
        echo -e "${YELLOW}Energy Performance Preference:${NC} $(cat $EPP_PATH)"
        echo -e "${YELLOW}Available Preferences:${NC} $(cat $CPUFREQ_PATH/energy_performance_available_preferences 2>/dev/null || echo 'N/A')"
    fi
    
    echo ""
    echo -e "${YELLOW}CPU Frequencies:${NC}"
    for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
        cpu_num=$(echo $i | sed 's/.*cpu\([0-9]*\).*/\1/')
        freq_mhz=$(( $(cat $i) / 1000 ))
        printf "  CPU%d: %d MHz\n" $cpu_num $freq_mhz
    done
}

# Set power profile
set_profile() {
    local profile=$1
    
    case $profile in
        performance)
            echo -e "${YELLOW}Setting CPU to Performance mode...${NC}"
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
                echo "performance" > "$cpu/scaling_governor"
                echo "performance" > "$cpu/energy_performance_preference" 2>/dev/null || true
            done
            echo -e "${GREEN}✓ Performance mode enabled${NC}"
            ;;
        
        balanced|balance)
            echo -e "${YELLOW}Setting CPU to Balanced mode...${NC}"
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
                echo "powersave" > "$cpu/scaling_governor"
                echo "balance_performance" > "$cpu/energy_performance_preference" 2>/dev/null || true
            done
            echo -e "${GREEN}✓ Balanced mode enabled${NC}"
            ;;
        
        powersave|battery)
            echo -e "${YELLOW}Setting CPU to Power Save mode...${NC}"
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
                echo "powersave" > "$cpu/scaling_governor"
                echo "power" > "$cpu/energy_performance_preference" 2>/dev/null || true
            done
            echo -e "${GREEN}✓ Power Save mode enabled${NC}"
            ;;
        
        *)
            echo -e "${RED}Error: Unknown profile '$profile'${NC}"
            echo "Available profiles: performance, balanced, powersave"
            exit 1
            ;;
    esac
}

# Main
case "${1:-status}" in
    status)
        show_status
        ;;
    performance)
        check_root
        set_profile "performance"
        show_status
        ;;
    balanced|balance)
        check_root
        set_profile "balanced"
        show_status
        ;;
    powersave|battery)
        check_root
        set_profile "powersave"
        show_status
        ;;
    *)
        echo -e "${BLUE}CPU Power Management Utility${NC}"
        echo ""
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  status              Show current CPU frequency scaling status"
        echo "  performance         Set to maximum performance"
        echo "  balanced            Set to balanced mode (recommended)"
        echo "  powersave|battery   Set to power saving mode"
        echo ""
        echo "Examples:"
        echo "  sudo $0 performance"
        echo "  sudo $0 balanced"
        echo "  sudo $0 status"
        echo ""
        show_status
        ;;
esac
