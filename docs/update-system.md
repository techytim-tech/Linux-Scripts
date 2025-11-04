# update-system.sh

[⬆️ Back to Main](../README.md)

A beautiful, universal Linux system update script with a modern Catppuccin dark theme interface.

---

## 📥 Quick Download

```bash
wget https://raw.githubusercontent.com/techytim-tech/Linux-Scripts/main/update-system.sh
chmod +x update-system.sh
./update-system.sh
```

---

## 📸 Screenshot

Click to view full size:

[![update-system.sh screenshot](../screenshots/update-system-screenshot.png)](../screenshots/update-system-screenshot.png)

*The script showing system information when no updates are available*

---

## ✨ Features

- **Beautiful Catppuccin Mocha Theme** - Modern, eye-pleasing terminal interface with carefully selected colors
- **Multi-Distribution Support** - Works seamlessly on Ubuntu, Debian, Arch Linux, Fedora, and openSUSE Tumbleweed
- **Smart Package Manager Detection** - Automatically detects and uses apt-fast if available on Debian/Ubuntu systems for faster parallel downloads
- **Clear Visual Tables** - Shows system information and available updates in organized, easy-to-read tables
- **Smart Permission Handling** - Detects if running as root or regular user and adjusts prompts accordingly
- **Interactive Prompts** - Clear y/q prompts for user confirmation before making any changes
- **Automatic Cleanup** - Removes unnecessary packages and cleans cache after updates
- **Detailed Update Summary** - Shows all available updates in a table format before proceeding
- **Reboot Notification** - Alerts you if a system reboot is required after updates
- **Live Progress Display** - Real-time output showing package operations as they happen

---

## 🐧 Supported Distributions

| Distribution | Package Manager | Icon | Status |
|--------------|----------------|------|--------|
| Ubuntu | APT / APT-Fast |  / 🐧 | ✅ Supported |
| Debian | APT / APT-Fast |  / 🐧 | ✅ Supported |
| Arch Linux | Pacman |  / 🎯 | ✅ Supported |
| Manjaro | Pacman |  / 🎯 | ✅ Supported |
| Fedora | DNF |  / 🎩 | ✅ Supported |
| openSUSE Tumbleweed | Zypper (dup) |  / 🦎 | ✅ Supported |
| openSUSE Leap | Zypper (update) |  / 🦎 | ✅ Supported |

**Note:** First icon shown with Nerd Fonts, second icon is emoji fallback

---

## 🚀 Usage

### Installation

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

### Running the Script

Simply execute the script - you don't need to run it with sudo initially:

```bash
./update-system.sh
```

The script will:
1. Automatically detect your Linux distribution
2. Show OS logo (Nerd Font or emoji fallback)
3. Display current user information
4. Present a menu with options
5. Wait for your selection

### Menu Options

```
Menu Options

[1] Update System
[2] Install Nerd Fonts
[q] Quit
```

**Option 1: Update System**
- Checks for available updates
- Shows update summary
- Asks for confirmation
- Prompts for sudo password when you confirm
- Installs updates and cleans up

**Option 2: Install Nerd Fonts**
- Opens Nerd Fonts installer menu
- Choose from 6 popular fonts
- Install individually or all at once
- Automatic font cache update

**q: Quit**
- Exit the script

---

## 🔄 How It Works

### Main Menu

When you launch the script:

1. **Operating System Detection**
   - Automatically identifies your Linux distribution
   - Displays appropriate OS logo (Nerd Font icon or emoji)
   - Detects Nerd Font support and shows status
   - Selects the appropriate package manager commands
   - Special handling for openSUSE Tumbleweed (dup) vs Leap (update)
   - Detects apt-fast on Ubuntu/Debian systems for faster downloads

2. **User Information Display**
   Shows a table with:
   - Current User (with sudo indication if applicable)
   - User Type (Root User / Regular User / Regular User (elevated))
   - User ID (UID)
   - Home Directory

3. **Clear Instructions**
   - Shows exactly what the script will do
   - No surprises or hidden operations

4. **Menu Selection**
   - Option 1: Update System
   - Option 2: Install Nerd Fonts
   - q: Quit

### Option 1: Update System
**1. System Information Check**
   - Fetches the latest package information
   - Lists all available updates in an organized table (up to 15 packages shown)
   - If more than 15 updates are available, shows count of remaining packages
   - Displays OS logo, version, package manager, and current user
   
**2. No Updates Available**
   If system is up to date:
   - Shows status table with "✓ Up to date"
   - Displays "Nothing to do here!" message
   - Press 'q' to quit

**3. User Confirmation**
   If updates are available:
   - Clear prompt asking: "Do you want to Upgrade the System?"
   - Shows whether you're running as root (no password needed) or regular user (will prompt for password)
   - Press **'y'** to proceed with upgrade
   - Press **'q'** to quit without making any changes

**4. System Upgrade**
   - Only runs after you confirm with 'y'
   - Prompts for sudo password if needed
   - Shows live progress of package installations
   - Color-coded output for easy reading

**5. Automatic Cleanup**
   - Removes unnecessary packages (autoremove)
   - Cleans package cache (autoclean)

**6. Update Summary**
   - Shows comprehensive table with:
     - Operating System (with logo)
     - Package Manager used
     - Current User
     - Number of packages updated
     - System Status
   - Success message
   - Reboot notification if required

**7. Return to Menu**
   - Press any key to return to main menu

### Option 2: Install Nerd Fonts

**What are Nerd Fonts?**
Nerd Fonts are patched developer fonts with extra glyphs (icons) from popular icon fonts. They provide beautiful OS logos and programming symbols.

**Nerd Fonts Menu:**
```
Available Nerd Fonts

1. FiraCode Nerd Font (Ligatures, popular for coding)
2. JetBrainsMono Nerd Font (Designed by JetBrains)
3. Hack Nerd Font (Clean, readable monospace)
4. Meslo Nerd Font (Customized Menlo font)
5. UbuntuMono Nerd Font (Ubuntu's monospace font)
6. DejaVuSansMono Nerd Font (Classic, widely compatible)
7. Install ALL Fonts (Downloads all above fonts)

[b] Back to Main Menu
```

**Installation Process:**

**Individual Font Installation:**
1. Select font number (1-6)
2. Downloads from official Nerd Fonts GitHub
3. Shows download progress
4. Extracts to `~/.local/share/fonts/NerdFonts/`
5. Updates font cache automatically
6. Shows installation status
7. Returns to Nerd Fonts menu

**Bulk Installation (Option 7):**
1. Warns about ~500MB download
2. Asks for confirmation
3. Downloads all 6 fonts with progress
4. Extracts each font
5. Updates font cache
6. Shows summary table:
   - Successfully Installed
   - Failed
   - Total Processed
7. Returns to Nerd Fonts menu

**After Installation:**
- Restart your terminal application
- Configure terminal to use installed Nerd Font
- Script will automatically detect and use Nerd Font icons on next run

**Font Detection:**
The script detects Nerd Fonts by:
1. Checking terminal type (iTerm, WezTerm, Kitty, Alacritty)
2. Scanning installed fonts with `fc-list`
3. Looking for common Nerd Font families

**Icon Display:**
- **With Nerd Fonts:**   (Ubuntu),  (Arch),  (Fedora),  (openSUSE)
- **Without Nerd Fonts:** 🐧 (Ubuntu), 🎯 (Arch), 🎩 (Fedora), 🦎 (openSUSE)

---

## 🎨 Visual Features

The script includes beautiful visual elements:

### Color Scheme (Catppuccin Mocha)
- 🟢 **Green** - Success messages and confirmations
- 🟡 **Yellow** - Warnings and important notices
- 🔴 **Red** - Errors and quit option
- 🔵 **Blue** - Section headers
- 🟦 **Cyan/Teal** - Status messages
- 🟠 **Peach** - Active operations and package names
- 🟣 **Mauve/Lavender** - Borders and decorative elements

### UI Elements
- **OS Logos** - Distribution-specific icons (Nerd Font or emoji)
- **Bordered Boxes** - Important prompts and headers
- **Tables** - System information and package lists with perfectly aligned columns
- **Progress Indicators** - Live package operation status
- **Icons** - Visual indicators (✓, ✗, ⚠, ➜, ⟳, ℹ)
- **User Information** - Current user and privilege level display

### Table Alignment
All tables use fixed column widths (25 and 50 characters) with automatic text truncation for perfect alignment across all distributions.

---

## 📋 Requirements

- **Bash shell** - Standard on all Linux distributions
- **sudo privileges** - Unless running as root
- **Internet connection** - Required to download updates
- **Supported distribution** - One of: Ubuntu, Debian, Arch Linux, Manjaro, Fedora, openSUSE Tumbleweed, or openSUSE Leap
- **wget** - For downloading Nerd Fonts (usually pre-installed)
- **unzip** - For extracting Nerd Fonts (usually pre-installed)
- **fontconfig** - For font cache management (usually pre-installed)

---

## ⚡ APT-Fast Support

### What is apt-fast?

apt-fast is a shellscript wrapper for apt that can drastically improve download speeds by downloading packages in parallel using multiple connections.

### Automatic Detection

On Ubuntu and Debian systems, the script automatically:
- Checks if apt-fast is installed
- Uses apt-fast if available for faster parallel downloads
- Falls back to regular apt if not installed
- Informs you which tool is being used in the system information table

### Installing apt-fast

To install apt-fast on Ubuntu/Debian:

```bash
sudo add-apt-repository ppa:apt-fast/stable
sudo apt update
sudo apt install apt-fast
```

During installation, you'll be asked to configure:
- Maximum number of connections (recommended: 5-16)
- Whether to suppress apt-fast confirmation dialog

After installation, the update-system.sh script will automatically detect and use apt-fast on subsequent runs.

---

## 🔧 Troubleshooting

### Common Issues

**Q: The script says my OS is unsupported**

A: Currently supported distributions are:
- Ubuntu and Debian (APT-based)
- Arch Linux and Manjaro (Pacman-based)
- Fedora (DNF-based)
- openSUSE Tumbleweed and Leap (Zypper-based)

Make sure you're running one of these distributions. Check with: `cat /etc/os-release`

---

**Q: I'm not being prompted for a password**

A: This is normal if you're running as root. The script detects your user status and will show:
- "Running as root user - No password needed" if you're root
- "Running as regular user - You will be prompted for sudo password" if you're not root

---

**Q: Can I cancel the update after starting the script?**

A: Yes! Before the actual upgrade begins, you'll see a clear prompt:

```
Do you want to Upgrade the System?

[y] Press 'y' to UPGRADE the system
[q] Press 'q' to QUIT without upgrading
```

Pressing **'q'** will exit the script immediately without making any changes to your system.

---

**Q: The script shows 0 updates available but I know there are updates**

A: Try running the package manager's update command manually first:
- Ubuntu/Debian: `sudo apt update`
- Arch: `sudo pacman -Sy`
- Fedora: `sudo dnf check-update`
- openSUSE: `sudo zypper refresh`

**For openSUSE users:** The script now uses `sudo zypper list-updates` which is more reliable. If issues persist, try manually:
```bash
sudo zypper refresh
sudo zypper list-updates
```

If updates still don't appear, check your repository configuration.

---

**Q: Why are openSUSE Tumbleweed and Leap separate?**

A: They use different update commands:
- **Tumbleweed** (rolling release): Uses `zypper dup` (distribution upgrade) to stay on the rolling edge
- **Leap** (point release): Uses `zypper update` for regular package updates within the same release

The script automatically detects which variant you're using and applies the correct command.

---

**Q: OS icons aren't showing properly**

A: The script has automatic fallback:
- **With Nerd Fonts:** Shows distribution logos ( )
- **Without Nerd Fonts:** Shows emoji fallback (🐧 🎯 🎩 🦎)

To get proper logos, use Option 2 to install Nerd Fonts, restart your terminal, and configure it to use a Nerd Font.

---

**Q: How do I configure my terminal to use Nerd Fonts?**

A: After installing fonts:
1. Restart your terminal
2. Go to terminal preferences/settings
3. Find Font or Appearance settings
4. Select a Nerd Font (e.g., "FiraCode Nerd Font Mono")
5. Apply and restart terminal

Terminal-specific:
- **GNOME Terminal**: Preferences → Profile → Text → Font
- **Konsole**: Settings → Edit Current Profile → Appearance → Font
- **Alacritty**: Edit `~/.config/alacritty/alacritty.yml` → font.normal.family
- **Kitty**: Edit `~/.config/kitty/kitty.conf` → font_family

---

**Q: Nerd Font installation failed**

A: Check:
- Internet connection is stable
- You have write permissions to `~/.local/share/fonts/`
- `wget` and `unzip` are installed: `sudo apt install wget unzip`
- Enough disk space (~100MB per font)

Manual installation:
```bash
mkdir -p ~/.local/share/fonts/NerdFonts
cd ~/.local/share/fonts/NerdFonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip FiraCode.zip
fc-cache -f ~/.local/share/fonts/
```

---

**Q: Where are Nerd Fonts installed?**

A: `~/.local/share/fonts/NerdFonts/`

To remove:
```bash
rm -rf ~/.local/share/fonts/NerdFonts/
fc-cache -f
```

---

**Q: Script detects wrong user type**

A: The script shows three scenarios:
- **Root User**: Running as actual root user
- **Regular User (elevated)**: Running with sudo (shows "via sudo")
- **Regular User**: Running without privileges

This is informational - the script will prompt for sudo when needed regardless.

---

**Q: Can I run this script in a cron job?**

A: The script is designed for interactive use with user prompts. For automated updates, you should use the package manager's built-in automation features:
- Ubuntu/Debian: `unattended-upgrades`
- Fedora: `dnf-automatic`
- Arch: Consider `pacman-contrib` with custom scripts

---

**Q: Does this script upgrade to a new distribution version?**

A: No, this script only updates packages within your current distribution version. For distribution upgrades:
- Ubuntu/Debian: Use `do-release-upgrade`
- Fedora: Use `dnf system-upgrade`
- Arch: Rolling release (this script handles it)
- openSUSE Tumbleweed: Rolling release (this script handles it)

---

**Q: Why does the script use different commands for different distributions?**

A: Each Linux distribution uses a different package manager with its own commands:
- **APT** (Debian/Ubuntu): `apt update` and `apt upgrade`
- **Pacman** (Arch): `pacman -Sy` and `pacman -Syu`
- **DNF** (Fedora): `dnf check-update` and `dnf upgrade`
- **Zypper** (openSUSE): `zypper refresh` and `zypper update`

The script automatically detects your distribution and uses the correct commands.

---

## 🛡️ Security Considerations

- The script requires sudo privileges to install system updates
- All commands are displayed with full output for transparency
- No automatic execution - user confirmation required before any changes
- Uses official package manager commands only
- No external scripts or downloads during execution

---

## 📝 Examples

### Regular System Update

```bash
# Launch the script
./update-system.sh

# Script detects OS and shows menu
# Press 1 for Update System
1

# Review the update summary
# Press 'y' to confirm
y

# Enter sudo password when prompted
# Wait for updates to complete
# Review the update summary
# Press any key to return to menu
# Press 'q' to quit
q
```

---

### Installing Nerd Fonts

```bash
# Launch the script
./update-system.sh

# Press 2 for Install Nerd Fonts
2

# Choose a font (e.g., FiraCode)
1

# Wait for download and installation
# Press any key to return to font menu
# Press 'b' to go back to main menu
b

# Quit the script
q

# Restart your terminal
# Configure terminal to use the installed Nerd Font
```

---

### Installing All Nerd Fonts

```bash
# Launch the script
./update-system.sh

# Press 2 for Install Nerd Fonts
2

# Choose option 7 to install all
7

# Press 'y' to confirm
y

# Wait for all fonts to download and install
# Review the summary
# Press any key to return
# Press 'b' to go back
b

# Quit and restart terminal
q
```

---

### Checking System Status Without Updating

```bash
# Launch the script
./update-system.sh

# Press 1 to see available updates
1

# Review the update list
# Press 'q' to quit without updating
q
```

---

## 🤝 Contributing

Found a bug or want to add support for another distribution? Contributions are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This script is open source and available under the MIT License.

---

[⬆️ Back to Main](../README.md)