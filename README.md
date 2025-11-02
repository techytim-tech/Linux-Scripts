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

### 🔄 update-system.sh

A beautiful, universal Linux system update script with a modern Catppuccin dark theme interface.

#### Features

- ✨ **Beautiful Catppuccin Mocha Theme** - Modern, eye-pleasing terminal interface
- 🐧 **Multi-Distribution Support** - Works on Ubuntu, Debian, Arch Linux, Fedora, and openSUSE Tumbleweed
- 🚀 **Smart Package Manager Detection** - Automatically detects and uses apt-fast if available on Debian/Ubuntu systems
- 📊 **Clear Visual Tables** - Shows system information and available updates in organized tables
- 🔐 **Smart Permission Handling** - Detects if running as root or regular user
- ⚡ **Interactive Prompts** - Clear y/q prompts for user confirmation before upgrading
- 🧹 **Automatic Cleanup** - Removes unnecessary packages and cleans cache after updates
- 📋 **Detailed Update Summary** - Shows all available updates before proceeding
- 🔔 **Reboot Notification** - Alerts you if a system reboot is required

#### Supported Distributions

| Distribution | Package Manager | Status |
|--------------|----------------|--------|
| Ubuntu | APT / APT-Fast | ✅ Supported |
| Debian | APT / APT-Fast | ✅ Supported |
| Arch Linux | Pacman | ✅ Supported |
| Manjaro | Pacman | ✅ Supported |
| Fedora | DNF | ✅ Supported |
| openSUSE Tumbleweed | Zypper | ✅ Supported |
| openSUSE Leap | Zypper | ✅ Supported |

#### Usage

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/techytim-tech/Linux-Scripts/main/update-system.sh
   ```

2. **Make it executable:**
   ```bash
   chmod +x update-system.sh
   ```

3. **Run the script:**
   ```bash
   ./update-system.sh
   ```

#### How It Works

1. **Detects your operating system** automatically
2. **Shows clear instructions** of what the script will do
3. **Displays system information** in a beautiful table format
4. **Checks for available updates** and lists them in a table
5. **Asks for confirmation** with clear y/q options
6. **Prompts for sudo password** (if not running as root) only when you confirm
7. **Installs all updates** with live progress output
8. **Cleans up** unnecessary packages and cache
9. **Notifies you** if a system reboot is required

#### Screenshots

The script features:
- Color-coded status messages (success in green, warnings in yellow, errors in red)
- Beautiful bordered boxes for important prompts
- Live update progress with highlighted package operations
- Clean, organized table layouts for information display

#### Requirements

- Bash shell
- sudo privileges (unless running as root)
- Internet connection
- One of the supported Linux distributions

#### APT-Fast Support

On Ubuntu and Debian systems, the script automatically detects if `apt-fast` is installed and uses it for faster parallel downloads. If not installed, it seamlessly falls back to regular `apt`.

To install apt-fast:
```bash
sudo add-apt-repository ppa:apt-fast/stable
sudo apt update
sudo apt install apt-fast
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