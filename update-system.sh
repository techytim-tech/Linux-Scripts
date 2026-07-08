#!/bin/bash
# Linux System Updater – Catppuccin Macchiato + P10K Style
# Logic & Color Rendering Fix – March 2026

set -euo pipefail
trap 'echo -e "${RESET}"; stty echo 2>/dev/null || true; exit 1' INT TERM

# ═══════════════════════════════════════════════════════════════
# Catppuccin Macchiato Palette
# ═══════════════════════════════════════════════════════════════
BG_BLUE="\033[48;2;138;173;244m"
BG_MAUVE="\033[48;2;198;160;246m"
BG_SURFACE="\033[48;2;54;58;79m"
FG_BLUE="\033[38;2;138;173;244m"
FG_MAUVE="\033[38;2;198;160;246m"
FG_SURFACE="\033[38;2;54;58;79m"
FG_BLACK="\033[38;5;232m"
TEXT="\033[38;2;202;211;245m"
SUBTEXT="\033[38;2;165;173;203m"
GREEN="\033[38;2;166;218;149m"
RED="\033[38;2;237;135;150m"
YELLOW="\033[38;2;238;212;159m"
LAVENDER="\033[38;2;183;189;248m"
BOLD="\033[1m"
RESET="\033[0m"

SEP=""

# ═══════════════════════════════════════════════════════════════
# Global Variables & Detection
# ═══════════════════════════════════════════════════════════════
declare -g OS_NAME OS_VER OS_ID OS_ICON PKG_MANAGER SUDO_CMD=""
declare -g UPDATE_CMD UPGRADE_CMD CLEAN_CMD SHELL_NAME

SHELL_NAME=$(basename "$SHELL")

declare -A NF=( [fedora]="" [opensuse]="" [ubuntu]="󰕈" [debian]="" [arch]="" [cachyos]="" [manjaro]="" [linux]="" )

get_icon() {
    local id="${1,,}"
    echo -e "${NF[$id]:-${NF[linux]}}"
}

detect_os() {
    [[ -f /etc/os-release ]] || exit 1
    source /etc/os-release
    OS_NAME="$NAME"
    OS_VER="${VERSION_ID:-rolling}"
    OS_ID="$ID"
    OS_ICON=$(get_icon "$OS_ID")
    [[ "$EUID" -eq 0 ]] && SUDO_CMD="" || SUDO_CMD="sudo "

    case "$OS_ID" in
        ubuntu|debian|pop|mint|kali)
            PKG_MANAGER="APT"; UPDATE_CMD="${SUDO_CMD}apt update"
            UPGRADE_CMD="${SUDO_CMD}apt upgrade -y"; CLEAN_CMD="${SUDO_CMD}apt autoremove -y" ;;
        arch|manjaro|cachyos)
            PKG_MANAGER="Pacman"; UPDATE_CMD="${SUDO_CMD}pacman -Sy"
            UPGRADE_CMD="${SUDO_CMD}pacman -Syu --noconfirm"; CLEAN_CMD="${SUDO_CMD}pacman -Rns \$(pacman -Qdtq) --noconfirm 2>/dev/null || true" ;;
        fedora*)
            PKG_MANAGER="DNF"; UPDATE_CMD="${SUDO_CMD}dnf check-update --quiet || true"
            UPGRADE_CMD="${SUDO_CMD}dnf upgrade -y"; CLEAN_CMD="${SUDO_CMD}dnf autoremove -y" ;;
        *) echo -e "${RED}Unsupported OS${RESET}"; exit 1 ;;
    esac
}

# ═══════════════════════════════════════════════════════════════
# UI Elements
# ═══════════════════════════════════════════════════════════════
print_p10k_header() {
    printf "${BG_BLUE}${FG_BLACK}${BOLD}   ${SHELL_NAME^^}  ${RESET}${FG_BLUE}${BG_MAUVE}${SEP}${RESET}"
    printf "${BG_MAUVE}${FG_BLACK}${BOLD}  LINUX SYSTEM UPDATER  ${RESET}${FG_MAUVE}${SEP}${RESET}\n"
}

print_stat_line() {
    # Using echo -e to ensure the $2 variable (which may contain color codes) is parsed
    echo -e " ${SUBTEXT}$(printf '%-16s' "$1") ${FG_BLUE}➜ ${TEXT}$2${RESET}"
}

count_updates() {
    local val=0
    case "$OS_ID" in
        ubuntu|debian|pop|mint)
            val=$(apt list --upgradable 2>/dev/null | grep -c "/" || echo 0) ;;
        arch|manjaro|cachyos)
            val=$(pacman -Qu 2>/dev/null | wc -l || echo 0) ;;
        fedora*)
            val=$(dnf list updates --quiet 2>/dev/null | grep -c "\." || echo 0) ;;
    esac
    echo "${val//[!0-9]/}"
}

# ═══════════════════════════════════════════════════════════════
# Logic
# ═══════════════════════════════════════════════════════════════
show_summary() {
    echo -e "\n ${FG_BLUE}󰑐 Fetching latest metadata...${RESET}"
    $UPDATE_CMD >/dev/null 2>&1 || true

    local up_raw; up_raw=$(count_updates)
    local up=$(( ${up_raw:-0} + 0 ))

    echo -e "\n ${BG_SURFACE}${TEXT}${BOLD}  SYSTEM SUMMARY  ${RESET}${FG_SURFACE}${SEP}${RESET}"
    print_stat_line "Node" "$OS_ICON $OS_NAME"
    print_stat_line "Manager" "$PKG_MANAGER"

    # We pass the colorized string directly to print_stat_line
    if [ "$up" -gt 0 ]; then
        print_stat_line "Pending" "${YELLOW}$up updates found"
    else
        print_stat_line "Pending" "${GREEN}0 updates found"
    fi

    if [ "$up" -eq 0 ]; then
        echo -e "\n ${GREEN}  ✔ System is optimized.${RESET}"
        echo -e "  ${SUBTEXT}Press any key to return...${RESET}"
        read -n1 -s -r
        return 1
    fi
    return 0
}

perform_update() {
    echo -e "\n  ${YELLOW}${BOLD}󰚰  Execute Upgrade? (y/n)${RESET}"
    read -n1 -s -r ans
    if [[ "$ans" =~ ^[yY]$ ]]; then
        echo -e "  ${FG_BLUE}󰏔 Processing...${RESET}\n"
        $UPGRADE_CMD

        if [[ -n "$CLEAN_CMD" ]]; then
            echo -e "\n  ${FG_BLUE}󰃢 Optimizing storage...${RESET}"
            eval "$CLEAN_CMD"
        fi

        echo -e "\n ${GREEN}  ✔ Completed Successfully.${RESET}"
        echo -e "  ${SUBTEXT}Press any key to return...${RESET}"
        read -n1 -s -r
    fi
}

# ═══════════════════════════════════════════════════════════════
# Main Menu
# ═══════════════════════════════════════════════════════════════
main() {
    detect_os
    while true; do
        clear
        print_p10k_header

        echo -e "\n  ${SUBTEXT}OS:${RESET} ${FG_MAUVE}${BOLD}${OS_NAME}${RESET} ${SUBTEXT}[${OS_VER}]${RESET}"

        echo -e "\n  ${GREEN}${BOLD} 1 ${RESET} ${TEXT}Check & Run Updates${RESET}"
        echo -e "  ${GREEN}${BOLD} 2 ${RESET} ${TEXT}Purge Package Cache${RESET}"
        echo -e "  ${RED}${BOLD} q ${RESET} ${TEXT}Exit Session${RESET}"

        echo -e "\n ${FG_MAUVE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

        read -n1 -s -r choice
        case "$choice" in
            1) clear; print_p10k_header; if show_summary; then perform_update; fi ;;
            2) clear; print_p10k_header; echo -e "\n  ${FG_BLUE}󰃢 Cleaning Cache...${RESET}"; eval "$CLEAN_CMD" || true; sleep 2 ;;
            q|Q) clear; echo -e "\n  ${LAVENDER}Session Closed.${RESET}\n"; exit 0 ;;
        esac
    done
}

main
