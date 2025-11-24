#!/bin/bash

# Handle laptop lid close event
# Disables internal monitor if external monitor is available

set -e

INTERNAL_OUTPUT="eDP-1"  # Common internal display name
LOGFILE="/tmp/sway-lid-close.log"

echo "[$(date)]" >> "$LOGFILE"
echo "Lid closed event triggered" >> "$LOGFILE"

# Get list of all outputs
OUTPUTS=$(swaymsg -t get_outputs | jq -r '.[].name')

echo "Available outputs: $OUTPUTS" >> "$LOGFILE"

# Check if any external monitor is connected
EXTERNAL_CONNECTED=0
for output in $OUTPUTS; do
    if [ "$output" != "$INTERNAL_OUTPUT" ]; then
        STATUS=$(swaymsg -t get_outputs | jq -r ".[] | select(.name==\"$output\") | .active")
        if [ "$STATUS" = "true" ]; then
            EXTERNAL_CONNECTED=1
            echo "External monitor found: $output (active)" >> "$LOGFILE"
            break
        else
            echo "External monitor found: $output (inactive)" >> "$LOGFILE"
            # Try to enable it
            swaymsg output "$output" enable 2>> "$LOGFILE"
            EXTERNAL_CONNECTED=1
            break
        fi
    fi
done

# If external monitor is connected, disable internal
if [ $EXTERNAL_CONNECTED -eq 1 ]; then
    echo "Disabling internal monitor: $INTERNAL_OUTPUT" >> "$LOGFILE"
    swaymsg output "$INTERNAL_OUTPUT" disable 2>> "$LOGFILE"
    echo "✓ Internal monitor disabled" >> "$LOGFILE"
else
    echo "No external monitor detected, keeping internal monitor active" >> "$LOGFILE"
fi
