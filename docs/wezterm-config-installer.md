# WezTerm Ultimate Installer – README.md

```
██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
 ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
                  Ultimate Config Installer • 2025
```

The **WezTerm Ultimate Installer** is a single, zero-error script that sets up a beautiful, modern, and fully functional `wezterm.lua` configuration — **whether you’re using the native version or Flatpak**.

It solves the #1 pain point of Flatpak WezTerm: your config is hidden deep inside a sandbox — this script **automatically symlinks** `~/.config/wezterm/` → real Flatpak location so you **always edit the right file**.

## Features

- Works perfectly with **Flatpak** and **native** WezTerm
- Automatically detects your installation type
- Creates a **symlink** so `~/.config/wezterm/wezterm.lua` is always valid
- Interactive setup with the best themes:
  - Catppuccin Mocha (dark) — default & most popular
  - Catppuccin Latte (light)
  - Tokyo Night
  - Dracula
  - Gruvbox Dark
- Smart KDE Plasma 6 title bar detection (recommended ON)
- JetBrainsMono Nerd Font + perfect spacing
- Full tmux-style leader key (`Ctrl+a`) with:
  - Pane splitting (`-` and `|`)
  - Vim-style pane navigation (`h j k l`)
  - Tab switching (`1–9`)
- Fancy tab bar + beautiful colors
- Backs up your old config automatically
- Launches WezTerm when done

## One-Command Installation

```bash
curl -fsSL https://raw.githubusercontent.com/grok/wezterm-ultimate/main/install.sh | bash
```

Or download and run:

```bash
wget https://raw.githubusercontent.com/grok/wezterm-ultimate/main/install.sh -O wezterm-install.sh
chmod +x wezterm-install.sh
./wezterm-install.sh
```

## What It Does (Step by Step)

1. Detects if you’re using **Flatpak** or **native** WezTerm
2. Creates the correct config directory
3. For Flatpak: creates a symlink  
   `~/.config/wezterm → ~/.var/app/org.wezfurlong.wezterm/config/wezterm`
4. Backs up your current config (with timestamp)
5. Writes a clean, beautiful `wezterm.lua` with your chosen theme
6. Launches WezTerm so you see the result instantly

## Your Config Will Always Be Here

```
~/.config/wezterm/wezterm.lua
```

Even on Flatpak — this is now the **real, working file**.

No more hunting through sandbox folders.

## Supported Themes

| Choice | Theme               | Vibe             |
|--------|---------------------|------------------|
| 1      | Catppuccin Mocha    | Dark, cozy, king |
| 2      | Catppuccin Latte    | Light, clean     |
| 3      | Tokyo Night         | Deep purple      |
| 4      | Dracula             | Classic blood    |
| 5      | Gruvbox Dark        | Retro warmth     |

## Recommended Font

Install this for best results:

```bash
# Debian/Ubuntu
sudo apt install fonts-jetbrains-mono

# Or use Nerd Font version (recommended)
# https://www.nerdfonts.com/font-downloads → JetBrainsMono
```

## Troubleshooting

| Problem                                    | Solution                                                                 |
|--------------------------------------------|--------------------------------------------------------------------------|
| Config not applying in Flatpak             | Run the script again — it will fix the symlink automatically            |
| `wezterm.lua` not found                    | You probably used Flatpak before. Run this script — it fixes everything |
| Font looks broken (tofu characters)        | Install **JetBrainsMono Nerd Font** from nerdfonts.com                   |
| Title bar missing on KDE Plasma 6          | Choose `y` when asked — script enables it correctly                      |
| Script says “Flatpak not detected”         | Make sure you launched WezTerm at least once after installing Flatpak   |
| Want to change theme later                 | Just run the script again — it overwrites with backup                   |

## Uninstall / Reset

To remove the symlink and go back to default:

```bash
rm -rf ~/.config/wezterm
# Flatpak will recreate its own config next launch
```

## Author

Made with passion by **you** and **Grok** in 2025.

> “Because your terminal deserves to be as beautiful as your soul.”

Enjoy the ultimate WezTerm experience — forever.
