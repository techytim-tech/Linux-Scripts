# Linux Scripts

A collection of useful scripts for Linux users to simplify system maintenance and administration tasks.

## 📥 Quick Download

```bash
git clone https://github.com/techytim-tech/Linux-Scripts.git
cd Linux-Scripts
chmod +x *.sh
```

---

## 📜 Available Scripts

### [🔄 update-system.sh](docs/update-system.md)

A beautiful, universal Linux system update script with a modern Catppuccin dark theme interface that works across multiple distributions.

**Quick Features:**
- ✨ Multi-distribution support (Ubuntu, Debian, Arch, Fedora, openSUSE)
- 🎨 Beautiful Catppuccin Mocha theme interface
- 🚀 Smart apt-fast detection for faster downloads
- 📊 Clear visual tables and interactive prompts

**[📖 Read full documentation →](docs/update-system.md)**

---

### [📦 flatpak-menu.sh](docs/flatpak-menu.md)

An interactive Flatpak manager with a Fedora-themed interface for installing and updating Flatpak applications.

**Quick Features:**
- 🎨 Beautiful Fedora-inspired blue theme interface
- 🐧 Multi-distribution support for Flatpak installation
- 📊 Interactive menu system with status monitoring
- 🔄 Easy Flatpak app updates with progress display

**[📖 Read full documentation →](docs/flatpak-menu.md)**

---

### [📥 flatpak-installer.sh](docs/flatpak-installer.md)

A curated app installer featuring 28 popular Flatpak applications with descriptions and easy installation.

**Quick Features:**
- 🎯 28 hand-picked popular applications
- 📝 Detailed descriptions for each app
- ✓ Shows which apps are already installed
- 🔄 Install, reinstall, or uninstall with ease

**[📖 Read full documentation →](docs/flatpak-installer.md)**

---

### [🗑️ flatpak-remover.sh](docs/flatpak-remover.md)

A dedicated app removal tool for managing and uninstalling Flatpak applications.

**Quick Features:**
- 📋 Lists all installed Flatpak apps
- 📊 Shows app sizes and details
- 🗑️ Remove individual apps or all at once
- 🧹 Automatic cleanup of unused dependencies

**[📖 Read full documentation →](docs/flatpak-remover.md)**

---

### [🖥️ alacritty-conf-installer.sh](docs/alacritty-config-installer.md)

The **Alacritty Ultimate Installer** is a professional, zero-error script that generates a beautiful, modern, and fully validated `alacritty.toml` configuration — **whether you're using the native version or Flatpak**.

**Quick Features:**
- ✨ Multi-distribution support (Ubuntu, Debian, Arch, Fedora, openSUSE, macOS)
- 🎨 8 beautiful color themes (Catppuccin, Tokyo Night, Dracula, Gruvbox, Nord, One Dark, Solarized)
- 📊 **GPU-optimized** renderer selection (NVIDIA/AMD/Intel detection)
- 🔍 **Built-in TOML validation** before installation
- 🛡️ **Temp-file safety** - validates before overwriting configs
- ✅ **Zero Alacritty warnings** - all deprecated keys removed

**[🖥️ Read full documentation →](docs/alacritty-config-installer.md)**

---

### [💻 wezterm-config-installer.sh](docs/wezterm-config-installer.md)

The **WezTerm Ultimate Installer** is a single, zero-error script that sets up a beautiful, modern, and fully functional `wezterm.lua` configuration 
— **whether you’re using the native version or Flatpak**.

**Quick Features:**
- ✨ Multi-distribution support (Ubuntu, Debian, Arch, Fedora, openSUSE)
- 🎨 Beautiful themeed interface
- 📊 Works perfectly with **Flatpak** and **native** WezTerm
- 🧹 Automatically detects your installation type

**[💻 Read full documentation →](docs/wezterm-config-installer.md)**

---

### [🌅 eyefest.sh](docs/eyefest.md)

Eyefest is a beautiful, fast, and intelligent terminal-based wallpaper manager for Linux that works perfectly on **KDE Plasma** (using native tools) and falls back gracefully to **feh** on all other desktops.

> ⚠️ **Note**: Eyefest is currently in **alpha** stage and may not work reliably on all systems. Use with caution and check the documentation for known issues.

**Quick Features:**
- ✨ Native KDE Plasma support (`plasma-apply-wallpaperimage`)
- 🎨 Perfect feh fallback everywhere else
- 📊 Thumbnail browser (press Enter to set)
- 🧹 Instant random wallpaper
- ✨ Background auto-changer (10 min – 2 hours) – terminal stays free

**[🌅 Read full documentation →](docs/eyefest.md)**

---


## 💡 Tips & Tricks

### Adding Convenient Aliases

Make the scripts even easier to use by adding aliases to your shell configuration. Add these lines to your `~/.bashrc`, `~/.zshrc`, or equivalent shell config file:

```bash
# Linux Scripts Aliases
alias update='~/Linux-Scripts/update-system.sh'
alias flatpak-menu='~/Linux-Scripts/flatpak-menu.sh'
alias flatpak-install='~/Linux-Scripts/flatpak-installer.sh'
alias flatpak-remove='~/Linux-Scripts/flatpak-remover.sh'
alias alacritty-config='~/Linux-Scripts/alacritty-conf-installer.sh'
alias wezterm-config='~/Linux-Scripts/wezterm-conf-installer.sh'

# Optional: Quick access to all scripts
alias linux-scripts='cd ~/Linux-Scripts && ls -la *.sh'
```

**Apply the changes:**
```bash
source ~/.bashrc   # or source ~/.zshrc
```

**Now you can simply run:**
```bash
update                    # Instead of: ~/Linux-Scripts/update-system.sh
flatpak-menu            # Instead of: ~/Linux-Scripts/flatpak-menu.sh
alacritty-config        # Instead of: ~/Linux-Scripts/alacritty-conf-installer.sh
```

### Custom Installation Path

If you installed the scripts in a different location, update the alias paths accordingly:

```bash
# Example for custom path
alias update='/opt/Linux-Scripts/update-system.sh'
alias menu='/opt/Linux-Scripts/menu.sh'
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## 📄 License

This project is open source and available under the MIT License.

## 👤 Author

Created by [techytim-tech](https://github.com/techytim-tech)

---

## 🌟 Support

If you find these scripts useful, please consider giving this repository a star ⭐
