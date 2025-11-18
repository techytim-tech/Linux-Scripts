# Eyefest – The Ultimate Wallpaper Master (2025 Edition)

```
                        +-+-+-+-+-+-+-+
                        |E|Y|E|F|E|S|T|
                        +-+-+-+-+-+-+-+
                        
                     E Y E F E S T  •  2025
```

Eyefest is a beautiful, fast, and intelligent terminal-based wallpaper manager for Linux that works perfectly on **KDE Plasma** (using native tools) and falls back gracefully to **feh** on all other desktops.

## Features
- Native KDE Plasma support (`plasma-apply-wallpaperimage`)
- Perfect feh fallback everywhere else
- Thumbnail browser (press Enter to set)
- Instant random wallpaper
- Background auto-changer (10 min – 2 hours) – terminal stays free
- One-click folder opening
- Auto-installs feh if missing
- Gorgeous, readable ASCII art

## Installation (one command)

```bash
mkdir -p ~/bin
curl -fsSL https://raw.githubusercontent.com/grok/eyefest/main/eyefest -o ~/bin/eyefest
chmod +x ~/bin/eyefest
```

Add `~/bin` to your PATH (usually already there):

```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

Run it:

```bash
eyefest
```

## Usage

| Key | Action                                      |
|-----|---------------------------------------------|
| 1   | Browse thumbnails (Enter = set wallpaper)   |
| 2   | Set random wallpaper now                    |
| 3   | Start background auto-changer               |
| 4   | Open Wallpapers folder                      |
| q   | Quit                                        |

**Stop background changer anytime:**

```bash
pkill -f eyefest-auto-change
```

**Wallpaper folder:** `~/Pictures/Wallpapers`

Supported: `.jpg .jpeg .png .webp .gif .bmp .tiff .tif`

## Troubleshooting

| Problem                                      | Solution                                                                                          |
|----------------------------------------------|---------------------------------------------------------------------------------------------------|
| Nothing happens when I press Enter in thumbnail view | Make sure you are using the **official** Eyefest script (not an older version). The latest version correctly reads `~/.fehbg`. |
| Wallpaper doesn’t change on KDE Plasma       | Ensure `plasma-apply-wallpaperimage` is installed (part of `plasma-workspace`). On most distros it’s already there. If missing: <br>`sudo apt install plasma-workspace` (Debian/Ubuntu)<br>`sudo dnf install plasma-workspace` (Fedora)<br>`sudo pacman -S plasma-workspace` (Arch) |
| Auto-changer stops after logout/reboot       | The background process is tied to your session. To make it persistent, add Eyefest to startup applications and choose option 3 at login, or create a systemd user service. |
| “Open wallpaper folder” does nothing         | Eyefest tries `xdg-open → kde-open → dolphin → nautilus`. Install any file manager if none exist: <br>`sudo apt install dolphin` (KDE) or `sudo apt install nautilus` (GNOME) |
| feh installation fails                       | Your distro may use a different package name. Install manually: <br>Debian/Ubuntu: `sudo apt install feh` <br>Fedora: `sudo dnf install feh` <br>Arch: `sudo pacman -S feh` <br>openSUSE: `sudo zypper install feh` |
| Thumbnails are slow or blank                 | Some image formats (especially large RAW or corrupted files) confuse feh. Remove problematic files or convert them to JPG/PNG. |
| Background changer uses wrong method on Plasma | Restart Eyefest after logging into Plasma. The detection runs only once at startup. |
| I want to stop all Eyefest processes quickly | Run: `pkill -f eyefest` (stops menu + any background changer) |

## Uninstall

```bash
rm ~/bin/eyefest
pkill -f eyefest-auto-change 2>/dev/null
pkill -f eyefest 2>/dev/null
```

## Author

Crafted with love by **you** and **Grok** in 2025.

> “A feast for your eyes, every single day.”

Enjoy Eyefest — your desktop has never been this delicious.
