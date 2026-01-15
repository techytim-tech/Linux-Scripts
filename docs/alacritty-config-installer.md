# 🖥️ Alacritty Ultimate Installer

The **Alacritty Ultimate Installer** is a professional, zero-error script that generates a beautiful, modern, and fully validated `alacritty.toml` configuration — **whether you're using the native version or Flatpak**.

## ✨ Features

- 🎨 **8 Beautiful Themes**: Catppuccin Mocha/Latte, Tokyo Night, Dracula, Gruvbox Dark, Nord, One Dark, Solarized Dark
- 🚀 **GPU-Optimized**: Automatic GPU detection (NVIDIA/AMD/Intel) with optimized renderer selection
- 🔍 **Built-in Validation**: TOML syntax validation before installation using Python's tomllib
- 🛡️ **Safety First**: Creates temp files and validates before overwriting your config
- ✅ **Zero Warnings**: All deprecated config keys removed for Alacritty 0.16+ compatibility
- 🎯 **Cross-Platform**: Works on Linux (all distros) and macOS
- 📦 **Flatpak Support**: Detects and works with both native and Flatpak installations

## 🚀 Quick Start

```bash
# Download and run
git clone https://github.com/techytim-tech/Linux-Scripts.git
cd Linux-Scripts
chmod +x alacritty-conf-installer.sh
./alacritty-conf-installer.sh
```

**Optional**: For enhanced TOML validation, install toml-cli:
```bash
pip3 install --user pipx
pipx ensurepath
pipx install toml-cli
```

## 🎨 Theme Preview

The installer offers 8 professionally designed themes:

1. **Catppuccin Mocha** (default) - Warm, modern dark theme
2. **Catppuccin Latte** - Clean, light theme
3. **Tokyo Night** - Popular dark theme with vibrant colors
4. **Dracula** - Classic dark theme
5. **Gruvbox Dark** - Retro green/brown color scheme
6. **Nord** - Arctic-inspired color palette
7. **One Dark** - Atom-inspired theme
8. **Solarized Dark** - Precision color scheme

## ⚙️ Configuration Options

### Window Settings
- **Dimensions**: 120x30 columns (customizable)
- **Padding**: 8px margins
- **Decorations**: Full window decorations
- **Opacity**: 95% when transparency enabled

### Font Configuration
- **Family**: JetBrains Mono Nerd Font (Medium, Bold, Italic variants)
- **Size**: Customizable (validated 1.0-100.0 range)
- **Rendering**: Optimized glyph and font offset settings

### Advanced Features
- **GPU Detection**: Automatic renderer optimization
- **OSC52 Support**: Clipboard integration
- **Keyboard Bindings**: Ctrl+Shift+C/V, Ctrl+Plus/Minus, etc.
- **Scroll Settings**: 10,000 lines history with smooth scrolling

## 🔧 Technical Details

### Validation System
The script implements a robust 3-tier validation system:

1. **Python tomllib** (Python 3.11+) - Primary validation using built-in Python library
2. **Python tomli** (fallback) - For older Python versions without tomllib
3. **Basic syntax check** - Last resort file structure validation

**Note**: For enhanced validation with `toml-cli`, you'll need to install it separately. The script will work without it but provides installation guidance.

### Safety Features
- **Automatic Backups**: Existing configs saved with timestamps
- **Temp File Processing**: Validates in isolation before installation
- **Error Recovery**: Clear error messages with installation guidance
- **User Confirmation**: Asks before installing potentially broken configs

### Installing toml-cli for Enhanced Validation

For the best experience with TOML validation, install `toml-cli` using pipx:

#### First, Install pipx (if not already installed):
```bash
# On most systems
pip3 install --user pipx
pipx ensurepath

# Or via package manager (recommended where available):
# Ubuntu/Debian: sudo apt-get install pipx
# Fedora/RHEL: sudo dnf install pipx
# Arch: sudo pacman -S python-pipx
# macOS: brew install pipx
```

#### Then Install toml-cli:
```bash
pipx install toml-cli
```

### OS-Specific Installation Options

If pipx is not available, the script provides alternative installation commands:

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y toml-cli

# Fedora/RHEL
sudo dnf install -y toml-cli || pipx install toml-cli

# Arch Linux
sudo pacman -S toml-cli

# openSUSE
pipx install toml-cli

# macOS
brew install toml-cli || pipx install toml-cli
```

**Note**: pipx creates isolated environments for Python CLI tools, avoiding dependency conflicts with your system Python installation.

## 🎯 Use Cases

- **New Alacritty Users**: Get a professional config instantly
- **Theme Switching**: Easy theme changes without manual config editing
- **System Migration**: Consistent config across multiple machines
- **GPU Optimization**: Automatic performance tuning based on hardware
- **Flatpak Users**: Seamless integration with Flatpak Alacritty

## 🔄 Updates & Compatibility

- ✅ **Alacritty 0.16+** - Fully compatible, zero warnings
- ✅ **All Linux Distros** - Ubuntu, Debian, Arch, Fedora, openSUSE, Gentoo
- ✅ **macOS Support** - Native macOS compatibility
- ✅ **Flatpak Integration** - Works with both native and Flatpak versions
- ✅ **KDE Plasma** - Optimized for KDE Plasma 6

## 📊 Performance

- **GPU-Accelerated**: Automatic renderer selection for optimal performance
- **Fast Validation**: Sub-second TOML syntax checking
- **Efficient Installation**: Minimal system impact during setup
- **Clean Configs**: Only essential, working configuration keys

## 🛠️ Troubleshooting

### Common Issues

**"pipx: command not found"**
- Install pipx first: `pip3 install --user pipx && pipx ensurepath`
- Restart your terminal or run: `source ~/.bashrc`
- Alternative: Use system package manager to install pipx

**"Config validation failed"**
- Check Python installation: `python3 --version`
- Ensure temp file permissions are correct
- Try installing toml-cli: `pipx install toml-cli`

**"No themes available"**
- Verify internet connection for theme downloads
- Check disk space for config generation

**GPU detection issues**
- Script falls back to safe defaults
- Manual GPU specification available in advanced mode

### Manual Recovery
If automatic installation fails, configs are available at:
```bash
ls -la ~/.config/alacritty/alacritty.toml*
```

## 🤝 Contributing

Found a bug or want to add a theme? Contributions welcome!

1. Fork the repository
2. Create a feature branch
3. Test thoroughly (multiple distros if possible)
4. Submit a pull request

## 📄 License

MIT License - feel free to use and modify as needed.

---

**Created with ❤️ for the Alacritty community**