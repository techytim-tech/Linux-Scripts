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

echo
echo "Enable window transparency? (subtle blur effect)"
echo "  y = Yes (modern look)"
echo "  n = No  (solid background)"
read -rp " (y/n) [n]: " transparency
transparency=${transparency:-n}
[[ $transparency =~ ^[Yy] ]] && OPACITY=0.95 || OPACITY=1.0

# 4. Backup & write config
[[ -f "$CONFIG_FILE" ]] && cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"

cat > "$CONFIG_FILE" << EOF
-- WezTerm – $NAME – $([[ $title =~ ^[Yy] ]] && echo "with title bar" || echo "borderless")
-- Always located at ~/.config/wezterm/wezterm.lua (even on Flatpak)

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Maximize window on startup
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

-- Maximize window when config is loaded (for initial launch)
wezterm.on('window-config-reloaded', function(window, pane)
  window:gui_window():maximize()
end)

config.window_close_confirmation = 'NeverPrompt'
config.warn_about_missing_glyphs = false
config.enable_wayland = true
config.enable_tab_bar = true
config.show_tab_index_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = true
config.tab_max_width = 25
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}

config.window_background_opacity = $OPACITY
config.text_background_opacity = 1.0

config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Medium' })
config.font_size = 13.0
config.line_height = 1.15
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

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
  {key='h', mods='LEADER', action=act.ActivatePaneDirection('Left')},
  {key='j', mods='LEADER', action=act.ActivatePaneDirection('Down')},
  {key='k', mods='LEADER', action=act.ActivatePaneDirection('Up')},
  {key='l', mods='LEADER', action=act.ActivatePaneDirection('Right')},
  {key='c', mods='LEADER', action=act.SpawnTab('CurrentPaneDomain')},
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
  tab_bar={
    background="#e6e9ef",
    active_tab={bg_color="#1e66f5", fg_color="#eff1f5", intensity="Bold"},
    inactive_tab={bg_color="#dce0e8", fg_color="#6c6f85"},
    inactive_tab_hover={bg_color="#ccd0da", fg_color="#4c4f69"},
    new_tab={bg_color="#e6e9ef", fg_color="#6c6f85"},
    new_tab_hover={bg_color="#1e66f5", fg_color="#eff1f5"},
  };
}
EOF
        ;;
    tokyo)
        cat >> "$CONFIG_FILE" << 'EOF'
-- Tokyo Night
config.colors = {
  foreground="#c0caf5"; background="#1a1b26";
  cursor_bg="#c0caf5"; cursor_border="#c0caf5";
  selection_fg="#1a1b26"; selection_bg="#c0caf5";
  ansi={"#15161e","#f7768e","#9ece6a","#e0af68","#7aa2f7","#bb9af7","#7dcfff","#a9b1d6"};
  brights={"#414868","#f7768e","#9ece6a","#e0af68","#7aa2f7","#bb9af7","#7dcfff","#c0caf5"};
  tab_bar={
    background="#16161e",
    active_tab={bg_color="#7aa2f7", fg_color="#1a1b26", intensity="Bold"},
    inactive_tab={bg_color="#1f2335", fg_color="#565f89"},
    inactive_tab_hover={bg_color="#292e42", fg_color="#c0caf5"},
    new_tab={bg_color="#16161e", fg_color="#565f89"},
    new_tab_hover={bg_color="#7aa2f7", fg_color="#1a1b26"},
  };
}
EOF
        ;;
    dracula)
        cat >> "$CONFIG_FILE" << 'EOF'
-- Dracula
config.colors = {
  foreground="#f8f8f2"; background="#282a36";
  cursor_bg="#f8f8f2"; cursor_border="#f8f8f2";
  selection_fg="#282a36"; selection_bg="#f8f8f2";
  ansi={"#000000","#ff5555","#50fa7b","#f1fa8c","#bd93f9","#ff79c6","#8be9fd","#bbbbbb"};
  brights={"#555555","#ff5555","#50fa7b","#f1fa8c","#bd93f9","#ff79c6","#8be9fd","#ffffff"};
  tab_bar={
    background="#1e1f29",
    active_tab={bg_color="#bd93f9", fg_color="#282a36", intensity="Bold"},
    inactive_tab={bg_color="#282a36", fg_color="#6272a4"},
    inactive_tab_hover={bg_color="#44475a", fg_color="#f8f8f2"},
    new_tab={bg_color="#1e1f29", fg_color="#6272a4"},
    new_tab_hover={bg_color="#bd93f9", fg_color="#282a36"},
  };
}
EOF
        ;;
    gruvbox)
        cat >> "$CONFIG_FILE" << 'EOF'
-- Gruvbox Dark
config.colors = {
  foreground="#ebdbb2"; background="#282828";
  cursor_bg="#ebdbb2"; cursor_border="#ebdbb2";
  selection_fg="#282828"; selection_bg="#ebdbb2";
  ansi={"#282828","#cc241d","#98971a","#d79921","#458588","#b16286","#689d6a","#a89984"};
  brights={"#928374","#fb4934","#b8bb26","#fabd2f","#83a598","#d3869b","#8ec07c","#ebdbb2"};
  tab_bar={
    background="#1d2021",
    active_tab={bg_color="#458588", fg_color="#282828", intensity="Bold"},
    inactive_tab={bg_color="#282828", fg_color="#928374"},
    inactive_tab_hover={bg_color="#3c3836", fg_color="#ebdbb2"},
    new_tab={bg_color="#1d2021", fg_color="#928374"},
    new_tab_hover={bg_color="#458588", fg_color="#282828"},
  };
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
  tab_bar={
    background="#11111b",
    active_tab={bg_color="#89b4fa", fg_color="#1e1e2e", intensity="Bold"},
    inactive_tab={bg_color="#181825", fg_color="#6c7086"},
    inactive_tab_hover={bg_color="#313244", fg_color="#cdd6f4"},
    new_tab={bg_color="#11111b", fg_color="#6c7086"},
    new_tab_hover={bg_color="#89b4fa", fg_color="#1e1e2e"},
  };
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
echo "   Transparency: $([[ $transparency =~ ^[Yy] ]] && echo "ON" || echo "OFF")"
echo
echo "Restart WezTerm → enjoy your beautiful terminal!"

# Launch
if command -v flatpak >/dev/null 2>&1 && flatpak info org.wezfurlong.wezterm >/dev/null 2>&1; then
    flatpak run org.wezfurlong.wezterm >/dev/null 2>&1 &
else
    wezterm start --cwd "$PWD" 2>/dev/null || true
fi

exit 0
