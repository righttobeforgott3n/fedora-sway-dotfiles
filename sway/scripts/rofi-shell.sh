#!/bin/bash
# Rofi Shell Command Launcher
# This script allows executing shell commands with full shell syntax support

# Get user input from rofi
cmd=$(rofi -dmenu -p "Shell Command" -theme-str 'window {width: 800px;}' -theme-str 'listview {enabled: false;}')

# Exit if no command entered
if [ -z "$cmd" ]; then
    exit 0
fi

# Check if command should run in terminal
# Commands that typically need a terminal
terminal_commands="vim|nano|htop|top|ssh|less|man|tail|watch|tmux|screen|bash|zsh|python|node|ipython"

# Check if command matches terminal commands or contains pipes/redirects
if echo "$cmd" | grep -qE "^($terminal_commands)|[|&><]"; then
    # Run in terminal
    foot -e bash -c "$cmd; echo -e '\n\nPress Enter to exit...'; read"
else
    # Run in background (for GUI apps or simple commands)
    bash -c "$cmd" &
fi
