#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   Alacritty Terminal Configuration Installer                ║
# ║   Installs to ~/.config/alacritty/alacritty.toml            ║
# ║   Supports: Arch, CachyOS, Manjaro, Garuda, Artix,          ║
# ║             Fedora, Ubuntu, Debian, openSUSE, Void, Alpine   ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

# ─────────────────────────────────────────────────────────────────
# COLOUR HELPERS
# ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
info()    { echo -e "${CYAN}ℹ${RESET}  $*"; }
success() { echo -e "${GREEN}✓${RESET}  $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $*"; }
error()   { echo -e "${RED}✗${RESET}  $*"; }

# ─────────────────────────────────────────────────────────────────
# detect_os  – returns the lowercase distro ID from /etc/os-release
# FIX #2 – cachyos, garuda, artix now explicitly recognised.
# ─────────────────────────────────────────────────────────────────
detect_os() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "${ID,,}"          # lowercase
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif command -v lsb_release >/dev/null 2>&1; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    else
        uname -s | tr '[:upper:]' '[:lower:]'
    fi
}

# ─────────────────────────────────────────────────────────────────
# get_pkg_manager  – returns a short token used by install_pkg()
# ─────────────────────────────────────────────────────────────────
get_pkg_manager() {
    local os="$1"
    case "$os" in
        arch|cachyos|manjaro|endeavouros|garuda|artix|parabola|hyperbola)
            echo "pacman" ;;
        ubuntu|debian|pop|elementary|linuxmint|kali|raspbian|mx)
            echo "apt" ;;
        fedora)
            echo "dnf" ;;
        rhel|centos|almalinux|rocky|ol)
            echo "dnf" ;;
        opensuse*|sles|tumbleweed|leap)
            echo "zypper" ;;
        gentoo)
            echo "emerge" ;;
        alpine)
            echo "apk" ;;
        void)
            echo "xbps" ;;
        macos)
            echo "brew" ;;
        *)
            # Last-resort: probe for whatever is actually present
            for pm in pacman apt dnf yum zypper apk xbps-install brew; do
                command -v "$pm" >/dev/null 2>&1 && echo "$pm" && return
            done
            echo "unknown"
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────────
# install_pkg  – installs a single package using the detected PM
# ─────────────────────────────────────────────────────────────────
install_pkg() {
    local pkg="$1"
    local pm="$2"
    info "Installing '$pkg' via $pm …"
    case "$pm" in
        pacman)  sudo pacman -Sy --noconfirm "$pkg" ;;
        apt)     sudo apt-get update -qq && sudo apt-get install -y "$pkg" ;;
        dnf)     sudo dnf install -y "$pkg" ;;
        yum)     sudo yum install -y "$pkg" ;;
        zypper)  sudo zypper install -y "$pkg" ;;
        emerge)  sudo emerge "$pkg" ;;
        apk)     sudo apk add "$pkg" ;;
        xbps)    sudo xbps-install -Sy "$pkg" ;;
        brew)    brew install "$pkg" ;;
        *)
            error "Unknown package manager – cannot auto-install '$pkg'."
            error "Please install '$pkg' manually and re-run this script."
            exit 1
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────────
# NEW: ensure_bc  – auto-install bc if it isn't on PATH.
# FIX #1 (extended) – the original script used bc for the font-size
#   range check but fell back to `|| echo "1"` when bc was absent,
#   which made (( 1 == 1 )) always true and rejected every input.
#   Now we just install bc automatically so it's always available.
# ─────────────────────────────────────────────────────────────────
ensure_bc() {
    if command -v bc >/dev/null 2>&1; then
        return 0
    fi
    warn "'bc' not found – attempting automatic installation…"
    local os pm
    os=$(detect_os)
    pm=$(get_pkg_manager "$os")
    install_pkg "bc" "$pm" && success "'bc' installed successfully." || {
        error "Auto-install of 'bc' failed."
        error "Please install it manually ('sudo <your-pkg-manager> install bc') and re-run."
        exit 1
    }
}

# ─────────────────────────────────────────────────────────────────
# detect_gpu  – returns NVIDIA | AMD | Intel | Unknown
# ─────────────────────────────────────────────────────────────────
detect_gpu() {
    if command -v lspci >/dev/null 2>&1; then
        if   lspci | grep -qi "nvidia";                        then echo "NVIDIA"
        elif lspci | grep -qi "amd\|ati\|radeon";              then echo "AMD"
        elif lspci | grep -qi "intel.*graphics\|vga.*intel";   then echo "Intel"
        else echo "Unknown"
        fi
    elif command -v glxinfo >/dev/null 2>&1; then
        local gpu
        gpu=$(glxinfo 2>/dev/null | grep -i "opengl renderer" | cut -d: -f2 | tr -d ' ')
        if   echo "$gpu" | grep -qi "nvidia";       then echo "NVIDIA"
        elif echo "$gpu" | grep -qi "amd\|radeon";  then echo "AMD"
        elif echo "$gpu" | grep -qi "intel";        then echo "Intel"
        else echo "Unknown"
        fi
    else
        echo "Unknown"
    fi
}

# ─────────────────────────────────────────────────────────────────
# NEW: detect_nvidia_details
#   Probes driver version, checks Wayland vs X11, and returns the
#   best Alacritty renderer + any env-var recommendations.
#   Sets globals: NV_DRIVER  NV_SESSION  NV_RENDERER  NV_ENV_HINTS
# ─────────────────────────────────────────────────────────────────
detect_nvidia_details() {
    NV_DRIVER="unknown"
    NV_SESSION="unknown"
    NV_RENDERER="glsl3"     # safe default for all modern NVIDIA cards
    NV_ENV_HINTS=""

    # --- Driver version ---
    if command -v nvidia-smi >/dev/null 2>&1; then
        NV_DRIVER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null \
                    | head -1 | tr -d ' ') || NV_DRIVER="unknown"
    elif [[ -f /proc/driver/nvidia/version ]]; then
        NV_DRIVER=$(awk '/NVIDIA/{print $8}' /proc/driver/nvidia/version 2>/dev/null) \
                   || NV_DRIVER="unknown"
    fi

    # --- Wayland vs X11 ---
    if [[ "${WAYLAND_DISPLAY:-}" != "" ]]; then
        NV_SESSION="Wayland"
    elif [[ "${DISPLAY:-}" != "" ]]; then
        NV_SESSION="X11"
    fi

    # --- Choose renderer ---
    # glsl3  = OpenGL 3.3 core – best performance on all modern NVIDIA (≥ Kepler)
    # gles2  = OpenGL ES 2.0   – fallback for very old cards / broken GL installs
    # None   = Alacritty picks automatically (safe but slower on some setups)
    #
    # We stay on glsl3 for all supported NVIDIA hardware.
    # If the driver is so old it predates GL 3.3 (pre-340 series) we warn and
    # drop to None so Alacritty can self-detect rather than crash.
    if [[ "$NV_DRIVER" != "unknown" ]]; then
        local major
        major=$(echo "$NV_DRIVER" | cut -d. -f1)
        if (( major < 340 )); then
            warn "NVIDIA driver $NV_DRIVER is very old (< 340). Falling back to renderer 'None'."
            NV_RENDERER="None"
            NV_ENV_HINTS+="  • Consider updating your NVIDIA driver for best performance.\n"
        fi
    fi

    # --- Wayland-specific env hints ---
    if [[ "$NV_SESSION" == "Wayland" ]]; then
        NV_ENV_HINTS+="  • On Wayland + NVIDIA, add to /etc/environment (or your shell rc):\n"
        NV_ENV_HINTS+="      GBM_BACKEND=nvidia-drm\n"
        NV_ENV_HINTS+="      __GLX_VENDOR_LIBRARY_NAME=nvidia\n"
        NV_ENV_HINTS+="      WLR_NO_HARDWARE_CURSORS=1   # if cursor disappears\n"
        NV_ENV_HINTS+="  • Ensure 'nvidia-drm.modeset=1' is set in your kernel parameters.\n"
    fi
}

# ─────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────

CONFIG_DIR="$HOME/.config/alacritty"
CONFIG_FILE="$CONFIG_DIR/alacritty.toml"
mkdir -p "$CONFIG_DIR"

# Ensure bc is installed before we need it
ensure_bc

OS_ID=$(detect_os)
GPU_TYPE=$(detect_gpu)

# NVIDIA-specific probe
NV_DRIVER=""; NV_SESSION=""; NV_RENDERER="glsl3"; NV_ENV_HINTS=""
if [[ "$GPU_TYPE" == "NVIDIA" ]]; then
    detect_nvidia_details
fi

# Pick renderer for non-NVIDIA GPUs
if [[ "$GPU_TYPE" != "NVIDIA" ]]; then
    case $GPU_TYPE in
        AMD)   NV_RENDERER="glsl3" ;;
        Intel) NV_RENDERER="None"  ;;
        *)     NV_RENDERER="None"  ;;
    esac
fi
RENDERER="$NV_RENDERER"

# ── Banner ────────────────────────────────────────────────────────
echo
echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║     Alacritty Terminal Configuration Installer           ║${RESET}"
echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${RESET}"
echo

if [[ "$GPU_TYPE" != "Unknown" ]]; then
    if [[ "$GPU_TYPE" == "NVIDIA" ]]; then
        info "Detected GPU  : ${BOLD}NVIDIA${RESET} (driver: ${NV_DRIVER}, session: ${NV_SESSION})"
        info "Auto-selected renderer: ${BOLD}${RENDERER}${RESET} (OpenGL 3.3 – optimal for NVIDIA)"
    else
        info "Detected GPU  : ${BOLD}${GPU_TYPE}${RESET}"
        info "Auto-selected renderer: ${BOLD}${RENDERER}${RESET}"
    fi
    echo
fi

# ── Theme ─────────────────────────────────────────────────────────
echo "Choose your theme:"
echo "  1) Catppuccin Mocha (dark)     ← most popular"
echo "  2) Catppuccin Latte (light)"
echo "  3) Tokyo Night"
echo "  4) Dracula"
echo "  5) Gruvbox Dark"
echo "  6) Nord"
echo "  7) One Dark"
echo "  8) Solarized Dark"
read -rp " [1-8] (default 1): " theme_choice
theme_choice=${theme_choice:-1}

case $theme_choice in
    2) THEME="latte";     NAME="Catppuccin Latte"  ;;
    3) THEME="tokyo";     NAME="Tokyo Night"        ;;
    4) THEME="dracula";   NAME="Dracula"            ;;
    5) THEME="gruvbox";   NAME="Gruvbox Dark"       ;;
    6) THEME="nord";      NAME="Nord"               ;;
    7) THEME="onedark";   NAME="One Dark"           ;;
    8) THEME="solarized"; NAME="Solarized Dark"     ;;
    *) THEME="mocha";     NAME="Catppuccin Mocha"   ;;
esac

# ── Transparency ──────────────────────────────────────────────────
echo
echo "Enable window transparency?"
echo "  y = Yes (95% opacity)"
echo "  n = No  (solid background)"
read -rp " (y/n) [n]: " transparency
transparency=${transparency:-n}
[[ $transparency =~ ^[Yy] ]] && OPACITY=0.95 || OPACITY=1.0

# ── Font size ─────────────────────────────────────────────────────
# FIX #1 – bc is now guaranteed to be present (ensure_bc above).
#           Original broken logic: `bc -l || echo "1"` made the guard
#           always true when bc was missing, rejecting every valid input.
echo
echo "Font size?"
while true; do
    read -rp " [default 12.0]: " font_size
    font_size=${font_size:-12.0}

    # Must look like a positive decimal number
    if [[ ! $font_size =~ ^[0-9]*\.?[0-9]+$ ]]; then
        error "Invalid font size. Please enter a number between 1.0 and 100.0"
        continue
    fi

    # bc is guaranteed available after ensure_bc()
    if (( $(echo "$font_size < 1.0 || $font_size > 100.0" | bc -l) == 1 )); then
        error "Font size must be between 1.0 and 100.0"
        continue
    fi

    break
done

# ─────────────────────────────────────────────────────────────────
# BACKUP
# ─────────────────────────────────────────────────────────────────
if [[ -f "$CONFIG_FILE" ]]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    success "Backed up existing config"
fi

# ─────────────────────────────────────────────────────────────────
# BUILD CONFIG  (everything goes into TEMP_CONFIG first)
# FIX #3 – GPU renderer was originally appended directly to $CONFIG_FILE
#   BEFORE the temp-file copy, so it was silently overwritten and lost.
#   That block has since been removed entirely: [renderer] / backend is NOT
#   a valid Alacritty config key (causes "Unused config key: renderer").
#   Alacritty selects its own OpenGL backend automatically at runtime.
# FIX #4 – Removed the `sed -i 's/value = 1.0/value = 0.95/'` block that
#   ran against $CONFIG_FILE (which didn't exist yet at that point) and
#   matched nothing anyway since the key is `opacity`, not `value`.
#   Opacity is handled correctly by expanding $OPACITY in the heredoc.
# FIX #7 – detect_os / get_pkg_manager were defined mid-script after the
#   summary banner in the original. All functions are now defined up-front.
# ─────────────────────────────────────────────────────────────────
TEMP_CONFIG=$(mktemp)
# FIX #8 – trap only removes the temp file; we copy to a stable path before
#   any error-exit so the user can inspect the generated (but invalid) config.
trap 'rm -f "$TEMP_CONFIG"' EXIT

# ── Base config ───────────────────────────────────────────────────
cat > "$TEMP_CONFIG" << EOF
# Alacritty Terminal Configuration
# Theme    : $NAME
# GPU      : $GPU_TYPE
# Renderer : $RENDERER
# Generated: $(date +"%Y-%m-%d %H:%M:%S")

[window]
opacity      = $OPACITY
padding      = { x = 8, y = 8 }
decorations  = "full"
startup_mode = "Windowed"

[window.dimensions]
columns = 120
lines   = 30

[window.class]
instance = "Alacritty"
general  = "Alacritty"

[scrolling]
history    = 10000
multiplier = 3

[font]
normal      = { family = "JetBrainsMono Nerd Font", style = "Medium" }
bold        = { family = "JetBrainsMono Nerd Font", style = "Bold" }
italic      = { family = "JetBrainsMono Nerd Font", style = "Italic" }
bold_italic = { family = "JetBrainsMono Nerd Font", style = "Bold Italic" }
size = $font_size

[font.offset]
x = 0
y = 0

[font.glyph_offset]
x = 0
y = 0

[cursor]
style            = "Block"
unfocused_hollow = true

[selection]
semantic_escape_chars = ",│\`|:\"' ()[]{}<>\t"
save_to_clipboard     = true

[colors]
EOF

# ── Theme colours ─────────────────────────────────────────────────
case $THEME in
    latte)
        cat >> "$TEMP_CONFIG" << 'EOF'
# Catppuccin Latte
primary        = { background = "#eff1f5", foreground = "#4c4f69" }
cursor         = { text = "#eff1f5", cursor = "#dc8a78" }
vi_mode_cursor = { text = "#eff1f5", cursor = "#dc8a78" }
selection      = { text = "#eff1f5", background = "#dc8a78" }
normal  = { black = "#5c5f77", red = "#d20f39", green = "#40a02b", yellow = "#df8e1d", blue = "#1e66f5", magenta = "#ea76cb", cyan = "#179299", white = "#acb0be" }
bright  = { black = "#6c6f85", red = "#d20f39", green = "#40a02b", yellow = "#df8e1d", blue = "#1e66f5", magenta = "#ea76cb", cyan = "#179299", white = "#bcc0cc" }
EOF
        ;;
    tokyo)
        cat >> "$TEMP_CONFIG" << 'EOF'
# Tokyo Night
primary        = { background = "#1a1b26", foreground = "#c0caf5" }
cursor         = { text = "#1a1b26", cursor = "#c0caf5" }
vi_mode_cursor = { text = "#1a1b26", cursor = "#c0caf5" }
selection      = { text = "#1a1b26", background = "#c0caf5" }
normal  = { black = "#15161e", red = "#f7768e", green = "#9ece6a", yellow = "#e0af68", blue = "#7aa2f7", magenta = "#bb9af7", cyan = "#7dcfff", white = "#a9b1d6" }
bright  = { black = "#414868", red = "#f7768e", green = "#9ece6a", yellow = "#e0af68", blue = "#7aa2f7", magenta = "#bb9af7", cyan = "#7dcfff", white = "#c0caf5" }
EOF
        ;;
    dracula)
        cat >> "$TEMP_CONFIG" << 'EOF'
# Dracula
primary        = { background = "#282a36", foreground = "#f8f8f2" }
cursor         = { text = "#282a36", cursor = "#f8f8f2" }
vi_mode_cursor = { text = "#282a36", cursor = "#f8f8f2" }
selection      = { text = "#282a36", background = "#f8f8f2" }
normal  = { black = "#000000", red = "#ff5555", green = "#50fa7b", yellow = "#f1fa8c", blue = "#bd93f9", magenta = "#ff79c6", cyan = "#8be9fd", white = "#bbbbbb" }
bright  = { black = "#555555", red = "#ff5555", green = "#50fa7b", yellow = "#f1fa8c", blue = "#bd93f9", magenta = "#ff79c6", cyan = "#8be9fd", white = "#ffffff" }
EOF
        ;;
    gruvbox)
        cat >> "$TEMP_CONFIG" << 'EOF'
# Gruvbox Dark
primary        = { background = "#282828", foreground = "#ebdbb2" }
cursor         = { text = "#282828", cursor = "#ebdbb2" }
vi_mode_cursor = { text = "#282828", cursor = "#ebdbb2" }
selection      = { text = "#282828", background = "#ebdbb2" }
normal  = { black = "#282828", red = "#cc241d", green = "#98971a", yellow = "#d79921", blue = "#458588", magenta = "#b16286", cyan = "#689d6a", white = "#a89984" }
bright  = { black = "#928374", red = "#fb4934", green = "#b8bb26", yellow = "#fabd2f", blue = "#83a598", magenta = "#d3869b", cyan = "#8ec07c", white = "#ebdbb2" }
EOF
        ;;
    nord)
        cat >> "$TEMP_CONFIG" << 'EOF'
# Nord
primary        = { background = "#2e3440", foreground = "#d8dee9" }
cursor         = { text = "#2e3440", cursor = "#d8dee9" }
vi_mode_cursor = { text = "#2e3440", cursor = "#d8dee9" }
selection      = { text = "#2e3440", background = "#d8dee9" }
normal  = { black = "#3b4252", red = "#bf616a", green = "#a3be8c", yellow = "#ebcb8b", blue = "#81a1c1", magenta = "#b48ead", cyan = "#88c0d0", white = "#e5e9f0" }
bright  = { black = "#4c566a", red = "#bf616a", green = "#a3be8c", yellow = "#ebcb8b", blue = "#81a1c1", magenta = "#b48ead", cyan = "#8fbcbb", white = "#eceff4" }
EOF
        ;;
    onedark)
        cat >> "$TEMP_CONFIG" << 'EOF'
# One Dark
primary        = { background = "#282c34", foreground = "#abb2bf" }
cursor         = { text = "#282c34", cursor = "#abb2bf" }
vi_mode_cursor = { text = "#282c34", cursor = "#abb2bf" }
selection      = { text = "#282c34", background = "#abb2bf" }
normal  = { black = "#282c34", red = "#e06c75", green = "#98c379", yellow = "#e5c07b", blue = "#61afef", magenta = "#c678dd", cyan = "#56b6c2", white = "#abb2bf" }
bright  = { black = "#5c6370", red = "#e06c75", green = "#98c379", yellow = "#e5c07b", blue = "#61afef", magenta = "#c678dd", cyan = "#56b6c2", white = "#ffffff" }
EOF
        ;;
    solarized)
        cat >> "$TEMP_CONFIG" << 'EOF'
# Solarized Dark
primary        = { background = "#002b36", foreground = "#839496" }
cursor         = { text = "#002b36", cursor = "#839496" }
vi_mode_cursor = { text = "#002b36", cursor = "#839496" }
selection      = { text = "#002b36", background = "#839496" }
normal  = { black = "#073642", red = "#dc322f", green = "#859900", yellow = "#b58900", blue = "#268bd2", magenta = "#d33682", cyan = "#2aa198", white = "#eee8d5" }
bright  = { black = "#002b36", red = "#cb4b16", green = "#586e75", yellow = "#657b83", blue = "#839496", magenta = "#6c71c4", cyan = "#93a1a1", white = "#fdf6e3" }
EOF
        ;;
    *)
        # Catppuccin Mocha (default)
        cat >> "$TEMP_CONFIG" << 'EOF'
# Catppuccin Mocha
primary        = { background = "#1e1e2e", foreground = "#cdd6f4" }
cursor         = { text = "#1e1e2e", cursor = "#f5e0dc" }
vi_mode_cursor = { text = "#1e1e2e", cursor = "#f5e0dc" }
selection      = { text = "#1e1e2e", background = "#f5e0dc" }
normal  = { black = "#45475a", red = "#f38ba8", green = "#a6e3a1", yellow = "#f9e2af", blue = "#89b4fa", magenta = "#f5c2e7", cyan = "#94e2d5", white = "#bac2de" }
bright  = { black = "#585b70", red = "#f38ba8", green = "#a6e3a1", yellow = "#f9e2af", blue = "#89b4fa", magenta = "#f5c2e7", cyan = "#94e2d5", white = "#a6adc8" }
EOF
        ;;
esac

# ── Remaining settings (all written to TEMP_CONFIG) ─────────────
cat >> "$TEMP_CONFIG" << EOF

[general]
live_config_reload = true

[bell]
animation = "EaseOutExpo"
duration  = 0
color     = "#ffffff"

[terminal]
osc52 = "CopyPaste"

[mouse]
hide_when_typing = false

[keyboard]
bindings = [
  { key = "V",        mods = "Control|Shift", action = "Paste" },
  { key = "C",        mods = "Control|Shift", action = "Copy" },
  { key = "Plus",     mods = "Control",       action = "IncreaseFontSize" },
  { key = "Minus",    mods = "Control",       action = "DecreaseFontSize" },
  { key = "Key0",     mods = "Control",       action = "ResetFontSize" },
  { key = "PageUp",   mods = "Shift",         action = "ScrollPageUp" },
  { key = "PageDown", mods = "Shift",         action = "ScrollPageDown" },
  { key = "Home",     mods = "Shift",         action = "ScrollToTop" },
  { key = "End",      mods = "Shift",         action = "ScrollToBottom" },
]

# ── GPU info (informational only – Alacritty manages its own renderer) ──
# Detected GPU : $GPU_TYPE
# Driver       : ${NV_DRIVER:-n/a}
# Session      : ${NV_SESSION:-n/a}
#
# NOTE: [renderer] is NOT a valid Alacritty config key and was removed to
# prevent the "Unused config key: renderer" warning. Alacritty selects its
# OpenGL backend (glsl3 / gles2 / Metal / etc.) automatically at runtime.
EOF

# ─────────────────────────────────────────────────────────────────
# VALIDATE  (python3 tomllib / tomli, or structural check)
# ─────────────────────────────────────────────────────────────────
echo
info "Validating generated configuration…"

CONFIG_VALID=true

if command -v python3 >/dev/null 2>&1; then
    if python3 - "$TEMP_CONFIG" << 'PYEOF'
import sys
path = sys.argv[1]
try:
    import tomllib
    with open(path, "rb") as f:
        tomllib.load(f)
except ImportError:
    try:
        import tomli
        with open(path, "rb") as f:
            tomli.load(f)
    except ImportError:
        # No TOML library – basic structural check
        with open(path) as f:
            content = f.read()
        if not (content.strip() and ("[" in content or "=" in content)):
            sys.exit(1)
except Exception:
    sys.exit(1)
PYEOF
    then
        success "Config validation passed!"
    else
        error "Config validation failed!"
        CONFIG_VALID=false
    fi
else
    warn "python3 not found – skipping TOML validation."
fi

# ─────────────────────────────────────────────────────────────────
# INSTALL
# FIX #5 – "Installation Complete!" banner was printed BEFORE
#   validation and install in the original. Now it only appears
#   after a confirmed successful write to disk.
# ─────────────────────────────────────────────────────────────────
if [[ "$CONFIG_VALID" == true ]]; then
    cp "$TEMP_CONFIG" "$CONFIG_FILE"
    success "Config written to: ~/.config/alacritty/alacritty.toml"
else
    echo
    warn "The generated config may contain syntax errors."
    read -rp "Install it anyway? (y/N): " install_anyway
    if [[ ${install_anyway:-n} =~ ^[Yy]$ ]]; then
        cp "$TEMP_CONFIG" "$CONFIG_FILE"
        warn "Config installed with validation warnings."
    else
        # FIX #8 – Save to a stable path before the EXIT trap deletes TEMP_CONFIG.
        SAVED="$CONFIG_DIR/alacritty.toml.generated"
        cp "$TEMP_CONFIG" "$SAVED"
        error "Config NOT installed."
        info  "Generated (uninstalled) config saved to: $SAVED"
        info  "Fix any issues then: cp $SAVED $CONFIG_FILE"
        exit 1
    fi
fi

# ─────────────────────────────────────────────────────────────────
# SUMMARY  (FIX #5 – only reached after successful install)
# ─────────────────────────────────────────────────────────────────
echo
echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║                  Installation Complete!                  ║${RESET}"
echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${RESET}"
echo
echo -e "   Theme        : ${BOLD}$NAME${RESET}"
echo -e "   Transparency : $([[ $transparency =~ ^[Yy] ]] && echo "${BOLD}ON (95%)${RESET}" || echo "OFF")"
echo -e "   Font size    : ${BOLD}$font_size${RESET}"
echo -e "   GPU          : ${BOLD}$GPU_TYPE${RESET} (renderer auto-selected by Alacritty at runtime)"
if [[ "$GPU_TYPE" == "NVIDIA" ]]; then
    echo -e "   Driver       : ${BOLD}${NV_DRIVER}${RESET}"
    echo -e "   Session      : ${BOLD}${NV_SESSION}${RESET}"
fi
echo
echo "➜  Restart Alacritty to apply the new configuration."
echo

# NVIDIA post-install notes
if [[ "$GPU_TYPE" == "NVIDIA" && -n "$NV_ENV_HINTS" ]]; then
    echo -e "${YELLOW}NVIDIA notes:${RESET}"
    echo -e "$NV_ENV_HINTS"
fi

# Font install hint based on distro
PM=$(get_pkg_manager "$OS_ID")
case "$PM" in
    pacman) FONT_CMD="sudo pacman -S ttf-jetbrains-mono-nerd" ;;
    apt)    FONT_CMD="sudo apt-get install fonts-jetbrains-mono" ;;
    dnf)    FONT_CMD="sudo dnf install jetbrains-mono-fonts" ;;
    brew)   FONT_CMD="brew install --cask font-jetbrains-mono-nerd-font" ;;
    *)      FONT_CMD="# install 'JetBrainsMono Nerd Font' via your package manager or https://nerdfonts.com" ;;
esac
info "To install the configured font (JetBrainsMono Nerd Font):"
echo "    $FONT_CMD"
echo

exit 0
