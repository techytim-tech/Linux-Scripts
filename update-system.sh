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

# Function to print a table
print_table() {
    local col1_width=25
    local col2_width=50
    
    # Top border
    echo -e "${MAUVE}┌$(printf '─%.0s' $(seq 1 $col1_width))┬$(printf '─%.0s' $(seq 1 $col2_width))┐${RESET}"
    
    # Header
    printf "${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-${col1_width}s${RESET}${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-${col2_width}s${RESET}${MAUVE}│${RESET}\n" "$1" "$2"
    
    # Middle border
    echo -e "${MAUVE}├$(printf '─%.0s' $(seq 1 $col1_width))┼$(printf '─%.0s' $(seq 1 $col2_width))┤${RESET}"
    
    # Content rows
    shift 2
    while [ $# -gt 0 ]; do
        printf "${MAUVE}│${RESET} ${TEXT}%-${col1_width}s${RESET}${MAUVE}│${RESET} ${PEACH}%-${col2_width}s${RESET}${MAUVE}│${RESET}\n" "$1" "$2"
        shift 2
    done
    
    # Bottom border
    echo -e "${MAUVE}└$(printf '─%.0s' $(seq 1 $col1_width))┴$(printf '─%.0s' $(seq 1 $col2_width))┘${RESET}"
}

# Variables for OS detection
OS_NAME=""
OS_VERSION=""
UPDATE_CMD=""
UPGRADE_CMD=""
CLEAN_CMD=""

# Detect operating system
print_header "Universal Linux System Update"

print_section "Detecting Operating System"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERSION=$VERSION_ID
    
    case $ID in
        ubuntu|debian)
            print_success "Detected: $OS_NAME"
            
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
            print_success "Detected: $OS_NAME"
            UPDATE_CMD="sudo pacman -Sy"
            UPGRADE_CMD="sudo pacman -Syu --noconfirm"
            CLEAN_CMD="sudo pacman -Sc --noconfirm"
            PKG_MANAGER="Pacman"
            ;;
        fedora)
            print_success "Detected: $OS_NAME"
            UPDATE_CMD="sudo dnf check-update"
            UPGRADE_CMD="sudo dnf upgrade -y"
            CLEAN_CMD="sudo dnf autoremove -y && sudo dnf clean all"
            PKG_MANAGER="DNF"
            ;;
        opensuse-tumbleweed|opensuse-leap|opensuse)
            print_success "Detected: $OS_NAME"
            UPDATE_CMD="sudo zypper refresh"
            UPGRADE_CMD="sudo zypper update -y"
            CLEAN_CMD="sudo zypper clean -a"
            PKG_MANAGER="Zypper"
            ;;
        *)
            print_error "Unsupported operating system: $OS_NAME"
            echo -e "${SUBTEXT1}  Supported: Ubuntu, Debian, Arch Linux, Fedora, openSUSE Tumbleweed${RESET}"
            exit 1
            ;;
    esac
else
    print_error "Cannot detect operating system"
    exit 1
fi

# Show instructions
print_section "Instructions"
echo -e "${TEXT}  This script will:${RESET}"
echo -e "${TEAL}  1.${RESET} ${SUBTEXT1}Check for available updates${RESET}"
echo -e "${TEAL}  2.${RESET} ${SUBTEXT1}Show you a summary of updates${RESET}"
echo -e "${TEAL}  3.${RESET} ${SUBTEXT1}Ask for confirmation before upgrading${RESET}"
echo -e "${TEAL}  4.${RESET} ${SUBTEXT1}Prompt for sudo password when you confirm${RESET}"
echo -e "${TEAL}  5.${RESET} ${SUBTEXT1}Install updates and clean up${RESET}"

# Update package lists
print_section "Checking for Updates"
print_status "Fetching latest package information..."

if [ "$PKG_MANAGER" = "APT" ]; then
    if $UPDATE_CMD 2>&1 | while IFS= read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done; then
        print_success "Package lists updated successfully"
    else
        print_error "Failed to update package lists"
        exit 1
    fi
elif [ "$PKG_MANAGER" = "Pacman" ]; then
    if $UPDATE_CMD 2>&1 | while IFS= read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done; then
        print_success "Package database synchronized"
    else
        print_error "Failed to sync package database"
        exit 1
    fi
elif [ "$PKG_MANAGER" = "DNF" ]; then
    $UPDATE_CMD 2>&1 | while IFS= read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done
    print_success "Update check completed"
elif [ "$PKG_MANAGER" = "Zypper" ]; then
    if $UPDATE_CMD 2>&1 | while IFS= read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done; then
        print_success "Repository metadata refreshed"
    else
        print_error "Failed to refresh repositories"
        exit 1
    fi
fi

# Count upgradeable packages
print_section "System Information"

UPGRADABLE=0
if [ "$PKG_MANAGER" = "APT" ]; then
    UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
    UPGRADABLE=$((UPGRADABLE-1))
elif [ "$PKG_MANAGER" = "Pacman" ]; then
    UPGRADABLE=$(pacman -Qu 2>/dev/null | wc -l)
elif [ "$PKG_MANAGER" = "DNF" ]; then
    UPGRADABLE=$(dnf list updates 2>/dev/null | grep -v "^Last" | grep -v "^Available" | grep -v "^Updated" | wc -l)
elif [ "$PKG_MANAGER" = "Zypper" ]; then
    UPGRADABLE=$(zypper list-updates 2>/dev/null | grep "v |" | wc -l)
fi

# Display system information table
echo ""
print_table "Property" "Value" \
    "Operating System" "$OS_NAME" \
    "Version" "${OS_VERSION:-N/A}" \
    "Package Manager" "$PKG_MANAGER" \
    "Updates Available" "$UPGRADABLE packages"
echo ""

if [ "$UPGRADABLE" -gt 0 ]; then
    print_info "Updates are available for your system"
    
    # Show upgradeable packages in a table
    print_section "Available Updates"
    
    if [ "$PKG_MANAGER" = "APT" ]; then
        # Get package list and format for table
        PACKAGES=$(apt list --upgradable 2>/dev/null | tail -n +2 | head -15)
        echo ""
        echo -e "${MAUVE}┌──────────────────────────────────┬──────────────────────────────────┐${RESET}"
        printf "${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-32s${RESET} ${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-32s${RESET} ${MAUVE}│${RESET}\n" "Package Name" "Version"
        echo -e "${MAUVE}├──────────────────────────────────┼──────────────────────────────────┤${RESET}"
        
        echo "$PACKAGES" | while IFS= read -r line; do
            PKG_NAME=$(echo "$line" | cut -d'/' -f1)
            PKG_VER=$(echo "$line" | awk '{print $2}')
            printf "${MAUVE}│${RESET} ${TEXT}%-32s${RESET} ${MAUVE}│${RESET} ${PEACH}%-32s${RESET} ${MAUVE}│${RESET}\n" "$PKG_NAME" "$PKG_VER"
        done
        
        if [ "$UPGRADABLE" -gt 15 ]; then
            printf "${MAUVE}│${RESET} ${OVERLAY1}%-32s${RESET} ${MAUVE}│${RESET} ${OVERLAY1}%-32s${RESET} ${MAUVE}│${RESET}\n" "... and $((UPGRADABLE-15)) more" ""
        fi
        echo -e "${MAUVE}└──────────────────────────────────┴──────────────────────────────────┘${RESET}"
        
    elif [ "$PKG_MANAGER" = "Pacman" ]; then
        PACKAGES=$(pacman -Qu 2>/dev/null | head -15)
        echo ""
        echo -e "${MAUVE}┌──────────────────────────────────┬──────────────────────────────────┐${RESET}"
        printf "${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-32s${RESET} ${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-32s${RESET} ${MAUVE}│${RESET}\n" "Package Name" "New Version"
        echo -e "${MAUVE}├──────────────────────────────────┼──────────────────────────────────┤${RESET}"
        
        echo "$PACKAGES" | while IFS= read -r line; do
            PKG_NAME=$(echo "$line" | awk '{print $1}')
            PKG_VER=$(echo "$line" | awk '{print $4}')
            printf "${MAUVE}│${RESET} ${TEXT}%-32s${RESET} ${MAUVE}│${RESET} ${PEACH}%-32s${RESET} ${MAUVE}│${RESET}\n" "$PKG_NAME" "$PKG_VER"
        done
        
        if [ "$UPGRADABLE" -gt 15 ]; then
            printf "${MAUVE}│${RESET} ${OVERLAY1}%-32s${RESET} ${MAUVE}│${RESET} ${OVERLAY1}%-32s${RESET} ${MAUVE}│${RESET}\n" "... and $((UPGRADABLE-15)) more" ""
        fi
        echo -e "${MAUVE}└──────────────────────────────────┴──────────────────────────────────┘${RESET}"
        
    elif [ "$PKG_MANAGER" = "DNF" ]; then
        PACKAGES=$(dnf list updates 2>/dev/null | grep -v "^Last" | grep -v "^Available" | grep -v "^Updated" | head -15)
        echo ""
        echo -e "${MAUVE}┌──────────────────────────────────┬──────────────────────────────────┐${RESET}"
        printf "${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-32s${RESET} ${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-32s${RESET} ${MAUVE}│${RESET}\n" "Package Name" "Version"
        echo -e "${MAUVE}├──────────────────────────────────┼──────────────────────────────────┤${RESET}"
        
        echo "$PACKAGES" | while IFS= read -r line; do
            PKG_NAME=$(echo "$line" | awk '{print $1}')
            PKG_VER=$(echo "$line" | awk '{print $2}')
            printf "${MAUVE}│${RESET} ${TEXT}%-32s${RESET} ${MAUVE}│${RESET} ${PEACH}%-32s${RESET} ${MAUVE}│${RESET}\n" "$PKG_NAME" "$PKG_VER"
        done
        
        if [ "$UPGRADABLE" -gt 15 ]; then
            printf "${MAUVE}│${RESET} ${OVERLAY1}%-32s${RESET} ${MAUVE}│${RESET} ${OVERLAY1}%-32s${RESET} ${MAUVE}│${RESET}\n" "... and $((UPGRADABLE-15)) more" ""
        fi
        echo -e "${MAUVE}└──────────────────────────────────┴──────────────────────────────────┘${RESET}"
        
    elif [ "$PKG_MANAGER" = "Zypper" ]; then
        PACKAGES=$(zypper list-updates 2>/dev/null | grep "v |" | head -15)
        echo ""
        echo -e "${MAUVE}┌──────────────────────────────────┬──────────────────────────────────┐${RESET}"
        printf "${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-32s${RESET} ${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-32s${RESET} ${MAUVE}│${RESET}\n" "Package Name" "Version"
        echo -e "${MAUVE}├──────────────────────────────────┼──────────────────────────────────┤${RESET}"
        
        echo "$PACKAGES" | while IFS= read -r line; do
            PKG_NAME=$(echo "$line" | awk '{print $3}')
            PKG_VER=$(echo "$line" | awk '{print $7}')
            printf "${MAUVE}│${RESET} ${TEXT}%-32s${RESET} ${MAUVE}│${RESET} ${PEACH}%-32s${RESET} ${MAUVE}│${RESET}\n" "$PKG_NAME" "$PKG_VER"
        done
        
        if [ "$UPGRADABLE" -gt 15 ]; then
            printf "${MAUVE}│${RESET} ${OVERLAY1}%-32s${RESET} ${MAUVE}│${RESET} ${OVERLAY1}%-32s${RESET} ${MAUVE}│${RESET}\n" "... and $((UPGRADABLE-15)) more" ""
        fi
        echo -e "${MAUVE}└──────────────────────────────────┴──────────────────────────────────┘${RESET}"
    fi
    echo ""
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
        read -n 1 -s choice
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
    read -n 1 -s choice
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

# Upgrade packages
print_section "Upgrading Packages"

# Show different message based on user type
if [ "$EUID" -eq 0 ]; then
    print_status "Installing updates as root user..."
else
    print_status "Installing updates (enter your sudo password when prompted)..."
fi

if $UPGRADE_CMD 2>&1 | while IFS= read -r line; do 
    if echo "$line" | grep -qE "Setting up|Unpacking|Processing|Installing|Upgrading"; then
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

# Cleanup
print_section "Cleaning Up"
print_status "Removing unnecessary packages and cleaning cache..."
if $CLEAN_CMD 2>&1 | while IFS= read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done; then
    print_success "Cleanup completed"
else
    print_warning "Cleanup had some issues"
fi

# Final message
print_header "Update Complete!"
print_success "Your $OS_NAME system is now up to date"

# Check if reboot is required (mainly for Debian-based systems)
if [ -f /var/run/reboot-required ]; then
    echo ""
    print_warning "A system reboot is required"
    echo -e "${YELLOW}  Run: ${BOLD}sudo reboot${RESET}"
fi

echo -e "\n${TEXT}Press any key to exit...${RESET}"
read -n 1 -s
clear