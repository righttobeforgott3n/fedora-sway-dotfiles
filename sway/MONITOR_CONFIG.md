# Sway Multi-Monitor Configuration Guide

## Overview

This guide helps you configure multiple monitors with Sway and handle dynamic output changes like laptop lid close/open events.

## Issues Solved

### 1. Mouse Not Following Active Workspace
**Solution:** Added mouse focus and warping configuration in `config.d/10-mouse.conf`

- `focus_follows_mouse yes` - Mouse focus follows active workspace
- `mouse_warping workspace` - Mouse warps to new workspace when switching

### 2. Multi-Monitor Configuration
**Solution:** Interactive monitor configuration script

#### Using the Monitor Configuration Script

```bash
# Run the interactive monitor setup tool
~/.config/sway/monitor-config.sh
```

**Features:**
- Auto-detect connected monitors
- Mirror displays (clone to all monitors)
- Extended layout (side-by-side configuration)
- Custom manual configuration
- Disable secondary monitors

#### Manual Monitor Configuration

Get available monitors:
```bash
swaymsg -t get_outputs
```

Example configurations:

**Side-by-side (1920x1080 + 1920x1080):**
```bash
swaymsg output HDMI-1 resolution 1920x1080 position 0 0
swaymsg output DP-1 resolution 1920x1080 position 1920 0
```

**Primary + Secondary (2560x1440 + 1920x1080):**
```bash
swaymsg output DP-1 resolution 2560x1440 position 0 0
swaymsg output HDMI-1 resolution 1920x1080 position 2560 0
```

**Mirror displays:**
```bash
swaymsg output HDMI-1 resolution 1920x1080
swaymsg output DP-1 resolution 1920x1080
```

### 3. Laptop Screen Remains Active When Closed
**Solution:** Automatic lid event handling scripts

#### How It Works

- `handle-lid-close.sh` - Disables internal monitor (eDP-1) when lid closes and external monitor exists
- `handle-lid-open.sh` - Re-enables internal monitor when lid opens

These scripts are automatically triggered by `config.d/15-output-events.conf` using Sway's `bindswitch` command.

#### Configuration

Edit `scripts/handle-lid-close.sh` if your internal display name differs from `eDP-1`:

```bash
# Find your internal display name
swaymsg -t get_outputs | grep '"name"'
```

Common internal display names:
- `eDP-1` (Intel/most systems)
- `LVDS-1` (older systems)
- `DP-1-1` (some ThinkPads)

Update the `INTERNAL_OUTPUT` variable in both scripts:

```bash
INTERNAL_OUTPUT="your-display-name"
```

#### Debugging

Check if lid events are working:

```bash
# Watch lid switch events in real-time
tail -f /tmp/sway-lid-close.log
tail -f /tmp/sway-lid-open.log
```

## Permanent Configuration

To save your preferred monitor layout permanently, add to `~/.config/sway/config.d/` or update `~/.config/sway/config`:

```bash
# Example: ~/.config/sway/config.d/20-outputs.conf
output HDMI-1 {
    resolution 1920x1080
    position 0 0
}

output DP-1 {
    resolution 2560x1440
    position 1920 0
}
```

## Keyboard Shortcuts

Once you add monitor setup bindings to your Sway config, you can quickly reconfigure:

```bash
# Add to ~/.config/sway/config
bindsym $mod+Shift+m exec ~/.config/sway/monitor-config.sh
```

Then press `Win+Shift+M` to open the interactive monitor configuration tool.

## Troubleshooting

### Monitor not detected
```bash
# Ensure monitor is connected and powered on
# Force probe connected outputs
swaymsg output '*' enable
```

### Wrong resolution
```bash
# List available resolutions for specific output
swaymsg -t get_outputs | jq '.[] | select(.name=="HDMI-1") | .modes'
```

### Workspaces not moving to monitors
```bash
# Assign workspaces to specific outputs
workspace 1 output HDMI-1
workspace 2 output DP-1
```

### Internal monitor won't disable
Check if your display name matches `INTERNAL_OUTPUT` in the scripts and verify ACPI lid event support:

```bash
cat /proc/acpi/button/lid/*/state
# Should show: state:      open or closed
```

## Testing

After configuration, reload Sway to apply changes:
```bash
# Reload Sway config (Win+Shift+C or manually)
swaymsg reload
```

Test monitor changes:
```bash
# Disable monitor
swaymsg output HDMI-1 disable

# Enable monitor
swaymsg output HDMI-1 enable

# Toggle
swaymsg output HDMI-1 toggle
```
