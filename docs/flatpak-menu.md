# flatpak-menu.sh

[⬆️ Back to Main](../README.md)

An interactive Flatpak manager with a beautiful Fedora-themed interface for installing Flatpak, adding Flathub repository, and updating Flatpak applications.

---

## 📥 Quick Download

```bash
wget https://raw.githubusercontent.com/techytim-tech/Linux-Scripts/main/flatpak-menu.sh
chmod +x flatpak-menu.sh
./flatpak-menu.sh
```

---

## ✨ Features

- **Beautiful Fedora Theme** - Inspired by Fedora's iconic blue branding with a modern interface
- **Interactive Menu System** - Easy-to-navigate menu with clear options
- **Multi-Distribution Support** - Automatically detects and installs Flatpak on Ubuntu, Debian, Fedora, Arch, openSUSE, RHEL, and more
- **Smart Status Monitoring** - Shows current installation status of Flatpak, Flathub, and installed apps
- **Automatic Detection** - Checks if Flatpak and Flathub are already installed
- **Update Management** - Lists available updates with detailed information
- **Live Progress Display** - Real-time output showing download and installation progress
- **Persistent Menu** - Returns to menu after each operation until user quits
- **Clear Instructions** - Step-by-step guidance for every operation
- **Summary Tables** - Beautiful table displays for system status and updates

---

## 🐧 Supported Distributions

Flatpak installation is supported on:

| Distribution | Package Manager | Status |
|--------------|----------------|--------|
| Ubuntu | APT | ✅ Supported |
| Debian | APT | ✅ Supported |
| Linux Mint | APT | ✅ Supported |
| Pop!_OS | APT | ✅ Supported |
| Fedora | DNF | ✅ Supported |
| Arch Linux | Pacman | ✅ Supported |
| Manjaro | Pacman | ✅ Supported |
| openSUSE Tumbleweed | Zypper | ✅ Supported |
| openSUSE Leap | Zypper | ✅ Supported |
| RHEL / CentOS | YUM/DNF | ✅ Supported |
| Rocky Linux | DNF | ✅ Supported |
| AlmaLinux | DNF | ✅ Supported |

---

## 🎮 Usage

### Installation

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/techytim-tech/Linux-Scripts/main/flatpak-menu.sh
   ```

2. **Make it executable:**
   ```bash
   chmod +x flatpak-menu.sh
   ```

3. **Run the script:**
   ```bash
   ./flatpak-menu.sh
   ```

### Menu Navigation

The script presents an interactive menu with the following options:

```
Menu Options

[1] Install Flatpak & Flathub Repository
[2] Update Flatpak Apps
[3] Remove Flatpak from System
[q] Quit
```

**To select an option:**
- Press **1** to install Flatpak and add Flathub repository
- Press **2** to update all installed Flatpak applications
- Press **3** to completely remove Flatpak from your system
- Press **q** to quit the application

---

## 🔄 How It Works

### Main Menu

When you launch the script, it displays:

1. **System Status Table** showing:
   - Flatpak installation status
   - Flatpak version (if installed)
   - Flathub repository status
   - Number of installed Flatpak apps

2. **Menu Options** for available actions

3. **Interactive Prompt** waiting for your choice

### Option 1: Install Flatpak & Flathub

**What it does:**
1. Checks if Flatpak is already installed
2. Checks if Flathub repository is already added
3. Shows what needs to be installed/configured
4. Asks for confirmation (y/q)
5. Detects your Linux distribution
6. Installs Flatpak using your distro's package manager
7. Adds Flathub repository
8. Returns to main menu

**If already installed:**
- Displays success message
- Indicates everything is set up
- Suggests using Option 2 to update apps

**User confirmation:**
- Press **y** to proceed with installation
- Press **q** to return to menu without changes
- Shows whether sudo password will be needed

### Option 2: Update Flatpak Apps

**What it does:**
1. Verifies Flatpak is installed
2. Verifies Flathub repository is added
3. Checks for available updates
4. Displays update summary with app count
5. Shows list of apps with updates (up to 10)
6. Asks for confirmation (y/q)
7. Downloads and installs all updates
8. Returns to main menu

**If no updates available:**
- Displays "up to date" status table
- Shows success message
- Returns to menu after key press

**User confirmation:**
- Press **y** to proceed with updates
- Press **q** to return to menu without updating
- Shows sudo password requirements

---

## 🎨 Visual Features

The script features a beautiful Fedora-inspired interface:

### Color Scheme (Fedora Theme)
- 🔵 **Fedora Blue** - Primary branding color for borders and headers
- ⚪ **White** - Main text and important information
- 🟢 **Green** - Success messages and confirmations
- 🔴 **Red** - Errors and quit option
- 🟡 **Yellow** - Warnings and confirmation prompts
- 🟠 **Orange** - Active operations and status indicators
- 🔷 **Cyan** - Info messages and status icons
- ⚫ **Gray** - Secondary text and output

### UI Elements
- **Bordered Headers** - Clean, professional section headers
- **Status Tables** - Organized information display
- **Menu System** - Clear numbered options
- **Progress Indicators** - Live operation status
- **Color-Coded Output** - Easy-to-read feedback
- **Icons** - Visual indicators (✓, ✗, ⚠, ➜, ⟳, ℹ)

---

## 📋 Requirements

- **Bash shell** - Standard on all Linux distributions
- **sudo privileges** - Required for installation operations
- **Internet connection** - Required to download Flatpak and updates
- **Supported distribution** - One of the listed distributions above

---

## 📊 Status Monitoring

The script continuously monitors and displays:

| Component | Information Shown |
|-----------|------------------|
| Flatpak Installation | Installed or Not Installed |
| Flatpak Version | Version number (if installed) |
| Flathub Repository | Added or Not Added |
| Installed Apps | Count of installed Flatpak apps |

---

## 🔧 Menu Options Explained

### Option 1: Install Flatpak & Flathub Repository

**Purpose:** Set up Flatpak on your system and add the Flathub repository.

**When to use:**
- First time setting up Flatpak
- Flatpak was removed and needs reinstallation
- Flathub repository was not added during initial setup

**What happens:**
1. System check for existing installations
2. OS detection for correct package manager
3. Flatpak installation via distro package manager
4. Flathub repository configuration
5. Confirmation of successful setup

**After installation:**
- Flatpak is ready to use
- Flathub repository is available
- You can install apps from Flathub
- Session restart recommended for full integration

### Option 2: Update Flatpak Apps

**Purpose:** Update all installed Flatpak applications to their latest versions.

**When to use:**
- Regular maintenance (weekly/monthly)
- After installing new apps
- When apps notify you of updates
- To fix bugs in current versions

**What happens:**
1. Verification of Flatpak installation
2. Check for available updates
3. Display of apps needing updates
4. User confirmation request
5. Download and installation of updates
6. Cleanup and completion

**Update process:**
- Downloads updates in parallel when possible
- Shows progress for each app
- Handles dependencies automatically
- Validates downloads
- Reports completion status

---

### Option 3: Remove Flatpak from System

**Purpose:** Completely remove Flatpak and all associated apps from your system.

**When to use:**
- No longer need Flatpak applications
- Switching to different package format
- Troubleshooting persistent Flatpak issues
- Freeing up significant disk space
- Clean system reinstall preparation

**⚠️ WARNING:** This is a destructive operation that cannot be easily undone.

**What happens:**

**Pre-removal checks:**
1. Verifies Flatpak is installed
2. Detects your operating system
3. Counts installed Flatpak apps
4. Shows system information table
5. Lists all apps that will be removed (up to 10 shown)
6. Displays comprehensive warning

**Warning displayed:**
```
This operation will:
  1. Remove all installed Flatpak applications (X apps)
  2. Remove all Flatpak runtimes and dependencies
  3. Remove Flatpak itself from your system
  4. Remove Flathub repository configuration

Note: App data in ~/.var/app/ will NOT be removed
```

**User confirmation:**
- Press **y** to proceed with removal
- Press **q** to return to menu without changes
- Shows whether sudo password will be needed

**4-Step Removal Process:**

**Step 1: Remove Flatpak Applications**
- Uninstalls all Flatpak apps using `flatpak uninstall --all`
- Shows live progress for each app
- Displays success message
- **Safety Check:** Verifies all apps were removed
- **Aborts if:** Apps remain installed (protection against partial removal)

**Step 2: Remove Unused Runtimes**
- Cleans up dependencies with `flatpak uninstall --unused`
- Frees up disk space from shared libraries
- Shows cleanup progress
- Continues even if some runtimes can't be removed (non-critical)

**Step 3: Remove Flathub Repository**
- Removes Flathub remote configuration
- Cleans up repository metadata
- Continues if already removed

**Step 4: Remove Flatpak Package**
- Detects your distribution
- Uses appropriate package manager:
  - **Ubuntu/Debian**: `apt remove flatpak`
  - **Fedora/RHEL/CentOS**: `dnf remove flatpak`
  - **Arch/Manjaro**: `pacman -R flatpak`
  - **openSUSE**: `zypper remove flatpak`
- Runs autoremove to clean up dependencies
- Shows removal progress
- **Aborts if:** Package removal fails

**Verification:**
- Checks if `flatpak` command still exists
- Warns if session restart needed
- Provides optional cleanup instructions

**What gets removed:**
- ✅ All Flatpak applications
- ✅ All Flatpak runtimes and dependencies
- ✅ Flathub repository configuration
- ✅ Flatpak package and binaries

**What stays (optional manual cleanup):**
- 📁 User app data: `~/.var/app/`
- 📁 System Flatpak data: `/var/lib/flatpak/`
- 📁 User Flatpak data: `~/.local/share/flatpak/`

**Optional cleanup commands shown:**
```bash
# Remove user app data
rm -rf ~/.var/app/

# Remove system app data (requires sudo)
sudo rm -rf /var/lib/flatpak/

# Remove user Flatpak data
rm -rf ~/.local/share/flatpak/
```

**Safety features:**
- Multiple confirmation steps
- Verifies each step completed successfully
- Aborts if critical steps fail
- Never leaves system in broken state
- Clear error messages for failures
- Returns to menu on any failure

**After removal:**
- Session restart recommended
- All Flatpak apps removed from application menu
- Disk space freed
- Can reinstall Flatpak later using Option 1 if needed

---

## 💡 Usage Examples

### First-Time Setup

```bash
# Launch the script
./flatpak-menu.sh

# You'll see the status showing Flatpak not installed
# Press 1 to install
# Press y to confirm
# Enter sudo password when prompted
# Wait for installation to complete
# Press any key to return to menu
```

### Regular Updates

```bash
# Launch the script
./flatpak-menu.sh

# Status shows installed apps
# Press 2 to update
# Review the list of updates
# Press y to confirm
# Wait for updates to complete
# Press any key to return to menu
# Press q to quit
```

### Checking Status Only

```bash
# Launch the script
./flatpak-menu.sh

# View the status table
# Press q to quit without making changes
```

---

### Removing Flatpak from System

```bash
# Launch the script
./flatpak-menu.sh

# Press 3 for remove Flatpak
3

# Review the warning and app list
# Press y to confirm removal
y

# Enter sudo password when prompted
# Wait for 4-step removal process
# Review completion message
# Press any key to return to menu
```

---

## 🔍 Troubleshooting

### Common Issues

**Q: Script says "Flatpak is not installed" but I have it**

A: The script checks for the `flatpak` command in your PATH. Try:
```bash
which flatpak
flatpak --version
```
If these work, there may be a PATH issue. Try running with full path:
```bash
/usr/bin/flatpak --version
```

---

**Q: Flathub repository not detected after adding it**

A: Verify Flathub was added correctly:
```bash
flatpak remote-list
```
You should see "flathub" in the list. If not, manually add it:
```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

---

**Q: Installation fails on my distribution**

A: If your distribution is not in the supported list, install Flatpak manually:
- Visit: https://flatpak.org/setup/
- Find your distribution
- Follow the installation instructions
- Then use Option 2 to update apps

---

**Q: Update shows "0 apps" but I have apps installed**

A: Check your installed apps:
```bash
flatpak list --app
```
If apps are shown, the update check might have timed out. Try running:
```bash
flatpak remote-ls --updates
```

---

**Q: Script doesn't return to menu after operation**

A: Press any key when you see "Press any key to return to menu..."
If this doesn't work, the script may have encountered an error. Press Ctrl+C and restart.

---

**Q: Permission denied errors during installation**

A: The script requires sudo privileges. Make sure:
- You have sudo access on your system
- You enter the correct password when prompted
- Your user is in the sudoers file

---

**Q: Can I run updates without confirmation?**

A: The script is designed for interactive use and always asks for confirmation before making changes. This is a safety feature to prevent unwanted modifications.

---

**Q: How do I install specific apps?**

A: This script focuses on system-wide Flatpak management. To install specific apps:
```bash
flatpak search <app-name>
flatpak install flathub <app-id>
```

Or use GNOME Software, KDE Discover, or other graphical app stores.

---

**Q: Where are Flatpak apps installed?**

A: Flatpak apps can be installed in two locations:
- System-wide: `/var/lib/flatpak/`
- User-specific: `~/.local/share/flatpak/`

This script updates apps in both locations.

---

## 🎯 Best Practices

### Regular Maintenance
- Run updates weekly or monthly
- Check status before updating
- Read the update list before confirming
- Keep Flatpak itself updated via your system package manager

### Installation
- Always add Flathub repository for maximum app availability
- Restart your desktop session after first installation
- Verify installation before attempting updates

### Updates
- Review what's being updated
- Ensure stable internet connection
- Allow updates to complete without interruption
- Restart apps after updating them

---

## 🛡️ Security Considerations

- Script requires sudo privileges only when needed
- All operations display full output for transparency
- No automatic execution without user confirmation
- Uses official Flatpak commands only
- Flathub is the official Flatpak repository
- Updates are cryptographically verified by Flatpak

---

## 📚 Additional Resources

- **Flatpak Official Site:** https://flatpak.org/
- **Flathub App Store:** https://flathub.org/
- **Flatpak Documentation:** https://docs.flatpak.org/
- **Flatpak GitHub:** https://github.com/flatpak/flatpak

---

## 🔄 What's Next

After setting up Flatpak, you can:

1. **Browse apps on Flathub:**
   ```bash
   # Search for apps
   flatpak search <keyword>
   
   # Install apps
   flatpak install flathub <app-id>
   ```

2. **Use GUI software centers:**
   - GNOME Software (GNOME)
   - Discover (KDE)
   - Pop!_Shop (Pop!_OS)

3. **Manage your apps:**
   ```bash
   # List installed apps
   flatpak list --app
   
   # Remove apps
   flatpak uninstall <app-id>
   
   # Run apps
   flatpak run <app-id>
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