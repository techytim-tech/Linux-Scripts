# flatpak-remover.sh

[⬆️ Back to Main](../README.md)

A dedicated Flatpak application removal tool for managing and uninstalling Flatpak applications with detailed information and bulk removal options.

---

## 📥 Quick Download

```bash
wget https://raw.githubusercontent.com/techytim-tech/Linux-Scripts/main/flatpak-remover.sh
chmod +x flatpak-remover.sh
./flatpak-remover.sh
```

---

## ✨ Features

- **Automatic Detection** - Lists all installed Flatpak applications
- **Detailed Information** - Shows app name, ID, version, branch, and size
- **Individual Removal** - Remove apps one at a time with confirmation
- **Bulk Removal** - Remove all Flatpak apps at once
- **Smart Cleanup** - Automatically removes unused runtimes and dependencies
- **Beautiful Fedora Theme** - Professional interface with Fedora's blue colors
- **Status Monitoring** - Shows app count and installation status
- **Safety Features** - Multiple confirmations for destructive operations
- **Live Progress** - Real-time removal progress with colored output
- **Persistent Interface** - Returns to list after operations until quit

---

## 🚀 Usage

### Installation

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/techytim-tech/Linux-Scripts/main/flatpak-remover.sh
   ```

2. **Make it executable:**
   ```bash
   chmod +x flatpak-remover.sh
   ```

3. **Run the script:**
   ```bash
   ./flatpak-remover.sh
   ```

### Navigation

The script presents an interactive interface:

```
Flatpak App Remover

▶ System Status
┌──────────────────────────────┬─────────────────────────────────────────────┐
│ Component                    │ Status                                      │
├──────────────────────────────┼─────────────────────────────────────────────┤
│ Flatpak                      │ ✓ Installed                                 │
│ Flatpak Version              │ 1.15.4                                      │
│ Flathub Repository           │ ✓ Added                                     │
│ Installed Apps               │ 12 applications                             │
└──────────────────────────────┴─────────────────────────────────────────────┘

▶ Installed Applications (12 apps)

 1. Visual Studio Code                   com.visualstudio.code
 2. VLC Media Player                     org.videolan.VLC
 3. GIMP                                 org.gimp.GIMP
...

▶ Actions

  Enter app number (1-12) to view details and remove
  Press 'a' to remove ALL apps
  Press 'q' to quit
```

**To use:**
- **Enter a number** to view app details and remove it
- **Press 'a'** to remove all apps at once
- **Press 'q'** to quit

---

## 🔄 How It Works

### Main Interface

When you launch the script:

1. **Prerequisites Check**
   - Verifies Flatpak is installed
   - Shows message and exits if not installed

2. **Status Display**
   - Shows Flatpak version
   - Lists total number of installed apps
   - Displays Flathub repository status

3. **App List**
   - Dynamically loads installed apps
   - Shows app names and IDs
   - Numbers each app for easy selection
   - Updates after each removal

4. **Action Menu**
   - Individual removal by number
   - Bulk removal with 'a' key
   - Quit with 'q' key

### No Apps Installed

If no Flatpak apps are installed:

```
┌──────────────────────────────┬─────────────────────────────────────────────┐
│ Status                       │ Message                                     │
├──────────────────────────────┼─────────────────────────────────────────────┤
│ Installed Apps               │ 0 applications                              │
│ Updates Available            │ 0 apps                                      │
│ Action Required              │ None                                        │
└──────────────────────────────┴─────────────────────────────────────────────┘

✓ No Flatpak apps are installed
ℹ Nothing to remove

╔══════════════════════════════════════════════════════════════╗
║                  All clean!                                  ║
╚══════════════════════════════════════════════════════════════╝

  [q] Press 'q' to QUIT
```

### Individual App Removal

When you select an app by number:

1. **App Details Display**
   ```
   App Details
   
   Application: VLC Media Player
   App ID: org.videolan.VLC
   Version: 3.0.20
   Branch: stable
   
   ▶ Additional Information
   ➜ Fetching app size...
   Installed Size: 250.4 MB
   ```

2. **Confirmation Prompt**
   ```
   ╔══════════════════════════════════════════════════════════════╗
   ║              Remove this application?                        ║
   ╚══════════════════════════════════════════════════════════════╝
   
   ⚠ This will uninstall VLC Media Player and free up disk space
   
     [y] Press 'y' to REMOVE
     [b] Press 'b' to go BACK
   ```

3. **Removal Process**
   - Shows removal progress
   - Displays success or error message
   - Frees up disk space
   - Returns to app list

### Bulk Removal (Remove All)

When you press 'a':

1. **Warning Display**
   ```
   Remove All Apps
   
   ⚠ WARNING: This will remove ALL 12 Flatpak applications!
   
   ▶ Apps to be removed:
   
     ✗ Visual Studio Code
     ✗ VLC Media Player
     ✗ GIMP
     ...
   ```

2. **Strong Confirmation**
   ```
   ╔══════════════════════════════════════════════════════════════╗
   ║      Are you SURE you want to remove ALL apps?               ║
   ╚══════════════════════════════════════════════════════════════╝
   
     Type YES (in capitals) to confirm or n to cancel
   Confirm:
   ```
   
   **Must type "YES" exactly** - Not 'y', 'yes', or 'Yes'

3. **Removal Process**
   - Removes apps one by one
   - Shows progress for each app
   - Displays success/failure for each
   - Shows summary table at end
   - Cleans up unused dependencies

4. **Summary Display**
   ```
   ▶ Summary
   
   ┌──────────────────────────────┬─────────────────────────────────────────────┐
   │ Result                       │ Count                                       │
   ├──────────────────────────────┼─────────────────────────────────────────────┤
   │ Successfully Removed         │ 12 apps                                     │
   │ Failed                       │ 0 apps                                      │
   │ Total Processed              │ 12 apps                                     │
   └──────────────────────────────┴─────────────────────────────────────────────┘
   
   ✓ All applications removed successfully!
   ```

---

## 🎨 Visual Features

### Color Scheme (Fedora Theme)
- 🔵 **Fedora Blue** - Primary interface and borders
- ⚪ **White** - App names and main text
- 🔴 **Red** - Removal operations and numbers
- 🟡 **Yellow** - Warnings and confirmations
- 🟢 **Green** - Success messages
- 🟠 **Orange** - Active operations
- 🔷 **Cyan** - Information messages
- ⚫ **Gray** - Secondary text and IDs

### UI Elements
- **Status Tables** - System information display
- **Numbered Lists** - Easy app selection
- **Bordered Prompts** - Clear confirmation boxes
- **Progress Indicators** - Live removal status (✗ icon)
- **Color-Coded Feedback** - Easy status identification

---

## 📋 Requirements

- **Flatpak installed** - Must be present on system
- **Bash shell** - Standard on all Linux distributions
- **sudo privileges** - May be required for system-wide apps

**Note:** The script checks for Flatpak and provides guidance if not installed.

---

## 💡 Usage Examples

### Removing a Single App

```bash
# Launch the script
./flatpak-remover.sh

# Browse the list of installed apps
# Select one (e.g., app #3)
3

# Review app details and size
# Press 'y' to confirm removal
y

# Wait for removal to complete
# Press any key to return to list
```

### Removing All Apps

```bash
# Launch the script
./flatpak-remover.sh

# Press 'a' for remove all
a

# Review the list of apps to be removed
# Type YES (in capitals) to confirm
YES

# Wait for all apps to be removed
# Review the summary
# Press any key to return
```

### Checking Installed Apps Without Removing

```bash
# Launch the script
./flatpak-remover.sh

# Browse the list to see what's installed
# Select an app to see its details
5

# Press 'b' to go back without removing
b

# Press 'q' when done
q
```

### Freeing Up Disk Space

```bash
# Launch the script to see app sizes
./flatpak-remover.sh

# Select large apps to remove
# Each app shows its size
# Remove apps you don't need
# Script automatically cleans up dependencies
```

---

## 🔍 Troubleshooting

### Common Issues

**Q: Script says "Flatpak is not installed"**

A: You need Flatpak installed. The script will exit with this message:
```
✗ Flatpak is not installed on your system
ℹ There are no Flatpak apps to remove
```
If you want to install Flatpak, use flatpak-menu.sh.

---

**Q: App list is empty but I have apps installed**

A: Try running manually to check:
```bash
flatpak list --app
```
If apps appear, there may be a permissions issue. Try running the script with sudo:
```bash
sudo ./flatpak-remover.sh
```

---

**Q: Failed to remove an app**

A: This can happen if:
- The app is currently running (close it first)
- System-wide app requires sudo privileges
- App dependencies are in use

Try:
1. Close the application completely
2. Run the script with sudo
3. Check if other apps depend on it

---

**Q: "Remove All" fails on some apps**

A: The script shows a summary of what succeeded and failed. Common reasons:
- Some apps are running
- Permission issues on system-wide installations
- Dependency conflicts

The script will:
- Continue removing other apps
- Show which ones failed
- Display a summary at the end

---

**Q: Removed apps but disk space not freed**

A: After removing apps, run cleanup:
```bash
flatpak uninstall --unused -y
```
The script does this automatically after "Remove All", but you can run it manually too.

---

**Q: I typed "yes" but nothing happened**

A: For bulk removal, you must type **YES** in capital letters exactly. This is a safety feature to prevent accidental removal of all apps.

---

**Q: Can I remove Flatpak itself?**

A: This script only removes Flatpak apps, not Flatpak itself. To remove Flatpak:
```bash
# Ubuntu/Debian
sudo apt remove flatpak

# Fedora
sudo dnf remove flatpak

# Arch
sudo pacman -R flatpak
```

---

**Q: How do I restore removed apps?**

A: Use flatpak-installer.sh or install manually:
```bash
flatpak install flathub <app-id>
```
Your app data may still be in `~/.var/app/` if you want to restore it.

---

## 🎯 Best Practices

### Before Removing Apps

1. **Close all applications** - Ensure apps you want to remove aren't running
2. **Review dependencies** - Some apps share runtimes
3. **Backup data** - App data is in `~/.var/app/<app-id>/`
4. **Check disk space** - Note how much space you'll free

### When Removing Apps

1. **Read confirmations carefully** - Especially for bulk removal
2. **Review app details** - Check size and version before removing
3. **Don't interrupt** - Let removal complete fully
4. **Check the summary** - Verify which apps were removed

### After Removing Apps

1. **Run cleanup** - Script does this automatically
2. **Check freed space** - Use `df -h` to verify
3. **Verify removal** - Check your application menu
4. **Update remaining apps** - Use flatpak-menu.sh Option 2

---

## 🛡️ Security Considerations

- Script requires confirmation before removing apps
- "Remove All" requires typing "YES" to prevent accidents
- App data remains in `~/.var/app/` after removal
- Runtimes and dependencies are automatically cleaned up
- No apps are removed without explicit user confirmation

---

## 🧹 Cleanup Information

### What Gets Removed

When you remove an app:
- Application binaries
- App-specific libraries
- Desktop shortcuts and icons
- Application metadata

### What Stays

After removal (unless manually deleted):
- App configuration in `~/.var/app/<app-id>/config/`
- App data in `~/.var/app/<app-id>/data/`
- App cache in `~/.var/app/<app-id>/cache/`

### Additional Cleanup

To remove app data too:
```bash
# Remove specific app data
rm -rf ~/.var/app/<app-id>/

# Remove all Flatpak app data
rm -rf ~/.var/app/
```

To remove unused runtimes:
```bash
flatpak uninstall --unused -y
```

---

## 🔄 Related Scripts

- **[flatpak-menu.sh](flatpak-menu.md)** - Install Flatpak, add Flathub, and update apps
- **[flatpak-installer.sh](flatpak-installer.md)** - Install curated apps from a list

---

## 📊 Understanding App Sizes

### Size Information

The script shows installed size for each app, which includes:
- Application binaries
- App-specific libraries
- Resources (images, sounds, etc.)
- Does NOT include shared runtimes

### Typical App Sizes

- **Small apps**: 50-150 MB (Flatseal, Impression)
- **Medium apps**: 150-500 MB (VS Code, Telegram)
- **Large apps**: 500 MB - 2 GB (Kdenlive, GIMP)
- **Very large apps**: 2+ GB (Steam, OBS Studio with plugins)

### Shared Runtimes

Multiple apps may share runtimes:
- **GNOME Runtime**: Used by many GNOME apps
- **KDE Runtime**: Used by KDE apps
- **Freedesktop Runtime**: Common base runtime

Removing all apps that use a runtime allows its removal during cleanup.

---

## 🤝 Contributing

Found a bug or have suggestions?

1. Fork the repository
2. Create your feature branch
3. Test thoroughly
4. Submit a pull request

---

## 📄 License

This script is open source and available under the MIT License.

---

[⬆️ Back to Main](../README.md)