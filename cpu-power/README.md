# CPU Frequency Scaling & Power Management by Claude Haiku 4.5

This directory contains tools for optimizing CPU power consumption on Fedora Sway with AMD P-State driver.

## System Information

- **CPU Driver**: AMD P-State (amd-pstate-epp)
- **Available Governors**: `performance`, `powersave`
- **Energy Performance Preference**: `performance`, `balance_performance`, `balance_power`, `power`
- **Default State**: `powersave` governor with `balance_performance` EPP (balanced mode)

## Quick Start

### Installation

```bash
cd /path/to/fedora-sway-dotfiles/cpu-power
./install.sh
```

This installs:
- `cpu-power` launcher script to `~/.local/bin/`
- `cpufreq.sh` utility to `~/.local/bin/`

### Usage

**Interactive menu:**
```bash
cpu-power
# Select profile 1-5 from the menu
```

**Command-line:**
```bash
# Check status
cpu-power status

# Change modes (requires sudo)
sudo cpu-power performance
sudo cpu-power balanced
sudo cpu-power powersave
```

**Show help:**
```bash
cpu-power help
```

## Files

### `cpu-power` (Launcher)
Menu-driven interface for CPU power management.

**Features:**
- Interactive menu mode (runs without arguments)
- Command-line mode for direct profile switching
- Sends notifications on profile change (optional)
- Clean, colored output

**Examples:**
```bash
# Interactive menu
cpu-power

# Command-line
sudo cpu-power performance
sudo cpu-power balanced
sudo cpu-power powersave
cpu-power status
```

### `cpufreq.sh` (Utility)
Low-level CPU frequency scaling utility.

**Features:**
- Direct access to CPU frequency scaling
- Check current status
- Switch governors and EPP preferences
- Real-time CPU frequency display

**Usage:**
```bash
./cpufreq.sh status
sudo ./cpufreq.sh performance
sudo ./cpufreq.sh balanced
```

### `install.sh`
Installation script that sets up both tools in `~/.local/bin/`.

**What it does:**
1. Creates `~/.local/bin` if needed
2. Copies and makes executable `cpu-power` and `cpufreq.sh`
3. Checks if `~/.local/bin` is in PATH
4. Provides instructions for passwordless sudo (optional)

## Power Profiles Explained

### Performance Mode
- **CPU Governor**: `performance`
- **EPP**: `performance`
- **Use When**: Gaming, video editing, heavy workloads
- **Power Impact**: Maximum consumption
- **Latency**: Minimal

### Balanced Mode (Recommended)
- **CPU Governor**: `powersave`
- **EPP**: `balance_performance`
- **Use When**: General usage, web browsing, development
- **Power Impact**: Moderate consumption
- **Latency**: Balanced (responsive while saving power)

### Power Save Mode
- **CPU Governor**: `powersave`
- **EPP**: `power`
- **Use When**: Battery-only operation, idle browsing
- **Power Impact**: Minimal consumption
- **Latency**: Higher (but acceptable for most tasks)

## Optional: Passwordless Sudo

To avoid entering password every time you switch modes:

```bash
sudo visudo
```

Add this line at the end:
```
%wheel ALL=(ALL) NOPASSWD: /home/YOUR_USERNAME/.local/bin/cpufreq.sh
```

Then you can run:
```bash
# Without "sudo"
cpu-power performance
cpu-power balanced
cpu-power powersave
```

## Optional: Automatic Balanced Mode on Startup

Install the systemd service to automatically set balanced mode:

```bash
sudo cp cpu-balanced-startup.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cpu-balanced-startup.service
```

Check status:
```bash
systemctl status cpu-balanced-startup
```

## AMD P-State Driver Details

The AMD P-State driver provides:
- **Dynamic frequency scaling**: CPUs adjust clock speed based on demand
- **Energy Performance Preference (EPP)**: Fine-tuning power vs. performance
- **Automatic**: No manual kernel parameters needed for operation

## Manual CPU Frequency Control

View current frequencies in real-time:
```bash
watch -n 1 'for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do echo $(cat $i); done'
```

Check scaling driver:
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
```

Check available governors:
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
```

## System Configuration

### Disable CPU frequency scaling (not recommended):
```bash
echo 1 | sudo tee /sys/devices/system/cpu/cpu*/online
```

### Force specific governor directly:
```bash
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

## Integration with Waybar

The waybar battery module shows:
- Current battery capacity %
- Battery status (charging/discharging)
- Color-coded warnings (green/yellow/red)

Combined with CPU frequency scaling, you now have comprehensive power management:
- **UPower** → battery monitoring
- **AMD P-State** → CPU frequency scaling
- **swayidle** → screen locking and display off
- **swaylock** → custom lock screen

## Troubleshooting

**"Permission denied" errors:**
```bash
# Use sudo
sudo cpu-power performance

# OR set up passwordless sudo (see section above)
```

**CPU frequencies not changing:**
- Verify driver: `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver`
- Should show: `amd-pstate-epp`
- Check BIOS - CPU frequency scaling must be enabled

**High CPU temperature in performance mode:**
- This is normal - performance mode maximizes clock speeds
- Switch to balanced or power-save mode if concerned
- Ensure adequate cooling

**Command not found:**
- Ensure `~/.local/bin` is in PATH: `echo $PATH`
- Or run with full path: `/home/USERNAME/.local/bin/cpu-power status`

## Further Optimization

Consider implementing:
1. **Display brightness control** with `brightnessctl`
2. **GPU power management** (if applicable)
3. **Network interface power management**
4. **Disk I/O optimization** with `powertop`
5. **Thermal monitoring** with automatic fan control

## References

- AMD P-State Documentation: https://www.kernel.org/doc/html/latest/admin-guide/pm/amd-pstate.html
- systemd Services: https://systemd.io/
- Linux CPU Frequency Scaling: https://www.kernel.org/doc/html/latest/admin-guide/pm/cpufreq.html


### Performance Mode
- **CPU Governor**: `performance`
- **EPP**: `performance`
- **Use When**: Gaming, video editing, heavy workloads
- **Power Impact**: Maximum consumption
- **Latency**: Minimal

### Balanced Mode (Recommended)
- **CPU Governor**: `powersave`
- **EPP**: `balance_performance`
- **Use When**: General usage, web browsing, development
- **Power Impact**: Moderate consumption
- **Latency**: Balanced (responsive while saving power)

### Power Save Mode
- **CPU Governor**: `powersave`
- **EPP**: `power`
- **Use When**: Battery-only operation, idle browsing
- **Power Impact**: Minimal consumption
- **Latency**: Higher (but acceptable for most tasks)

## AMD P-State Driver Details

The AMD P-State driver provides:
- **Dynamic frequency scaling**: CPUs adjust clock speed based on demand
- **Energy Performance Preference (EPP)**: Allows fine-tuning power vs. performance
- **Automatic**: No manual configuration needed for basic operation

## Manual CPU Frequency Control

View current frequencies:
```bash
watch -n 1 'for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do echo $(cat $i); done'
```

Check scaling driver:
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
```

Check available governors:
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
```

## System Configuration

### Disable CPU frequency scaling (not recommended):
```bash
echo 1 | tee /sys/devices/system/cpu/cpu*/online
```

### Force specific governor (requires root):
```bash
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

## Integration with Battery Monitoring

The waybar battery module already shows:
- Current battery capacity %
- Battery status (charging/discharging)
- Color-coded warnings (green/yellow/red)

Combined with CPU frequency scaling, this provides comprehensive power management.

## Troubleshooting

**"Permission denied" when running cpufreq.sh:**
- Use `sudo ./cpufreq.sh` for mode changes
- Status check works without sudo

**CPU frequencies not changing:**
- Verify driver: `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver`
- Should show: `amd-pstate-epp`
- Check BIOS settings - CPU frequency scaling must be enabled

**High CPU temperature in performance mode:**
- This is normal - performance mode intentionally maximizes clock speeds
- Switch to balanced or power-save mode if concerned
- Ensure adequate cooling (clean vents, proper airflow)

## Further Optimization

Consider adding:
1. **Display brightness control** with `brightnessctl`
2. **GPU power management** (if applicable)
3. **Network interface power management**
4. **Disk I/O optimization** with `powertop` or `tuned`

## References

- AMD P-State Documentation: https://www.kernel.org/doc/html/latest/admin-guide/pm/amd-pstate.html
- systemd Services: https://systemd.io/
- Sway Configuration: https://man.archlinux.org/man/sway.5
