#!/bin/bash

# Handle laptop lid open event
# Re-enables internal monitor when lid is opened

set -e

INTERNAL_OUTPUT="eDP-1"  # Common internal display name
LOGFILE="/tmp/sway-lid-open.log"

echo "[$(date)]" >> "$LOGFILE"
echo "Lid opened event triggered" >> "$LOGFILE"

# Re-enable internal monitor
echo "Enabling internal monitor: $INTERNAL_OUTPUT" >> "$LOGFILE"
swaymsg output "$INTERNAL_OUTPUT" enable 2>> "$LOGFILE"

echo "✓ Internal monitor enabled" >> "$LOGFILE"
