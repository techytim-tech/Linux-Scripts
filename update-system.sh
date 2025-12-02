#!/bin/bash

# Atelier Sulphurpool Theme (Gogh-inspired)
# Base colors (dark theme)
BASE00="\033[48;2;32;39;70m"  # Darkest background (BG_BASE)
BASE0="\033[38;2;189;195;199m"  # Light text (TEXT)
BASE1="\033[38;2;174;180;184m"  # Subtext (SUBTEXT1)
BASE2="\033[38;2;159;165;169m"  # Overlay (OVERLAY1)
BASE3="\033[38;2;144;150;154m"  # Muted text (SUBTEXT0)
BG_SURFACE="\033[48;2;37;44;75m"  # Surface background

# Accent colors
RED="\033[38;2;217;112;106m"    # Errors
ORANGE="\033[38;2;253;151;31m"  # Warnings, Peach
GREEN="\033[38;2;143;189;110m"  # Success
YELLOW="\033[38;2;253;214;144m" # Info
BLUE="\033[38;2;131;148;211m"   # Headers, Sections
PURPLE="\033[38;2;175;152;171m" # Mauve, Headers
TEAL="\033[38;2;133;200;198m"   # Status
RESET="\033[0m"
BOLD="\033[1m"

# Clear screen and set background
clear
echo -e "${BASE00}${BASE0}  $(printf '%*s' $(( $(tput cols) - 2 )) '' | tr ' ' ' ') ${RESET}"

# Function to print a fancy header (optimized with tput for width)
print_header() {
    local cols=$(tput cols)
    local text="$1"
    local padding=$(( (cols - ${#text} - 4) / 2 ))
    echo -e "\n${PURPLE}${BOLD}╔$(printf '═%.0s' $(seq 1 $((cols-2))))╗${RESET}"
    printf "${PURPLE}${BOLD}║${RESET}%*s${BLUE}${BOLD} %s ${RESET}%*s${PURPLE}${BOLD}║${RESET}\n" $padding "" "$text" $padding ""
    echo -e "${PURPLE}${BOLD}╚$(printf '═%.0s' $(seq 1 $((cols-2))))╝${RESET}\n"
}

# Function to print a section header (shortened line for efficiency)
print_section() {
    echo -e "\n${BLUE}${BOLD}▶ $1${RESET}"
    echo -e "${BASE2}$(printf '─%.0s' $(seq 1 40))${RESET}"  # Reduced from 50
}

# Status functions (consolidated for brevity)
print_status() { echo -e "${TEAL}➜${RESET} ${BASE0}$1${RESET}"; }
print_success() { echo -e "${GREEN}✓${RESET} ${BASE0}$1${RESET}"; }
print_error() { echo -e "${RED}✗${RESET} ${BASE0}$1${RESET}"; }
print_warning() { echo -e "${YELLOW}⚠${RESET} ${BASE0}$1${RESET}"; }
print_info() { echo -e "${ORANGE}ℹ${RESET} ${BASE0}$1${RESET}"; }

# Optimized table printer (dynamic widths, fewer printf calls)
print_table() {
    local col1_width=25
    local col2_width=50
    local cols=$(tput cols)
    [ $((col1_width + col2_width + 4)) -gt $cols ] && col2_width=$((cols - col1_width - 6))

    echo -e "${PURPLE}┌$(printf '─%.0s' $(seq 1 $col1_width))┬$(printf '─%.0s' $(seq 1 $col2_width))┐${RESET}"
    printf "${PURPLE}│${RESET} ${BLUE}${BOLD}%-${col1_width}s${RESET} ${PURPLE}│${RESET} ${BLUE}${BOLD}%-${col2_width}s${RESET} ${PURPLE}│${RESET}\n" "$1" "$2"
    echo -e "${PURPLE}├$(printf '─%.0s' $(seq 1 $col1_width))┼$(printf '─%.0s' $(seq 1 $col2_width))┤${RESET}"

    shift 2
    while [ $# -gt 0 ]; do
        local val1="$1" val2="$2"
        [ ${#val1} -gt $((col1_width-2)) ] && val1="${val1:0:$((col1_width-5))}..."
        [ ${#val2} -gt $((col2_width-2)) ] && val2="${val2:0:$((col2_width-5))}..."
        printf "${PURPLE}│${RESET} ${BASE0}%-${col1_width}s${RESET} ${PURPLE}│${RESET} ${YELLOW}%-${col2_width}s${RESET} ${PURPLE}│${RESET}\n" "$val1" "$val2"
        shift 2
    done

    echo -e "${PURPLE}└$(printf '─%.0s' $(seq 1 $col1_width))┴$(printf '─%.0s' $(seq 1 $col2_width))┘${RESET}"
}

# Variables (global cache for OS/user info)
declare -A OS_CACHE=( [name]="" [version]="" [id]="" [icon]="" )
UPDATE_CMD="" UPGRADE_CMD="" CLEAN_CMD="" PKG_MANAGER=""
CURRENT_USER="" USER_TYPE="" USE_NERD_FONTS=false SUDO_CMD=""
UPGRADABLE=0

# Nerd Font icons (unchanged)
NF_ICON_FEDORA="" NF_ICON_OPENSUSE="" NF_ICON_UBUNTU="󰕈" NF_ICON_DEBIAN=""
NF_ICON_ARCH="" NF_ICON_MANJARO="" NF_ICON_CENTOS="" NF_ICON_RHEL="" NF_ICON_LINUX=""

# Emoji fallbacks (unchanged)
EMOJI_FEDORA="HAT" EMOJI_OPENSUSE="LIZARD" EMOJI_UBUNTU="PENGUIN" EMOJI_DEBIAN="PENGUIN"
EMOJI_ARCH="TARGET" EMOJI_MANJARO="TARGET" EMOJI_CENTOS="BOX" EMOJI_RHEL="BOX" EMOJI_LINUX="PENGUIN"

# Detect Nerd Fonts (efficient single check)
detect_nerd_fonts() {
    USE_NERD_FONTS=false
    command -v fc-list >/dev/null 2>&1 && fc-list | grep -qi "Nerd Font" && USE_NERD_FONTS=true
    [ "$USE_NERD_FONTS" = false ] && [ -d "$HOME/.local/share/fonts" ] && find "$HOME/.local/share/fonts" -iname "*Nerd*" -quit | grep -q . && USE_NERD_FONTS=true
}

get_os_icon() {
    local os_id="$1" icon="" emoji=""
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
    [ "$EUID" -eq 0 ] && { SUDO_CMD=""; CURRENT_USER="${SUDO_USER:-root}"; USER_TYPE="Root User"; } || { SUDO_CMD="sudo "; CURRENT_USER="$USER"; USER_TYPE="Regular User"; }
}

# Cached OS detection (call once)
detect_os() {
    if [[ -n "${OS_CACHE[name]}" ]]; then return; fi  # Cache hit
    detect_nerd_fonts
    get_user_info
    if [[ ! -f /etc/os-release ]]; then print_error "Cannot detect OS"; exit 1; fi
    source /etc/os-release
    OS_CACHE[name]="$NAME"
    OS_CACHE[version]="${VERSION_ID:-N/A}"
    OS_CACHE[id]="$ID"
    OS_CACHE[icon]=$(get_os_icon "$ID")

    case $ID in
        ubuntu|debian)
            if command -v apt-fast >/dev/null; then
                PKG_MANAGER="APT-Fast"
                UPDATE_CMD="${SUDO_CMD}apt-fast update"
                UPGRADE_CMD="${SUDO_CMD}apt-fast upgrade -y"
                CLEAN_CMD="${SUDO_CMD}apt-fast autoremove -y && ${SUDO_CMD}apt-fast autoclean"
            else
                PKG_MANAGER="APT"
                UPDATE_CMD="${SUDO_CMD}apt update"
                UPGRADE_CMD="${SUDO_CMD}apt upgrade -y"
                CLEAN_CMD="${SUDO_CMD}apt autoremove -y && ${SUDO_CMD}apt autoclean"
            fi
            ;;
        arch|manjaro)
            PKG_MANAGER="Pacman"
            UPDATE_CMD="${SUDO_CMD}pacman -Sy"
            UPGRADE_CMD="${SUDO_CMD}pacman -Syu --noconfirm"
            CLEAN_CMD="${SUDO_CMD}pacman -Sc --noconfirm"
            ;;
        fedora)
            PKG_MANAGER="DNF"
            UPDATE_CMD="${SUDO_CMD}dnf check-update"
            UPGRADE_CMD="${SUDO_CMD}dnf upgrade -y"
            CLEAN_CMD="${SUDO_CMD}dnf autoremove -y && ${SUDO_CMD}dnf clean all"
            ;;
        opensuse-tumbleweed)
            PKG_MANAGER="Zypper (Tumbleweed)"
            UPDATE_CMD="${SUDO_CMD}zypper --non-interactive refresh"
            UPGRADE_CMD="${SUDO_CMD}zypper --non-interactive dup --auto-agree-with-licenses --no-recommends"
            CLEAN_CMD="${SUDO_CMD}zypper clean -a"
            ;;
        opensuse-leap|opensuse)
            PKG_MANAGER="Zypper (Leap)"
            UPDATE_CMD="${SUDO_CMD}zypper refresh"
            UPGRADE_CMD="${SUDO_CMD}zypper update -y"
            CLEAN_CMD="${SUDO_CMD}zypper clean -a"
            ;;
        *)
            print_error "Unsupported OS: $NAME"
            exit 1
            ;;
    esac
}

# Efficient update counter (minimized subprocesses with direct eval where possible)
count_updates() {
    case ${OS_CACHE[id]} in
        ubuntu|debian)
            UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -c "/" || echo 0)
            [ "$UPGRADABLE" -gt 0 ] && UPGRADABLE=$((UPGRADABLE - 1))
            ;;
        arch|manjaro)
            UPGRADABLE=$(pacman -Qu 2>/dev/null | wc -l)
            ;;
        fedora)
            UPGRADABLE=$(dnf list updates 2>/dev/null | awk 'NR>3 && $1!~/^(Last|Available|Updated)/ {count++} END {print count+0}')
            ;;
        opensuse-tumbleweed)
            local output=$(${SUDO_CMD}zypper --non-interactive dup --dry-run --auto-agree-with-licenses --no-recommends 2>&1)
            if echo "$output" | grep -q "Nothing to do."; then
                UPGRADABLE=0
            else
                UPGRADABLE=$(echo "$output" | grep -oiE "[0-9]+ package" | head -1 | grep -oE "[0-9]+" || echo 0)
                [ "$UPGRADABLE" -eq 0 ] && UPGRADABLE=$(echo "$output" | grep -E "^[[:space:]]+[a-zA-Z]" | wc -l)
                [ "$UPGRADABLE" -eq 0 ] && UPGRADABLE=1
            fi
            ;;
        opensuse-leap|opensuse)
            UPGRADABLE=$(${SUDO_CMD}zypper lu 2>/dev/null | grep -E "^v |^  " | grep -v "Repository" | wc -l)
            ;;
    esac
    echo "$UPGRADABLE"
}

show_update_summary() {
    print_section "Checking for Updates"
    print_status "Refreshing package data..."
    $UPDATE_CMD 2>&1 | while IFS= read -r line; do echo -e "${BASE3}  $line${RESET}"; done
    print_success "Package data refreshed"

    UPGRADABLE=$(count_updates)

    print_section "System Information"
    print_table "Property" "Value" \
        "Operating System" "${OS_CACHE[icon]}  ${OS_CACHE[name]}" \
        "Version" "${OS_CACHE[version]}" \
        "Package Manager" "$PKG_MANAGER" \
        "Updates Available" "$UPGRADABLE packages"

    if [ "$UPGRADABLE" -gt 0 ]; then
        print_info "$UPGRADABLE update(s) available"
        print_section "Available Updates"
        echo -e "${PURPLE}┌$(printf '─%.0s' $(seq 1 40))┬$(printf '─%.0s' $(seq 1 40))┐${RESET}"
        printf "${PURPLE}│${RESET} ${BLUE}${BOLD}%-38s${RESET} │ ${BLUE}${BOLD}%-38s${RESET} ${PURPLE}│${RESET}\n" "Package" "Action"
        echo -e "${PURPLE}├$(printf '─%.0s' $(seq 1 40))┼$(printf '─%.0s' $(seq 1 40))┤${RESET}"

        case ${OS_CACHE[id]} in
            ubuntu|debian)
                apt list --upgradable 2>/dev/null | tail -n +2 | head -15 | while IFS= read -r line; do
                    name=$(echo "$line" | cut -d'/' -f1)
                    ver=$(echo "$line" | awk '{print $2}')
                    printf "${PURPLE}│${RESET} ${BASE0}%-38s${RESET} │ ${YELLOW}%-38s${RESET} ${PURPLE}│${RESET}\n" "$name" "→ $ver"
                done
                ;;
            arch|manjaro)
                pacman -Qu 2>/dev/null | head -15 | while IFS= read -r line; do
                    printf "${PURPLE}│${RESET} ${BASE0}%-38s${RESET} │ ${YELLOW}%-38s${RESET} ${PURPLE}│${RESET}\n" "$line" "$(echo "$line" | awk '{print $2" -> "$4}')"
                done
                ;;
            fedora)
                dnf list updates 2>/dev/null | tail -n +4 | head -15 | while IFS= read -r line; do
                    printf "${PURPLE}│${RESET} ${BASE0}%-38s${RESET} │ ${YELLOW}%-38s${RESET} ${PURPLE}│${RESET}\n" "$line" "→ $(echo "$line" | awk '{print $2}')"
                done
                ;;
            opensuse-tumbleweed)
                print_status "Simulating distribution upgrade..."
                local output=$(${SUDO_CMD}zypper --non-interactive dup --dry-run --auto-agree-with-licenses --no-recommends 2>&1)
                echo "$output" | grep -E "^[[:space:]]+[a-z]" | head -15 | while IFS= read -r line; do
                    action=$(echo "$line" | awk '{print $1}')
                    pkg=$(echo "$line" | awk '{print $2}' | cut -d'=' -f1 | sed 's/|$//')
                    case "$action" in i|i+) action="install" ;; u|u+) action="upgrade" ;; r|r-) action="remove" ;; d|d-) action="downgrade" ;; *) action="change" ;; esac
                    printf "${PURPLE}│${RESET} ${BASE0}%-38s${RESET} │ ${YELLOW}%-38s${RESET} ${PURPLE}│${RESET}\n" "$pkg" "→ $action"
                done
                ;;
        esac

        [ "$UPGRADABLE" -gt 15 ] && printf "${PURPLE}│${RESET} ${BASE2}%-38s${RESET} │ ${BASE2}%-38s${RESET} ${PURPLE}│${RESET}\n" "... and $((UPGRADABLE-15)) more" ""
        echo -e "${PURPLE}└$(printf '─%.0s' $(seq 1 40))┴$(printf '─%.0s' $(seq 1 40))┘${RESET}"
        return 0
    else
        print_success "System is up to date!"
        print_table "Status" "Message" "System" "Up to date" "Updates" "0" "Action" "None"
        echo -e "\n${PURPLE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${PURPLE}${BOLD}║${RESET}                  ${GREEN}${BOLD}Nothing to do! Have a great day!${RESET}           ${PURPLE}${BOLD}║${RESET}"
        echo -e "${PURPLE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}\n"
        read -n 1 -s -r -p "Press any key to return to menu..."
        return 1
    fi
}

perform_update() {
    echo -e "\n${YELLOW}${BOLD}Do you want to upgrade now?${RESET}"
    echo -e "${GREEN}[y] Yes    ${RED}[q] Quit${RESET}"
    read -n 1 -r choice
    [[ ! "$choice" =~ ^[yY]$ ]] && { echo -e "\n${RED}Upgrade cancelled.${RESET}"; sleep 2; return; }

    print_section "Upgrading System"
    $UPGRADE_CMD 2>&1 | while IFS= read -r line; do
        if echo "$line" | grep -qE "(Setting up|Unpacking|Installing|Upgrading)"; then
            echo -e "${ORANGE}  ⟳ $line${RESET}"
        else
            echo -e "${BASE3}  $line${RESET}"
        fi
    done && print_success "Upgrade completed!"

    print_section "Cleanup"
    eval "$CLEAN_CMD" 2>&1 | while IFS= read -r line; do echo -e "${BASE3}  $line${RESET}"; done

    print_header "All Done!"
    print_success "Your system is now fully updated"
    [[ -f /var/run/reboot-required ]] && print_warning "Reboot required!"
    echo -e "\nPress any key to exit..."
    read -n 1 -s -r
}

# Main loop (single, clean version)
main() {
    while true; do
        clear
        print_header "Universal Linux Updater"
        detect_os  # Calls get_user_info and caches OS

        echo -e "${GREEN}Detected:${RESET} ${OS_CACHE[icon]} ${BASE0}${OS_CACHE[name]}${RESET}"
        $USE_NERD_FONTS && echo -e "${GREEN}Nerd Fonts: Detected${RESET}" || echo -e "${YELLOW}Nerd Fonts: Not detected${RESET}"

        echo -e "\n${BLUE}${BOLD}[1]${RESET} Update system"
        echo -e "${RED}${BOLD}[q]${RESET} Quit\n"

        read -n 1 -r choice
        case "$choice" in
            1) show_update_summary && perform_update ;;
            q|Q) clear; print_header "Goodbye!"; exit 0 ;;
            *) print_error "Invalid choice. Please try again."; sleep 1 ;;
        esac
    done
}

# Start the script
main()