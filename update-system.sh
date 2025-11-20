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
    
    echo -e "${MAUVE}┌$(printf '─%.0s' $(seq 1 $col1_width))┬$(printf '─%.0s' $(seq 1 $col2_width))┐${RESET}"
    local header1="$1"
    local header2="$2"
    printf "${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-$((col1_width-1))s${RESET}${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-$((col2_width-1))s${RESET}${MAUVE}│${RESET}\n" "$header1" "$header2"
    echo -e "${MAUVE}├$(printf '─%.0s' $(seq 1 $col1_width))┼$(printf '─%.0s' $(seq 1 $col2_width))┤${RESET}"
    
    shift 2
    while [ $# -gt 0 ]; do
        local val1="$1"
        local val2="$2"
        if [ ${#val1} -gt $((col1_width-2)) ]; then val1="${val1:0:$((col1_width-5))}..."; fi
        if [ ${#val2} -gt $((col2_width-2)) ]; then val2="${val2:0:$((col2_width-5))}..."; fi
        printf "${MAUVE}│${RESET} ${TEXT}%-$((col1_width-1))s${RESET}${MAUVE}│${RESET} ${PEACH}%-$((col2_width-1))s${RESET}${MAUVE}│${RESET}\n" "$val1" "$val2"
        shift 2
    done
    
    echo -e "${MAUVE}└$(printf '─%.0s' $(seq 1 $col1_width))┴$(printf '─%.0s' $(seq 1 $col2_width))┘${RESET}"
}

# Variables
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
SUDO_CMD=""

# Nerd Font icons
NF_ICON_FEDORA=""
NF_ICON_OPENSUSE=""
NF_ICON_UBUNTU="󰕈"
NF_ICON_DEBIAN=""
NF_ICON_ARCH=""
NF_ICON_MANJARO=""
NF_ICON_CENTOS=""
NF_ICON_RHEL=""
NF_ICON_LINUX=""

# Emoji fallbacks
EMOJI_FEDORA="HAT"
EMOJI_OPENSUSE="LIZARD"
EMOJI_UBUNTU="PENGUIN"
EMOJI_DEBIAN="PENGUIN"
EMOJI_ARCH="TARGET"
EMOJI_MANJARO="TARGET"
EMOJI_CENTOS="BOX"
EMOJI_RHEL="BOX"
EMOJI_LINUX="PENGUIN"

# Detect Nerd Fonts
detect_nerd_fonts() {
    USE_NERD_FONTS=false
    if command -v fc-list &>/dev/null && fc-list | grep -qi "Nerd Font"; then
        USE_NERD_FONTS=true
    elif [ -d "$HOME/.local/share/fonts" ] && find "$HOME/.local/share/fonts" -iname "*Nerd*" | grep -q .; then
        USE_NERD_FONTS=true
    fi
}

get_os_icon() {
    local os_id="$1"
    local icon="" emoji=""
    case "$os_id" in
        fedora) icon="$NF_ICON_FEDORA"; emoji="$EMOJI_FEDORA" ;;
        opensuse*) icon="$NF_ICON_OPENSUSE"; emoji="$EMOJI_OPENSUSE" ;;
        ubuntu) icon="$NF_ICON_UBUNTU"; emoji="$EMOJI_UBUNTU" ;;
        debian) icon="$NF_ICON_DEBIAN"; emoji="$EMOJI_DEBIAN" ;;
        arch) icon="$NF_ICON_ARCH"; emoji="$EMOJI_ARCH" ;;
        manjaro) icon="$NF_ICON_MANJARO"; emoji="$EMOJI_MANJARO" ;;
        centos|rhel|rocky|almalinux) icon="$NF_ICON_RHEL"; emoji="$EMOJI_RHEL" ;;
        *) icon="$NF_ICON_LINUX"; emoji="$EMOJI_LINUX" ;;
    esac
    $USE_NERD_FONTS && echo -e "$icon" || echo -e "$emoji"
}

get_user_info() {
    if [ "$EUID" -eq 0 ]; then
        SUDO_CMD=""
        CURRENT_USER="${SUDO_USER:-root}"
        USER_TYPE="Root User"
    else
        SUDO_CMD="sudo "
        CURRENT_USER="$USER"
        USER_TYPE="Regular User"
    fi
}

detect_os() {
    detect_nerd_fonts
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
        OS_ID=$ID
        OS_ICON=$(get_os_icon "$OS_ID")

        case $ID in
            ubuntu|debian)
                if command -v apt-fast &>/dev/null; then
                    UPDATE_CMD="${SUDO_CMD}apt-fast update"
                    UPGRADE_CMD="${SUDO_CMD}apt-fast upgrade -y"
                    CLEAN_CMD="${SUDO_CMD}apt-fast autoremove -y && ${SUDO_CMD}apt-fast autoclean"
                    PKG_MANAGER="APT-Fast"
                else
                    UPDATE_CMD="${SUDO_CMD}apt update"
                    UPGRADE_CMD="${SUDO_CMD}apt upgrade -y"
                    CLEAN_CMD="${SUDO_CMD}apt autoremove -y && ${SUDO_CMD}apt autoclean"
                    PKG_MANAGER="APT"
                fi
                ;;
            arch|manjaro)
                UPDATE_CMD="${SUDO_CMD}pacman -Sy"
                UPGRADE_CMD="${SUDO_CMD}pacman -Syu --noconfirm"
                CLEAN_CMD="${SUDO_CMD}pacman -Sc --noconfirm"
                PKG_MANAGER="Pacman"
                ;;
            fedora)
                UPDATE_CMD="${SUDO_CMD}dnf check-update"
                UPGRADE_CMD="${SUDO_CMD}dnf upgrade -y"
                CLEAN_CMD="${SUDO_CMD}dnf autoremove -y && ${SUDO_CMD}dnf clean all"
                PKG_MANAGER="DNF"
                ;;
            opensuse-tumbleweed)
                UPDATE_CMD="${SUDO_CMD}zypper --non-interactive refresh"
                UPGRADE_CMD="${SUDO_CMD}zypper --non-interactive dup --auto-agree-with-licenses --no-recommends"
                CLEAN_CMD="${SUDO_CMD}zypper clean -a"
                PKG_MANAGER="Zypper (Tumbleweed)"
                ;;
            opensuse-leap|opensuse)
                UPDATE_CMD="${SUDO_CMD}zypper refresh"
                UPGRADE_CMD="${SUDO_CMD}zypper update -y"
                CLEAN_CMD="${SUDO_CMD}zypper clean -a"
                PKG_MANAGER="Zypper (Leap)"
                ;;
            *)
                print_error "Unsupported OS: $OS_NAME"
                exit 1
                ;;
        esac
    else
        print_error "Cannot detect OS"
        exit 1
    fi
}

# CRUCIAL: Fixed count_updates for Tumbleweed
count_updates() {
    local count=0
    case $OS_ID in
        ubuntu|debian)
            count=$(apt list --upgradable 2>/dev/null | grep -c "/") || count=0
            [ "$count" -gt 0 ] && count=$((count - 1))
            ;;
        arch|manjaro)
            count=$(pacman -Qu 2>/dev/null | wc -l)
            ;;
        fedora)
            count=$(dnf list updates 2>/dev/null | grep -vE "^(Last|Available|Updated)" | wc -l)
            ;;
        opensuse-tumbleweed)
            local output
            output=$(${SUDO_CMD}zypper --non-interactive dup --dry-run --auto-agree-with-licenses --no-recommends 2>&1)
            if echo "$output" | grep -q "Nothing to do."; then
                count=0
            else
                count=$(echo "$output" | grep -oiE "[0-9]+ package" | head -1 | grep -oE "[0-9]+")
                [ -z "$count" ] || [ "$count" -eq 0 ] && count=$(echo "$output" | grep -E "^[[:space:]]+[a-zA-Z]" | wc -l)
                [ -z "$count" ] || [ "$count" -eq 0 ] && count=1
            fi
            ;;
        opensuse-leap|opensuse,openSUSE)
            count=$(${SUDO_CMD}zypper lu 2>/dev/null | grep -E "^v |^  " | grep -v "Repository" | wc -l)
            ;;
    esac
    echo "$count"
}

show_update_summary() {
    print_section "Checking for Updates"
    print_status "Refreshing package data..."
    $UPDATE_CMD 2>&1 | while read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done
    print_success "Package data refreshed"

    UPGRADABLE=$(count_updates)

    print_section "System Information"
    print_table "Property" "Value" \
        "Operating System" "$OS_ICON  $OS_NAME" \
        "Version" "${OS_VERSION:-N/A}" \
        "Package Manager" "$PKG_MANAGER" \
        "Updates Available" "$UPGRADABLE packages"

    if [ "$UPGRADABLE" -gt 0 ]; then
        print_info "$UPGRADABLE update(s) available"
        print_section "Available Updates"
        echo -e "${MAUVE}┌────────────────────────────────────────┬────────────────────────────────────────┐${RESET}"
        printf "${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-38s${RESET} ${MAUVE}│${RESET} ${LAVENDER}${BOLD}%-38s${RESET} ${MAUVE}│${RESET}\n" "Package" "Action"
        echo -e "${MAUVE}├────────────────────────────────────────┼────────────────────────────────────────┤${RESET}"

        case $OS_ID in
            ubuntu|debian)
                apt list --upgradable 2>/dev/null | tail -n +2 | head -15 | while read -r line; do
                    name=$(echo "$line" | cut -d'/' -f1)
                    ver=$(echo "$line" | awk '{print $2}')
                    printf "${MAUVE}│${RESET} ${TEXT}%-38s${RESET} ${MAUVE}│${RESET} ${PEACH}%-38s${RESET} ${MAUVE}│${RESET}\n" "$name" "→ $ver"
                done
                ;;
            arch|manjaro)
                pacman -Qu 2>/dev/null | head -15 | awk '{printf "${MAUVE}│${RESET} ${TEXT}%-38s${RESET} ${MAUVE}│${RESET} ${PEACH}%-38s${RESET} ${MAUVE}│${RESET}\n", $1, $2" -> "$4}'
                ;;
            fedora)
                dnf list updates 2>/dev/null | tail -n +4 | head -15 | awk '{printf "${MAUVE}│${RESET} ${TEXT}%-38s${RESET} ${MAUVE}│${RESET} ${PEACH}%-38s${RESET} ${MAUVE}│${RESET}\n", $1, "→ "$2}'
                ;;
            opensuse-tumbleweed)
                print_status "Simulating distribution upgrade..."
                local output
                output=$(${SUDO_CMD}zypper --non-interactive dup --dry-run --auto-agree-with-licenses --no-recommends 2>&1)
                echo "$output" | grep -E "^[[:space:]]+[a-z]" | head -15 | while read -r line; do
                    action=$(echo "$line" | awk '{print $1}')
                    pkg=$(echo "$line" | awk '{print $2}' | cut -d'=' -f1 | sed 's/|$//')
                    case "$action" in i|i+) action="install" ;; u|u+) action="upgrade" ;; r|r-) action="remove" ;; d|d-) action="downgrade" ;; *) action="change" ;; esac
                    printf "${MAUVE}│${RESET} ${TEXT}%-38s${RESET} ${MAUVE}│${RESET} ${PEACH}%-38s${RESET} ${MAUVE}│${RESET}\n" "$pkg" "→ $action"
                done
                ;;
        esac

        [ "$UPGRADABLE" -gt 15 ] && printf "${MAUVE}│${RESET} ${OVERLAY1}%-38s${RESET} ${MAUVE}│${RESET} ${OVERLAY1}%-38s${RESET} ${MAUVE}│${RESET}\n" "... and $((UPGRADABLE-15)) more" ""
        echo -e "${MAUVE}└────────────────────────────────────────┴────────────────────────────────────────┘${RESET}"
        return 0
    else
        print_success "System is up to date!"
        print_table "Status" "Message" "System" "Up to date" "Updates" "0" "Action" "None"
        echo -e "\n${MAUVE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${MAUVE}${BOLD}║${RESET}                  ${GREEN}${BOLD}Nothing to do! Have a great day!${RESET}           ${MAUVE}${BOLD}║${RESET}"
        echo -e "${MAUVE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}\n"
        read -n 1 -s -r -p "Press any key to return to menu..."
        return 1
    fi
}

perform_update() {
    # ... (unchanged confirmation logic) ...
    echo -e "\n${YELLOW}${BOLD}Do you want to upgrade now?${RESET}"
    echo -e "${GREEN}[y] Yes    ${RED}[q] Quit${RESET}"
    read -n 1 choice
    [[ ! "$choice" =~ ^[yY]$ ]] && echo -e "\n${RED}Upgrade cancelled.${RESET}" && sleep 2 && return

    print_section "Upgrading System"
    $UPGRADE_CMD 2>&1 | while read -r line; do
        if echo "$line" | grep -qE "(Setting up|Unpacking|Installing|Upgrading)"; then
            echo -e "${PEACH}  ⟳ $line${RESET}"
        else
            echo -e "${SUBTEXT1}  $line${RESET}"
        fi
    done && print_success "Upgrade completed!"

    print_section "Cleanup"
    $CLEAN_CMD 2>&1 | while read -r line; do echo -e "${SUBTEXT1}  $line${RESET}"; done

    print_header "All Done!"
    print_success "Your system is now fully updated"
    [ -f /var/run/reboot-required ] && print_warning "Reboot required!"
    echo -e "\nPress any key to exit..."
    read -n 1 -s
}

# ... (Nerd Fonts functions unchanged) ...

main() {
    while true; do
        clear
        print_header "Universal Linux Updater"
        get_user_info
        detect_os

        echo -e "${GREEN}Detected:${RESET} $OS_ICON ${TEXT}$OS_NAME${RESET}"
        $USE_NERD_FONTS && echo -e "${GREEN}Nerd Fonts: Detected${RESET}" || echo -e "${YELLOW}Nerd Fonts: Not detected${RESET}"

        echo -e "\n${BLUE}${BOLD}[1]${RESET} Update System"
        echo -e "${LAVENDER}${BOLD}[2]${RESET} Install Nerd Fonts"
        echo -e "${RED}${BOLD}[q]${RESET} Quit\n"
        read -n 1 choice
        case $choice in
            1) show_update_summary && perform_update ;;
            2) echo "Nerd Fonts installer coming soon..." ; sleep 2 ;;
            q|Q) clear; print_header "Goodbye!"; exit 0 ;;
        esac
    done
}

main
