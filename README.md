<p align="center">
  <img src="assets/banner.png" alt="Fluid Volume & Media OSD" width="100%">
</p>

<p align="center">
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/python-3.8+-3776AB?style=flat&logo=python&logoColor=white" alt="Python 3.8+"></a>
  <a href="https://pypi.org/project/PyQt5/"><img src="https://img.shields.io/badge/GUI-PyQt5-41CD52?style=flat&logo=qt&logoColor=white" alt="PyQt5"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="MIT License"></a>
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey?style=flat" alt="Platform">
</p>

<p align="center">
  A lightweight, animated volume and media overlay (HUD) designed for minimal window managers and desktop setups. Features smooth 60 FPS transitions, dynamic gradient color tiers, vector icon animations, and a real-time equalizer wave—all driven by an instant IPC client with zero keypress latency.
</p>

---

## Previews

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Volume Control (Active)</b></td>
      <td align="center"><b>Muted State</b></td>
    </tr>
    <tr>
      <td><img src="assets/hud_volume.png" width="340" alt="Volume HUD"></td>
      <td><img src="assets/hud_muted.png" width="340" alt="Muted HUD"></td>
    </tr>
    <tr>
      <td align="center"><b>Media Playing (with Waveform)</b></td>
      <td align="center"><b>Media Paused</b></td>
    </tr>
    <tr>
      <td><img src="assets/hud_playing.png" width="340" alt="Playing HUD"></td>
      <td><img src="assets/hud_paused.png" width="340" alt="Paused HUD"></td>
    </tr>
    <tr>
      <td colspan="2" align="center"><b>Track Skip (Directional Kick)</b></td>
    </tr>
    <tr>
      <td colspan="2" align="center"><img src="assets/hud_next.png" width="340" alt="Skip HUD"></td>
    </tr>
  </table>
</div>

---

## Why another OSD?

Most volume notification tools on Linux either use generic desktop notifications (which feel sluggish and pop up in random screen corners), or re-launch an entire script on every keypress (introducing 200–300ms of lag).

`volume-osd` is built around a persistent background daemon and an ultra-fast client:
- **Instant Response (< 1ms IPC)**: Hotkeys communicate over a local UNIX domain socket. Pressing a key never waits for Python or Qt to initialize.
- **Smooth 60 FPS Animation**: Transitions use cubic easing curves so the progress bar glides smoothly rather than jumping abruptly.
- **Color Temperature Tiers**: The bar dynamically shifts colors as you change volume:
  - Low to mid volume: Cool cyan / azure
  - High volume (> 70%): Violet into warm amber
  - Near max (> 88%): Crimson warning accent
  - Muted: Subdued slate grey with a red strike-through
- **Smart Media Control**: Automatically detects and controls active media players. Supports both modern MPRIS2 players (browsers, Spotify, VLC, MPV) and classic X11 players (XMMS via native C bindings). Shows current track title and animated equalizer bars during playback.
- **Compositor Agnostic**: Uses 1-bit X11 shape masking as a fallback, giving you clean rounded pill corners even on standalone window managers without a compositor running (e.g., IceWM, Fluxbox, or lightweight antiX/Debian setups).
- **Never Steals Focus**: Configured with window flags to remain completely transparent to window focus—your active typing, terminal session, or fullscreen game is never interrupted.

---

## Installation

### Method 1: Automated Installer (Linux & macOS)

Clone the repository and run `install.sh`:

```bash
git clone https://github.com/<YOUR_USERNAME>/volume-osd.git
cd volume-osd
chmod +x install.sh
./install.sh
```

The script will:
1. Check for Python 3 and PyQt5.
2. Install the `volume-osd` executable into `~/.local/bin/`.
3. Create default configuration at `~/.config/volume-osd/config.json`.
4. Register an autostart desktop entry and systemd user service.
5. Pop up a quick preview test to confirm everything works.

Ensure `~/.local/bin` is in your `$PATH`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Method 2: Python Package (pip)

```bash
git clone https://github.com/<YOUR_USERNAME>/volume-osd.git
cd volume-osd
pip install -e .
```

### Method 3: Standalone Executable

If you don't want to install packages, the repository includes a self-contained single-file script named `volume-osd`. Simply copy it anywhere in your PATH:

```bash
cp volume-osd ~/.local/bin/
chmod +x ~/.local/bin/volume-osd
```

---

## Hotkey Configuration

Bind `volume-osd` commands in your window manager or hotkey daemon of choice.

### i3wm / Sway (`~/.config/i3/config` or `~/.config/sway/config`)

```i3
# Hardware multimedia keys
bindsym XF86AudioRaiseVolume exec --no-startup-id volume-osd up
bindsym XF86AudioLowerVolume exec --no-startup-id volume-osd down
bindsym XF86AudioMute        exec --no-startup-id volume-osd mute
bindsym XF86AudioPlay        exec --no-startup-id volume-osd play-pause
bindsym XF86AudioNext        exec --no-startup-id volume-osd next
bindsym XF86AudioPrev        exec --no-startup-id volume-osd prev

# Custom modifier hotkeys (Ctrl + Super)
bindsym Control+Mod4+x       exec --no-startup-id volume-osd up
bindsym Control+Mod4+z       exec --no-startup-id volume-osd down
bindsym Control+Mod4+m       exec --no-startup-id volume-osd mute
bindsym Control+Mod4+space   exec --no-startup-id volume-osd play-pause
bindsym Control+Mod4+Right   exec --no-startup-id volume-osd next
bindsym Control+Mod4+Left    exec --no-startup-id volume-osd prev

# Autostart daemon
exec --no-startup-id volume-osd --daemon
```

### Hyprland (`~/.config/hypr/hyprland.conf`)

```ini
# Volume
bind = , XF86AudioRaiseVolume, exec, volume-osd up
bind = , XF86AudioLowerVolume, exec, volume-osd down
bind = , XF86AudioMute,        exec, volume-osd mute

# Media
bind = , XF86AudioPlay, exec, volume-osd play-pause
bind = , XF86AudioNext, exec, volume-osd next
bind = , XF86AudioPrev, exec, volume-osd prev

# Custom combos (Ctrl + Super)
bind = CTRL_SUPER, X,     exec, volume-osd up
bind = CTRL_SUPER, Z,     exec, volume-osd down
bind = CTRL_SUPER, M,     exec, volume-osd mute
bind = CTRL_SUPER, SPACE, exec, volume-osd play-pause
bind = CTRL_SUPER, RIGHT, exec, volume-osd next
bind = CTRL_SUPER, LEFT,  exec, volume-osd prev

# Autostart
exec-once = volume-osd --daemon
```

### sxhkd / bspwm (`~/.config/sxhkd/sxhkdrc`)

```sxhkdrc
# Multimedia keys
XF86Audio{RaiseVolume,LowerVolume,Mute}
    volume-osd {up,down,mute}

XF86Audio{Play,Next,Prev}
    volume-osd {play-pause,next,prev}

# Ctrl + Super bindings
ctrl + super + {x,z,m}
    volume-osd {up,down,mute}

ctrl + super + {space,Right,Left}
    volume-osd {play-pause,next,prev}
```

### IceWM (`~/.icewm/keys`)

```icewm
key "XF86AudioRaiseVolume" volume-osd up
key "XF86AudioLowerVolume" volume-osd down
key "XF86AudioMute"        volume-osd mute
key "XF86AudioPlay"        volume-osd play-pause
key "XF86AudioNext"        volume-osd next
key "XF86AudioPrev"        volume-osd prev

key "Ctrl+Super+x"         volume-osd up
key "Ctrl+Super+z"         volume-osd down
key "Ctrl+Super+m"         volume-osd mute
key "Ctrl+Super+space"     volume-osd play-pause
key "Ctrl+Super+Right"     volume-osd next
key "Ctrl+Super+Left"      volume-osd prev
```

To autostart in IceWM, add this line to `~/.icewm/startup`:
```bash
volume-osd --daemon &
```

### macOS (skhd)

Using [skhd](https://github.com/koekeishiya/skhd):

```sh
ctrl + cmd - x     : volume-osd up
ctrl + cmd - z     : volume-osd down
ctrl + cmd - m     : volume-osd mute
ctrl + cmd - space : volume-osd play-pause
ctrl + cmd - right : volume-osd next
ctrl + cmd - left  : volume-osd prev
```

### Windows (AutoHotkey)

Save the following in an `.ahk` script:

```autohotkey
^#x::Run, python -m volume_osd.cli up,, Hide
^#z::Run, python -m volume_osd.cli down,, Hide
^#m::Run, python -m volume_osd.cli mute,, Hide
^#Space::Run, python -m volume_osd.cli play-pause,, Hide
^#Right::Run, python -m volume_osd.cli next,, Hide
^#Left::Run, python -m volume_osd.cli prev,, Hide
```

---

## CLI Reference

```
Usage: volume-osd <command> [argument]

Commands:
  up [step]          Increase volume by step percent (default: 5%)
  down [step]        Decrease volume by step percent (default: 5%)
  mute               Toggle mute state
  set <0-100>        Set volume to an exact percentage
  show               Display HUD with current state without changing values
  play-pause         Toggle play/pause on the active player
  next               Skip to next track
  prev               Skip to previous track
  --daemon           Start background HUD service
  --test             Trigger a test animation sequence
  --ping             Check if background daemon is active
```

---

## Configuration

Configuration is loaded from `~/.config/volume-osd/config.json`. A default config is automatically generated on first run:

```json
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
```

| Setting | Type | Description |
| :--- | :--- | :--- |
| `position` | `string` | HUD screen position: `"top-center"`, `"bottom-center"`, or `"center"`. |
| `margin_y` | `int` | Distance in pixels from the screen edge. |
| `timeout_ms` | `int` | Time in milliseconds before the HUD fades out. |
| `enable_mask` | `bool` | Enables 1-bit X11 shape masking. Ensures rounded corners on non-composited window managers. |
| `step` | `int` | Default volume step percentage when not specified on CLI. |
| `unmute_on_up` | `bool` | Automatically unmute when increasing volume. |

---

## Technical Details

### Architecture

```
Hotkey Trigger (e.g., Ctrl+Super+X)
         │
         ▼  (< 1ms via socket)
  ┌───────────────┐
  │  volume-osd   │  (Lightweight CLI IPC client)
  └───────┬───────┘
          │ UNIX Domain Socket (/tmp/volume_osd_<UID>.sock)
          ▼
  ┌──────────────────────────────────────────────┐
  │             volume-osd --daemon              │
  │  ┌────────────────────┐  ┌────────────────┐  │
  │  │  PyQt5 HUD Window  │  │ Audio & Media  │  │
  │  │  • 60 FPS Easing   │  │ Worker Thread  │  │
  │  │  • QPainter Vector │  │ • wpctl/amixer │  │
  │  │  • Waveform Timer  │  │ • playerctl/C  │  │
  │  └────────────────────┘  └────────────────┘  │
  └──────────────────────────────────────────────┘
```

1. **Non-blocking IPC**: The CLI client opens a standard Unix domain socket, delivers the command, and terminates in less than 1ms.
2. **Worker Threading & Coalescing**: System audio commands (`wpctl`, `amixer`, `playerctl`) run asynchronously on a background worker thread. If you hold down or spam a volume hotkey, rapid events are coalesced so audio adjustments never bottleneck the UI rendering loop.
3. **Automatic Daemon Spawning**: If the daemon is not running when a hotkey is pressed, the client starts it in the background on demand so no input is ever dropped.
4. **State-Aware Media Controller**: Player status is tracked using MPRIS2 and native `libxmms` bindings to eliminate state race conditions when toggling playback.

---

## License

MIT License. Feel free to use, modify, and distribute as you like.
