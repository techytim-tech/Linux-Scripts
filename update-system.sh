#!/bin/bash

# Catppuccin Mocha Colors
ROSEWATER="\033[38;2;245;224;220m"
FLAMINGO="\033[38;2;242;205;205m"
PINK="\033[38;2;245;194;231m"
MAUVE="\033[38;2;203;166;247m"
RED="\033[38;2;243;139;168m"
MAROON="\033[38;2;235;160;172m"
PEACH="\033[38;2;250;179;135m"
YELLOW="\033[38;2;249;226;175m"
GREEN="\033[38;2;166;227;161m"
TEAL="\033[38;2;148;226;213m"
SKY="\033[38;2;137;220;235m"
SAPPHIRE="\033[38;2;116;199;236m"
BLUE="\033[38;2;137;180;250m"
LAVENDER="\033[38;2;180;190;254m"
TEXT="\033[38;2;205;214;244m"
SUBTEXT1="\033[38;2;186;194;222m"
SUBTEXT0="\033[38;2;166;173;200m"
OVERLAY2="\033[38;2;147;153;178m"
OVERLAY1="\033[38;2;127;132;156m"
SURFACE2="\033[38;2;88;91;112m"
SURFACE1="\033[38;2;69;71;90m"
BASE="\033[38;2;30;30;46m"
MANTLE="\033[38;2;24;24;37m"
CRUST="\033[48;2;17;17;27m"
RESET="\033[0m"
BOLD="\033[1m"

# Background colors
BG_BASE="\033[48;2;30;30;46m"
BG_SURFACE0="\033[48;2;49;50;68m"
BG_SURFACE1="\033[48;2;69;71;90m"

# Clear screen and set background
clear
echo -e "${BG_BASE}${TEXT}"

# Function to print a fancy header
print_header() {
    local cols=$(tput cols)
    echo -e "\n${MAUVE}${BOLD}╔$(printf '═%.0s' $(seq 1 $((cols-2))))╗${RESET}"
    local text="$1"
    local padding=$(( (cols - ${#text} - 2) / 2 ))
    printf "${MAUVE}${BOLD}║${RESET}%*s${LAVENDER}${BOLD}%s${RESET}%*s${MAUVE}${BOLD}║${RESET}\n" $padding "" "$text" $padding ""
    echo -e "${MAUVE}${BOLD}╚$(printf '═%.0s' $(seq 1 $((cols-2))))╝${RESET}\n"
}

# Function to print a section header
print_section() {
    echo -e "\n${BLUE}${BOLD}▶ $1${RESET}"
    echo -e "${OVERLAY2}$(printf '─%.0s' $(seq 1 50))${RESET}"
}

# Function to print status messages
print_status() {
    echo -e "${TEAL}➜${RESET} ${TEXT}$1${RESET}"
}

print_success() {
    echo -e "${GREEN}✓${RESET} ${TEXT}$1${RESET}"
}

print_error() {
    echo -e "${RED}✗${RESET} ${TEXT}$1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}⚠${RESET} ${TEXT}$1${RESET}"
}

print_info() {
    echo -e "${SKY}ℹ${RESET} ${TEXT}$1${RESET}"
}

# Function to print a table with fixed column widths
print_table() {
    local col1_width=25
    local col2_width=50
    
    # Top border
    echo -e "${MAUVE}┌$(printf '─%.0s' $(seq 1 $col1_width))┬$(printf '─%.0s' $(seq 1 $col2_width))┐${RESET}"
    
    # Header
    local header1="$1"
    local header2="$2"
    printf "${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-$((col1_width-1))s${RESET}${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-$((col2_width-1))s${RESET}${MAUVE}│${RESET}\n" "$header1" "$header2"
    
    # Middle border
    echo -e "${MAUVE}├$(printf '─%.0s' $(seq 1 $col1_width))┼$(printf '─%.0s' $(seq 1 $col2_width))┤${RESET}"
    
    # Content rows
    shift 2
    while [ $# -gt 0 ]; do
        local val1="$1"
        local val2="$2"
        # Truncate if too long
        if [ ${#val1} -gt $((col1_width-2)) ]; then
            val1="${val1:0:$((col1_width-5))}..."
        fi
        if [ ${#val2} -gt $((col2_width-2)) ]; then
            val2="${val2:0:$((col2_width-5))}..."
        fi
        printf "${MAUVE}│${RESET} ${TEXT}%-$((col1_width-1))s${RESET}${MAUVE}│${RESET} ${PEACH}%-$((col2_width-1))s${RESET}${MAUVE}│${RESET}\n" "$val1" "$val2"
        shift 2
    done
    
    # Bottom border
    echo -e "${MAUVE}└$(printf '─%.0s' $(seq 1 $col1_width))┴$(printf '─%.0s' $(seq 1 $col2_width))┘${RESET}"
}

# Variables for OS detection
OS_NAME=""
OS_VERSION=""
OS_ID=""
OS_ICON=""
UPDATE_CMD=""
UPGRADE_CMD=""
CLEAN_CMD=""
PKG_MANAGER=""
CURRENT_USER=""
USER_TYPE=""
USE_NERD_FONTS=false

# Nerd Font icons for Linux distributions (Unicode code points)
# Reference: https://www.nerdfonts.com/cheat-sheet
NF_ICON_FEDORA="\uf30a"          #  (U+F30A)
NF_ICON_OPENSUSE="\uf314"        #  (U+F314)
NF_ICON_UBUNTU="\uf31b"          #  (U+F31B)
NF_ICON_DEBIAN="\uf306"          #  (U+F306)
NF_ICON_ARCH="\uf303"            #  (U+F303)
NF_ICON_MANJARO="\uf312"         #  (U+F312)
NF_ICON_CENTOS="\uf304"          #  (U+F304)
NF_ICON_RHEL="\uf316"            #  (U+F316)
NF_ICON_LINUX="\uf17c"           #  (U+F17C) Generic Linux

# Emoji fallbacks (when Nerd Fonts are not available)
EMOJI_FEDORA="🎩"
EMOJI_OPENSUSE="🦎"
EMOJI_UBUNTU="🐧"
EMOJI_DEBIAN="🐧"
EMOJI_ARCH="🎯"
EMOJI_MANJARO="🎯"
EMOJI_CENTOS="📦"
EMOJI_RHEL="📦"
EMOJI_LINUX="🐧"

# Function to detect if Nerd Fonts are available
detect_nerd_fonts() {
    USE_NERD_FONTS=false
    
    # Method 1: Check if fontconfig can find Nerd Font families
    if command -v fc-list &> /dev/null; then
        local nerd_font_check=$(fc-list 2>/dev/null | grep -iE "nerd[_-]?font|NerdFont" | head -1)
        if [ -n "$nerd_font_check" ]; then
            USE_NERD_FONTS=true
            return 0
        fi
    fi
    
    # Method 2: Check common Nerd Font installation locations
    local font_dirs=(
        "$HOME/.local/share/fonts/NerdFonts"
        "$HOME/.local/share/fonts"
        "$HOME/.fonts"
        "/usr/share/fonts"
        "/usr/local/share/fonts"
        "$HOME/Library/Fonts"  # macOS
    )
    
    for font_dir in "${font_dirs[@]}"; do
        if [ -d "$font_dir" ]; then
            # Look for Nerd Font files (common patterns)
            if find "$font_dir" -type f \( -iname "*NerdFont*" -o -iname "*nerd-font*" -o -iname "*Nerd*Font*" \) 2>/dev/null | head -1 | grep -q .; then
                USE_NERD_FONTS=true
                return 0
            fi
            # Also check for specific Nerd Font family names in font files (if fc-query is available)
            if command -v fc-query &> /dev/null; then
                local font_files=$(find "$font_dir" -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null | head -5)
                if [ -n "$font_files" ]; then
                    while IFS= read -r font_file; do
                        if [ -n "$font_file" ] && fc-query --format="%{family}" "$font_file" 2>/dev/null | grep -qiE "nerd|NerdFont"; then
                            USE_NERD_FONTS=true
                            return 0
                        fi
                    done <<< "$font_files"
                fi
            fi
        fi
    done
    
    # Method 3: Check if we're in a terminal that commonly uses Nerd Fonts
    # and check TERM_PROGRAM environment variable
    if [ -n "$TERM_PROGRAM" ]; then
        case "$TERM_PROGRAM" in
            *kitty*|*alacritty*|*wezterm*|*foot*|*tmux*)
                # These terminals commonly use Nerd Fonts
                # Still prefer file-based detection, but this is a hint
                ;;
        esac
    fi
    
    # Method 4: Check current terminal font (if queryable)
    # This works on some systems where we can query the active font
    if command -v gsettings &> /dev/null && [ "$XDG_SESSION_TYPE" = "x11" ] 2>/dev/null; then
        local term_font=$(gsettings get org.gnome.desktop.interface monospace-font-name 2>/dev/null || echo "")
        if echo "$term_font" | grep -qiE "nerd|NerdFont"; then
            USE_NERD_FONTS=true
            return 0
        fi
    fi
    
    # Default to false if we can't detect
    USE_NERD_FONTS=false
}

# Function to get OS icon (Nerd Font or emoji fallback)
get_os_icon() {
    local os_id="$1"
    local icon=""
    local emoji=""
    
    case "$os_id" in
        fedora)
            icon="$NF_ICON_FEDORA"
            emoji="$EMOJI_FEDORA"
            ;;
        opensuse-tumbleweed|opensuse-leap|opensuse)
            icon="$NF_ICON_OPENSUSE"
            emoji="$EMOJI_OPENSUSE"
            ;;
        ubuntu)
            icon="$NF_ICON_UBUNTU"
            emoji="$EMOJI_UBUNTU"
            ;;
        debian)
            icon="$NF_ICON_DEBIAN"
            emoji="$EMOJI_DEBIAN"
            ;;
        arch)
            icon="$NF_ICON_ARCH"
            emoji="$EMOJI_ARCH"
            ;;
        manjaro)
            icon="$NF_ICON_MANJARO"
            emoji="$EMOJI_MANJARO"
            ;;
        centos|rhel|rocky|almalinux)
            if [ "$os_id" = "rhel" ]; then
                icon="$NF_ICON_RHEL"
                emoji="$EMOJI_RHEL"
            else
                icon="$NF_ICON_CENTOS"
                emoji="$EMOJI_CENTOS"
            fi
            ;;
        *)
            icon="$NF_ICON_LINUX"
            emoji="$EMOJI_LINUX"
            ;;
    esac
    
    if [ "$USE_NERD_FONTS" = true ]; then
        echo -e "$icon"
    else
        echo -e "$emoji"
    fi
}

# Function to get current user info
get_user_info() {
    if [ "$EUID" -eq 0 ]; then
        # Running as root
        if [ -n "$SUDO_USER" ]; then
            CURRENT_USER="$SUDO_USER (via sudo)"
            USER_TYPE="Regular User (elevated)"
        else
            CURRENT_USER="root"
            USER_TYPE="Root User"
        fi
    else
        CURRENT_USER="$USER"
        USER_TYPE="Regular User"
    fi
}

# Detect operating system
detect_os() {
    # First, detect if Nerd Fonts are available
    detect_nerd_fonts
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
        OS_ID=$ID
        
        # Get OS icon (Nerd Font or emoji)
        OS_ICON=$(get_os_icon "$OS_ID")
        
        case $ID in
            ubuntu|debian)
                # Check if apt-fast is available
                if command -v apt-fast &> /dev/null; then
                    print_info "apt-fast detected - using faster parallel downloads"
                    UPDATE_CMD="sudo apt-fast update"
                    UPGRADE_CMD="sudo apt-fast upgrade -y"
                    CLEAN_CMD="sudo apt-fast autoremove -y && sudo apt-fast autoclean -y"
                    PKG_MANAGER="APT-Fast"
                else
                    UPDATE_CMD="sudo apt update"
                    UPGRADE_CMD="sudo apt upgrade -y"
                    CLEAN_CMD="sudo apt autoremove -y && sudo apt autoclean -y"
                    PKG_MANAGER="APT"
                fi
                ;;
            arch|manjaro)
                UPDATE_CMD="sudo pacman -Sy"
                UPGRADE_CMD="sudo pacman -Syu --noconfirm"
                CLEAN_CMD="sudo pacman -Sc --noconfirm"
                PKG_MANAGER="Pacman"
                ;;
            fedora)
                UPDATE_CMD="sudo dnf check-update"
                UPGRADE_CMD="sudo dnf upgrade"
                CLEAN_CMD="sudo dnf autoremove -y && sudo dnf clean all"
                PKG_MANAGER="DNF"
                ;;
            opensuse-tumbleweed)
                UPDATE_CMD="sudo zypper refresh"
                UPGRADE_CMD="sudo zypper dup -y --auto-agree-with-licenses"
                CLEAN_CMD="sudo zypper clean -a"
                PKG_MANAGER="Zypper (Tumbleweed)"
                ;;
            opensuse-leap|opensuse)
                UPDATE_CMD="sudo zypper refresh"
                UPGRADE_CMD="sudo zypper update -y"
                CLEAN_CMD="sudo zypper clean -a"
                PKG_MANAGER="Zypper (Leap)"
                ;;
            *)
                print_error "Unsupported operating system: $OS_NAME"
                echo -e "${SUBTEXT1}  Supported: Ubuntu, Debian, Arch, Fedora, openSUSE${RESET}"
                exit 1
                ;;
        esac
    else
        OS_ICON=$(get_os_icon "linux")
        print_error "Cannot detect operating system"
        exit 1
    fi
}

# Main menu
show_menu() {
    clear
    print_header "Universal Linux System Update"
    
    # Get user info
    get_user_info
    
    # Detect OS
    print_section "Detecting Operating System"
    detect_os
    
    # Show OS with icon
    echo -e "${GREEN}✓${RESET} ${TEXT}Detected: ${RESET}${OS_ICON}  ${TEXT}$OS_NAME${RESET}"
    
    # Show Nerd Font status with better visibility
    if [ "$USE_NERD_FONTS" = true ]; then
        echo -e "${GREEN}✓${RESET} ${TEXT}Nerd Fonts: ${GREEN}Detected${RESET} ${SUBTEXT1}- Using enhanced icons${RESET}"
    else
        echo -e "${YELLOW}ℹ${RESET} ${TEXT}Nerd Fonts: ${YELLOW}Not detected${RESET} ${SUBTEXT1}- Using emoji fallback${RESET}"
        echo -e "${SUBTEXT1}  Tip: Use Option 2 to install Nerd Fonts for better icons${RESET}"
    fi
    
    # Show user information
    print_section "User Information"
    echo ""
    print_table "Property" "Value" \
        "Current User" "$CURRENT_USER" \
        "User Type" "$USER_TYPE" \
        "User ID (UID)" "$EUID" \
        "Home Directory" "$HOME"
    echo ""
    
    # Show instructions
    print_section "Instructions"
    echo -e "${TEXT}  This script will:${RESET}"
    echo -e "${TEAL}  1.${RESET} ${SUBTEXT1}Check for available updates${RESET}"
    echo -e "${TEAL}  2.${RESET} ${SUBTEXT1}Show you a summary of updates${RESET}"
    echo -e "${TEAL}  3.${RESET} ${SUBTEXT1}Ask for confirmation before upgrading${RESET}"
    echo -e "${TEAL}  4.${RESET} ${SUBTEXT1}Prompt for sudo password when you confirm${RESET}"
    echo -e "${TEAL}  5.${RESET} ${SUBTEXT1}Install updates and clean up${RESET}"
    
    print_section "Menu Options"
    echo ""
    echo -e "${BLUE}${BOLD}  [1]${RESET} ${TEXT}Update System${RESET}"
    echo -e "${LAVENDER}${BOLD}  [2]${RESET} ${TEXT}Install Nerd Fonts${RESET}"
    echo -e "${RED}${BOLD}  [q]${RESET} ${TEXT}Quit${RESET}"
    echo ""
    echo -n -e "${LAVENDER}${BOLD}Your choice: ${RESET}"
}

# Function to count upgradeable packages
count_updates() {
    local count=0
    
    case $OS_ID in
        ubuntu|debian)
            count=$(apt list --upgradable 2>/dev/null | grep -c "upgradable")
            if [ $count -gt 0 ]; then
                count=$((count-1))
            fi
            ;;
        arch|manjaro)
            count=$(pacman -Qu 2>/dev/null | wc -l)
            ;;
        fedora)
            count=$(dnf list updates 2>/dev/null | grep -v "^Last" | grep -v "^Available" | grep -v "^Updated" | grep -v "^$" | wc -l)
            ;;
        opensuse-tumbleweed)
            # For Tumbleweed, check if dup would update anything
            # This is the most reliable method for Tumbleweed's rolling release model
            local dup_output=$(sudo zypper dup --dry-run --auto-agree-with-licenses --no-recommends 2>&1)
            # Check if there are updates (if "Nothing to do" is not in output, there are updates)
            if echo "$dup_output" | grep -qi "Nothing to do\|No updates found"; then
                count=0
            else
                # Try to extract package count from summary lines
                # Look for patterns like "42 packages will be upgraded" or "The following 42 packages are going to be upgraded"
                local pkg_count=$(echo "$dup_output" | grep -iE "([0-9]+)\s+packages?\s+(are|will be|going to be)" | head -1 | grep -oE "[0-9]+" | head -1)
                if [ -n "$pkg_count" ] && [ "$pkg_count" -gt 0 ]; then
                    count=$pkg_count
                else
                    # Alternative: count lines that look like package names (indented lines starting with lowercase)
                    # This is a fallback if summary extraction fails
                    local line_count=$(echo "$dup_output" | grep -E "^\s+[a-z0-9]" | grep -v "The following\|packages\|to upgrade\|to install\|to remove\|to downgrade\|Nothing to do\|Loading\|Repository\|Warning\|Error" | wc -l)
                    if [ "$line_count" -gt 0 ]; then
                        count=$line_count
                    else
                        # Last resort: if dup --dry-run ran without "Nothing to do", assume there are updates
                        # Set to a non-zero value so the update process will run
                        count=1
                    fi
                fi
            fi
            ;;
        opensuse-leap|opensuse)
            # For Leap, use zypper lu (list updates)
            count=$(sudo zypper lu 2>/dev/null | grep -E "^v |^  " | grep -v "^$" | grep -v "S | Repository" | grep -v "^--" | wc -l)
            ;;
    esac
    
    echo $count
}

# Function to show update summary
show_update_summary() {
    print_section "Checking for Updates"
    print_status "Fetching latest package information..."
    
    if [ "$PKG_MANAGER" = "APT" ] || [ "$PKG_MANAGER" = "APT-Fast" ]; then
        $UPDATE_CMD 2>&1 | while IFS= read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done
        print_success "Package lists updated successfully"
    elif [ "$PKG_MANAGER" = "Pacman" ]; then
        $UPDATE_CMD 2>&1 | while IFS= read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done
        print_success "Package database synchronized"
    elif [ "$PKG_MANAGER" = "DNF" ]; then
        $UPDATE_CMD 2>&1 | while IFS= read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done
        print_success "Update check completed"
    elif [[ "$PKG_MANAGER" == "Zypper"* ]]; then
        $UPDATE_CMD 2>&1 | while IFS= read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done
        print_success "Repository metadata refreshed"
    fi
    
    # Count updates
    UPGRADABLE=$(count_updates)
    
    # Show system information
    print_section "System Information"
    echo ""
    print_table "Property" "Value" \
        "Operating System" "$OS_ICON  $OS_NAME" \
        "Version" "${OS_VERSION:-N/A}" \
        "Package Manager" "$PKG_MANAGER" \
        "Current User" "$CURRENT_USER" \
        "Updates Available" "$UPGRADABLE packages"
    echo ""
    
    if [ "$UPGRADABLE" -gt 0 ]; then
        print_info "Updates are available for your system"
        
        # Show updates in table
        print_section "Available Updates"
        
        echo ""
        echo -e "${MAUVE}┌────────────────────────────────────────┬────────────────────────────────────────┐${RESET}"
        printf "${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-38s${RESET} ${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-38s${RESET} ${MAUVE}│${RESET}\n" "Package Name" "Version"
        echo -e "${MAUVE}├────────────────────────────────────────┼────────────────────────────────────────┤${RESET}"
        
        case $OS_ID in
            ubuntu|debian)
                apt list --upgradable 2>/dev/null | tail -n +2 | head -15 | while IFS= read -r line; do
                    PKG_NAME=$(echo "$line" | cut -d'/' -f1)
                    PKG_VER=$(echo "$line" | awk '{print $2}')
                    # Truncate if needed
                    if [ ${#PKG_NAME} -gt 38 ]; then PKG_NAME="${PKG_NAME:0:35}..."; fi
                    if [ ${#PKG_VER} -gt 38 ]; then PKG_VER="${PKG_VER:0:35}..."; fi
                    printf "${MAUVE}│${RESET} ${TEXT}%-38s${RESET} ${MAUVE}│${RESET} ${PEACH}%-38s${RESET} ${MAUVE}│${RESET}\n" "$PKG_NAME" "$PKG_VER"
                done
                ;;
            arch|manjaro)
                pacman -Qu 2>/dev/null | head -15 | while IFS= read -r line; do
                    PKG_NAME=$(echo "$line" | awk '{print $1}')
                    PKG_VER=$(echo "$line" | awk '{print $4}')
                    if [ ${#PKG_NAME} -gt 38 ]; then PKG_NAME="${PKG_NAME:0:35}..."; fi
                    if [ ${#PKG_VER} -gt 38 ]; then PKG_VER="${PKG_VER:0:35}..."; fi
                    printf "${MAUVE}│${RESET} ${TEXT}%-38s${RESET} ${MAUVE}│${RESET} ${PEACH}%-38s${RESET} ${MAUVE}│${RESET}\n" "$PKG_NAME" "$PKG_VER"
                done
                ;;
            fedora)
                dnf list updates 2>/dev/null | grep -v "^Last" | grep -v "^Available" | grep -v "^Updated" | grep -v "^$" | head -15 | while IFS= read -r line; do
                    PKG_NAME=$(echo "$line" | awk '{print $1}')
                    PKG_VER=$(echo "$line" | awk '{print $2}')
                    if [ ${#PKG_NAME} -gt 38 ]; then PKG_NAME="${PKG_NAME:0:35}..."; fi
                    if [ ${#PKG_VER} -gt 38 ]; then PKG_VER="${PKG_VER:0:35}..."; fi
                    printf "${MAUVE}│${RESET} ${TEXT}%-38s${RESET} ${MAUVE}│${RESET} ${PEACH}%-38s${RESET} ${MAUVE}│${RESET}\n" "$PKG_NAME" "$PKG_VER"
                done
                ;;
            opensuse-tumbleweed)
                # For Tumbleweed, extract package list from dup --dry-run output
                local dup_output=$(sudo zypper dup --dry-run --auto-agree-with-licenses --no-recommends 2>&1)
                # Extract package names from the output (lines that look like package entries)
                echo "$dup_output" | grep -E "^\s+[a-z0-9]" | grep -v "The following\|packages\|to upgrade\|to install\|to remove\|to downgrade\|Nothing to do\|Loading\|Repository\|Warning\|Error\|^$" | head -15 | while IFS= read -r line; do
                    # Extract package name (first word, might have repo/ prefix)
                    PKG_NAME=$(echo "$line" | awk '{print $1}' | sed 's/.*\///' | sed 's/:.*$//')
                    # Try to extract version (look for version-like patterns)
                    PKG_VER=$(echo "$line" | awk '{for(i=2;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]/) {print $i; exit}}')
                    if [ -z "$PKG_VER" ]; then
                        # Try alternative version patterns
                        PKG_VER=$(echo "$line" | grep -oE "[0-9]+\.[0-9]+[^ ]*" | head -1)
                    fi
                    if [ -z "$PKG_VER" ]; then
                        PKG_VER="new version"
                    fi
                    if [ -z "$PKG_NAME" ] || [ ${#PKG_NAME} -lt 2 ]; then
                        continue
                    fi
                    if [ ${#PKG_NAME} -gt 38 ]; then PKG_NAME="${PKG_NAME:0:35}..."; fi
                    if [ ${#PKG_VER} -gt 38 ]; then PKG_VER="${PKG_VER:0:35}..."; fi
                    printf "${MAUVE}│${RESET} ${TEXT}%-38s${RESET} ${MAUVE}│${RESET} ${PEACH}%-38s${RESET} ${MAUVE}│${RESET}\n" "$PKG_NAME" "$PKG_VER"
                done
                ;;
            opensuse-leap|opensuse)
                # For Leap, show packages from zypper lu
                sudo zypper lu 2>/dev/null | grep -E "^v |^  " | grep -v "^$" | grep -v "S | Repository" | grep -v "^--" | head -15 | while IFS= read -r line; do
                    PKG_NAME=$(echo "$line" | awk '{print $3}')
                    PKG_VER=$(echo "$line" | awk 'NF>=7 {print $7} NF<7 {print "N/A"}')
                    if [ -z "$PKG_NAME" ] || [ "$PKG_NAME" = "Repository" ]; then
                        continue
                    fi
                    if [ ${#PKG_NAME} -gt 38 ]; then PKG_NAME="${PKG_NAME:0:35}..."; fi
                    if [ ${#PKG_VER} -gt 38 ]; then PKG_VER="${PKG_VER:0:35}..."; fi
                    printf "${MAUVE}│${RESET} ${TEXT}%-38s${RESET} ${MAUVE}│${RESET} ${PEACH}%-38s${RESET} ${MAUVE}│${RESET}\n" "$PKG_NAME" "$PKG_VER"
                done
                ;;
        esac
        
        if [ "$UPGRADABLE" -gt 15 ]; then
            printf "${MAUVE}│${RESET} ${OVERLAY1}%-38s${RESET} ${MAUVE}│${RESET} ${OVERLAY1}%-38s${RESET} ${MAUVE}│${RESET}\n" "... and $((UPGRADABLE-15)) more" ""
        fi
        echo -e "${MAUVE}└────────────────────────────────────────┴────────────────────────────────────────┘${RESET}"
        echo ""
        
        return 0
    else
        # System is up to date
        echo ""
        print_table "Status" "Message" \
            "System Status" "✓ Up to date" \
            "Updates Available" "0 packages" \
            "Action Required" "None"
        echo ""
        
        print_success "Your $OS_NAME system is already up to date!"
        print_info "No updates need to be installed"
        
        echo ""
        echo -e "${MAUVE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${MAUVE}${BOLD}║${RESET}                  ${GREEN}${BOLD}Nothing to do here!${RESET}                      ${MAUVE}${BOLD}║${RESET}"
        echo -e "${MAUVE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "${RED}${BOLD}  [q]${RESET} ${TEXT}Press 'q' to${RESET} ${RED}${BOLD}QUIT${RESET}"
        echo ""
        echo -n -e "${LAVENDER}${BOLD}Your choice: ${RESET}"
        
        while true; do
            read -n 1 choice
            case $choice in
                q|Q)
                    echo -e "${RED}${BOLD}q${RESET}\n"
                    clear
                    exit 0
                    ;;
                *)
                    continue
                    ;;
            esac
        done
    fi
}

# Function to perform system update
perform_update() {
    # Ask user to continue with clear instructions
    echo ""
    echo -e "${MAUVE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAUVE}${BOLD}║${RESET}          ${YELLOW}${BOLD}Do you want to Upgrade the System?${RESET}             ${MAUVE}${BOLD}║${RESET}"
    echo -e "${MAUVE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        echo -e "${SKY}${BOLD}  Running as root user${RESET} - No password needed"
    else
        echo -e "${PEACH}${BOLD}  Running as regular user${RESET} - You will be prompted for sudo password"
    fi
    
    echo ""
    echo -e "${GREEN}${BOLD}  [y]${RESET} ${TEXT}Press 'y' to${RESET} ${GREEN}${BOLD}UPGRADE${RESET} ${TEXT}the system${RESET}"
    echo -e "${RED}${BOLD}  [q]${RESET} ${TEXT}Press 'q' to${RESET} ${RED}${BOLD}QUIT${RESET} ${TEXT}without upgrading${RESET}"
    echo ""
    echo -n -e "${LAVENDER}${BOLD}Your choice: ${RESET}"
    
    while true; do
        read -n 1 choice
        case $choice in
            y|Y)
                echo -e "${GREEN}${BOLD}y${RESET}\n"
                break
                ;;
            q|Q)
                echo -e "${RED}${BOLD}q${RESET}\n"
                echo ""
                print_warning "System upgrade cancelled by user"
                print_info "No changes were made to your system"
                echo -e "\n${TEXT}Press any key to exit...${RESET}"
                read -n 1 -s
                clear
                exit 0
                ;;
            *)
                continue
                ;;
        esac
    done
    
    # Store initial package count
    local initial_count=$UPGRADABLE
    
    # Upgrade packages
    print_section "Upgrading Packages"
    
    # Show different message based on user type
    if [ "$EUID" -eq 0 ]; then
        print_status "Installing updates as root user..."
    else
        print_status "Installing updates (enter your sudo password when prompted)..."
    fi
    
    if $UPGRADE_CMD 2>&1 | while IFS= read -r line; do 
        if echo "$line" | grep -qE "Setting up|Unpacking|Processing|Installing|Upgrading|Retrieving"; then
            echo -e "${PEACH}  ⟳ $line${RESET}"
        else
            echo -e "${SUBTEXT1}  $line${RESET}"
        fi
    done; then
        print_success "Packages upgraded successfully"
    else
        print_error "Failed to upgrade packages"
        exit 1
    fi
    
    # Autoremove
    print_section "Cleaning Up"
    print_status "Removing unnecessary packages..."
    if $CLEAN_CMD 2>&1 | while IFS= read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done; then
        print_success "Cleanup completed"
    else
        print_warning "Cleanup had some issues"
    fi
    
    # Final summary
    print_header "Update Complete!"
    
    print_section "Update Summary"
    echo ""
    print_table "Component" "Status" \
        "Operating System" "$OS_ICON  $OS_NAME" \
        "Package Manager" "$PKG_MANAGER" \
        "Current User" "$CURRENT_USER" \
        "Packages Updated" "$initial_count packages" \
        "System Status" "✓ Up to date"
    echo ""
    
    print_success "Your $OS_NAME system is now up to date"
    
    # Check if reboot is required
    if [ -f /var/run/reboot-required ]; then
        echo ""
        print_warning "A system reboot is required"
        echo -e "${YELLOW}  Run: ${BOLD}sudo reboot${RESET}"
    fi
    
    echo -e "\n${TEXT}Press any key to exit...${RESET}"
    read -n 1 -s
    clear
}

# Function to install Nerd Fonts
install_nerd_fonts() {
    clear
    print_header "Nerd Fonts Installer"
    
    print_section "About Nerd Fonts"
    echo ""
    echo -e "${TEXT}Nerd Fonts are patched developer fonts with extra glyphs from${RESET}"
    echo -e "${TEXT}popular icon fonts. They provide beautiful OS logos and icons.${RESET}"
    echo ""
    
    print_section "Available Nerd Fonts"
    echo ""
    echo -e "${LAVENDER}${BOLD} 1.${RESET} ${TEXT}FiraCode Nerd Font${RESET} ${SUBTEXT1}(Ligatures, popular for coding)${RESET}"
    echo -e "${LAVENDER}${BOLD} 2.${RESET} ${TEXT}JetBrainsMono Nerd Font${RESET} ${SUBTEXT1}(Designed by JetBrains)${RESET}"
    echo -e "${LAVENDER}${BOLD} 3.${RESET} ${TEXT}Hack Nerd Font${RESET} ${SUBTEXT1}(Clean, readable monospace)${RESET}"
    echo -e "${LAVENDER}${BOLD} 4.${RESET} ${TEXT}Meslo Nerd Font${RESET} ${SUBTEXT1}(Customized Menlo font)${RESET}"
    echo -e "${LAVENDER}${BOLD} 5.${RESET} ${TEXT}UbuntuMono Nerd Font${RESET} ${SUBTEXT1}(Ubuntu's monospace font)${RESET}"
    echo -e "${LAVENDER}${BOLD} 6.${RESET} ${TEXT}DejaVuSansMono Nerd Font${RESET} ${SUBTEXT1}(Classic, widely compatible)${RESET}"
    echo -e "${LAVENDER}${BOLD} 7.${RESET} ${TEXT}Install ALL Fonts${RESET} ${SUBTEXT1}(Downloads all above fonts)${RESET}"
    echo ""
    echo -e "${RED}${BOLD} [b]${RESET} ${TEXT}Back to Main Menu${RESET}"
    echo ""
    echo -n -e "${LAVENDER}${BOLD}Select font to install (1-7) or 'b': ${RESET}"
    
    read choice
    
    case $choice in
        1) install_single_font "FiraCode" "FiraCode" ;;
        2) install_single_font "JetBrainsMono" "JetBrains Mono" ;;
        3) install_single_font "Hack" "Hack" ;;
        4) install_single_font "Meslo" "Meslo" ;;
        5) install_single_font "UbuntuMono" "Ubuntu Mono" ;;
        6) install_single_font "DejaVuSansMono" "DejaVu Sans Mono" ;;
        7) install_all_fonts ;;
        b|B) return ;;
        *)
            print_warning "Invalid choice"
            sleep 1
            install_nerd_fonts
            ;;
    esac
}

# Function to install a single Nerd Font
install_single_font() {
    local font_name="$1"
    local display_name="$2"
    
    clear
    print_header "Installing $display_name Nerd Font"
    
    print_section "Download and Install"
    print_status "Downloading $display_name..."
    
    # Create fonts directory
    local font_dir="$HOME/.local/share/fonts/NerdFonts"
    mkdir -p "$font_dir"
    
    # Download URL
    local download_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
    local temp_file="/tmp/${font_name}.zip"
    
    echo ""
    if wget -q --show-progress "$download_url" -O "$temp_file" 2>&1 | while IFS= read -r line; do
        echo -e "${PEACH}  $line${RESET}"
    done; then
        print_success "Downloaded successfully"
        
        print_status "Extracting font files..."
        if unzip -q -o "$temp_file" -d "$font_dir/$font_name" 2>&1 | while IFS= read -r line; do
            echo -e "${SUBTEXT1}  $line${RESET}"
        done; then
            print_success "Extracted successfully"
            
            # Clean up
            rm -f "$temp_file"
            
            # Update font cache
            print_status "Updating font cache..."
            if fc-cache -f "$font_dir" &>/dev/null; then
                print_success "Font cache updated"
            fi
            
            print_header "Installation Complete!"
            print_success "$display_name Nerd Font installed successfully"
            echo ""
            print_info "Font location: $font_dir/$font_name"
            print_warning "Please restart your terminal to use the new font"
            echo ""
            print_info "Configure your terminal to use: ${BOLD}$display_name Nerd Font${RESET}"
        else
            print_error "Failed to extract font files"
            rm -f "$temp_file"
        fi
    else
        print_error "Failed to download $display_name"
        print_info "Please check your internet connection"
    fi
    
    echo ""
    echo -e "${TEXT}Press any key to return to Nerd Fonts menu...${RESET}"
    read -n 1 -s
    install_nerd_fonts
}

# Function to install all Nerd Fonts
install_all_fonts() {
    clear
    print_header "Installing All Nerd Fonts"
    
    echo ""
    print_warning "This will download and install 6 Nerd Fonts (~500MB total)"
    echo ""
    echo -e "${YELLOW}${BOLD}Continue with installation?${RESET}"
    echo -e "${GREEN}${BOLD}  [y]${RESET} ${TEXT}Yes, install all fonts${RESET}"
    echo -e "${RED}${BOLD}  [n]${RESET} ${TEXT}No, go back${RESET}"
    echo ""
    echo -n -e "${LAVENDER}${BOLD}Your choice: ${RESET}"
    
    read -n 1 choice
    echo ""
    
    if [[ "$choice" != "y" ]] && [[ "$choice" != "Y" ]]; then
        install_nerd_fonts
        return
    fi
    
    echo ""
    
    local fonts=("FiraCode:FiraCode" "JetBrainsMono:JetBrains Mono" "Hack:Hack" "Meslo:Meslo" "UbuntuMono:Ubuntu Mono" "DejaVuSansMono:DejaVu Sans Mono")
    local font_dir="$HOME/.local/share/fonts/NerdFonts"
    local installed=0
    local failed=0
    
    mkdir -p "$font_dir"
    
    for font_info in "${fonts[@]}"; do
        local font_name="${font_info%%:*}"
        local display_name="${font_info##*:}"
        
        print_section "Installing $display_name"
        print_status "Downloading..."
        
        local download_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
        local temp_file="/tmp/${font_name}.zip"
        
        if wget -q --show-progress "$download_url" -O "$temp_file" 2>&1 | grep -o "[0-9]\+%" | tail -1 | while read percent; do
            echo -ne "\r${PEACH}  Progress: $percent${RESET}"
        done; then
            echo ""
            print_status "Extracting..."
            if unzip -q -o "$temp_file" -d "$font_dir/$font_name" 2>&1; then
                rm -f "$temp_file"
                print_success "$display_name installed"
                ((installed++))
            else
                print_error "Failed to extract $display_name"
                rm -f "$temp_file"
                ((failed++))
            fi
        else
            print_error "Failed to download $display_name"
            ((failed++))
        fi
        echo ""
    done
    
    # Update font cache
    print_section "Finalizing Installation"
    print_status "Updating font cache..."
    if fc-cache -f "$font_dir" &>/dev/null; then
        print_success "Font cache updated"
    fi
    
    # Summary
    print_header "Installation Summary"
    echo ""
    print_table "Result" "Count" \
        "Successfully Installed" "$installed fonts" \
        "Failed" "$failed fonts" \
        "Total Processed" "6 fonts"
    echo ""
    
    if [ $installed -eq 6 ]; then
        print_success "All Nerd Fonts installed successfully!"
    elif [ $installed -gt 0 ]; then
        print_warning "Some fonts were installed, but $failed failed"
    else
        print_error "Failed to install Nerd Fonts"
    fi
    
    echo ""
    print_info "Fonts location: $font_dir"
    print_warning "Please restart your terminal to use the new fonts"
    
    echo ""
    echo -e "${TEXT}Press any key to return to Nerd Fonts menu...${RESET}"
    read -n 1 -s
    install_nerd_fonts
}

# Main function
main() {
    while true; do
        show_menu
        read -n 1 choice
        echo ""
        
        case $choice in
            1)
                if show_update_summary; then
                    perform_update
                fi
                ;;
            2)
                install_nerd_fonts
                ;;
            q|Q)
                clear
                print_header "Goodbye!"
                echo -e "${TEXT}Thank you for using Universal Linux System Update${RESET}\n"
                exit 0
                ;;
            *)
                print_warning "Invalid option. Please press 1, 2, or q"
                sleep 1
                ;;
        esac
    done
}

# Start the script
main