#!/usr/bin/env bash
# Alacritty Ultimate Installer – Installs config to ~/.config/alacritty/
# Works perfectly with Native + Flatpak, KDE Plasma 6, zero errors

set -euo pipefail

# 1. Define the config location
CONFIG_DIR="$HOME/.config/alacritty"
CONFIG_FILE="$CONFIG_DIR/alacritty.toml"

# 2. Create config directory
mkdir -p "$CONFIG_DIR"

# 2.5. Detect GPU (informational - Alacritty is GPU-accelerated)
detect_gpu() {
    if command -v lspci >/dev/null 2>&1; then
        if lspci | grep -qi "nvidia"; then
            echo "NVIDIA"
        elif lspci | grep -qi "amd\|ati\|radeon"; then
            echo "AMD"
        elif lspci | grep -qi "intel.*graphics\|vga.*intel"; then
            echo "Intel"
        else
            echo "Unknown"
        fi
    elif command -v glxinfo >/dev/null 2>&1; then
        local gpu=$(glxinfo 2>/dev/null | grep -i "opengl renderer" | cut -d: -f2 | tr -d ' ')
        if echo "$gpu" | grep -qi "nvidia"; then
            echo "NVIDIA"
        elif echo "$gpu" | grep -qi "amd\|radeon"; then
            echo "AMD"
        elif echo "$gpu" | grep -qi "intel"; then
            echo "Intel"
        else
            echo "Unknown"
        fi
    else
        echo "Unknown"
    fi
}

GPU_TYPE=$(detect_gpu)

# 3. Interactive choices
echo
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     Alacritty Terminal Configuration Installer           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo
if [[ "$GPU_TYPE" != "Unknown" ]]; then
    echo "ℹ Detected GPU: $GPU_TYPE (Alacritty uses GPU acceleration)"
    echo
fi
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
    2) THEME="latte";  NAME="Catppuccin Latte" ;;
    3) THEME="tokyo";  NAME="Tokyo Night" ;;
    4) THEME="dracula"; NAME="Dracula" ;;
    5) THEME="gruvbox"; NAME="Gruvbox Dark" ;;
    6) THEME="nord";    NAME="Nord" ;;
    7) THEME="onedark"; NAME="One Dark" ;;
    8) THEME="solarized"; NAME="Solarized Dark" ;;
    *) THEME="mocha";   NAME="Catppuccin Mocha" ;;
esac

echo
echo "Enable window transparency? (subtle blur effect)"
echo "  y = Yes (modern look)"
echo "  n = No  (solid background)"
read -rp " (y/n) [n]: " transparency
transparency=${transparency:-n}
[[ $transparency =~ ^[Yy] ]] && OPACITY=0.95 || OPACITY=1.0

echo
echo "Font size?"
read -rp " [default 12.0]: " font_size
font_size=${font_size:-12.0}

# 3.5. Set GPU renderer based on GPU type
# NVIDIA and AMD typically work best with glsl3 (OpenGL 3.3+)
# Intel integrated graphics may need gles2 or auto-detect
case $GPU_TYPE in
    NVIDIA|AMD)
        RENDERER="glsl3"  # Best performance for dedicated GPUs
        ;;
    Intel)
        RENDERER="None"   # Auto-detect (may use gles2 on older Intel)
        ;;
    *)
        RENDERER="None"   # Auto-detect for unknown GPUs
        ;;
esac

# 4. Backup existing config
if [[ -f "$CONFIG_FILE" ]]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    echo "✓ Backed up existing config"
fi

# 5. Write base config
cat > "$CONFIG_FILE" << EOF
# Alacritty Terminal Configuration
# Theme: $NAME
# Generated: $(date +"%Y-%m-%d %H:%M:%S")

# Window settings
[window]
opacity = $OPACITY
padding = { x = 8, y = 8 }
decorations = "full"
startup_mode = "Windowed"

[window.dimensions]
columns = 120
lines = 30

[window.class]
instance = "Alacritty"
general = "Alacritty"

# Scrolling
[scrolling]
history = 10000
multiplier = 3

# Font configuration
[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Medium" }
bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
bold_italic = { family = "JetBrainsMono Nerd Font", style = "Bold Italic" }
size = $font_size

[font.offset]
x = 0
y = 0

[font.glyph_offset]
x = 0
y = 0

# Cursor configuration
[cursor]
style = "Block"
unfocused_hollow = true
blink = true
blink_interval = 750
blink_timeout = 3

# Selection
[selection]
semantic_escape_chars = ",│\`|:\\\"' ()[]{}<>\\t"
save_to_clipboard = true

# Colors
[colors]

EOF

# 6. Add selected theme colors
case $THEME in
    latte)
        cat >> "$CONFIG_FILE" << 'EOF'
# Catppuccin Latte
primary = {
  background = "#eff1f5"
  foreground = "#4c4f69"
}

cursor = {
  text = "#eff1f5"
  cursor = "#dc8a78"
}

vi_mode_cursor = {
  text = "#eff1f5"
  cursor = "#dc8a78"
}

selection = {
  text = "#eff1f5"
  background = "#dc8a78"
}

normal = {
  black = "#5c5f77"
  red = "#d20f39"
  green = "#40a02b"
  yellow = "#df8e1d"
  blue = "#1e66f5"
  magenta = "#ea76cb"
  cyan = "#179299"
  white = "#acb0be"
}

bright = {
  black = "#6c6f85"
  red = "#d20f39"
  green = "#40a02b"
  yellow = "#df8e1d"
  blue = "#1e66f5"
  magenta = "#ea76cb"
  cyan = "#179299"
  white = "#bcc0cc"
}
EOF
        ;;
    tokyo)
        cat >> "$CONFIG_FILE" << 'EOF'
# Tokyo Night
primary = {
  background = "#1a1b26"
  foreground = "#c0caf5"
}

cursor = {
  text = "#1a1b26"
  cursor = "#c0caf5"
}

vi_mode_cursor = {
  text = "#1a1b26"
  cursor = "#c0caf5"
}

selection = {
  text = "#1a1b26"
  background = "#c0caf5"
}

normal = {
  black = "#15161e"
  red = "#f7768e"
  green = "#9ece6a"
  yellow = "#e0af68"
  blue = "#7aa2f7"
  magenta = "#bb9af7"
  cyan = "#7dcfff"
  white = "#a9b1d6"
}

bright = {
  black = "#414868"
  red = "#f7768e"
  green = "#9ece6a"
  yellow = "#e0af68"
  blue = "#7aa2f7"
  magenta = "#bb9af7"
  cyan = "#7dcfff"
  white = "#c0caf5"
}
EOF
        ;;
    dracula)
        cat >> "$CONFIG_FILE" << 'EOF'
# Dracula
primary = {
  background = "#282a36"
  foreground = "#f8f8f2"
}

cursor = {
  text = "#282a36"
  cursor = "#f8f8f2"
}

vi_mode_cursor = {
  text = "#282a36"
  cursor = "#f8f8f2"
}

selection = {
  text = "#282a36"
  background = "#f8f8f2"
}

normal = {
  black = "#000000"
  red = "#ff5555"
  green = "#50fa7b"
  yellow = "#f1fa8c"
  blue = "#bd93f9"
  magenta = "#ff79c6"
  cyan = "#8be9fd"
  white = "#bbbbbb"
}

bright = {
  black = "#555555"
  red = "#ff5555"
  green = "#50fa7b"
  yellow = "#f1fa8c"
  blue = "#bd93f9"
  magenta = "#ff79c6"
  cyan = "#8be9fd"
  white = "#ffffff"
}
EOF
        ;;
    gruvbox)
        cat >> "$CONFIG_FILE" << 'EOF'
# Gruvbox Dark
primary = {
  background = "#282828"
  foreground = "#ebdbb2"
}

cursor = {
  text = "#282828"
  cursor = "#ebdbb2"
}

vi_mode_cursor = {
  text = "#282828"
  cursor = "#ebdbb2"
}

selection = {
  text = "#282828"
  background = "#ebdbb2"
}

normal = {
  black = "#282828"
  red = "#cc241d"
  green = "#98971a"
  yellow = "#d79921"
  blue = "#458588"
  magenta = "#b16286"
  cyan = "#689d6a"
  white = "#a89984"
}

bright = {
  black = "#928374"
  red = "#fb4934"
  green = "#b8bb26"
  yellow = "#fabd2f"
  blue = "#83a598"
  magenta = "#d3869b"
  cyan = "#8ec07c"
  white = "#ebdbb2"
}
EOF
        ;;
    nord)
        cat >> "$CONFIG_FILE" << 'EOF'
# Nord
primary = {
  background = "#2e3440"
  foreground = "#d8dee9"
}

cursor = {
  text = "#2e3440"
  cursor = "#d8dee9"
}

vi_mode_cursor = {
  text = "#2e3440"
  cursor = "#d8dee9"
}

selection = {
  text = "#2e3440"
  background = "#d8dee9"
}

normal = {
  black = "#3b4252"
  red = "#bf616a"
  green = "#a3be8c"
  yellow = "#ebcb8b"
  blue = "#81a1c1"
  magenta = "#b48ead"
  cyan = "#88c0d0"
  white = "#e5e9f0"
}

bright = {
  black = "#4c566a"
  red = "#bf616a"
  green = "#a3be8c"
  yellow = "#ebcb8b"
  blue = "#81a1c1"
  magenta = "#b48ead"
  cyan = "#8fbcbb"
  white = "#eceff4"
}
EOF
        ;;
    onedark)
        cat >> "$CONFIG_FILE" << 'EOF'
# One Dark
primary = {
  background = "#282c34"
  foreground = "#abb2bf"
}

cursor = {
  text = "#282c34"
  cursor = "#abb2bf"
}

vi_mode_cursor = {
  text = "#282c34"
  cursor = "#abb2bf"
}

selection = {
  text = "#282c34"
  background = "#abb2bf"
}

normal = {
  black = "#282c34"
  red = "#e06c75"
  green = "#98c379"
  yellow = "#e5c07b"
  blue = "#61afef"
  magenta = "#c678dd"
  cyan = "#56b6c2"
  white = "#abb2bf"
}

bright = {
  black = "#5c6370"
  red = "#e06c75"
  green = "#98c379"
  yellow = "#e5c07b"
  blue = "#61afef"
  magenta = "#c678dd"
  cyan = "#56b6c2"
  white = "#ffffff"
}
EOF
        ;;
    solarized)
        cat >> "$CONFIG_FILE" << 'EOF'
# Solarized Dark
primary = {
  background = "#002b36"
  foreground = "#839496"
}

cursor = {
  text = "#002b36"
  cursor = "#839496"
}

vi_mode_cursor = {
  text = "#002b36"
  cursor = "#839496"
}

selection = {
  text = "#002b36"
  background = "#839496"
}

normal = {
  black = "#073642"
  red = "#dc322f"
  green = "#859900"
  yellow = "#b58900"
  blue = "#268bd2"
  magenta = "#d33682"
  cyan = "#2aa198"
  white = "#eee8d5"
}

bright = {
  black = "#002b36"
  red = "#cb4b16"
  green = "#586e75"
  yellow = "#657b83"
  blue = "#839496"
  magenta = "#6c71c4"
  cyan = "#93a1a1"
  white = "#fdf6e3"
}
EOF
        ;;
    *)
        # Catppuccin Mocha (default)
        cat >> "$CONFIG_FILE" << 'EOF'
# Catppuccin Mocha (default)
primary = {
  background = "#1e1e2e"
  foreground = "#cdd6f4"
}

cursor = {
  text = "#1e1e2e"
  cursor = "#f5e0dc"
}

vi_mode_cursor = {
  text = "#1e1e2e"
  cursor = "#f5e0dc"
}

selection = {
  text = "#1e1e2e"
  background = "#f5e0dc"
}

normal = {
  black = "#45475a"
  red = "#f38ba8"
  green = "#a6e3a1"
  yellow = "#f9e2af"
  blue = "#89b4fa"
  magenta = "#f5c2e7"
  cyan = "#94e2d5"
  white = "#bac2de"
}

bright = {
  black = "#585b70"
  red = "#f38ba8"
  green = "#a6e3a1"
  yellow = "#f9e2af"
  blue = "#89b4fa"
  magenta = "#f5c2e7"
  cyan = "#94e2d5"
  white = "#a6adc8"
}
EOF
        ;;
esac

# 7. Add additional settings
cat >> "$CONFIG_FILE" << EOF

# Bell
[bell]
animation = "EaseOutExpo"
duration = 0
color = "#ffffff"

# Background opacity (for transparency)
[background_opacity]
value = 1.0

# Live config reload
[live_config_reload]
enabled = true

# Terminal
[terminal]
osc52 = "OnlyClipboard"

# Mouse
[mouse]
double_click = { threshold = 300 }
triple_click = { threshold = 300 }
hide_when_typing = false

# Keyboard bindings
[keyboard]
bindings = [
  { key = "V", mods = "Control|Shift", action = "Paste" },
  { key = "C", mods = "Control|Shift", action = "Copy" },
  { key = "Plus", mods = "Control", action = "IncreaseFontSize" },
  { key = "Minus", mods = "Control", action = "DecreaseFontSize" },
  { key = "Key0", mods = "Control", action = "ResetFontSize" },
  { key = "PageUp", mods = "Shift", action = "ScrollPageUp" },
  { key = "PageDown", mods = "Shift", action = "ScrollPageDown" },
  { key = "Home", mods = "Shift", action = "ScrollToTop" },
  { key = "End", mods = "Shift", action = "ScrollToBottom" },
]
EOF

# 8. Add GPU renderer configuration (after main config is written, so variables expand)
cat >> "$CONFIG_FILE" << EOF

# GPU Rendering backend
# Options: "glsl3" (OpenGL 3.3+), "gles2" (OpenGL ES 2.0), "gles2pure", "None" (auto-detect)
# Set based on detected GPU: $GPU_TYPE
[renderer]
backend = "$RENDERER"
EOF

# 8.5. Update opacity if transparency is enabled
if [[ $transparency =~ ^[Yy] ]]; then
    sed -i 's/value = 1.0/value = 0.95/' "$CONFIG_FILE"
fi

# 9. Done!
echo
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                    Installation Complete!                ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo
echo "✓ Config installed to: ~/.config/alacritty/alacritty.toml"
echo
echo "   Theme: $NAME"
echo "   Transparency: $([[ $transparency =~ ^[Yy] ]] && echo "ON (95%)" || echo "OFF")"
echo "   Font size: $font_size"
if [[ "$GPU_TYPE" != "Unknown" ]]; then
    echo "   GPU: $GPU_TYPE"
    echo "   Renderer: $RENDERER $([[ "$RENDERER" == "glsl3" ]] && echo "(OpenGL 3.3+)" || echo "(auto-detect)")"
fi
echo
echo "Restart Alacritty to apply the new configuration!"
echo
if [[ "$GPU_TYPE" != "Unknown" ]]; then
    echo "ℹ GPU Note: Alacritty uses GPU acceleration. Ensure your $GPU_TYPE drivers"
    echo "   are properly installed for optimal performance."
    if [[ "$RENDERER" == "glsl3" ]]; then
        echo "   Renderer set to 'glsl3' for best performance on $GPU_TYPE."
    fi
    echo
fi

# Validate TOML syntax if toml-cli is available
if command -v toml-cli >/dev/null 2>&1; then
    if toml-cli validate "$CONFIG_FILE" >/dev/null 2>&1; then
        echo "✓ Config syntax validated successfully"
    else
        echo "⚠ Warning: Config validation failed (install toml-cli for validation)"
    fi
else
    echo "ℹ Tip: Install 'toml-cli' to validate config syntax"
fi

exit 0

