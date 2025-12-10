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

# Auto-detect box drawing
if printf '\u250f\u2501\u2513' 2>/dev/null | grep -q "┏━┓" 2>/dev/null; then
    TL="┏" TR="┓" BL="┗" BR="┛" H="━" V="┃"
else
    TL="+" TR="+" BL="+" BR="+" H="-" V="|"
fi

detect_os() {
    [[ -f /etc/os-release ]] && source /etc/os-release
    case "$ID" in
        ubuntu|pop|debian) echo "Ubuntu/Debian" ;;
        arch|manjaro*) echo "Arch Linux" ;;
        fedora) echo "Fedora" ;;
        *) echo "${PRETTY_NAME:-Linux}" ;;
    esac
}
OS_INFO=$(detect_os)

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

    tput cup "$top_pad" "$left_pad"; set_bg "$BG"; set_fg "$YELLOW"; printf "%s%s%s" "$TL" "$(printf '%*s' "$MENU_WIDTH" '' | tr ' ' "$H")" "$TR"; reset
    for ((i=1; i<=MENU_HEIGHT; i++)); do
        tput cup "$((top_pad + i))" "$left_pad"; set_bg "$BG"; set_fg "$YELLOW"; printf "%s" "$V"; reset
        tput cup "$((top_pad + i))" "$((left_pad + MENU_WIDTH + 1))"; set_bg "$BG"; set_fg "$YELLOW"; printf "%s" "$V"; reset
    done
    tput cup "$((top_pad + MENU_HEIGHT + 1))" "$left_pad"; set_bg "$BG"; set_fg "$YELLOW"; printf "%s%s%s" "$BL" "$(printf '%*s' "$MENU_WIDTH" '' | tr ' ' "$H")" "$BR"; reset

    print_centered "Techys Linux Menu" "$ORANGE" 2
    print_centered "OS: $OS_INFO" "$AQUA" 5
    print_centered "Choose an option:" "$GRAY" 8
    print_centered "1. Set Nerd Font (Auto-Detect & Apply)" "$GREEN"  10
    print_centered "2. Download Linux Scripts"             "$GREEN"  11
    print_centered "3. Execute Linux Scripts"              "$GREEN"  12
    print_centered "4. Htop/Btop Tools"                    "$PURPLE" 13
    print_centered "5. Install Build Tools"                "$YELLOW" 14
    print_centered "6. Install lsd + alias ls='lsd'"       "$AQUA"   15
    print_centered "7. Remove lsd + alias"                 "$RED"    16
    print_centered "8. Shell Management"                   "$PURPLE" 17
    print_centered "9. Editor Management"                  "$AQUA"   18
    print_centered "q. Quit"                               "$RED"    20

    tput cup "$((top_pad + MENU_HEIGHT + 3))" "$((left_pad + 2))"
    set_fg "$ORANGE"; printf "Enter choice: "; reset
}

# ─────────────────────────────────────────────
# Global
# ─────────────────────────────────────────────
SCRIPTS_DIR="$HOME/Linux-Scripts"

# ─────────────────────────────────────────────
# Detect Current Terminal
# ─────────────────────────────────────────────
detect_terminal() {
    # Check environment variables first
    [[ -n "$WEZTERM_EXECUTABLE" ]] && echo "wezterm" && return
    [[ -n "$KITTY_WINDOW_ID" ]] && echo "kitty" && return
    [[ -n "$ALACRITTY_SOCKET" || -n "$ALACRITTY_LOG" ]] && echo "alacritty" && return
    [[ "$TERM_PROGRAM" == "vscode" ]] && echo "vscode" && return
    [[ "$TERM_PROGRAM" == "ghostty" || -n "$GHOSTTY_RESOURCES_DIR" ]] && echo "ghostty" && return
    [[ "$COLORTERM" == "gnome-terminal" || "$VTE_VERSION" ]] && echo "gnome-terminal" && return
    [[ -n "$KONSOLE_VERSION" ]] && echo "konsole" && return
    [[ -n "$XFCE4_TERMINAL" ]] && echo "xfce4-terminal" && return
    
    # Check parent process
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
# 1. Set Nerd Font – Enhanced with more terminals
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
        set_fg "$AQUA"; printf "  %2d)" "$i"; reset
        set_fg "$GREEN"; echo " $name"; reset
        ((i++))
    done

    echo; set_fg "$RED"; echo "  b) Back"; reset; set_fg "$AQUA"; printf "\n  → "; reset
    read -r choice
    [[ "$choice" == "b" || "$choice" == "B" ]] && return
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
        (cd "$SCRIPTS_DIR" && git pull --quiet) && set_fg "$GREEN"; echo "Updated!"; reset
    else
        git clone --quiet https://github.com/techytim-tech/Linux-Scripts.git "$SCRIPTS_DIR" && set_fg "$GREEN"; echo "Downloaded!"; reset
    fi
    [[ $? -eq 0 ]] || { set_fg "$RED"; echo "Failed! Check internet."; reset; }
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
        [[ ${#scripts[@]} -eq 0 ]] && { echo "  No scripts found!"; read -p "Press Enter..."; return; }

        local i=1
        for s in "${scripts[@]}"; do
            set_fg "$AQUA"; printf "  %2d)" "$i"; reset
            set_fg "$GREEN"; echo " $s"; reset
            ((i++))
        done

        echo; set_fg "$RED"; echo "  b) Back"; reset; echo; set_fg "$AQUA"; printf "  → "; reset
        read -r c
        [[ "$c" == "b" || "$c" == "B" ]] && return
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
        echo "  1) Run htop"
        echo "  2) Install htop"
        echo "  3) Install btop + Theme"
        echo "  4) Run btop"
        echo "  b) Back"
        read -p "  → " sub

        case "$sub" in
            1) command -v htop &>/dev/null && htop || { set_fg "$RED"; echo "htop not installed"; reset; }; read -p "Enter..." ;;
            2)
                if command -v apt >/dev/null; then
                    sudo apt update && sudo apt install -y htop
                elif command -v dnf >/dev/null; then
                    sudo dnf install -y htop
                elif command -v pacman >/dev/null; then
                    sudo pacman -S htop --noconfirm
                fi
                read -p "Enter..."
                ;;
            3)
                clear; set_fg "$YELLOW"; echo "Installing btop..."; reset
                [[ -d ~/btop ]] && (cd ~/btop && git pull) || git clone https://github.com/aristocratos/btop.git ~/btop
                cd ~/btop && make -j$(nproc) && sudo make install
                [[ $? -eq 0 ]] && set_fg "$GREEN"; echo "btop installed!"; reset || set_fg "$RED"; echo "Failed"; reset
                read -p "Enter..."
                ;;
            4) command -v btop &>/dev/null && btop || { set_fg "$RED"; echo "btop not installed"; reset; sleep 2; } ;;
            b|"") return ;;
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
        sudo apt update && sudo apt install -y git build-essential cmake
    elif command -v dnf >/dev/null; then
        sudo dnf groupinstall -y "Development Tools" && sudo dnf install -y git cmake
    elif command -v pacman >/dev/null; then
        sudo pacman -S --needed base-devel git cmake --noconfirm
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
    set_fg "$YELLOW"; echo "Installing lsd..."; reset
    local lsd_installed=false

    if command -v apt >/dev/null; then
        set_fg "$AQUA"; echo "Using apt to install lsd..."; reset
        sudo apt update && sudo apt install -y lsd
        [[ $? -eq 0 ]] && lsd_installed=true && set_fg "$GREEN"; echo "lsd installed via apt."; reset
    elif command -v dnf >/dev/null; then
        set_fg "$AQUA"; echo "Using dnf to install lsd..."; reset
        sudo dnf install -y lsd
        [[ $? -eq 0 ]] && lsd_installed=true && set_fg "$GREEN"; echo "lsd installed via dnf."; reset
    elif command -v pacman >/dev/null; then
        set_fg "$AQUA"; echo "Using pacman to install lsd..."; reset
        sudo pacman -S lsd --noconfirm
        [[ $? -eq 0 ]] && lsd_installed=true && set_fg "$GREEN"; echo "lsd installed via pacman."; reset
    elif command -v cargo >/dev/null; then
        set_fg "$AQUA"; echo "Using cargo to install lsd..."; reset
        cargo install lsd
        [[ $? -eq 0 ]] && lsd_installed=true && set_fg "$GREEN"; echo "lsd installed via cargo."; reset
    fi

    if [[ "$lsd_installed" = true ]]; then
        echo
        set_fg "$YELLOW"; echo "Adding 'ls' alias to shell config..."; reset
        local shell_config_file=""
        
        [[ -f "$HOME/.zshrc" ]] && shell_config_file="$HOME/.zshrc"
        [[ -f "$HOME/.bashrc" ]] && shell_config_file="$HOME/.bashrc"
        
        if [[ -n "$shell_config_file" ]]; then
            if ! grep -qF "alias ls='lsd --color=auto'" "$shell_config_file" 2>/dev/null; then
                echo -e "\n# lsd alias\nalias ls='lsd --color=auto'" >> "$shell_config_file"
                set_fg "$GREEN"; echo "Alias added to $shell_config_file"; reset
            fi
        fi
    fi
    read -p "Press Enter..."
}

# ─────────────────────────────────────────────
# 7. Remove lsd + alias
# ─────────────────────────────────────────────
remove_lsd() {
    clear
    set_fg "$YELLOW"; echo "Removing lsd and its alias..."; reset
    
    if command -v lsd &>/dev/null; then
        if command -v apt >/dev/null && dpkg -s lsd &>/dev/null; then
            sudo apt remove -y lsd
        elif command -v dnf >/dev/null && rpm -q lsd &>/dev/null; then
            sudo dnf remove -y lsd
        elif command -v pacman >/dev/null && pacman -Q lsd &>/dev/null; then
            sudo pacman -Rs --noconfirm lsd
        elif command -v cargo >/dev/null; then
            cargo uninstall lsd
        fi
        set_fg "$GREEN"; echo "lsd removed."; reset
    fi

    for config in "$HOME/.zshrc" "$HOME/.bashrc"; do
        [[ -f "$config" ]] && sed -i "/^# lsd alias$/d; /^alias ls='lsd --color=auto'$/d" "$config"
    done
    
    set_fg "$GREEN"; echo "Alias removed from configs."; reset
    read -p "Press Enter..."
}

# ─────────────────────────────────────────────
# 8. Shell Management - NEW
# ─────────────────────────────────────────────
shell_management_menu() {
    while true; do
        clear
        set_fg "$PURPLE"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$PURPLE"; echo " Shell Management"; reset
        set_fg "$PURPLE"; echo "═══════════════════════════════════════════════════════════"; reset
        echo
        
        # Detect current shell
        local current_shell=$(basename "$SHELL")
        set_fg "$AQUA"; echo " Current Shell: $current_shell"; reset
        echo
        
        # List installed shells
        set_fg "$YELLOW"; echo " Installed Shells:"; reset
        local shell_num=1
        declare -A shell_map
        
        for shell_path in /bin/bash /bin/zsh /usr/bin/fish /bin/dash /bin/sh; do
            if [[ -x "$shell_path" ]]; then
                local shell_name=$(basename "$shell_path")
                set_fg "$GREEN"; printf "   • %s" "$shell_name"; reset
                [[ "$shell_name" == "$current_shell" ]] && set_fg "$AQUA"; printf " (current)"; reset
                echo
                shell_map[$shell_num]="$shell_path"
                ((shell_num++))
            fi
        done
        
        echo
        set_fg "$GRAY"; echo " Options:"; reset
        echo "  1) Install Zsh"
        echo "  2) Install Fish"
        echo "  3) Install Bash (if missing)"
        echo "  4) Set Default Shell"
        echo "  5) View Shell Info"
        echo "  b) Back"
        echo
        set_fg "$AQUA"; printf "  → "; reset
        read -r choice
        
        case "$choice" in
            1)
                clear
                set_fg "$YELLOW"; echo "Installing Zsh..."; reset
                if command -v apt >/dev/null; then
                    sudo apt update && sudo apt install -y zsh
                elif command -v dnf >/dev/null; then
                    sudo dnf install -y zsh
                elif command -v pacman >/dev/null; then
                    sudo pacman -S --noconfirm zsh
                fi
                
                if [[ $? -eq 0 ]]; then
                    set_fg "$GREEN"; echo "✓ Zsh installed successfully!"; reset
                    echo
                    set_fg "$AQUA"; echo "Install Oh My Zsh? (y/n)"; reset
                    read -r install_omz
                    if [[ "$install_omz" =~ ^[Yy]$ ]]; then
                        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
                        set_fg "$GREEN"; echo "✓ Oh My Zsh installed!"; reset
                    fi
                fi
                read -p "Press Enter..."
                ;;
            2)
                clear
                set_fg "$YELLOW"; echo "Installing Fish..."; reset
                if command -v apt >/dev/null; then
                    sudo apt update && sudo apt install -y fish
                elif command -v dnf >/dev/null; then
                    sudo dnf install -y fish
                elif command -v pacman >/dev/null; then
                    sudo pacman -S --noconfirm fish
                fi
                [[ $? -eq 0 ]] && set_fg "$GREEN"; echo "✓ Fish installed successfully!"; reset
                read -p "Press Enter..."
                ;;
            3)
                clear
                set_fg "$YELLOW"; echo "Installing Bash..."; reset
                if command -v apt >/dev/null; then
                    sudo apt update && sudo apt install -y bash
                elif command -v dnf >/dev/null; then
                    sudo dnf install -y bash
                elif command -v pacman >/dev/null; then
                    sudo pacman -S --noconfirm bash
                fi
                [[ $? -eq 0 ]] && set_fg "$GREEN"; echo "✓ Bash installed successfully!"; reset
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
                        set_fg "$AQUA"; printf "  %d) %s" "$idx" "$shell_name"; reset
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
        esac
    done
}

# ─────────────────────────────────────────────
# 9. Editor Management - NEW
# ─────────────────────────────────────────────
editor_management_menu() {
    while true; do
        clear
        set_fg "$AQUA"; echo "═══════════════════════════════════════════════════════════"; reset
        set_fg "$AQUA"; echo " Editor Management"; reset
        set_fg "$AQUA"; echo "═══════════════════════════════════════════════════════════"; reset
        echo
        
        # Detect current editor
        local current_editor="${EDITOR:-not set}"
        set_fg "$YELLOW"; echo " Current EDITOR: $current_editor"; reset
        echo
        
        # List installed editors
        set_fg "$YELLOW"; echo " Installed Editors:"; reset
        declare -A editors=(
            ["nano"]="nano"
            ["vim"]="vim"
            ["nvim"]="neovim"
            ["helix"]="helix"
            ["micro"]="micro"
            ["emacs"]="emacs"
            ["ne"]="ne (nice editor)"
        )
        
        for cmd in nano vim nvim helix micro emacs ne; do
            if command -v "$cmd" &>/dev/null; then
                set_fg "$GREEN"; printf "   • %s" "${editors[$cmd]}"; reset
                [[ "$cmd" == "$current_editor" ]] && set_fg "$AQUA"; printf " (current)"; reset
                echo
            fi
        done
        
        echo
        set_fg "$GRAY"; echo " Options:"; reset
        echo "  1) Install Nano"
        echo "  2) Install Vim"
        echo "  3) Install Neovim"
        echo "  4) Install Helix"
        echo "  5) Install Micro"
        echo "  6) Install Ne (Nice Editor)"
        echo "  7) Set Default Editor"
        echo "  8) View Editor Info"
        echo "  b) Back"
        echo
        set_fg "$AQUA"; printf "  → "; reset
        rea
