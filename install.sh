#!/usr/bin/env bash
# ==============================================================================
# Fluid Volume & Media OSD - Universal Installer for Linux & macOS
# ==============================================================================

set -e

BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}${CYAN}────────────────────────────────────────────────────────────────${RESET}"
echo -e "${BOLD}${CYAN}          Fluid Volume & Media OSD — Installer                  ${RESET}"
echo -e "${BOLD}${CYAN}────────────────────────────────────────────────────────────────${RESET}"

# 1. Check Python 3
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}[ERROR] Python 3 is required but not installed.${RESET}"
    exit 1
fi

PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo -e "${GREEN}✓ Found Python ${PY_VER}${RESET}"

# 2. Check PyQt5
echo -n "Checking PyQt5 dependency... "
if python3 -c "import PyQt5" &>/dev/null; then
    echo -e "${GREEN}✓ Installed${RESET}"
else
    echo -e "${YELLOW}Missing${RESET}"
    echo -e "${YELLOW}Installing PyQt5...${RESET}"
    if command -v apt-get &>/dev/null; then
        echo -e "${CYAN}Tip: You can install via system packages:${RESET} sudo apt install python3-pyqt5"
    elif command -v pacman &>/dev/null; then
        echo -e "${CYAN}Tip: You can install via system packages:${RESET} sudo pacman -S python-pyqt5"
    elif command -v dnf &>/dev/null; then
        echo -e "${CYAN}Tip: You can install via system packages:${RESET} sudo dnf install python3-qt5"
    elif command -v brew &>/dev/null; then
        echo -e "${CYAN}Tip: You can install via Homebrew:${RESET} brew install pyqt@5"
    fi
    pip3 install --user PyQt5 || {
        echo -e "${RED}Failed to auto-install PyQt5 via pip. Please install python3-pyqt5 using your package manager.${RESET}"
    }
fi

# 3. Target Directories
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/volume-osd"
AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
SYSTEMD_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

mkdir -p "$INSTALL_DIR" "$CONFIG_DIR"

# 4. Copy Executable
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/volume-osd" ]; then
    cp "$SCRIPT_DIR/volume-osd" "$INSTALL_DIR/volume-osd"
elif [ -f "$SCRIPT_DIR/volume_osd/cli.py" ]; then
    cp "$SCRIPT_DIR/volume-osd" "$INSTALL_DIR/volume-osd" 2>/dev/null || {
        cat << 'EOF' > "$INSTALL_DIR/volume-osd"
#!/usr/bin/env python3
import sys
from volume_osd.cli import main
if __name__ == '__main__':
    main()
EOF
        pip3 install --user -e "$SCRIPT_DIR"
    }
fi
chmod +x "$INSTALL_DIR/volume-osd"
echo -e "${GREEN}✓ Installed volume-osd to ${INSTALL_DIR}/volume-osd${RESET}"

# Verify PATH
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        echo -e "${YELLOW}[!] Warning: ${INSTALL_DIR} is not in your PATH.${RESET}"
        echo -e "    Add this to your ~/.bashrc or ~/.zshrc:"
        echo -e "    ${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
        ;;
esac

# 5. Default Config
if [ ! -f "$CONFIG_DIR/config.json" ]; then
    cat << 'EOF' > "$CONFIG_DIR/config.json"
{
  "hud": {
    "width": 340,
    "height": 64,
    "border_radius": 30,
    "position": "top-center",
    "margin_y": 48,
    "timeout_ms": 1800,
    "enable_mask": true
  },
  "audio": {
    "step": 5,
    "unmute_on_up": true
  }
}
EOF
    echo -e "${GREEN}✓ Created default config at ${CONFIG_DIR}/config.json${RESET}"
fi

# 6. Autostart Setup (Systemd or XDG Desktop)
if command -v systemctl &>/dev/null && [ -d /run/systemd/system ]; then
    mkdir -p "$SYSTEMD_DIR"
    cp "$SCRIPT_DIR/systemd/volume-osd.service" "$SYSTEMD_DIR/volume-osd.service" 2>/dev/null || true
    echo -e "${CYAN}To enable systemd user service:${RESET}"
    echo -e "  systemctl --user enable --now volume-osd.service"
fi

if [ -f "$SCRIPT_DIR/assets/volume-osd.desktop" ]; then
    mkdir -p "$AUTOSTART_DIR"
    cp "$SCRIPT_DIR/assets/volume-osd.desktop" "$AUTOSTART_DIR/volume-osd.desktop"
    echo -e "${GREEN}✓ Added XDG desktop autostart entry${RESET}"
fi

# 7. Start Daemon & Test Animation
echo -e "${CYAN}Starting background daemon...${RESET}"
pkill -f "volume-osd --daemon" 2>/dev/null || true
python3 "$INSTALL_DIR/volume-osd" --daemon &>/dev/null &
sleep 0.5

echo -e "${GREEN}✓ Running test HUD popup...${RESET}"
"$INSTALL_DIR/volume-osd" --test &

echo -e "\n${BOLD}${GREEN}Installation Complete! 🎉${RESET}\n"
echo -e "${BOLD}Keyboard Shortcuts Setup:${RESET}"
echo -e "  Volume Up:       volume-osd up"
echo -e "  Volume Down:     volume-osd down"
echo -e "  Toggle Mute:     volume-osd mute"
echo -e "  Play / Pause:    volume-osd play-pause"
echo -e "  Next Track:      volume-osd next"
echo -e "  Previous Track:  volume-osd prev"
echo -e "\nCheck the ${BOLD}README.md${RESET} for copy-paste shortcuts for i3, Sway, Hyprland, bspwm, and IceWM.\n"
