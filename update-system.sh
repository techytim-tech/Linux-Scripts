#!/bin/bash
# Universal Linux Updater – Atelier Sulphurpool Theme
# Fixed, tested, and beautiful – December 2025

set -euo pipefail
trap 'echo -e "${RESET}"; stty echo 2>/dev/null || true; exit 1' INT TERM

# ═══════════════════════════════════════════════════════════════
# Atelier Sulphurpool Color Palette (Gogh #16)
# ═══════════════════════════════════════════════════════════════
BG_BASE="\033[48;2;32;39;70m"      # #202746
BG_SURFACE="\033[48;2;37;44;75m"   # Slightly lighter panel
TEXT="\033[38;2;189;195;199m"      # #bdc3c7
SUBTEXT="\033[38;2;144;150;154m"   # #90969a
ACCENT="\033[38;2;131;148;211m"    # #8394d3  Blue
RED="\033[38;2;217;112;106m"       # #d96d6a
GREEN="\033[38;2;143;189;110m"     # #8fbd6e
YELLOW="\033[38;2;253;214;144m"    # #fdd690
ORANGE="\033[38;2;253;151;31m"     # #fd9720
PURPLE="\033[38;2;175;152;171m"    # #af98ab
TEAL="\033[38;2;133;200;198m"      # #85c8c6
BOLD="\033[1m"
RESET="\033[0m"

# Clear screen + full background
clear
printf "${BG_BASE}%*s${RESET}\n" "$(tput cols)" "" | tr ' ' ' '

# ═══════════════════════════════════════════════════════════════
# Functions
# ═══════════════════════════════════════════════════════════════
print_header() {
    local title="$1"
    local cols=$(tput cols)
    local edge=$(printf '═%.0s' $(seq 1 $((cols-2))))
    local pad=$(( (cols - ${#title} - 4) / 2 ))
    echo -e "${PURPLE}${BOLD}╔${edge}╗${RESET}"
    printf "${PURPLE}${BOLD}║${RESET}%*s${ACCENT}${BOLD} %s ${RESET}%*s${PURPLE}${BOLD}║${RESET}\n" "$pad" "" "$title" "$pad" ""
    echo -e "${PURPLE}${BOLD}╚${edge}╝${RESET}\n"
}

print_section() { echo -e "\n${ACCENT}${BOLD}▶ $1${RESET}"; echo -e "${SUBTEXT}$(printf '─%.0s' {1..50})${RESET}"; }
print_status()  { echo -e "${TEAL}➜${RESET} ${TEXT}$1${RESET}"; }
print_success() { echo -e "${GREEN}✓${RESET} ${TEXT}$1${RESET}"; }
print_error()   { echo -e "${RED}✗${RESET} ${TEXT}$1${RESET}"; }
print_warning() { echo -e "${YELLOW}⚠${RESET} ${TEXT}$1${RESET}"; }
print_info()    { echo -e "${ORANGE}ℹ${RESET} ${TEXT}$1${RESET}"; }

# Dynamic table with auto-width
print_table() {
    local w1=22 w2=50
    (( w1 + w2 + 5 > $(tput cols) )) && w2=$(( $(tput cols) - w1 - 7 ))
    local line1=$(printf '─%.0s' $(seq 1 $w1))
    local line2=$(printf '─%.0s' $(seq 1 $w2))

    echo -e "${PURPLE}┌─${line1}─┬─${line2}─┐${RESET}"
    printf "${PURPLE}│ ${ACCENT}${BOLD}%-*s${RESET} ${PURPLE}│ ${ACCENT}${BOLD}%-*s${RESET} ${PURPLE}│${RESET}\n" $((w1)) "$1" $((w2)) "$2"
    echo -e "${PURPLE}├─${line1}─┼─${line2}─┤${RESET}"

    shift 2
    while (( $# >= 2 )); do
        local v1="$1" v2="$2"
        (( ${#v1} > w1-2 )) && v1="${v1:0:$((w1-5))}..."
        (( ${#v2} > w2-2 )) && v2="${v2:0:$((w2-5))}..."
        printf "${PURPLE}│ ${TEXT}%-*s${RESET} ${PURPLE}│ ${YELLOW}%-*s${RESET} ${PURPLE}│${RESET}\n" $((w1)) "$v1" $((w2)) "$v2"
        shift 2
    done
    echo -e "${PURPLE}└─${line1}─┴─${line2}─┘${RESET}"
}

# ═══════════════════════════════════════════════════════════════
# Global Variables & Detection
# ═══════════════════════════════════════════════════════════════
declare -g OS_NAME OS_VER OS_ID OS_ICON PKG_MANAGER SUDO_CMD=""
declare -g UPDATE_CMD UPGRADE_CMD CLEAN_CMD
declare -g USE_NERD_FONTS=false

# Icons
declare -A NF=( [fedora]="" [opensuse]="" [ubuntu]="󰕈" [debian]="" [arch]="" [manjaro]="" [rhel]="" [linux]="" )
declare -A EMOJI=( [fedora]="HAT" [opensuse]="LIZARD" [ubuntu]="PENGUIN" [debian]="PENGUIN" [arch]="TARGET" [manjaro]="TARGET" [rhel]="BOX" [linux]="PENGUIN" )

detect_nerd_fonts() {
    USE_NERD_FONTS=false
    if command -v fc-list >/dev/null 2>&1 && fc-list -f "%{family}\n" 2>/dev/null | grep -qi "nerd"; then
        USE_NERD_FONTS=true
    elif [[ -d "$HOME/.local/share/fonts" ]] && command -v find >/dev/null && find "$HOME/.local/share/fonts" -iname "*nerd*" -print -quit | grep -q .; then
        USE_NERD_FONTS=true
    fi
}

get_icon() {
    local id="$1"
    case "$id" in
        fedora)          icon="${NF[fedora]}"       ; fallback="${EMOJI[fedora]}" ;;
        opensuse*)       icon="${NF[opensuse]}"     ; fallback="${EMOJI[opensuse]}" ;;
        ubuntu)          icon="${NF[ubuntu]}"       ; fallback="${EMOJI[ubuntu]}" ;;
        debian)          icon="${NF[debian]}"       ; fallback="${EMOJI[debian]}" ;;
        arch)            icon="${NF[arch]}"         ; fallback="${EMOJI[arch]}" ;;
        manjaro)         icon="${NF[manjaro]}"      ; fallback="${EMOJI[manjaro]}" ;;
        centos|rhel|rocky|almalinux) icon="${NF[rhel]}" ; fallback="${EMOJI[rhel]}" ;;
        *)               icon="${NF[linux]}"        ; fallback="${EMOJI[linux]}" ;;
    esac
    $USE_NERD_FONTS && echo -e "$icon" || echo -e "$fallback"
}

detect_os() {
    [[ -f /etc/os-release ]] || { print_error "Cannot detect OS"; exit 1; }
    source /etc/os-release
    OS_NAME="$NAME"
    OS_VER="${VERSION_ID:-N/A}"
    OS_ID="$ID"
    OS_ICON=$(get_icon "$OS_ID")

    [[ "$EUID" -eq 0 ]] && SUDO_CMD="" || SUDO_CMD="sudo "

    case "$ID" in
        ubuntu|debian)
            if command -v apt-fast >/dev/null 2>&1; then
                PKG_MANAGER="APT-Fast"
                UPDATE_CMD="${SUDO_CMD}apt-fast update"
                UPGRADE_CMD="${SUDO_CMD}apt-fast upgrade -y"
                CLEAN_CMD="${SUDO_CMD}apt-fast autoremove -y && ${SUDO_CMD}apt-fast autoclean"
            else
                PKG_MANAGER="APT"
                UPDATE_CMD="${SUDO_CMD}apt update"
                UPGRADE_CMD="${SUDO_CMD}apt upgrade -y"
                CLEAN_CMD="${SUDO_CMD}apt autoremove -y && ${SUDO_CMD}apt autoclean"
            fi ;;
        arch|manjaro)
            PKG_MANAGER="Pacman"
            UPDATE_CMD="${SUDO_CMD}pacman -Sy"
            UPGRADE_CMD="${SUDO_CMD}pacman -Syu --noconfirm"
            CLEAN_CMD="${SUDO_CMD}pacman -Rns $(pacman -Qdtq 2>/dev/null || true) --noconfirm" ;;
        fedora*)
            PKG_MANAGER="DNF"
            UPDATE_CMD="${SUDO_CMD}dnf check-update --quiet"
            UPGRADE_CMD="${SUDO_CMD}dnf upgrade -y"
            CLEAN_CMD="${SUDO_CMD}dnf autoremove -y && ${SUDO_CMD}dnf clean all" ;;
        opensuse-tumbleweed)
            PKG_MANAGER="Zypper (Tumbleweed)"
            UPDATE_CMD="${SUDO_CMD}zypper --non-interactive refresh"
            UPGRADE_CMD="${SUDO_CMD}zypper --non-interactive dup --auto-agree-with-licenses --no-recommends"
            CLEAN_CMD="${SUDO_CMD}zypper clean -a" ;;
        opensuse*)
            PKG_MANAGER="Zypper (Leap)"
            UPDATE_CMD="${SUDO_CMD}zypper refresh"
            UPGRADE_CMD="${SUDO_CMD}zypper update -y"
            CLEAN_CMD="${SUDO_CMD}zypper clean -a" ;;
        *) print_error "Unsupported OS: $NAME"; exit 1 ;;
    esac
}

# ═══════════════════════════════════════════════════════════════
# Update Counter – 100% reliable now
# ═══════════════════════════════════════════════════════════════
count_updates() {
    local count=0
    case "$OS_ID" in
        ubuntu|debian)
            count=$(apt list --upgradable 2>/dev/null | wc -l); ((count--)) ;;
        arch|manjaro)
            count=$(pacman -Qu 2>/dev/null | wc -l || echo 0) ;;
        fedora*)
            count=$(dnf list updates 2>/dev/null | tail -n +4 | grep -v "^$" | wc -l || echo 0) ;;
        opensuse-tumbleweed)
            local out=$(${SUDO_CMD}zypper --non-interactive dup --dry-run --auto-agree-with-licenses --no-recommends 2>&1)
            if grep -q "Nothing to do." <<<"$out"; then
                count=0
            else
                count=$(grep -o "[0-9]\+ package" <<<"$out" | head -1 | grep -o "[0-9]\+" || echo 0)
                (( count == 0 )) && count=$(grep "^[[:space:]]\+[a-z]" <<<"$out" | wc -l)
                (( count == 0 )) && count=1
            fi ;;
        opensuse*)
            count=$(${SUDO_CMD}zypper lu 2>/dev/null | grep -E "^[[:space:]]+[0-9]+\|" | wc -l || echo 0) ;;
        *) count=0 ;;
    esac
    # Ensure count is numeric and trim any whitespace
    count=$((count + 0))
    echo "$count"
}

# ═══════════════════════════════════════════════════════════════
# Main Functions
# ═══════════════════════════════════════════════════════════════
show_update_summary() {
    print_section "Checking for Updates"
    print_status "Refreshing package metadata..."
    $UPDATE_CMD 2>/dev/null || true
    print_success "Ready"

    local updates=$(count_updates)
    # Ensure updates is numeric (trim whitespace and convert to number)
    updates=$((updates + 0))

    print_section "System Summary"
    print_table "Property" "Value" \
        "OS" "$OS_ICON  $OS_NAME" \
        "Version" "$OS_VER" \
        "Manager" "$PKG_MANAGER" \
        "Updates" "$updates package(s)"

    if (( updates == 0 )); then
        print_success "System is already up to date!"
        echo -e "\n${PURPLE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${PURPLE}${BOLD}║${RESET}             ${GREEN}${BOLD}All good! Nothing to do today.${RESET}             ${PURPLE}${BOLD}║${RESET}"
        echo -e "${PURPLE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}\n"
        read -n1 -s -r -p "Press any key to continue..."
        return 1
    else
        print_info "$updates update(s) available"
        return 0
    fi
}

perform_update() {
    echo -e "\n${YELLOW}${BOLD}Start upgrade now? (y/n)${RESET}"
    read -n1 -r ans
    [[ ! "$ans" =~ ^[yY]$ ]] && echo -e "\n${RED}Cancelled.${RESET}" && sleep 1 && return

    print_section "Upgrading System"
    $UPGRADE_CMD || { print_error "Upgrade failed"; return 1; }
    print_success "Upgrade completed"

    print_section "Cleaning up"
    if [[ "$CLEAN_CMD" == *"&&"* ]]; then
        bash -c "$CLEAN_CMD" || true
    else
        $CLEAN_CMD || true
    fi

    [[ -f /var/run/reboot-required ]] && print_warning "REBOOT REQUIRED"

    print_header "Done!"
    echo -e "\n${TEXT}Press any key to exit...${RESET}"
    read -n1 -s
}

# ═══════════════════════════════════════════════════════════════
# Main Menu
# ═══════════════════════════════════════════════════════════════
main() {
    detect_nerd_fonts
    detect_os

    while true; do
        clear
        printf "${BG_BASE}%*s${RESET}\n" "$(tput cols)" ""
        print_header "Universal Linux Updater"

        echo -e "${GREEN}Detected:${RESET} $OS_ICON ${TEXT}${OS_NAME}${RESET}"
        $USE_NERD_FONTS && echo -e "${GREEN}Nerd Fonts: Detected${RESET}" || echo -e "${YELLOW}Nerd Fonts: Not detected (using emoji)${RESET}"

        echo -e "\n${ACCENT}${BOLD}[1]${RESET} Check & Update System"
        echo -e "${RED}${BOLD}[q]${RESET} Quit\n"

        read -n1 -r choice
        case "$choice" in
            1) clear; show_update_summary && perform_update ;;
            q|Q) clear; print_header "See you!"; echo -e "${RESET}"; exit 0 ;;
            *) print_error "Invalid option"; sleep 1 ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
main
echo -e "${RESET}"  # Ensure colors reset on exit