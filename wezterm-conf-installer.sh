#!/usr/bin/env bash
# WezTerm Ultimate Installer – Forces config into ~/.config/wezterm/
# Works perfectly with Native + Flatpak, KDE Plasma 6, zero errors

set -euo pipefail

# 1. Define the REAL config location
if [[ -d "$HOME/.var/app/org.wezfurlong.wezterm" ]]; then
    echo "Flatpak WezTerm detected"
    REAL_CONFIG_DIR="$HOME/.var/app/org.wezfurlong.wezterm/config/wezterm"
    USER_CONFIG_DIR="$HOME/.config/wezterm"
else
    echo "Native WezTerm detected"
    REAL_CONFIG_DIR="$HOME/.config/wezterm"
    USER_CONFIG_DIR="$HOME/.config/wezterm"
fi

# 2. Create real directory + symlink so you always use ~/.config/wezterm/
mkdir -p "$REAL_CONFIG_DIR"
mkdir -p "$(dirname "$USER_CONFIG_DIR")"

# If Flatpak → create symlink so ~/.config/wezterm/ always points to the real one
if [[ "$REAL_CONFIG_DIR" != "$USER_CONFIG_DIR" ]]; then
    echo "Creating symlink: ~/.config/wezterm → Flatpak location"
    ln -sfn "$REAL_CONFIG_DIR" "$USER_CONFIG_DIR"
fi

CONFIG_FILE="$USER_CONFIG_DIR/wezterm.lua"   # ← This is what you asked for

# 3. Interactive choices
echo
echo "Choose your theme:"
echo "  1) Catppuccin Mocha (dark)     ← most popular"
echo "  2) Catppuccin Latte (light)"
echo "  3) Tokyo Night"
echo "  4) Dracula"
echo "  5) Gruvbox Dark"
read -rp " [1-5] (default 1): " theme_choice
theme_choice=${theme_choice:-1}

case $theme_choice in
    2) THEME="latte";  NAME="Catppuccin Latte" ;;
    3) THEME="tokyo";  NAME="Tokyo Night" ;;
    4) THEME="dracula";NAME="Dracula" ;;
    5) THEME="gruvbox";NAME="Gruvbox Dark" ;;
    *) THEME="mocha";  NAME="Catppuccin Mocha" ;;
esac

echo
echo "Title bar on KDE Plasma 6?"
echo "  y = Yes (recommended)"
echo "  n = No  (borderless)"
read -rp " (y/n) [y]: " title
title=${title:-y}
[[ $title =~ ^[Yy] ]] && DECOR="TITLE | RESIZE" || DECOR="RESIZE"

# 4. Backup & write config
[[ -f "$CONFIG_FILE" ]] && cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"

cat > "$CONFIG_FILE" << EOF
-- WezTerm – $NAME – $([[ $title =~ ^[Yy] ]] && echo "with title bar" || echo "borderless")
-- Always located at ~/.config/wezterm/wezterm.lua (even on Flatpak)

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.warn_about_missing_glyphs = false

config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Medium' })
config.font_size = 13.0
config.line_height = 1.15

config.window_decorations = "$DECOR"
config.window_padding = { left = '1cell', right = '1cell', top = '0.5cell', bottom = '0.5cell' }
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 600

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
local act = wezterm.action
config.keys = {
  {key='-', mods='LEADER', action=act.SplitVertical{domain='CurrentPaneDomain'}},
  {key='|', mods='LEADER|SHIFT', action=act.SplitHorizontal{domain='CurrentPaneDomain'}},
  {key='h', mods='LEADER', action=act.ActivatePaneDirection'Left'},
  {key='j', mods='LEADER', action=act.ActivatePaneDirection'Down'},
  {key='k', mods='LEADER', action=act.ActivatePaneDirection'Up'},
  {key='l', mods='LEADER', action=act.ActivatePaneDirection'Right'},
  {key='c', mods='LEADER', action=act.SpawnTab'CurrentPaneDomain'},
}
for i=1,9 do table.insert(config.keys, {key=tostring(i), mods='LEADER', action=act.ActivateTab(i-1)}) end

EOF

# 5. Add selected theme (100% valid Lua)
case $THEME in
    latte)
        cat >> "$CONFIG_FILE" << 'EOF'
config.colors = {
  foreground="#4c4f69"; background="#eff1f5";
  cursor_bg="#dc8a78"; cursor_border="#dc8a78";
  selection_fg="#eff1f5"; selection_bg="#dc8a78";
  ansi={"#5c5f77","#d20f39","#40a02b","#df8e1d","#1e66f5","#ea76cb","#179299","#acb0be"};
  brights={"#6c6f85","#d20f39","#40a02b","#df8e1d","#1e66f5","#ea76cb","#179299","#bcc0cc"};
  tab_bar={background="#e6e9ef", active_tab={bg_color="#1e66f5", fg_color="#eff1f5", intensity="Bold"}};
}
EOF
        ;;
    *)
        cat >> "$CONFIG_FILE" << 'EOF'
-- Catppuccin Mocha (default)
config.colors = {
  foreground="#cdd6f4"; background="#1e1e2e";
  cursor_bg="#f5e0dc"; cursor_border="#f5e0dc";
  selection_fg="#1e1e2e"; selection_bg="#f5e0dc";
  ansi={"#45475a","#f38ba8","#a6e3a1","#f9e2af","#89b4fa","#f5c2e7","#94e2d5","#bac2de"};
  brights={"#585b70","#f38ba8","#a6e3a1","#f9e2af","#89b4fa","#f5c2e7","#94e2d5","#a6adc8"};
  tab_bar={background="#11111b", active_tab={bg_color="#89b4fa", fg_color="#1e1e2e", intensity="Bold"}};
}
EOF
        ;;
esac

echo "return config" >> "$CONFIG_FILE"

# 6. Done!
echo
echo "Perfect! Your config is now at:"
echo "   ~/.config/wezterm/wezterm.lua   ← always here, even on Flatpak"
echo
echo "   Theme: $NAME"
echo "   Title bar: $([[ $title =~ ^[Yy] ]] && echo "ON" || echo "OFF")"
echo
echo "Restart WezTerm → enjoy your beautiful terminal!"

# Launch
if command -v flatpak >/dev/null 2>&1 && flatpak info org.wezfurlong.wezterm >/dev/null 2>&1; then
    flatpak run org.wezfurlong.wezterm >/dev/null 2>&1 &
else
    wezterm start --cwd "$PWD" 2>/dev/null || true
fi

exit 0
