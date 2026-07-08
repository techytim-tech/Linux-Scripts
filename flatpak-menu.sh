#!/bin/sh

# --- THE BOOTSTRAPPER ---
# This part is pure POSIX sh. It detects the environment and
# re-executes the script using the correct shell's internal logic.

if [ -n "$FISH_VERSION" ]; then
    # If we are in Fish, we define the Fish function and run it.
    # We use 'eval' to hide Fish syntax from POSIX shells during the initial pass.
    eval 'function fish_main
        while true
            clear
            set_color -b 236 00afff; echo -n "   Flatpak Manager (Fish) "; set_color normal
            set_color 236; echo ""
            echo "  1.   Install Flatpak & Flathub"
            echo "  2. 󰚰  Update All Apps"
            echo "  q. 󰈆  Exit"
            echo ""
            read -P "  Choice  " choice
            switch $choice
                case 1
                    sudo pacman -S --needed --noconfirm flatpak
                    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                case 2
                    flatpak update -y
                case q Q
                    exit 0
            end
        end
    end; fish_main'
    exit 0
fi

# --- BASH / ZSH / POSIX SECTION ---
# This part only runs if the Fish block didn't trigger 'exit 0'

# Optimisation: Use a variable for the Package Manager for easier BSD/Distro porting
if command -v pacman >/dev/null; then
    PKG_INST="sudo pacman -S --needed --noconfirm"
elif command -v pkg >/dev/null; then # FreeBSD
    PKG_INST="sudo pkg install -y"
elif command -v apt-get >/dev/null; then # Debian/Ubuntu
    PKG_INST="sudo apt-get install -y"
else
    PKG_INST="echo Error: No pkg manager found"
fi

# Theme Colors
BG_BLUE="\033[48;5;39;38;5;255m"
FG_BLUE="\033[38;5;39m"
RESET="\033[0m"

print_header() {
    echo -e "${BG_BLUE}   $1 ${RESET}${FG_BLUE}${RESET}\n"
}

while true; do
    clear
    print_header "Flatpak Manager (POSIX)"
    echo -e "  1.   Install Flatpak & Flathub"
    echo -e "  2. 󰚰  Update All Apps"
    echo -e "  q. 󰈆  Exit"
    echo -ne "\n  Choice  "

    # Bug Fix: Use -r with read to prevent backslash escaping
    read -r choice

    case "$choice" in
        1)
            $PKG_INST flatpak
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            ;;
        2)
            flatpak update -y
            ;;
        q|Q)
            exit 0
            ;;
        *)
            echo -e "\n  Invalid Option!"
            sleep 1
            ;;
    esac
done
