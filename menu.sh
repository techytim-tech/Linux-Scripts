#!/bin/bash
# Techys Linux Menu – Enhanced Edition
# Added: Shell Management, Editor Management, Improved Terminal Detection
# ─────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────
ORANGE="#d65d0e"
AQUA="#689d6a"
GREEN="#98971a"
RED="#cc241d"
YELLOW="#d79921"
PURPLE="#b16286"
GRAY="#a89984"
BG="#282828"
FG="#ebdbb2"
set_bg() { printf '\e[48;2;%d;%d;%dm' $(echo "$1" | tr -d '#' | sed 's/../0x& /g'); }
set_fg() { printf '\e[38;2;%d;%d;%dm' $(echo "$1" | tr -d '#' | sed 's/../0x& /g'); }
reset() { printf '\e[0m'; }
MENU_WIDTH=78
MENU_HEIGHT=28
# Plain double line border using "=" characters
TL="=" TR="=" BL="=" BR="=" H="=" V="|"
detect_os() {
    [[ -f /etc/os-release ]] && source /etc/os-release
    case "$ID" in
        ubuntu|pop|debian) echo "Ubuntu/Debian" ;;
        arch|manjaro*) echo "Arch Linux" ;;
        fedora) echo "Fedora" ;;
        *) echo "${PRETTY_NAME:-Linux}" ;;
    esac
}
detect_os_id() {
    [[ -f /etc/os-release ]] && source /etc/os-release
    echo "${ID:-unknown}"
}
OS_INFO=$(detect_os)
OS_ID=$(detect_os_id)
print_centered() {
    local text="$1" fg="${2:-$FG}" row="$3"
    local padded=" $text "
    local col=$(( (MENU_WIDTH - ${#padded}) / 2 ))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 1 + col))" 2>/dev/null
    set_bg "$BG"; set_fg "$fg"; printf "%s" "$padded"; reset
}
draw_menu() {
    clear
    local w=$(tput cols) h=$(tput lines)
    [[ $w -lt 84 || $h -lt 34 ]] && { clear; echo "Terminal too small! Need ~84x34"; exit 1; }
    top_pad=$(( (h - MENU_HEIGHT - 2) / 2 ))
    left_pad=$(( (w - MENU_WIDTH - 2) / 2 ))
    for ((i=top_pad; i<top_pad+MENU_HEIGHT+2; i++)); do
        tput cup "$i" "$left_pad" 2>/dev/null
        set_bg "$BG"; printf "%*s" "$((MENU_WIDTH+2))" ""; reset
    done
    tput cup "$top_pad" "$left_pad"; set_bg "$BG"; set_fg "$YELLOW"; printf "%s%s%s" "$TL$TL" "$(printf '%*s' "$MENU_WIDTH" '' | tr ' ' "$H$H")" "$TR$TR"; reset
    for ((i=1; i<=MENU_HEIGHT; i++)); do
        tput cup "$((top_pad + i))" "$left_pad"; set_bg "$BG"; set_fg "$YELLOW"; printf "%s" "$V"; reset
        tput cup "$((top_pad + i))" "$((left_pad + MENU_WIDTH + 1))"; set_bg "$BG"; set_fg "$YELLOW"; printf "%s" "$V"; reset
    done
    tput cup "$((top_pad + MENU_HEIGHT + 1))" "$left_pad"; set_bg "$BG"; set_fg "$YELLOW"; printf "%s%s%s" "$BL$BL" "$(printf '%*s' "$MENU_WIDTH" '' | tr ' ' "$H$H")" "$BR$BR"; reset
    print_centered "Techys Linux Menu" "$ORANGE" 2
    print_centered "OS: $OS_INFO" "$AQUA" 5
    print_centered "Choose an option:" "$GRAY" 8
   
    # Menu items with aligned numbers
    local row=10
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$GREEN"; printf "1."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$GREEN"; printf "Set Nerd Font (Auto-Detect & Apply)"; reset
   
    ((row++))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$GREEN"; printf "2."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$GREEN"; printf "Download Linux Scripts"; reset
   
    ((row++))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$GREEN"; printf "3."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$GREEN"; printf "Execute Linux Scripts"; reset
   
    ((row++))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$PURPLE"; printf "4."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$PURPLE"; printf "Htop/Btop Tools"; reset
   
    ((row++))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$YELLOW"; printf "5."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$YELLOW"; printf "Install Build Tools"; reset
   
    ((row++))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$AQUA"; printf "6."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$AQUA"; printf "Install lsd + alias ls='lsd'"; reset
   
    ((row++))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$RED"; printf "7."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$RED"; printf "Remove lsd + alias"; reset
   
    ((row++))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$PURPLE"; printf "8."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$PURPLE"; printf "Shell Management"; reset
   
    ((row++))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$AQUA"; printf "9."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$AQUA"; printf "Editor Management"; reset

    ((row++))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$GREEN"; printf "10."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$GREEN"; printf "Install Packages"; reset
   
    ((row++))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$AQUA"; printf "11."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$AQUA"; printf "Terminal Config Installers"; reset
   
    ((row+=2))
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 8))"; set_bg "$BG"; set_fg "$RED"; printf "q."; reset
    tput cup "$((top_pad + 1 + row))" "$((left_pad + 12))"; set_bg "$BG"; set_fg "$RED"; printf "Quit"; reset
    tput cup "$((top_pad + MENU_HEIGHT + 3))" "$((left_pad + 2))"
    set_fg "$ORANGE"; printf "Enter choice: "; reset
}
# ─────────────────────────────────────────────
# Global
# ─────────────────────────────────────────────
SCRIPTS_DIR="$HOME/Linux-Scripts"
# ─────────────────────────────────────────────
# Helper: Install Package with Detected Manager
# ─────────────────────────────────────────────
install_package() {
    for pkg in "$@"; do
        local result=0
        local original_pkg="$pkg"
        
        if command -v apt >/dev/null; then
            sudo apt update -qq 2>/dev/null && sudo apt install -y "$pkg" 2>/dev/null
            result=$?
        elif command -v dnf >/dev/null; then
            sudo dnf install -y "$pkg" 2>/dev/null
            result=$?
        elif command -v yum >/dev/null; then
            sudo yum install -y "$pkg" 2>/dev/null
            result=$?
        elif command -v pacman >/dev/null; then
            sudo pacman -S --noconfirm "$pkg" 2>/dev/null
            result=$?
        elif command -v zypper >/dev/null; then
            sudo zypper install -y "$pkg" 2>/dev/null
            result=$?
        elif command -v apk >/dev/null; then
            sudo apk add "$pkg" 2>/dev/null
            result=$?
        elif command -v eopkg >/dev/null; then
            sudo eopkg install "$pkg" 2>/dev/null
            result=$?
        elif command -v emerge >/dev/null; then
            case "$pkg" in
                cava) pkg="media-sound/cava" ;;
                sound-juicer) pkg="media-sound/sound-juicer" ;;
                soundconverter) pkg="media-sound/soundconverter" ;;
                mpv) pkg="media-video/mpv" ;;
                mediainfo) pkg="app-misc/mediainfo" ;;
            esac
            sudo emerge --ask=n "$pkg" 2>/dev/null
            result=$?
        elif command -v xbps-install >/dev/null; then
            sudo xbps-install -Sy "$pkg" 2>/dev/null
            result=$?
        else
            set_fg "$RED"; echo "✗ Unsupported package manager for $original_pkg"; reset
            return 1
        fi
        
        if [[ $result -ne 0 ]]; then
            set_fg "$RED"; echo "✗ Failed to install $original_pkg"; reset
            return 1
        fi
    done
    return 0
}
# ─────────────────────────────────────────────
# Helper: Uninstall Package with Detected Manager
# ─────────────────────────────────────────────
uninstall_package() {
    for pkg in "$@"; do
        if command -v apt >/dev/null; then
            sudo apt remove -y "$pkg" && sudo apt autoremove -y
        elif command -v dnf >/dev/null; then
            sudo dnf remove -y "$pkg"
        elif command -v yum >/dev/null; then
            sudo yum remove -y "$pkg"
        elif command -v pacman >/dev/null; then
            sudo pacman -Rs --noconfirm "$pkg"
        elif command -v zypper >/dev/null; then
            sudo zypper remove -y "$pkg"
        elif command -v apk >/dev/null; then
            sudo apk del "$pkg"
        elif command -v eopkg >/dev/null; then
            sudo eopkg remove "$pkg"
        elif command -v emerge >/dev/null; then
            case "$pkg" in
                cava) pkg="media-sound/cava" ;;
                sound-juicer) pkg="media-sound/sound-juicer" ;;
                soundconverter) pkg="media-sound/soundconverter" ;;
                mpv) pkg="media-video/mpv" ;;
                mediainfo) pkg="app-misc/mediainfo" ;;
            esac
            sudo emerge --unmerge "$pkg"
        elif command -v xbps-install >/dev/null; then
            sudo xbps-remove -y "$pkg"
        else
            set_fg "$RED"; echo "Unsupported package manager for removing $pkg"; reset
            return 1
        fi
        [[ $? -eq 0 ]] || { set_fg "$RED"; echo "Failed to remove $pkg"; reset; return 1; }
    done
    return 0
}
# ─────────────────────────────────────────────
# Detect Current Terminal
# ─────────────────────────────────────────────
detect_terminal() {
    [[ -n "$WEZTERM_EXECUTABLE" ]] && echo "wezterm" && return
    [[ -n "$KITTY_WINDOW_ID" ]] && echo "kitty" && return
    [[ -n "$ALACRITTY_SOCKET" || -n "$ALACRITTY_LOG" ]] && echo "alacritty" && return
    [[ "$TERM_PROGRAM" == "vscode" ]] && echo "vscode" && return
    [[ "$TERM_PROGRAM" == "ghostty" || -n "$GHOSTTY_RESOURCES_DIR" ]] && echo "ghostty" && return
    [[ "$COLORTERM" == "gnome-terminal" || "$VTE_VERSION" ]] && echo "gnome-terminal" && return
    [[ -n "$KONSOLE_VERSION" ]] && echo "konsole" && return
    [[ -n "$XFCE4_TERMINAL" ]] && echo "xfce4-terminal" && return
   
    local ppid_name=$(ps -o comm= -p $PPID 2>/dev/null)
    case "$ppid_name" in
        *wezterm*) echo "wezterm" ;;
        *kitty*) echo "kitty" ;;
        *alacritty*) echo "alacritty" ;;
        *ghostty*) echo "ghostty" ;;
        *gnome-terminal*) echo "gnome-terminal" ;;
        *konsole*) echo "konsole" ;;
        *xfce4-terminal*) echo "xfce4-terminal" ;;
        *) echo "unknown" ;;
    esac
}
# ─────────────────────────────────────────────
# 1. Set Nerd Font
# ─────────────────────────────────────────────
set_nerd_font() {
    clear
    set_fg "$ORANGE"; echo "═══════════════════════════════════════════════════════════"; reset
    set_fg "$ORANGE"; echo " Nerd Font Configuration"; reset
    set_fg "$ORANGE"; echo "═══════════════════════════════════════════════════════════"; reset
    echo
    local current_term=$(detect_terminal)
    set_fg "$AQUA"; echo " Detected Terminal: $current_term"; reset
    echo
    set_fg "$YELLOW"; echo " Scanning for Nerd Fonts..."; reset
    echo
    local font_dirs=("/usr/share/fonts" "/usr/local/share/fonts" "$HOME/.local/share/fonts" "$HOME/.fonts")
    local font_list=()
    local font_names=()
    while IFS= read -r file; do
        [[ "$file" =~ (Nerd|Hack|Fira|JetBrains|Cascadia|Meslo|Mononoki|DaddyTimeMono|Iosevka) ]] || continue
        local name=$(basename "$file" | sed -e 's/\.ttf\|\.otf$//' -e 's/NerdFont//' -e 's/-[a-zA-Z]*$//' -e 's/-/ /g' | xargs)
        font_list+=("$file")
        font_names+=("$name")
    done < <(find "${font_dirs[@]}" -type f \( -iname "*nerd*" -o -iname "*hack*" -o -iname "*fira*" -o -iname "*jet*" -o -iname "*cascadia*" -o -iname "*iosevka*" \) 2>/dev/null | sort -u)
    if [[ ${#font_names[@]} -eq 0 ]]; then
        set_fg "$RED"; echo " No Nerd Fonts found!"; reset
        echo " Download from: https://www.nerdfonts.com"
        read -p "Press Enter..."
        return
    fi
    local i=1
    for name in "${font_names[@]}"; do
        set_fg "$AQUA"; printf " %2d)" "$i"; reset
        set_fg "$GREEN"; echo " $name"; reset
        ((i++))
    done
    echo; set_fg "$RED"; echo " b) Back"; reset; set_fg "$AQUA"; echo " r) Return to Main Menu"; reset; set_fg "$AQUA"; printf "\n → "; reset
    read -r choice
    [[ "$choice" == "b" || "$choice" == "B" ]] && return
    [[ "$choice" == "r" || "$choice" == "R" ]] && return
    [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#font_names[@]} )) || { set_fg "$RED"; echo "Invalid"; reset; sleep 1; return; }
    local selected="${font_names[$((choice-1))]}"
    clear; set_fg "$YELLOW"; echo "Applying: $selected"; reset; echo
    case "$current_term" in
        wezterm)
            local wezterm_config="$HOME/.wezterm.lua"
            if [[ -f "$wezterm_config" ]]; then
                sed -i "/font = wezterm.font/d" "$wezterm_config"
            fi
            echo "config.font = wezterm.font('$selected')" >> "$wezterm_config"
            set_fg "$GREEN"; echo "✓ WezTerm config updated!"; reset
            ;;
        kitty)
            local kitty_config="$HOME/.config/kitty/kitty.conf"
            mkdir -p "$HOME/.config/kitty"
            if [[ -f "$kitty_config" ]]; then
                sed -i "/^font_family/d" "$kitty_config"
            fi
            echo "font_family $selected" >> "$kitty_config"
            set_fg "$GREEN"; echo "✓ Kitty config updated!"; reset
            ;;
        alacritty)
            local alacritty_config="$HOME/.config/alacritty/alacritty.toml"
            mkdir -p "$HOME/.config/alacritty"
            if [[ -f "$alacritty_config" ]]; then
                sed -i '/\[font\]/,/family = /d' "$alacritty_config"
            fi
            cat >> "$alacritty_config" << EOF
[font]
normal = { family = "$selected" }
EOF
            set_fg "$GREEN"; echo "✓ Alacritty config updated!"; reset
            ;;
        ghostty)
            local ghostty_config="$HOME/.config/ghostty/config"
            mkdir -p "$HOME/.config/ghostty"
            if [[ -f "$ghostty_config" ]]; then
                sed -i '/^font-family/d' "$ghostty_config"
            fi
            echo "font-family = $selected" >> "$ghostty_config"
            set_fg "$GREEN"; echo "✓ Ghostty config updated!"; reset
            ;;
        gnome-terminal)
            local profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
            dconf write /org/gnome/terminal/legacy/profiles:/:$profile/font "'$selected 11'"
            dconf write /org/gnome/terminal/legacy/profiles:/:$profile/use-system-font false
            set_fg "$GREEN"; echo "✓ GNOME Terminal profile updated!"; reset
            ;;
        konsole)
            set_fg "$YELLOW"; echo "For Konsole: Settings → Edit Current Profile → Appearance → Font"; reset
            set_fg "$YELLOW"; echo "Select: $selected"; reset
            ;;
        *)
            set_fg "$YELLOW"; echo "Manual setup needed for $current_term"; reset
            set_fg "$YELLOW"; echo "Use font: $selected"; reset
            ;;
    esac
   
    echo
    set_fg "$AQUA"; echo "Note: You may need to restart your terminal for changes to take effect."; reset
    read -p "Press Enter..."
}
# ─────────────────────────────────────────────
# 2. Download scripts
# ─────────────────────────────────────────────
download_scripts() {
    clear
    set_fg "$YELLOW"; echo "Downloading scripts to $SCRIPTS_DIR"; reset
    if [[ -d "$SCRIPTS_DIR" ]]; then
        if (cd "$SCRIPTS_DIR" && git pull --quiet); then
            set_fg "$GREEN"; echo "Updated!"; reset
        else
            set_fg "$RED"; echo "Failed to update scripts. Check your internet connection."; reset
            read -p "Press Enter..."
            return
        fi
    else
        if git clone --quiet https://github.com/techytim-tech/Linux-Scripts.git "$SCRIPTS_DIR"; then
            set_fg "$GREEN"; echo "Downloaded!"; reset
        else
            set_fg "$RED"; echo "Failed to download scripts. Check your internet connection."; reset
            read -p "Press Enter..."
            return
        fi
    fi
    read -p "Press Enter..."
}
# ─────────────────────────────────────────────
# 3. Execute scripts
# ─────────────────────────────────────────────
execute_scripts_menu() {
    [[ ! -d "$SCRIPTS_DIR" ]] && { clear; set_fg "$RED"; echo "Run option 2 first!"; reset; sleep 3; return; }
    while true; do
        clear
        set_fg "$ORANGE"; echo " Execute Linux Scripts"; reset; echo
        mapfile -t scripts < <(find "$SCRIPTS_DIR" -maxdepth 1 -name "*.sh" -exec basename {} \; | sort)
        [[ ${#scripts[@]} -eq 0 ]] && { echo " No scripts found!"; read -p "Press Enter..."; return; }
        local i=1
        for s in "${scripts[@]}"; do
            set_fg "$AQUA"; printf " %2d)" "$i"; reset
            set_fg "$GREEN"; echo " $s"; reset
            ((i++))
        done
        echo; set_fg "$RED"; echo " b) Back"; reset; set_fg "$AQUA"; echo " r) Return to Main Menu"; reset; echo; set_fg "$AQUA"; printf " → "; reset
        read -r c
        [[ "$c" == "b" || "$c" == "B" ]] && return
        [[ "$c" == "r" || "$c" == "R" ]] && return
        [[ "$c" =~ ^[0-9]+$ ]] && (( c >= 1 && c <= ${#scripts[@]} )) || continue
        clear
        set_fg "$YELLOW"; echo "Running: ${scripts[$((c-1))]}"; reset; echo
        bash "$SCRIPTS_DIR/${scripts[$((c-1))]}"
        read -p $'\nPress Enter to continue...'
    done
}
# ─────────────────────────────────────────────
# 4. Htop/Btop Tools
# ─────────────────────────────────────────────
htop_btop_menu() {
    while true; do
        clear
        set_fg "$PURPLE"; echo " Htop / Btop Tools"; reset; echo
        echo " 1) Run htop"
        echo " 2) Install htop"
        echo " 3) Install btop + Theme"
        echo " 4) Run btop"
        echo " b) Back  r) Return to Main Menu"
        read -p " → " sub
        case "$sub" in
            1) command -v htop &>/dev/null && htop || { set_fg "$RED"; echo "htop not installed"; reset; }; read -p "Enter..." ;;
            2)
                clear; set_fg "$YELLOW"; echo "Installing htop..."; reset
                if install_package htop; then
                    set_fg "$GREEN"; echo "✓ htop installed!"; reset
                else
                    set_fg "$RED"; echo "Failed to install htop"; reset
                fi
                read -p "Enter..."
                ;;
            3)
                clear; set_fg "$YELLOW"; echo "Installing btop..."; reset
                [[ -d ~/btop ]] && (cd ~/btop && git pull) || git clone https://github.com/aristocratos/btop.git ~/btop
                if cd ~/btop && make -j"$(nproc)" && sudo make install; then
                    set_fg "$GREEN"; echo "btop installed!"; reset
                else
                    set_fg "$RED"; echo "Failed to install btop"; reset
                fi
                read -p "Enter..."
                ;;
            4) command -v btop &>/dev/null && btop || { set_fg "$RED"; echo "btop not installed"; reset; sleep 2; } ;;
            b|"") return ;;
            r|R) return ;;
        esac
    done
}
# ─────────────────────────────────────────────
# 5. Install Build Tools
# ─────────────────────────────────────────────
install_build_tools() {
    clear
    set_fg "$YELLOW"; echo "Installing build tools..."; reset
    if command -v apt >/dev/null; then
        install_package git build-essential cmake
    elif command -v dnf >/dev/null; then
        sudo dnf groupinstall -y "Development Tools"
        install_package git cmake
    elif command -v yum >/dev/null; then
        sudo yum groupinstall -y "Development Tools"
        install_package git cmake
    elif command -v pacman >/dev/null; then
        install_package base-devel git cmake
    elif command -v zypper >/dev/null; then
        sudo zypper install -y -t pattern devel_basis
        install_package git cmake
    elif command -v apk >/dev/null; then
        install_package git make gcc g++ cmake
    elif command -v eopkg >/dev/null; then
        install_package git devel cmake
    elif command -v emerge >/dev/null; then
        install_package dev-vcs/git sys-devel/make sys-devel/gcc sys-devel/cmake
    elif command -v xbps-install >/dev/null; then
        install_package base-devel git cmake
    else
        set_fg "$RED"; echo "Unsupported package manager"; reset
    fi
    read -p "Press Enter..."
}
# ─────────────────────────────────────────────
# 6. Install lsd + alias
# ─────────────────────────────────────────────
install_lsd() {
    clear
    set_fg "$YELLOW"; echo "═══════════════════════════════════════════════════════════"; reset
    set_fg "$YELLOW"; echo " Install lsd LSDeluxe"; reset
    set_fg "$YELLOW"; echo "═══════════════════════════════════════════════════════════"; reset
    echo
   
    local lsd_installed=false
    local install_method=""
    local pkg_manager=""
   
    if command -v apt >/dev/null; then
        pkg_manager="apt"
    elif command -v dnf >/dev/null; then
        pkg_manager="dnf"
    elif command -v pacman >/dev/null; then
        pkg_manager="pacman"
    elif command -v zypper >/dev/null; then
        pkg_manager="zypper"
    fi
   
    set_fg "$AQUA"; echo " Installation Options:"; reset
    echo
   
    if [[ -n "$pkg_manager" ]]; then
        set_fg "$GREEN"; echo " 1) Install via $pkg_manager (Recommended)"; reset
    fi
   
    if command -v cargo >/dev/null; then
        set_fg "$YELLOW"; echo " 2) Install via Cargo (Compile from source)"; reset
    else
        set_fg "$GRAY"; echo " 2) Install via Cargo (cargo not installed)"; reset
    fi
   
    echo
    set_fg "$RED"; echo " b) Back"; reset
    set_fg "$AQUA"; echo " r) Return to Main Menu"; reset
    echo
    set_fg "$AQUA"; printf " → "; reset
    read -r choice
   
    case "$choice" in
        b|B) return ;;
        r|R) return ;;
        1)
            if [[ -z "$pkg_manager" ]]; then
                set_fg "$RED"; echo "No package manager detected!"; reset
                read -p "Press Enter..."
                return
            fi
           
            clear
            set_fg "$YELLOW"; echo "Installing lsd via $pkg_manager..."; reset
            echo

            if install_package lsd; then
                lsd_installed=true
                install_method="package_manager"
                set_fg "$GREEN"; echo "✓ lsd installed successfully via $pkg_manager!"; reset
            else
                set_fg "$RED"; echo "✗ Failed to install lsd via $pkg_manager"; reset
                read -p "Press Enter..."
                return
            fi
            ;;
           
        2)
            if ! command -v cargo >/dev/null; then
                set_fg "$RED"; echo "Cargo is not installed!"; reset
                set_fg "$YELLOW"; echo "Install Rust from: https://rustup.rs/"; reset
                read -p "Press Enter..."
                return
            fi
           
            clear
            set_fg "$YELLOW"; echo "Installing lsd via Cargo..."; reset
            set_fg "$AQUA"; echo "This will compile from source and may take a few minutes."; reset
            echo
           
            if cargo install --list | grep -q '^lsd v' &>/dev/null; then
                set_fg "$YELLOW"; echo "lsd is already installed via cargo."; reset
                set_fg "$AQUA"; echo "Reinstalling..."; reset
                cargo uninstall lsd
            fi
           
            if cargo install lsd; then
                lsd_installed=true
                install_method="cargo"
                set_fg "$GREEN"; echo "✓ lsd compiled and installed successfully via Cargo!"; reset
                echo
               
                local cargo_bin="$HOME/.cargo/bin"
                set_fg "$AQUA"; echo "lsd installed to: $cargo_bin/lsd"; reset
               
                if [[ ":$PATH:" != *":$cargo_bin:"* ]]; then
                    set_fg "$YELLOW"; echo ""; reset
                    set_fg "$YELLOW"; echo "⚠ $cargo_bin is not in your PATH!"; reset
                    set_fg "$YELLOW"; echo "Adding to shell configuration..."; reset
                   
                    local shell_config=""
                    if [[ -f "$HOME/.zshrc" ]]; then
                        shell_config="$HOME/.zshrc"
                    elif [[ -f "$HOME/.bashrc" ]]; then
                        shell_config="$HOME/.bashrc"
                    elif [[ -f "$HOME/.config/fish/config.fish" ]]; then
                        shell_config="$HOME/.config/fish/config.fish"
                    fi
                   
                    if [[ -n "$shell_config" ]]; then
                        if ! grep -qF "/.cargo/bin" "$shell_config" 2>/dev/null; then
                            if [[ "$shell_config" == *".fish" ]]; then
                                echo -e "\n# Cargo bin path\nset -gx PATH \$HOME/.cargo/bin \$PATH" >> "$shell_config"
                            else
                                echo -e "\n# Cargo bin path\nexport PATH=\"\$HOME/.cargo/bin:\$PATH\"" >> "$shell_config"
                            fi
                            set_fg "$GREEN"; echo "✓ Added $cargo_bin to PATH in $shell_config"; reset
                            set_fg "$AQUA"; echo "Please restart your terminal or run: source $shell_config"; reset
                        else
                            set_fg "$AQUA"; echo "Cargo bin already in PATH"; reset
                        fi
                    else
                        set_fg "$YELLOW"; echo "Could not detect shell config."; reset
                        set_fg "$YELLOW"; echo "Add to your shell config: export PATH=\"\$HOME/.cargo/bin:\$PATH\""; reset
                    fi
                else
                    set_fg "$GREEN"; echo "✓ Cargo bin already in PATH"; reset
                fi
            else
                set_fg "$RED"; echo "✗ Failed to compile lsd via Cargo"; reset
                read -p "Press Enter..."
                return
            fi
            ;;
           
        *)
            set_fg "$RED"; echo "Invalid option"; reset
            sleep 1
            return
            ;;
    esac
    if [[ "$lsd_installed" = true ]]; then
        echo
        set_fg "$YELLOW"; echo "Adding 'ls' alias to shell configuration..."; reset
       
        local shell_configs=()
        [[ -f "$HOME/.bashrc" ]] && shell_configs+=("$HOME/.bashrc")
        [[ -f "$HOME/.zshrc" ]] && shell_configs+=("$HOME/.zshrc")
        [[ -f "$HOME/.config/fish/config.fish" ]] && shell_configs+=("$HOME/.config/fish/config.fish")
       
        for config_file in "${shell_configs[@]}"; do
            if [[ "$config_file" == *".fish" ]]; then
                if ! grep -qF "alias ls 'lsd --color=auto'" "$config_file" 2>/dev/null; then
                    echo -e "\n# lsd alias\nalias ls 'lsd --color=auto'" >> "$config_file"
                    set_fg "$GREEN"; echo "✓ Alias added to $config_file"; reset
                else
                    set_fg "$AQUA"; echo "• Alias already exists in $config_file"; reset
                fi
            else
                if ! grep -qF "alias ls='lsd --color=auto'" "$config_file" 2>/dev/null; then
                    echo -e "\n# lsd alias\nalias ls='lsd --color=auto'" >> "$config_file"
                    set_fg "$GREEN"; echo "✓ Alias added to $config_file"; reset
                else
                    set_fg "$AQUA"; echo "• Alias already exists in $config_file"; reset
                fi
            fi
        done
       
        echo
        set_fg "$GREEN"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$GREEN"; echo " Installation Complete!"; reset
        set_fg "$GREEN"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$AQUA"; echo "Restart your terminal or run 'source ~/.bashrc' (or your shell config)"; reset
    fi
   
    read -p "Press Enter..."
}
# ─────────────────────────────────────────────
# 7. Remove lsd + alias
# ─────────────────────────────────────────────
remove_lsd() {
    clear
    set_fg "$YELLOW"; echo "═══════════════════════════════════════════════════════════"; reset
    set_fg "$YELLOW"; echo " Remove lsd LSDeluxe"; reset
    set_fg "$YELLOW"; echo "═══════════════════════════════════════════════════════════"; reset
    echo
   
    local lsd_removed=false
    local removal_method=""
    if ! command -v lsd &>/dev/null; then
        set_fg "$AQUA"; echo "lsd is not currently installed on this system."; reset
        read -p "Press Enter..."
        return
    fi
    set_fg "$YELLOW"; echo "Detecting lsd installation method..."; reset
    echo
    local removed_via_pkg=false
   
    if command -v apt >/dev/null && dpkg -s lsd &>/dev/null; then
        set_fg "$AQUA"; echo "Found: lsd installed via apt"; reset
        set_fg "$YELLOW"; echo "Removing lsd via apt..."; reset
        if uninstall_package lsd; then
            lsd_removed=true
            removed_via_pkg=true
            removal_method="apt"
            set_fg "$GREEN"; echo "✓ lsd removed via apt"; reset
        fi
    elif command -v dnf >/dev/null && rpm -q lsd &>/dev/null; then
        set_fg "$AQUA"; echo "Found: lsd installed via dnf"; reset
        set_fg "$YELLOW"; echo "Removing lsd via dnf..."; reset
        if uninstall_package lsd; then
            lsd_removed=true
            removed_via_pkg=true
            removal_method="dnf"
            set_fg "$GREEN"; echo "✓ lsd removed via dnf"; reset
        fi
    elif command -v pacman >/dev/null && pacman -Q lsd &>/dev/null; then
        set_fg "$AQUA"; echo "Found: lsd installed via pacman"; reset
        set_fg "$YELLOW"; echo "Removing lsd via pacman..."; reset
        if uninstall_package lsd; then
            lsd_removed=true
            removed_via_pkg=true
            removal_method="pacman"
            set_fg "$GREEN"; echo "✓ lsd removed via pacman"; reset
        fi
    elif command -v zypper >/dev/null && zypper se -i lsd &>/dev/null; then
        set_fg "$AQUA"; echo "Found: lsd installed via zypper"; reset
        set_fg "$YELLOW"; echo "Removing lsd via zypper..."; reset
        if uninstall_package lsd; then
            lsd_removed=true
            removed_via_pkg=true
            removal_method="zypper"
            set_fg "$GREEN"; echo "✓ lsd removed via zypper"; reset
        fi
    fi
   
    if command -v cargo >/dev/null && cargo install --list | grep -q '^lsd v' &>/dev/null; then
        set_fg "$AQUA"; echo "Found: lsd installed via cargo"; reset
        set_fg "$YELLOW"; echo "Removing lsd via cargo..."; reset
        if cargo uninstall lsd; then
            lsd_removed=true
            removal_method="cargo"
            set_fg "$GREEN"; echo "✓ lsd removed via cargo"; reset
            set_fg "$AQUA"; echo "Binary was located at: $HOME/.cargo/bin/lsd"; reset
        else
            set_fg "$RED"; echo "✗ Failed to remove lsd via cargo"; reset
        fi
    fi
    if [[ "$lsd_removed" = false ]] && command -v lsd &>/dev/null; then
        set_fg "$YELLOW"; echo "Could not determine installation method automatically."; reset
        set_fg "$YELLOW"; echo "lsd binary location: $(which lsd)"; reset
        set_fg "$YELLOW"; echo "You may need to remove it manually."; reset
    fi
    echo
    echo
    set_fg "$YELLOW"; echo "Removing 'ls' alias for 'lsd' from shell configs..."; reset
    echo
   
    local alias_removed=false
    local shell_config_files=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.config/fish/config.fish")
    local alias_string_bash_zsh="alias ls='lsd --color=auto'"
    local alias_string_fish="alias ls 'lsd --color=auto'"
    for config_file in "${shell_config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            local removed_from_this_file=false
           
            if grep -qF "$alias_string_bash_zsh" "$config_file" 2>/dev/null; then
                sed -i "/^# lsd alias$/d" "$config_file" 2>/dev/null
                sed -i "/^alias ls='lsd --color=auto'$/d" "$config_file" 2>/dev/null
                removed_from_this_file=true
            elif grep -qF "$alias_string_fish" "$config_file" 2>/dev/null; then
                sed -i "/^# lsd alias$/d" "$config_file" 2>/dev/null
                sed -i "/^alias ls 'lsd --color=auto'$/d" "$config_file" 2>/dev/null
                removed_from_this_file=true
            fi
           
            if [[ "$removed_from_this_file" = true ]]; then
                set_fg "$GREEN"; echo "✓ Removed alias from: $config_file"; reset
                alias_removed=true
            fi
        fi
    done
    if [[ "$alias_removed" = false ]]; then
        set_fg "$AQUA"; echo "No lsd aliases found in common shell configuration files."; reset
    fi
    echo
    set_fg "$GREEN"; echo "═══════════════════════════════════════════════════════════"; reset
    set_fg "$GREEN"; echo " Removal Complete!"; reset
    set_fg "$GREEN"; echo "═══════════════════════════════════════════════════════════"; reset
   
    if [[ "$alias_removed" = true ]]; then
        set_fg "$AQUA"; echo "Please restart your terminal or run 'source ~/.bashrc' (or your shell config)"; reset
        set_fg "$AQUA"; echo "for the alias changes to take effect."; reset
    fi
   
    read -p "Press Enter..."
}
# ─────────────────────────────────────────────
# 8. Shell Management
# ─────────────────────────────────────────────
shell_management_menu() {
    while true; do
        clear
        set_fg "$PURPLE"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$PURPLE"; echo " Shell Management"; reset
        set_fg "$PURPLE"; echo "═══════════════════════════════════════════════════════════"; reset
        echo
       
        local current_shell=$(basename "$SHELL")
        set_fg "$AQUA"; echo " Current Shell: $current_shell"; reset
        echo
       
        set_fg "$YELLOW"; echo " Installed Shells:"; reset
        local shell_num=1
        declare -A shell_map
       
        for shell_path in /bin/bash /bin/zsh /usr/bin/fish /bin/dash /bin/sh; do
            if [[ -x "$shell_path" ]]; then
                local shell_name=$(basename "$shell_path")
                set_fg "$GREEN"; printf " • %s" "$shell_name"; reset
                [[ "$shell_name" == "$current_shell" ]] && set_fg "$AQUA"; printf " (current)"; reset
                echo
                shell_map[$shell_num]="$shell_path"
                ((shell_num++))
            fi
        done
       
        echo
        set_fg "$GRAY"; echo " Options:"; reset
        echo " 1) Install Zsh"
        echo " 2) Install Fish"
        echo " 3) Install Bash (if missing)"
        echo " 4) Set Default Shell"
        echo " 5) View Shell Info"
        echo " b) Back  r) Return to Main Menu"
        echo
        set_fg "$AQUA"; printf " → "; reset
        read -r choice
       
        case "$choice" in
            1)
                clear
                set_fg "$YELLOW"; echo "Installing Zsh shell..."; reset
                echo
                if install_package zsh; then
                    set_fg "$GREEN"; echo "✓ Zsh shell installed successfully!"; reset
                    echo
                    set_fg "$AQUA"; echo "Install Oh My Zsh? (y/n): "; reset
                    read -r install_omz
                    if [[ "$install_omz" =~ ^[Yy]$ ]]; then
                        echo
                        set_fg "$YELLOW"; echo "Installing Oh My Zsh..."; reset
                        if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
                            set_fg "$GREEN"; echo "✓ Oh My Zsh installed!"; reset
                        else
                            set_fg "$RED"; echo "✗ Failed to install Oh My Zsh"; reset
                        fi
                    fi
                else
                    set_fg "$RED"; echo "✗ Failed to install Zsh"; reset
                fi
                read -p "Press Enter..."
                ;;
            2)
                clear
                set_fg "$YELLOW"; echo "Installing Fish shell..."; reset
                echo
                if install_package fish; then
                    set_fg "$GREEN"; echo "✓ Fish shell installed successfully!"; reset
                else
                    set_fg "$RED"; echo "✗ Failed to install Fish"; reset
                fi
                read -p "Press Enter..."
                ;;
            3)
                clear
                set_fg "$YELLOW"; echo "Installing Bash shell..."; reset
                echo
                if install_package bash; then
                    set_fg "$GREEN"; echo "✓ Bash shell installed successfully!"; reset
                else
                    set_fg "$RED"; echo "✗ Failed to install Bash"; reset
                fi
                read -p "Press Enter..."
                ;;
            4)
                clear
                set_fg "$YELLOW"; echo "Set Default Shell"; reset
                echo
                set_fg "$GRAY"; echo "Available shells:"; reset
               
                local valid_shells=()
                local shell_paths=()
                local idx=1
               
                for shell_path in /bin/bash /bin/zsh /usr/bin/fish /bin/dash; do
                    if [[ -x "$shell_path" ]]; then
                        local shell_name=$(basename "$shell_path")
                        set_fg "$AQUA"; printf " %d) %s" "$idx" "$shell_name"; reset
                        [[ "$shell_name" == "$current_shell" ]] && set_fg "$GREEN"; printf " (current)"; reset
                        echo
                        valid_shells+=("$shell_name")
                        shell_paths+=("$shell_path")
                        ((idx++))
                    fi
                done
               
                echo
                set_fg "$AQUA"; printf "Select shell (1-%d) or b to cancel: " "$((idx-1))"; reset
                read -r shell_choice
               
                if [[ "$shell_choice" =~ ^[0-9]+$ ]] && (( shell_choice >= 1 && shell_choice < idx )); then
                    local selected_path="${shell_paths[$((shell_choice-1))]}"
                    set_fg "$YELLOW"; echo "Changing default shell to $selected_path..."; reset
                    chsh -s "$selected_path"
                    if [[ $? -eq 0 ]]; then
                        set_fg "$GREEN"; echo "✓ Default shell changed successfully!"; reset
                        set_fg "$AQUA"; echo "Please log out and log back in for changes to take effect."; reset
                    else
                        set_fg "$RED"; echo "✗ Failed to change shell. You may need sudo access."; reset
                    fi
                fi
                read -p "Press Enter..."
                ;;
            5)
                clear
                set_fg "$YELLOW"; echo "Shell Information"; reset
                echo
                set_fg "$AQUA"; echo "Current Shell: $SHELL"; reset
                set_fg "$AQUA"; echo "Shell Version:"; reset
                $SHELL --version 2>/dev/null | head -n 1
                echo
                set_fg "$AQUA"; echo "Available Shells (from /etc/shells):"; reset
                cat /etc/shells 2>/dev/null | grep -v "^#"
                read -p "Press Enter..."
                ;;
            b|"")
                return
                ;;
            r|R)
                return
                ;;
        esac
    done
}
# ─────────────────────────────────────────────
# 9. Editor Management
# ─────────────────────────────────────────────
editor_management_menu() {
    declare -A editor_names=(
        ["nano"]="nano"
        ["vim"]="vim"
        ["nvim"]="neovim"
        ["helix"]="helix"
        ["micro"]="micro"
        ["emacs"]="emacs"
        ["ne"]="ne (nice editor)"
    )
   
    while true; do
        clear
        set_fg "$AQUA"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$AQUA"; echo " Editor Management"; reset
        set_fg "$AQUA"; echo "═══════════════════════════════════════════════════════════"; reset
        echo
       
        local current_editor="${EDITOR:-not set}"
        set_fg "$YELLOW"; echo " Current EDITOR: $current_editor"; reset
        echo
       
        set_fg "$YELLOW"; echo " Installed Editors:"; reset
       
        for cmd in nano vim nvim helix micro emacs ne; do
            if command -v "$cmd" &>/dev/null; then
                set_fg "$GREEN"; printf " • %s" "${editor_names[$cmd]}"; reset
                [[ "$cmd" == "$current_editor" ]] && set_fg "$AQUA"; printf " (current)"; reset
                echo
            fi
        done
       
        echo
        set_fg "$GRAY"; echo " Options:"; reset
        echo " 1) Install Nano"
        echo " 2) Install Vim"
        echo " 3) Install Neovim"
        echo " 4) Install Helix"
        echo " 5) Install Micro"
        echo " 6) Install Ne (Nice Editor)"
        echo " 7) Set Default Editor"
        echo " 8) View Editor Info"
        echo " b) Back  r) Return to Main Menu"
        echo
        set_fg "$AQUA"; printf " → "; reset
        read -r choice
       
        case "$choice" in
            1)
                clear
                set_fg "$YELLOW"; echo "Installing Nano editor..."; reset
                echo
                if install_package nano; then
                    set_fg "$GREEN"; echo "✓ Nano editor installed successfully!"; reset
                else
                    set_fg "$RED"; echo "✗ Failed to install Nano"; reset
                fi
                read -p "Press Enter..."
                ;;
            2)
                clear
                set_fg "$YELLOW"; echo "Installing Vim editor..."; reset
                echo
                if install_package vim; then
                    set_fg "$GREEN"; echo "✓ Vim editor installed successfully!"; reset
                else
                    set_fg "$RED"; echo "✗ Failed to install Vim"; reset
                fi
                read -p "Press Enter..."
                ;;
            3)
                clear
                set_fg "$YELLOW"; echo "Installing Neovim editor..."; reset
                echo
                if install_package neovim; then
                    set_fg "$GREEN"; echo "✓ Neovim editor installed successfully!"; reset
                else
                    set_fg "$RED"; echo "✗ Failed to install Neovim"; reset
                fi
                read -p "Press Enter..."
                ;;
            4)
                clear
                set_fg "$YELLOW"; echo "Installing Helix editor..."; reset
                echo
                if command -v apt >/dev/null; then
                    set_fg "$AQUA"; echo "Attempting to add PPA for Helix..."; reset
                    sudo add-apt-repository -y ppa:maveonair/helix-editor 2>/dev/null
                    sudo apt update
                fi
                if install_package helix; then
                    set_fg "$GREEN"; echo "✓ Helix editor installed successfully!"; reset
                else
                    if command -v cargo >/dev/null; then
                        set_fg "$AQUA"; echo "Installing via cargo..."; reset
                        if cargo install helix-term --locked; then
                            set_fg "$GREEN"; echo "✓ Helix installed via cargo!"; reset
                        else
                            set_fg "$RED"; echo "✗ Failed to install Helix via cargo"; reset
                        fi
                    else
                        set_fg "$RED"; echo "✗ Failed to install Helix"; reset
                    fi
                fi
                read -p "Press Enter..."
                ;;
            5)
                clear
                set_fg "$YELLOW"; echo "Installing Micro editor..."; reset
                echo
                if install_package micro; then
                    set_fg "$GREEN"; echo "✓ Micro editor installed successfully!"; reset
                else
                    set_fg "$AQUA"; echo "Installing via official script..."; reset
                    curl https://getmic.ro | bash
                    if [[ -f ./micro ]]; then
                        sudo mv micro /usr/local/bin/
                        sudo chmod +x /usr/local/bin/micro
                        set_fg "$GREEN"; echo "✓ Micro installed via script!"; reset
                    else
                        set_fg "$RED"; echo "✗ Failed to install Micro"; reset
                    fi
                fi
                read -p "Press Enter..."
                ;;
            6)
                clear
                set_fg "$YELLOW"; echo "Installing Ne (Nice Editor)..."; reset
                echo
                if install_package ne; then
                    set_fg "$GREEN"; echo "✓ Ne (Nice Editor) installed successfully!"; reset
                else
                    set_fg "$RED"; echo "✗ Failed to install Ne"; reset
                fi
                read -p "Press Enter..."
                ;;
            7)
                clear
                set_fg "$YELLOW"; echo "Set Default Editor"; reset
                echo
                set_fg "$GRAY"; echo "Available editors:"; reset
               
                local available_editors=()
                local editor_cmds=()
                local idx=1
               
                for cmd in nano vim nvim helix micro emacs ne; do
                    if command -v "$cmd" &>/dev/null; then
                        set_fg "$AQUA"; printf " %d) %s" "$idx" "${editor_names[$cmd]}"; reset
                        [[ "$cmd" == "$EDITOR" ]] && set_fg "$GREEN"; printf " (current)"; reset
                        echo
                        available_editors+=("${editor_names[$cmd]}")
                        editor_cmds+=("$cmd")
                        ((idx++))
                    fi
                done
               
                [[ ${#editor_cmds[@]} -eq 0 ]] && { set_fg "$RED"; echo "No editors installed!"; reset; read -p "Press Enter..."; continue; }
               
                echo
                set_fg "$AQUA"; printf "Select editor (1-%d) or b to cancel: " "$((idx-1))"; reset
                read -r editor_choice
               
                if [[ "$editor_choice" =~ ^[0-9]+$ ]] && (( editor_choice >= 1 && editor_choice < idx )); then
                    local selected_editor="${editor_cmds[$((editor_choice-1))]}"
                   
                    local config_file=""
                    if [[ "$SHELL" == *"zsh"* ]]; then
                        config_file="$HOME/.zshrc"
                    elif [[ "$SHELL" == *"bash"* ]]; then
                        config_file="$HOME/.bashrc"
                    elif [[ "$SHELL" == *"fish"* ]]; then
                        config_file="$HOME/.config/fish/config.fish"
                    fi
                   
                    if [[ -n "$config_file" ]]; then
                        sed -i '/^export EDITOR=/d' "$config_file" 2>/dev/null
                        sed -i '/^set -gx EDITOR/d' "$config_file" 2>/dev/null
                       
                        if [[ "$config_file" == *".fish" ]]; then
                            echo "set -gx EDITOR $selected_editor" >> "$config_file"
                        else
                            echo "export EDITOR=$selected_editor" >> "$config_file"
                        fi
                       
                        set_fg "$GREEN"; echo "✓ Default editor set to $selected_editor"; reset
                        set_fg "$AQUA"; echo "Added to: $config_file"; reset
                        set_fg "$YELLOW"; echo "Please restart your shell or run: source $config_file"; reset
                    else
                        set_fg "$YELLOW"; echo "Could not detect shell config file."; reset
                        set_fg "$YELLOW"; echo "Manually add: export EDITOR=$selected_editor"; reset
                    fi
                fi
                read -p "Press Enter..."
                ;;
            8)
                clear
                set_fg "$YELLOW"; echo "Editor Information"; reset
                echo
                set_fg "$AQUA"; echo "Current EDITOR: ${EDITOR:-not set}"; reset
                set_fg "$AQUA"; echo "Current VISUAL: ${VISUAL:-not set}"; reset
                echo
                set_fg "$AQUA"; echo "Installed Editors with Versions:"; reset
                echo
                for cmd in nano vim nvim helix micro emacs ne; do
                    if command -v "$cmd" &>/dev/null; then
                        set_fg "$GREEN"; printf "• %s: " "$cmd"; reset
                        case "$cmd" in
                            nvim) nvim --version | head -n 1 ;;
                            vim) vim --version | head -n 1 ;;
                            nano) nano --version | head -n 1 ;;
                            helix) helix --version 2>/dev/null || echo "installed" ;;
                            micro) micro --version 2>/dev/null || echo "installed" ;;
                            *) $cmd --version 2>/dev/null | head -n 1 || echo "installed" ;;
                        esac
                    fi
                done
                read -p "Press Enter..."
                ;;
            b|"")
                return
                ;;
            r|R)
                return
                ;;
        esac
    done
}
# ─────────────────────────────────────────────
# Helper: Install AppImage
# ─────────────────────────────────────────────
install_appimage() {
    local app_name="$1"
    local github_repo="$2"
    local appimage_name="$3"
    local install_dir="${4:-$HOME/.local/bin}"
    
    clear
    set_fg "$YELLOW"; echo "Installing $app_name via AppImage..."; reset
    echo
    
    if ! command -v curl >/dev/null && ! command -v wget >/dev/null; then
        set_fg "$RED"; echo "✗ curl or wget required but not found"; reset
        if install_package curl; then
            set_fg "$GREEN"; echo "✓ Installed curl"; reset
        else
            read -p "Press Enter..."; return 1
        fi
    fi
    
    mkdir -p "$install_dir"
    local download_cmd=""
    if command -v curl >/dev/null; then
        download_cmd="curl -L"
    else
        download_cmd="wget -O-"
    fi
    
    set_fg "$AQUA"; echo "Fetching latest release..."; reset
    local latest_tag=""
    if command -v curl >/dev/null; then
        latest_tag=$(curl -s "https://api.github.com/repos/$github_repo/releases/latest" | grep '"tag_name"' | cut -d '"' -f4)
    else
        latest_tag=$(wget -qO- "https://api.github.com/repos/$github_repo/releases/latest" | grep '"tag_name"' | cut -d '"' -f4)
    fi
    
    if [[ -z "$latest_tag" ]]; then
        set_fg "$RED"; echo "✗ Failed to fetch latest release"; reset
        read -p "Press Enter..."; return 1
    fi
    
    set_fg "$AQUA"; echo "Latest version: $latest_tag"; reset
    set_fg "$AQUA"; echo "Downloading AppImage..."; reset
    
    # Handle wildcard in appimage_name (e.g., "cursor-*-x86_64.AppImage")
    local actual_appimage_name="$appimage_name"
    if [[ "$appimage_name" == *"*"* ]]; then
        # Try to find the actual filename from the release assets
        if command -v curl >/dev/null; then
            actual_appimage_name=$(curl -s "https://api.github.com/repos/$github_repo/releases/latest" | grep '"name".*AppImage' | grep -oP '"name":\s*"\K[^"]*' | head -1)
        fi
        # Fallback: replace * with latest tag
        [[ -z "$actual_appimage_name" ]] && actual_appimage_name="${appimage_name//\*/${latest_tag}}"
    fi
    
    local download_url="https://github.com/$github_repo/releases/download/${latest_tag}/${actual_appimage_name}"
    local target_file="$install_dir/${app_name,,}.AppImage"
    
    if $download_cmd "$download_url" -o "$target_file"; then
        chmod +x "$target_file"
        set_fg "$GREEN"; echo "✓ $app_name AppImage installed to $target_file"; reset
        
        # Create desktop entry if possible
        if [[ -d "$HOME/.local/share/applications" ]]; then
            local desktop_file="$HOME/.local/share/applications/${app_name,,}.desktop"
            cat > "$desktop_file" << EOF
[Desktop Entry]
Name=$app_name
Exec=$target_file
Icon=application-x-executable
Type=Application
Categories=Utility;
EOF
            set_fg "$AQUA"; echo "✓ Desktop entry created"; reset
        fi
        
        set_fg "$GREEN"; echo "Installation complete! Run: $target_file"; reset
        return 0
    else
        set_fg "$RED"; echo "✗ Failed to download AppImage"; reset
        read -p "Press Enter..."; return 1
    fi
}

# ─────────────────────────────────────────────
# Helper: Install .deb package
# ─────────────────────────────────────────────
install_deb() {
    local app_name="$1"
    local deb_url="$2"
    local temp_deb="/tmp/${app_name,,}.deb"
    
    clear
    set_fg "$YELLOW"; echo "Installing $app_name via .deb package..."; reset
    echo
    
    if ! command -v curl >/dev/null && ! command -v wget >/dev/null; then
        set_fg "$RED"; echo "✗ curl or wget required"; reset
        read -p "Press Enter..."; return 1
    fi
    
    set_fg "$AQUA"; echo "Downloading .deb package..."; reset
    local download_cmd=""
    if command -v curl >/dev/null; then
        if curl -L "$deb_url" -o "$temp_deb"; then
            set_fg "$GREEN"; echo "✓ Downloaded"; reset
        else
            set_fg "$RED"; echo "✗ Download failed"; reset
            read -p "Press Enter..."; return 1
        fi
    else
        if wget "$deb_url" -O "$temp_deb"; then
            set_fg "$GREEN"; echo "✓ Downloaded"; reset
        else
            set_fg "$RED"; echo "✗ Download failed"; reset
            read -p "Press Enter..."; return 1
        fi
    fi
    
    set_fg "$AQUA"; echo "Installing package..."; reset
    if sudo dpkg -i "$temp_deb" 2>/dev/null || sudo apt-get install -f -y; then
        set_fg "$GREEN"; echo "✓ $app_name installed successfully"; reset
        rm -f "$temp_deb"
        return 0
    else
        set_fg "$RED"; echo "✗ Installation failed"; reset
        rm -f "$temp_deb"
        read -p "Press Enter..."; return 1
    fi
}

# ─────────────────────────────────────────────
# 10. Install Packages
# ─────────────────────────────────────────────
packages_menu() {
    while true; do
        clear
        set_fg "$GREEN"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$GREEN"; echo " 📦 Install Packages"; reset
        set_fg "$GREEN"; echo "═══════════════════════════════════════════════════════════"; reset
        echo
        set_fg "$GRAY"; echo " Categories:"; reset
        set_fg "$AQUA"; echo " 1) 🎵 Audio / Music"; reset
        set_fg "$PURPLE"; echo " 2) 🤖 A.I. Editors"; reset
        set_fg "$YELLOW"; echo " 3) 🎬 Video Tools"; reset
        echo
        set_fg "$RED"; echo " b) Back"; reset
        set_fg "$AQUA"; echo " r) Return to Main Menu"; reset
        echo
        set_fg "$AQUA"; printf " → "; reset
        read -r choice
    case "$choice" in
            1) audio_menu ;;
            2) ai_editors_menu ;;
            3) video_tools_menu ;;
            b|"") return ;;
            r|R) return ;;
        esac
    done
}

audio_menu() {
    while true; do
        clear
        set_fg "$GREEN"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$GREEN"; echo " 🎵 Audio / Music Programs"; reset
        set_fg "$GREEN"; echo "═══════════════════════════════════════════════════════════"; reset
        echo
        set_fg "$GRAY"; echo " Available Programs:"; reset
        set_fg "$AQUA"; echo " 1) 🎨 Cava (Audio Visualizer)"; reset
        set_fg "$AQUA"; echo " 2) 💿 Sound Juicer (CD Ripper)"; reset
        set_fg "$AQUA"; echo " 3) 🔄 Sound Converter (Audio Converter)"; reset
        set_fg "$AQUA"; echo " 4) 🎬 mpv (Media Player)"; reset
        set_fg "$AQUA"; echo " 5) ℹ️  MediaInfo (Media Info Tool)"; reset
        set_fg "$AQUA"; echo " 6) 🎵 Sonixd (Music Player - via AppImage)"; reset
        echo
        set_fg "$RED"; echo " b) Back"; reset
        set_fg "$AQUA"; echo " r) Return to Main Menu"; reset
        echo
        set_fg "$AQUA"; printf " → "; reset
        read -r choice
        case "$choice" in
            1)
                clear
                set_fg "$YELLOW"; echo "Installing Cava..."; reset
                if install_package cava; then
                    set_fg "$GREEN"; echo "✓ Cava installed!"; reset
                else
                    set_fg "$RED"; echo "Failed to install Cava"; reset
                fi
                read -p "Press Enter..."
                ;;
            2)
                clear
                set_fg "$YELLOW"; echo "Installing Sound Juicer..."; reset
                if install_package sound-juicer; then
                    set_fg "$GREEN"; echo "✓ Sound Juicer installed!"; reset
                else
                    set_fg "$RED"; echo "Failed to install Sound Juicer"; reset
                fi
                read -p "Press Enter..."
                ;;
            3)
                clear
                set_fg "$YELLOW"; echo "Installing Sound Converter..."; reset
                if install_package soundconverter; then
                    set_fg "$GREEN"; echo "✓ Sound Converter installed!"; reset
                else
                    set_fg "$RED"; echo "Failed to install Sound Converter"; reset
                fi
                read -p "Press Enter..."
                ;;
            4)
                clear
                set_fg "$YELLOW"; echo "Installing mpv..."; reset
                if install_package mpv; then
                    set_fg "$GREEN"; echo "✓ mpv installed!"; reset
                else
                    set_fg "$RED"; echo "Failed to install mpv"; reset
                fi
                read -p "Press Enter..."
                ;;
            5)
                clear
                set_fg "$YELLOW"; echo "Installing MediaInfo..."; reset
                if install_package mediainfo; then
                    set_fg "$GREEN"; echo "✓ MediaInfo installed!"; reset
                else
                    set_fg "$RED"; echo "Failed to install MediaInfo"; reset
                fi
                read -p "Press Enter..."
                ;;
            6)
                clear
                set_fg "$YELLOW"; echo "Installing Sonixd via AppImage..."; reset
                echo
                if command -v curl >/dev/null; then
                    local latest_tag=$(curl -s https://api.github.com/repos/jeffvli/sonixd/releases/latest | grep "tag_name" | cut -d '"' -f4)
                    mkdir -p ~/bin
                    cd ~/bin
                    if curl -L "https://github.com/jeffvli/sonixd/releases/download/${latest_tag}/sonixd-${latest_tag}-linux-x86_64.AppImage" -o sonixd.AppImage; then
                        chmod +x sonixd.AppImage
                        set_fg "$GREEN"; echo "✓ Sonixd AppImage downloaded to ~/bin/sonixd.AppImage"; reset
                        echo "Run with ~/bin/sonixd.AppImage"
                    else
                        set_fg "$RED"; echo "Failed to download Sonixd"; reset
                    fi
                else
                    set_fg "$RED"; echo "curl not installed. Please install curl or download manually from https://github.com/jeffvli/sonixd/releases"; reset
                fi
                read -p "Press Enter..."
                ;;
            b|"") return ;;
            r|R) return ;;
        esac
    done
}

# ─────────────────────────────────────────────
# A.I. Editors Menu
# ─────────────────────────────────────────────
ai_editors_menu() {
    while true; do
        clear
        set_fg "$PURPLE"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$PURPLE"; echo " 🤖 A.I. Editors"; reset
        set_fg "$PURPLE"; echo "═══════════════════════════════════════════════════════════"; reset
        echo
        set_fg "$GRAY"; echo " Available Editors:"; reset
        set_fg "$AQUA"; echo " 1) ✏️  Cursor AI Editor"; reset
        echo
        set_fg "$RED"; echo " b) Back"; reset
        set_fg "$AQUA"; echo " r) Return to Main Menu"; reset
        echo
        set_fg "$AQUA"; printf " → "; reset
        read -r choice
        case "$choice" in
            1) install_cursor_editor ;;
            b|"") return ;;
            r|R) return ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Install Cursor AI Editor
# ─────────────────────────────────────────────
install_cursor_editor() {
    clear
    set_fg "$YELLOW"; echo "Installing Cursor AI Editor..."; reset
    echo
    
    # Check for curl
    if ! command -v curl >/dev/null; then
        set_fg "$YELLOW"; echo "curl is required. Installing..."; reset
        if ! install_package curl; then
            set_fg "$RED"; echo "✗ Failed to install curl. Please install it manually."; reset
            read -p "Press Enter..."
            return 1
        fi
    fi
    
    # Check network connectivity
    set_fg "$AQUA"; echo "Checking network connectivity..."; reset
    if ! curl -s --max-time 5 https://www.google.com >/dev/null 2>&1; then
        set_fg "$RED"; echo "✗ No internet connection detected"; reset
        set_fg "$YELLOW"; echo "Please check your network connection and try again."; reset
        read -p "Press Enter..."
        return 1
    fi
    set_fg "$GREEN"; echo "✓ Network connection OK"; reset
    echo
    
    local install_dir="$HOME/.local/bin"
    mkdir -p "$install_dir"
    mkdir -p "$HOME/Downloads"
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$install_dir:"* ]]; then
        if ! grep -q "export PATH.*$install_dir" "$HOME/.bashrc" 2>/dev/null; then
            echo "export PATH=\"\$PATH:$install_dir\"" >> "$HOME/.bashrc"
        fi
        if [[ -f "$HOME/.zshrc" ]] && ! grep -q "export PATH.*$install_dir" "$HOME/.zshrc" 2>/dev/null; then
            echo "export PATH=\"\$PATH:$install_dir\"" >> "$HOME/.zshrc"
        fi
    fi
    
    # Method 1: Native package (RPM for Fedora/openSUSE, DEB for Debian/Ubuntu)
    local package_url=""
    local package_type=""
    local temp_package=""
    
    if command -v dnf >/dev/null || command -v zypper >/dev/null; then
        package_type="RPM"
        temp_package="/tmp/cursor.rpm"
        set_fg "$AQUA"; echo "Method 1: Installing via RPM package (recommended for Fedora/openSUSE)..."; reset
        echo
        
        # Try to get latest version, fallback to 2.2
        local version="2.2"
        set_fg "$AQUA"; echo "Fetching latest Cursor version..."; reset
        
        # Try to get version from API or use default
        local latest_version=$(curl -s "https://api2.cursor.sh/updates/check/golden/linux-x64-rpm/cursor" 2>/dev/null | grep -oP '"version":\s*"\K[^"]*' | head -1)
        if [[ -n "$latest_version" ]]; then
            version="$latest_version"
            set_fg "$GRAY"; echo "Latest version: $version"; reset
        else
            set_fg "$GRAY"; echo "Using version: $version"; reset
        fi
        
        package_url="https://api2.cursor.sh/updates/download/golden/linux-x64-rpm/cursor/$version"
        
    elif command -v apt >/dev/null || command -v apt-get >/dev/null; then
        package_type="DEB"
        temp_package="/tmp/cursor.deb"
        set_fg "$AQUA"; echo "Method 1: Installing via DEB package (recommended for Debian/Ubuntu)..."; reset
        echo
        
        # Try to get latest version, fallback to 2.2
        local version="2.2"
        set_fg "$AQUA"; echo "Fetching latest Cursor version..."; reset
        
        local latest_version=$(curl -s "https://api2.cursor.sh/updates/check/golden/linux-x64-deb/cursor" 2>/dev/null | grep -oP '"version":\s*"\K[^"]*' | head -1)
        if [[ -n "$latest_version" ]]; then
            version="$latest_version"
            set_fg "$GRAY"; echo "Latest version: $version"; reset
        else
            set_fg "$GRAY"; echo "Using version: $version"; reset
        fi
        
        package_url="https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/$version"
    fi
    
    if [[ -n "$package_url" ]]; then
        set_fg "$AQUA"; echo "Downloading $package_type package..."; reset
        if curl -L --progress-bar "$package_url" -o "$temp_package" 2>&1; then
            if [[ -f "$temp_package" ]] && [[ -s "$temp_package" ]]; then
                # Verify it's a valid package
                if [[ "$package_type" == "RPM" ]] && file "$temp_package" 2>/dev/null | grep -q "RPM"; then
                    set_fg "$GREEN"; echo "✓ RPM package downloaded"; reset
                    set_fg "$AQUA"; echo "Installing RPM package..."; reset
                    
                    if command -v dnf >/dev/null; then
                        if sudo dnf install -y "$temp_package" 2>&1 | grep -v "^$"; then
                            set_fg "$GREEN"; echo "✓ Cursor installed successfully via RPM!"; reset
                            rm -f "$temp_package"
                            
                            if command -v cursor >/dev/null 2>&1; then
                                set_fg "$GREEN"; echo "✓ Cursor is available in your PATH"; reset
                                set_fg "$GRAY"; echo "Location: $(which cursor)"; reset
                            fi
                            read -p "Press Enter..."
                            return 0
                        fi
                    elif command -v zypper >/dev/null; then
                        if sudo zypper install -y "$temp_package" 2>&1 | grep -v "^$"; then
                            set_fg "$GREEN"; echo "✓ Cursor installed successfully via RPM!"; reset
                            rm -f "$temp_package"
                            
                            if command -v cursor >/dev/null 2>&1; then
                                set_fg "$GREEN"; echo "✓ Cursor is available in your PATH"; reset
                                set_fg "$GRAY"; echo "Location: $(which cursor)"; reset
                            fi
                            read -p "Press Enter..."
                            return 0
                        fi
                    fi
                elif [[ "$package_type" == "DEB" ]] && file "$temp_package" 2>/dev/null | grep -qE "Debian|ar archive"; then
                    set_fg "$GREEN"; echo "✓ DEB package downloaded"; reset
                    set_fg "$AQUA"; echo "Installing DEB package..."; reset
                    
                    if sudo dpkg -i "$temp_package" 2>&1 | grep -v "^$"; then
                        # Fix any dependency issues
                        sudo apt-get install -f -y 2>&1 | grep -v "^$"
                        set_fg "$GREEN"; echo "✓ Cursor installed successfully via DEB!"; reset
                        rm -f "$temp_package"
                        
                        if command -v cursor >/dev/null 2>&1; then
                            set_fg "$GREEN"; echo "✓ Cursor is available in your PATH"; reset
                            set_fg "$GRAY"; echo "Location: $(which cursor)"; reset
                        fi
                        read -p "Press Enter..."
                        return 0
                    fi
                else
                    rm -f "$temp_package"
                    set_fg "$YELLOW"; echo "Downloaded file is not a valid $package_type package"; reset
                fi
                rm -f "$temp_package"
            else
                rm -f "$temp_package"
                set_fg "$YELLOW"; echo "Downloaded file is empty or invalid"; reset
            fi
        else
            rm -f "$temp_package"
            set_fg "$YELLOW"; echo "Failed to download $package_type package"; reset
        fi
        echo
    fi
    
    # Method 2: Try the gist script (but check for actual success)
    set_fg "$AQUA"; echo "Method 2: Trying recommended installation script..."; reset
    echo
    
    local install_log="/tmp/cursor-install.log"
    local method2_success=false
    
    # Check common locations before running script
    local check_locations=(
        "$HOME/Applications/cursor/cursor.AppImage"
        "$HOME/.local/bin/cursor.AppImage"
        "$HOME/bin/cursor.AppImage"
        "/usr/local/bin/cursor"
        "$(which cursor 2>/dev/null)"
    )
    
    if curl -fsSL https://gist.githubusercontent.com/tatosjb/0ca8551406499d52d449936964e9c1d6/raw/eec8df843c35872ba3e590c7db5451af7e131906/install-cursor-sh 2>"$install_log" | bash 2>>"$install_log"; then
        # Wait a moment for files to be written
        sleep 2
        
        # Check if cursor command exists
        export PATH="$PATH:$install_dir:$HOME/bin:/usr/local/bin"
        if command -v cursor >/dev/null 2>&1; then
            method2_success=true
        else
            # Check for AppImage in various locations
            for location in "${check_locations[@]}" "$HOME/Downloads/cursor-"*.AppImage; do
                if [[ -f "$location" ]] && [[ -x "$location" ]]; then
                    method2_success=true
                    # Create symlink if needed
                    if [[ ! -f "$install_dir/cursor" ]] && [[ "$location" != "$install_dir/cursor" ]]; then
                        ln -sf "$location" "$install_dir/cursor" 2>/dev/null
                    fi
                    break
                fi
            done
        fi
    fi
    
    if [[ "$method2_success" == "true" ]]; then
        echo
        set_fg "$GREEN"; echo "✓ Cursor AI Editor installation completed!"; reset
        set_fg "$AQUA"; echo "You can launch it from your applications menu or run: cursor"; reset
        
        export PATH="$PATH:$install_dir:$HOME/bin:/usr/local/bin"
        if command -v cursor >/dev/null 2>&1; then
            set_fg "$GREEN"; echo "✓ Cursor is available in your PATH"; reset
            set_fg "$GRAY"; echo "Location: $(which cursor)"; reset
        else
            set_fg "$YELLOW"; echo "Note: You may need to restart your terminal or run: source ~/.bashrc"; reset
            # Find and show AppImage location
            for location in "${check_locations[@]}"; do
                if [[ -f "$location" ]]; then
                    set_fg "$AQUA"; echo "Cursor found at: $location"; reset
                    break
                fi
            done
        fi
        rm -f "$install_log"
        read -p "Press Enter..."
        return 0
    fi
    
    # Method 3: AppImage fallback (works on all distributions)
    echo
    set_fg "$YELLOW"; echo "Method 3: Installing AppImage (universal fallback)..."; reset
    echo
    
    # Try to get latest version, fallback to 2.2
    local version="2.2"
    set_fg "$AQUA"; echo "Fetching latest Cursor version..."; reset
    
    local latest_version=$(curl -s "https://api2.cursor.sh/updates/check/golden/linux-x64/cursor" 2>/dev/null | grep -oP '"version":\s*"\K[^"]*' | head -1)
    if [[ -n "$latest_version" ]]; then
        version="$latest_version"
        set_fg "$GRAY"; echo "Latest version: $version"; reset
    else
        set_fg "$GRAY"; echo "Using version: $version"; reset
    fi
    
    local appimage_url="https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/$version"
    local appimage_file="$install_dir/cursor.AppImage"
    local temp_file="/tmp/cursor-download.AppImage"
    
    set_fg "$AQUA"; echo "Downloading AppImage from official API..."; reset
    if curl -L --progress-bar "$appimage_url" -o "$temp_file" 2>&1; then
        if [[ -f "$temp_file" ]] && [[ -s "$temp_file" ]]; then
            if file "$temp_file" 2>/dev/null | grep -qE "AppImage|ELF|executable"; then
                mv "$temp_file" "$appimage_file"
                chmod +x "$appimage_file"
                set_fg "$GREEN"; echo "✓ Cursor AppImage downloaded successfully"; reset
                
                # Create wrapper script
                cat > "$install_dir/cursor" << EOF
#!/bin/bash
exec "$appimage_file" "\$@"
EOF
                chmod +x "$install_dir/cursor"
                set_fg "$GREEN"; echo "✓ Created 'cursor' command wrapper"; reset
                
                # Create desktop entry
                mkdir -p "$HOME/.local/share/applications"
                cat > "$HOME/.local/share/applications/cursor.desktop" << EOF
[Desktop Entry]
Name=Cursor
Comment=The AI-first code editor
Exec=$appimage_file %F
Icon=cursor
Type=Application
Categories=Development;TextEditor;
MimeType=text/plain;inode/directory;
StartupNotify=true
EOF
                if command -v update-desktop-database >/dev/null 2>&1; then
                    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null
                fi
                
                echo
                set_fg "$GREEN"; echo "✓ Cursor AI Editor installation completed!"; reset
                set_fg "$AQUA"; echo "You can launch it from your applications menu or run: cursor"; reset
                set_fg "$GRAY"; echo "Location: $appimage_file"; reset
                
                export PATH="$PATH:$install_dir"
                if command -v cursor >/dev/null 2>&1; then
                    set_fg "$GREEN"; echo "✓ Cursor is available in your PATH"; reset
                else
                    set_fg "$YELLOW"; echo "Note: You may need to restart your terminal or run: source ~/.bashrc"; reset
                fi
                rm -f "$install_log"
                read -p "Press Enter..."
                return 0
            else
                rm -f "$temp_file"
                set_fg "$YELLOW"; echo "Downloaded file is not a valid AppImage"; reset
            fi
        else
            rm -f "$temp_file"
            set_fg "$YELLOW"; echo "Downloaded file is empty"; reset
        fi
    else
        rm -f "$temp_file"
        set_fg "$YELLOW"; echo "Failed to download AppImage"; reset
    fi
    
    # All methods failed
    echo
    set_fg "$RED"; echo "✗ Failed to install Cursor AI Editor"; reset
    echo
    
    if [[ -f "$install_log" ]] && [[ -s "$install_log" ]]; then
        set_fg "$YELLOW"; echo "Error details:"; reset
        set_fg "$GRAY"; tail -30 "$install_log"; reset
        echo
    fi
    
    set_fg "$AQUA"; echo "Manual installation options:"; reset
    set_fg "$GRAY"; echo "1. Download directly using curl:"; reset
    if command -v dnf >/dev/null || command -v zypper >/dev/null; then
        set_fg "$GRAY"; echo "   curl -L https://api2.cursor.sh/updates/download/golden/linux-x64-rpm/cursor/2.2 -o cursor.rpm"; reset
        set_fg "$GRAY"; echo "   sudo zypper install cursor.rpm  (openSUSE)"; reset
        set_fg "$GRAY"; echo "   sudo dnf install cursor.rpm  (Fedora)"; reset
    elif command -v apt >/dev/null || command -v apt-get >/dev/null; then
        set_fg "$GRAY"; echo "   curl -L https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.2 -o cursor.deb"; reset
        set_fg "$GRAY"; echo "   sudo dpkg -i cursor.deb"; reset
    else
        set_fg "$GRAY"; echo "   curl -L https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/2.2 -o cursor.AppImage"; reset
        set_fg "$GRAY"; echo "   chmod +x cursor.AppImage && ./cursor.AppImage"; reset
    fi
    set_fg "$GRAY"; echo "2. Visit https://cursor.sh/downloads for other options"; reset
    set_fg "$GRAY"; echo "3. Check DNS/network settings if you see connection errors"; reset
    
    rm -f "$install_log"
    read -p "Press Enter..."
}

# ─────────────────────────────────────────────
# Video Tools Menu
# ─────────────────────────────────────────────
video_tools_menu() {
    while true; do
        clear
        set_fg "$YELLOW"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$YELLOW"; echo " 🎬 Video Tools"; reset
        set_fg "$YELLOW"; echo "═══════════════════════════════════════════════════════════"; reset
        echo
        set_fg "$GRAY"; echo " Available Tools:"; reset
        set_fg "$AQUA"; echo " 1) 🎞️  Handbrake (Video Converter)"; reset
        set_fg "$AQUA"; echo " 2) 💿 MakeMKV (DVD/Blu-ray Ripper)"; reset
        set_fg "$AQUA"; echo " 3) 📀 K3b (CD/DVD Burner)"; reset
        set_fg "$AQUA"; echo " 4) 🎵 Kid3 (Audio Tag Editor)"; reset
        set_fg "$AQUA"; echo " 5) 📹 OBS Studio (Screen Recorder)"; reset
        set_fg "$AQUA"; echo " 6) 🎥 VLC Media Player"; reset
        echo
        set_fg "$RED"; echo " b) Back"; reset
        set_fg "$AQUA"; echo " r) Return to Main Menu"; reset
        echo
        set_fg "$AQUA"; printf " → "; reset
        read -r choice
        case "$choice" in
            1) install_handbrake ;;
            2) install_makemkv ;;
            3) install_k3b ;;
            4) install_kid3 ;;
            5) install_obs_studio ;;
            6) install_vlc ;;
            b|"") return ;;
            r|R) return ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Install Handbrake
# ─────────────────────────────────────────────
install_handbrake() {
    clear
    set_fg "$YELLOW"; echo "Installing Handbrake..."; reset
    echo
    
    local os_id=$(detect_os_id)
    local install_success=false
    
    case "$os_id" in
        ubuntu|debian|pop)
            set_fg "$AQUA"; echo "Installing Handbrake GUI for Debian/Ubuntu..."; reset
            # Prioritize GUI packages - try handbrake-gtk first (includes GUI)
            if install_package handbrake-gtk; then
                install_success=true
            elif install_package handbrake; then
                # If handbrake package includes GUI, we're good
                install_success=true
            else
                set_fg "$YELLOW"; echo "Standard package not available. Adding Handbrake PPA..."; reset
                if command -v add-apt-repository >/dev/null; then
                    if sudo add-apt-repository -y ppa:stebbins/handbrake-releases 2>/dev/null; then
                        sudo apt update -qq 2>/dev/null
                        # Try GUI package first
                        if install_package handbrake-gtk; then
                            install_success=true
                        elif install_package handbrake; then
                            install_success=true
                        fi
                    fi
                fi
                # Fallback: try Flatpak (GUI included)
                if [[ "$install_success" == "false" ]] && command -v flatpak >/dev/null; then
                    set_fg "$YELLOW"; echo "Trying Flatpak installation (includes GUI)..."; reset
                    if flatpak install -y flathub fr.handbrake.ghb 2>/dev/null; then
                        install_success=true
                    fi
                fi
            fi
            ;;
        fedora)
            set_fg "$AQUA"; echo "Installing Handbrake GUI for Fedora..."; reset
            # Enable RPM Fusion repositories
            if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
                set_fg "$YELLOW"; echo "Enabling RPM Fusion repositories..."; reset
                local fedora_version=$(rpm -E %fedora 2>/dev/null || echo "rawhide")
                if [[ "$fedora_version" != "rawhide" ]]; then
                    sudo dnf install -y --nogpgcheck "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm" 2>/dev/null
                fi
            fi
            # HandBrake package on Fedora includes GUI
            if install_package HandBrake; then
                install_success=true
            elif install_package handbrake; then
                install_success=true
            else
                # Fallback: Flatpak (GUI included)
                if command -v flatpak >/dev/null; then
                    set_fg "$YELLOW"; echo "Trying Flatpak installation (includes GUI)..."; reset
                    if flatpak install -y flathub fr.handbrake.ghb 2>/dev/null; then
                        install_success=true
                    fi
                fi
            fi
            ;;
        arch|manjaro*)
            set_fg "$AQUA"; echo "Installing Handbrake GUI for Arch Linux..."; reset
            # handbrake package on Arch includes GUI
            if install_package handbrake; then
                install_success=true
            else
                # Try AUR helper if available
                if command -v yay >/dev/null; then
                    set_fg "$YELLOW"; echo "Trying AUR installation with yay..."; reset
                    if yay -S --noconfirm handbrake 2>/dev/null; then
                        install_success=true
                    fi
                elif command -v paru >/dev/null; then
                    set_fg "$YELLOW"; echo "Trying AUR installation with paru..."; reset
                    if paru -S --noconfirm handbrake 2>/dev/null; then
                        install_success=true
                    fi
                fi
                # Fallback: Flatpak
                if [[ "$install_success" == "false" ]] && command -v flatpak >/dev/null; then
                    set_fg "$YELLOW"; echo "Trying Flatpak installation (includes GUI)..."; reset
                    if flatpak install -y flathub fr.handbrake.ghb 2>/dev/null; then
                        install_success=true
                    fi
                fi
            fi
            ;;
        opensuse*|suse|opensuse-tumbleweed|opensuse-leap)
            set_fg "$AQUA"; echo "Installing Handbrake GUI for openSUSE..."; reset
            # Detect openSUSE version
            local suse_version=""
            if [[ -f /etc/os-release ]]; then
                source /etc/os-release
                if [[ "$VERSION_ID" =~ ^[0-9]+$ ]]; then
                    suse_version="Leap_${VERSION_ID}"
                else
                    suse_version="Tumbleweed"
                fi
            else
                suse_version="Tumbleweed"
            fi
            
            set_fg "$GRAY"; echo "Detected openSUSE version: $suse_version"; reset
            
            # Try adding the correct repository
            if [[ "$suse_version" == "Tumbleweed" ]]; then
                set_fg "$YELLOW"; echo "Adding Handbrake repository for Tumbleweed..."; reset
                if sudo zypper addrepo -f "https://download.opensuse.org/repositories/home:/marguerite/openSUSE_Tumbleweed/" handbrake 2>/dev/null; then
                    sudo zypper refresh 2>/dev/null
                    # handbrake package includes GUI
                    if install_package handbrake; then
                        install_success=true
                    fi
                fi
            else
                # For Leap, try the Leap repository
                set_fg "$YELLOW"; echo "Adding Handbrake repository for Leap..."; reset
                if sudo zypper addrepo -f "https://download.opensuse.org/repositories/home:/marguerite/openSUSE_${suse_version}/" handbrake 2>/dev/null; then
                    sudo zypper refresh 2>/dev/null
                    if install_package handbrake; then
                        install_success=true
                    fi
                fi
            fi
            
            # Fallback: try standard package or Flatpak
            if [[ "$install_success" == "false" ]]; then
                set_fg "$YELLOW"; echo "Trying standard repository..."; reset
                if install_package handbrake; then
                    install_success=true
                elif command -v flatpak >/dev/null; then
                    set_fg "$YELLOW"; echo "Trying Flatpak installation (includes GUI)..."; reset
                    if flatpak install -y flathub fr.handbrake.ghb 2>/dev/null; then
                        install_success=true
                    fi
                fi
            fi
            ;;
        *)
            set_fg "$YELLOW"; echo "Installing Handbrake GUI via package manager..."; reset
            # Try GUI packages first
            if install_package handbrake-gtk handbrake; then
                install_success=true
            elif install_package handbrake; then
                install_success=true
            elif command -v flatpak >/dev/null; then
                set_fg "$YELLOW"; echo "Trying Flatpak installation (includes GUI)..."; reset
                if flatpak install -y flathub fr.handbrake.ghb 2>/dev/null; then
                    install_success=true
                fi
            fi
            ;;
    esac
    
    echo
    if [[ "$install_success" == "true" ]]; then
        # Check if GUI is available (check multiple possible command names)
        local gui_found=false
        local gui_command=""
        
        # Check for GUI commands
        if command -v ghb >/dev/null; then
            gui_found=true
            gui_command="ghb"
        elif command -v handbrake >/dev/null; then
            # Check if it's GUI or CLI by testing --help output or checking for GUI libs
            if handbrake --help 2>&1 | grep -qi "gui\|gtk\|qt" || ldd $(which handbrake) 2>/dev/null | grep -qi "gtk\|qt"; then
                gui_found=true
                gui_command="handbrake"
            fi
        elif command -v HandBrake >/dev/null; then
            gui_found=true
            gui_command="HandBrake"
        elif flatpak list 2>/dev/null | grep -q "fr.handbrake.ghb"; then
            gui_found=true
            gui_command="flatpak run fr.handbrake.ghb"
        fi
        
        if [[ "$gui_found" == "true" ]]; then
            set_fg "$GREEN"; echo "✓ Handbrake GUI installed successfully!"; reset
            set_fg "$AQUA"; echo "Launch Handbrake GUI with:"; reset
            if [[ "$gui_command" == "flatpak run fr.handbrake.ghb" ]]; then
                set_fg "$GRAY"; echo "  $gui_command"; reset
                set_fg "$GRAY"; echo "  Or search for 'HandBrake' in your application menu"; reset
            else
                set_fg "$GRAY"; echo "  $gui_command"; reset
                set_fg "$GRAY"; echo "  Or search for 'HandBrake' in your application menu"; reset
            fi
        else
            set_fg "$YELLOW"; echo "⚠ Handbrake installed but GUI may not be available."; reset
            set_fg "$YELLOW"; echo "Only CLI version detected. Trying to install GUI..."; reset
            # Try to install GUI specifically
            case "$os_id" in
                ubuntu|debian|pop)
                    install_package handbrake-gtk 2>/dev/null
                    ;;
            esac
            set_fg "$GRAY"; echo "You may need to restart your terminal or log out/in."; reset
            set_fg "$GRAY"; echo "Or try: flatpak install flathub fr.handbrake.ghb"; reset
        fi
    else
        set_fg "$RED"; echo "✗ Failed to install Handbrake GUI"; reset
        set_fg "$YELLOW"; echo "You can try installing manually:"; reset
        set_fg "$GRAY"; echo "  - Visit https://handbrake.fr/downloads.php"; reset
        set_fg "$GRAY"; echo "  - Or install via Flatpak: flatpak install flathub fr.handbrake.ghb"; reset
        set_fg "$GRAY"; echo "  - Flatpak includes the GUI version"; reset
    fi
    read -p "Press Enter..."
}

# ─────────────────────────────────────────────
# Install MakeMKV
# ─────────────────────────────────────────────
install_makemkv() {
    clear
    set_fg "$YELLOW"; echo "Installing MakeMKV..."; reset
    echo
    
    local os_id=$(detect_os_id)
    case "$os_id" in
        ubuntu|debian|pop)
            set_fg "$AQUA"; echo "Adding MakeMKV repository..."; reset
            echo "deb https://ppa.launchpadcontent.net/heyarje/makemkv-beta/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/makemkv.list >/dev/null
            sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x8C718D3B5072E1F5 2>/dev/null || true
            sudo apt update
            install_package makemkv-bin makemkv-oss
            ;;
        fedora)
            sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
            install_package makemkv
            ;;
        arch|manjaro*)
            if command -v yay >/dev/null; then
                yay -S makemkv --noconfirm
            elif command -v paru >/dev/null; then
                paru -S makemkv --noconfirm
            else
                set_fg "$YELLOW"; echo "Install yay or paru for AUR access, or install manually"; reset
            fi
            ;;
        opensuse*|suse)
            sudo zypper addrepo https://download.opensuse.org/repositories/home:/marguerite/openSUSE_Tumbleweed/ makemkv
            sudo zypper refresh
            install_package makemkv
            ;;
        *)
            set_fg "$YELLOW"; echo "Please install MakeMKV manually from: https://www.makemkv.com/download/"; reset
            ;;
    esac
    
    if command -v makemkv >/dev/null || command -v makemkvcon >/dev/null; then
        set_fg "$GREEN"; echo "✓ MakeMKV installed!"; reset
        set_fg "$AQUA"; echo "Note: MakeMKV requires a license key for full functionality"; reset
    else
        set_fg "$YELLOW"; echo "MakeMKV installation attempted. Check manually if needed."; reset
    fi
    read -p "Press Enter..."
}

# ─────────────────────────────────────────────
# Install K3b
# ─────────────────────────────────────────────
install_k3b() {
    clear
    set_fg "$YELLOW"; echo "Installing K3b..."; reset
    echo
    
    if install_package k3b; then
        set_fg "$GREEN"; echo "✓ K3b installed!"; reset
    else
        set_fg "$RED"; echo "✗ Failed to install K3b"; reset
    fi
    read -p "Press Enter..."
}

# ─────────────────────────────────────────────
# Install Kid3
# ─────────────────────────────────────────────
install_kid3() {
    clear
    set_fg "$YELLOW"; echo "Installing Kid3..."; reset
    echo
    
    if install_package kid3; then
        set_fg "$GREEN"; echo "✓ Kid3 installed!"; reset
    else
        set_fg "$RED"; echo "✗ Failed to install Kid3"; reset
    fi
    read -p "Press Enter..."
}

# ─────────────────────────────────────────────
# Install OBS Studio
# ─────────────────────────────────────────────
install_obs_studio() {
    clear
    set_fg "$YELLOW"; echo "Installing OBS Studio..."; reset
    echo
    
    local os_id=$(detect_os_id)
    case "$os_id" in
        ubuntu|debian|pop)
            if ! install_package obs-studio; then
                set_fg "$YELLOW"; echo "Adding OBS Studio PPA..."; reset
                sudo add-apt-repository -y ppa:obsproject/obs-studio 2>/dev/null
                sudo apt update
                install_package obs-studio
            fi
            ;;
        fedora)
            sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
            install_package obs-studio
            ;;
        arch|manjaro*)
            install_package obs-studio
            ;;
        opensuse*|suse)
            sudo zypper addrepo -f https://download.opensuse.org/repositories/X11:Utilities/openSUSE_Tumbleweed/ obs
            sudo zypper refresh
            install_package obs-studio
            ;;
        *)
            install_package obs-studio
            ;;
    esac
    
    if command -v obs >/dev/null; then
        set_fg "$GREEN"; echo "✓ OBS Studio installed!"; reset
    else
        set_fg "$RED"; echo "✗ Installation may have failed. Check manually."; reset
    fi
    read -p "Press Enter..."
}

# ─────────────────────────────────────────────
# Install VLC Media Player
# ─────────────────────────────────────────────
install_vlc() {
    clear
    set_fg "$YELLOW"; echo "Installing VLC Media Player..."; reset
    echo
    
    local os_id=$(detect_os_id)
    case "$os_id" in
        ubuntu|debian|pop)
            if ! install_package vlc; then
                set_fg "$YELLOW"; echo "Adding VLC PPA..."; reset
                sudo add-apt-repository -y ppa:videolan/stable-daily 2>/dev/null
                sudo apt update
                install_package vlc
            fi
            ;;
        fedora)
            sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
            install_package vlc
            ;;
        arch|manjaro*)
            install_package vlc
            ;;
        opensuse*|suse)
            sudo zypper addrepo -f https://download.opensuse.org/repositories/home:/marguerite/openSUSE_Tumbleweed/ vlc
            sudo zypper refresh
            install_package vlc
            ;;
        *)
            install_package vlc
            ;;
    esac
    
    if command -v vlc >/dev/null; then
        set_fg "$GREEN"; echo "✓ VLC Media Player installed!"; reset
    else
        set_fg "$RED"; echo "✗ Installation may have failed. Check manually."; reset
    fi
    read -p "Press Enter..."
}

# ─────────────────────────────────────────────
# 11. Terminal Config Installers
# ─────────────────────────────────────────────
terminal_config_menu() {
    while true; do
        clear
        set_fg "$AQUA"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$AQUA"; echo " Terminal Configuration Installers"; reset
        set_fg "$AQUA"; echo "═══════════════════════════════════════════════════════════"; reset
        echo
        set_fg "$YELLOW"; echo " Available Terminal Config Installers:"; reset
        echo
        set_fg "$GREEN"; echo " 1) Alacritty Config Installer"; reset
        set_fg "$AQUA"; echo "    Install beautiful Alacritty terminal config with themes"; reset
        echo
        set_fg "$GREEN"; echo " 2) WezTerm Config Installer"; reset
        set_fg "$AQUA"; echo "    Install beautiful WezTerm terminal config with themes"; reset
        echo
        set_fg "$RED"; echo " b) Back"; reset
        set_fg "$AQUA"; echo " r) Return to Main Menu"; reset
        echo
        set_fg "$AQUA"; printf " → "; reset
        read -r choice
        
        case "$choice" in
            1)
                clear
                set_fg "$YELLOW"; echo "Running Alacritty Config Installer..."; reset
                echo
                if [[ -f "$SCRIPTS_DIR/alacritty-conf-installer.sh" ]]; then
                    bash "$SCRIPTS_DIR/alacritty-conf-installer.sh"
                else
                    set_fg "$RED"; echo "✗ alacritty-conf-installer.sh not found!"; reset
                    echo "  Make sure you've downloaded the scripts (option 2)"; reset
                fi
                read -p $'\nPress Enter to continue...'
                ;;
            2)
                clear
                set_fg "$YELLOW"; echo "Running WezTerm Config Installer..."; reset
                echo
                if [[ -f "$SCRIPTS_DIR/wezterm-conf-installer.sh" ]]; then
                    bash "$SCRIPTS_DIR/wezterm-conf-installer.sh"
                else
                    set_fg "$RED"; echo "✗ wezterm-conf-installer.sh not found!"; reset
                    echo "  Make sure you've downloaded the scripts (option 2)"; reset
                fi
                read -p $'\nPress Enter to continue...'
                ;;
            b|B)
                return
                ;;
            r|R)
                return
                ;;
            *)
                set_fg "$RED"; echo "Invalid option"; reset
                sleep 1
                ;;
        esac
    done
}

# ─────────────────────────────────────────────
# Main Loop
# ─────────────────────────────────────────────
while true; do
    draw_menu
    read -r choice
    clear
    case "${choice,,}" in
        1) set_nerd_font ;;
        2) download_scripts ;;
        3) execute_scripts_menu ;;
        4) htop_btop_menu ;;
        5) install_build_tools ;;
        6) install_lsd ;;
        7) remove_lsd ;;
        8) shell_management_menu ;;
        9) editor_management_menu ;;
        10) packages_menu ;;
        11) terminal_config_menu ;;
        q|quit) clear; set_fg "$GREEN"; echo "Goodbye, Techy!"; reset; sleep 1; exit 0 ;;
        *) set_fg "$RED"; echo "Invalid option"; reset; sleep 1 ;;
    esac
done
