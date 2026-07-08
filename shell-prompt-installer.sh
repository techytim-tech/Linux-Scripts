#!/bin/bash
# Shell Prompt Installer
# Installs and configures Starship, Oh My Posh, and Liquid Prompt
# with default themes. Detects OS and architecture for correct binaries.
# ─────────────────────────────────────────────

# Colors
ORANGE='\033[38;2;214;93;14m'
AQUA='\033[38;2;104;157;106m'
GREEN='\033[38;2;152;151;26m'
RED='\033[38;2;204;36;29m'
YELLOW='\033[38;2;215;153;33m'
PURPLE='\033[38;2;177;134;134m'
GRAY='\033[38;2;168;152;132m'
BOLD='\033[1m'
RESET='\033[0m'

# ─────────────────────────────────────────────
# Platform Detection
# ─────────────────────────────────────────────
detect_os_id() {
    [[ -f /etc/os-release ]] && source /etc/os-release
    echo "${ID:-unknown}"
}

detect_arch() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)  echo "x86_64" ;;
        aarch64|arm64)  echo "aarch64" ;;
        armv7l|armhf)   echo "armv7" ;;
        *)              echo "$arch" ;;
    esac
}

detect_shell_config() {
    local current_shell=$(basename "$SHELL")
    case "$current_shell" in
        zsh)  echo "$HOME/.zshrc" ;;
        bash) echo "$HOME/.bashrc" ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        *)    echo "" ;;
    esac
}

# ─────────────────────────────────────────────
# Package Manager Helpers
# ─────────────────────────────────────────────
install_packages() {
    local pkgs=("$@")
    if command -v apt >/dev/null; then
        sudo apt update -qq 2>/dev/null && sudo apt install -y "${pkgs[@]}" 2>/dev/null
    elif command -v dnf >/dev/null; then
        sudo dnf install -y "${pkgs[@]}" 2>/dev/null
    elif command -v yum >/dev/null; then
        sudo yum install -y "${pkgs[@]}" 2>/dev/null
    elif command -v pacman >/dev/null; then
        sudo pacman -S --noconfirm "${pkgs[@]}" 2>/dev/null
    elif command -v zypper >/dev/null; then
        sudo zypper install -y "${pkgs[@]}" 2>/dev/null
    elif command -v apk >/dev/null; then
        sudo apk add "${pkgs[@]}" 2>/dev/null
    else
        return 1
    fi
    return $?
}

ensure_build_tools() {
    local missing=()
    command -v curl >/dev/null 2>&1 || missing+=("curl")
    command -v git >/dev/null 2>&1   || missing+=("git")
    command -v tar >/dev/null 2>&1   || missing+=("tar")
    command -v unzip >/dev/null 2>&1 || missing+=("unzip")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Installing build prerequisites: ${missing[*]}${RESET}"
        install_packages "${missing[@]}" || {
            echo -e "${RED}Failed to install prerequisites${RESET}"
            return 1
        }
    fi
    return 0
}

ensure_rust() {
    if ! command -v cargo >/dev/null 2>&1; then
        echo -e "${YELLOW}Rust/Cargo not found. Installing Rust toolchain...${RESET}"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>/dev/null
        if [[ -f "$HOME/.cargo/env" ]]; then
            source "$HOME/.cargo/env"
            echo -e "${GREEN}✓ Rust installed${RESET}"
        else
            echo -e "${RED}✗ Failed to install Rust${RESET}"
            return 1
        fi
    fi
    return 0
}

add_to_shell_config() {
    local config_file="$1"
    local marker="$2"
    local content="$3"

    if [[ ! -f "$config_file" ]]; then
        mkdir -p "$(dirname "$config_file")"
        touch "$config_file"
    fi

    if grep -qF "$marker" "$config_file" 2>/dev/null; then
        echo -e "${YELLOW}⚠ $marker already in $config_file, skipping${RESET}"
        return 0
    fi

    echo "" >> "$config_file"
    echo "# $marker" >> "$config_file"
    echo "$content" >> "$config_file"
    echo -e "${GREEN}✓ Added prompt init to $config_file${RESET}"
}

# ─────────────────────────────────────────────
# Starship
# ─────────────────────────────────────────────
install_starship() {
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${YELLOW}  Installing Starship Prompt${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    local arch=$(detect_arch)
    echo -e "${GRAY}Architecture: $arch${RESET}"
    echo

    if command -v starship &>/dev/null; then
        echo -e "${GREEN}✓ Starship already installed${RESET}"
    else
        ensure_build_tools || return 1

        echo -e "${GRAY}Choose installation method:${RESET}"
        echo -e "${AQUA}  1) Official install script (curl | sh)${RESET}"
        echo -e "${PURPLE}  2) GitHub release (prebuilt binary)${RESET}"
        echo -e "${YELLOW}  3) Build from source (cargo)${RESET}"
        echo -ne "${AQUA}  → ${RESET}"
        read -r starship_method

        case "${starship_method:-1}" in
            1)
                echo -e "${AQUA}Using official install script...${RESET}"
                if curl -sS https://starship.rs/install.sh | sh -s -- -y 2>/dev/null; then
                    echo -e "${GREEN}✓ Starship installed${RESET}"
                else
                    echo -e "${YELLOW}Official install failed, trying GitHub release...${RESET}"
                    starship_method=2
                fi
                ;;
        esac

        if ! command -v starship &>/dev/null && [[ "${starship_method:-1}" == "2" || "${starship_method:-1}" == "" ]]; then
            echo -e "${AQUA}Downloading GitHub release for $arch...${RESET}"
            local gh_arch="$arch"
            [[ "$arch" == "x86_64" ]] && gh_arch="x86_64"
            [[ "$arch" == "aarch64" ]] && gh_arch="aarch64"

            local url="https://github.com/starship/starship/releases/latest/download/starship-${gh_arch}-unknown-linux-gnu.tar.gz"
            local tmp="/tmp/starship.tar.gz"
            if curl -L "$url" -o "$tmp" 2>/dev/null; then
                sudo tar xzf "$tmp" -C /usr/local/bin starship 2>/dev/null
                rm -f "$tmp"
                echo -e "${GREEN}✓ Starship installed from GitHub release${RESET}"
            else
                echo -e "${YELLOW}GitHub release failed, trying cargo...${RESET}"
                starship_method=3
            fi
        fi

        if ! command -v starship &>/dev/null && [[ "${starship_method:-1}" == "3" ]]; then
            echo -e "${AQUA}Building from source via cargo (this may take a while)...${RESET}"
            ensure_rust || return 1
            cargo install starship --locked 2>/dev/null && echo -e "${GREEN}✓ Starship built from source${RESET}" || {
                echo -e "${RED}✗ All methods failed for Starship${RESET}"
                return 1
            }
        fi
    fi

    # ── Catppuccin Mocha theme ──
    local cfg="$HOME/.config/starship.toml"
    mkdir -p "$(dirname "$cfg")"
    cat > "$cfg" << 'EOF'
# Starship - Catppuccin Mocha
format = "$os$username$hostname$directory$git_branch$git_status$nodejs$rust$python$cmd_duration$line_break$jobs$battery$time$status$shell$character"

[character]
success_symbol = "[](purple)"
error_symbol = "[](red)"

[directory]
style = "bold lavender"
truncation_length = 3
fish_style_pwd_dir_length = 1

[git_branch]
style = "bold peach"
format = " on [$branch](bold peach) "

[git_status]
style = "bold maroon"
format = '([$all_status$ahead_behind]($style) )'

[nodejs]     format = "via [⬢ $version](bold green) "
[rust]       format = "via [🦀 $version](bold red) "
[python]     format = "via [🐍 $version](bold blue) "
[cmd_duration] style = "bold text" format = "took [$duration]($style) "

[os]
disabled = false
style = "bold lavender"
format = "[ $symbol]($style)"
[os.symbols]
linux = "󰌽"
macos = ""
windows = ""

[memory_usage]
disabled = false
threshold = 75
style = "bold maroon"
format = "[$ram_pct]($style) "

[hostname]
ssh_only = true
format = "@[$hostname](bold lavender) "

[username]
show_always = true
style_user = "bold lavender"
style_root = "bold red"
format = "[$user]($style)"
EOF
    echo -e "${GREEN}✓ Theme: Catppuccin Mocha applied${RESET}"

    # ── Shell init ──
    local cf=$(detect_shell_config)
    if [[ -n "$cf" ]]; then
        if [[ "$(basename "$SHELL")" == "fish" ]]; then
            add_to_shell_config "$cf" "Starship Init" "starship init fish | source"
        else
            local init_shell=$(basename "$SHELL")
            add_to_shell_config "$cf" "Starship Init" "eval \"\$(starship init $init_shell)\""
        fi
        echo -e "${AQUA}→ Run: source $cf${RESET}"
    else
        echo -e "${YELLOW}⚠ Add 'eval \"\$(starship init \$(basename \$SHELL))\"' to your shell rc${RESET}"
    fi
    echo -e "${GREEN}✓ Starship complete${RESET}"
}

# ─────────────────────────────────────────────
# Oh My Posh
# ─────────────────────────────────────────────
install_ohmyposh() {
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${YELLOW}  Installing Oh My Posh${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    local arch=$(detect_arch)
    local os_id=$(detect_os_id)
    echo -e "${GRAY}Architecture: $arch | OS: $os_id${RESET}"
    echo

    if command -v oh-my-posh &>/dev/null; then
        echo -e "${GREEN}✓ Oh My Posh already installed${RESET}"
    else
        ensure_build_tools || return 1

        # Map arch to GitHub release naming
        local gh_arch="$arch"
        [[ "$arch" == "x86_64" ]] && gh_arch="amd64"
        [[ "$arch" == "aarch64" ]] && gh_arch="arm64"

        local installed=false

        # Try .deb / .rpm packages first
        case "$os_id" in
            ubuntu|debian|pop)
                local url=$(curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest 2>/dev/null \
                    | grep "browser_download_url.*posh-linux-${gh_arch}.deb" | cut -d '"' -f4)
                if [[ -n "$url" ]]; then
                    local tmp="/tmp/oh-my-posh.deb"
                    curl -L "$url" -o "$tmp" 2>/dev/null && sudo dpkg -i "$tmp" 2>/dev/null && installed=true
                    rm -f "$tmp"
                fi
                ;;
            fedora|centos|rhel)
                local url=$(curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest 2>/dev/null \
                    | grep "browser_download_url.*posh-linux-${gh_arch}.rpm" | cut -d '"' -f4)
                if [[ -n "$url" ]]; then
                    local tmp="/tmp/oh-my-posh.rpm"
                    curl -L "$url" -o "$tmp" 2>/dev/null && sudo rpm -i "$tmp" 2>/dev/null && installed=true
                    rm -f "$tmp"
                fi
                ;;
        esac

        # Fallback: direct binary download
        if [[ "$installed" != "true" ]]; then
            echo -e "${AQUA}Downloading binary for $arch...${RESET}"
            local url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${gh_arch}"
            sudo curl -L "$url" -o /usr/local/bin/oh-my-posh 2>/dev/null
            if [[ $? -eq 0 ]]; then
                sudo chmod +x /usr/local/bin/oh-my-posh
                installed=true
            fi
        fi

        if [[ "$installed" == "true" ]]; then
            echo -e "${GREEN}✓ Oh My Posh installed${RESET}"
        else
            echo -e "${RED}✗ Failed to install Oh My Posh${RESET}"
            echo -e "${YELLOW}Manual: https://ohmyposh.dev${RESET}"
            return 1
        fi
    fi

    # ── TokyoNight theme ──
    local thm="$HOME/.config/ohmyposh/theme.toml"
    mkdir -p "$(dirname "$thm")"

    # Download the official TokyoNight theme from Oh My Posh repo
    if curl -sL "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/tokyonight_storm.omp.json" -o "$thm" 2>/dev/null; then
        echo -e "${GREEN}✓ Theme: TokyoNight Storm applied${RESET}"
    else
        echo -e "${YELLOW}⚠ Could not download theme; using embedded fallback${RESET}"
        cat > "$thm" << 'POSH_JSON'
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "blocks": [
    {
      "alignment": "left",
      "segments": [
        { "background": "#1a1b26", "foreground": "#7aa2f0", "leading_diamond": "\ue0b6", "style": "diamond", "type": "session" },
        { "background": "#24283b", "foreground": "#a9b1d6", "powerline_symbol": "\ue0b4", "style": "powerline", "type": "path", "properties": { "style": "folder", "truncate_to_folder": 2 } },
        { "background": "#414868", "foreground": "#9ece6a", "powerline_symbol": "\ue0b4", "style": "powerline", "type": "git" }
      ], "type": "prompt"
    },
    {
      "alignment": "right",
      "segments": [
        { "background": "#414868", "foreground": "#bb9af7", "style": "plain", "type": "time", "properties": { "time_format": "15:04" } },
        { "background": "#24283b", "foreground": "#f7768e", "style": "plain", "type": "status", "properties": { "always_enabled": true } }
      ], "type": "prompt"
    },
    {
      "alignment": "left", "newline": true,
      "segments": [
        { "background": "transparent", "foreground": "#7aa2f0", "style": "plain", "template": "\u276f ", "type": "text", "properties": { "always_enabled": true } }
      ], "type": "prompt"
    }
  ], "final_space": true, "version": 2
}
POSH_JSON
    fi

    # ── Shell init ──
    local cf=$(detect_shell_config)
    local sh=$(basename "$SHELL")
    if [[ -n "$cf" ]]; then
        case "$sh" in
            fish) add_to_shell_config "$cf" "Oh My Posh Init" "oh-my-posh init fish --config $thm | source" ;;
            *)    add_to_shell_config "$cf" "Oh My Posh Init" "eval \"\$(oh-my-posh init $sh --config $thm)\"" ;;
        esac
        echo -e "${AQUA}→ Run: source $cf${RESET}"
    fi
    echo -e "${GREEN}✓ Oh My Posh complete${RESET}"
}

# ─────────────────────────────────────────────
# Liquid Prompt
# ─────────────────────────────────────────────
install_liquidprompt() {
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${YELLOW}  Installing Liquid Prompt${RESET}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo

    local lp_dir="$HOME/.config/liquidprompt"
    local cf=$(detect_shell_config)
    local sh=$(basename "$SHELL")

    ensure_build_tools || return 1

    if [[ -d "$lp_dir" ]]; then
        echo -e "${GREEN}✓ Liquid Prompt directory exists${RESET}"
    else
        echo -e "${AQUA}Cloning Liquid Prompt...${RESET}"
        if ! git clone https://github.com/nojhan/liquidprompt.git "$lp_dir" 2>/dev/null; then
            echo -e "${RED}✗ Failed to clone${RESET}"
            return 1
        fi
        echo -e "${GREEN}✓ Cloned to $lp_dir${RESET}"
    fi

    # ── Minimal config ──
    local rc="$HOME/.config/liquidpromptrc"
    cat > "$rc" << 'LPRC'
# Liquid Prompt - clean default theme
LP_ENABLE_BATT=0
LP_ENABLE_TIME=1
LP_ENABLE_LOAD=0
LP_ENABLE_TEMP=0
LP_ENABLE_GIT=1
LP_ENABLE_JOBS=1
LP_ENABLE_PERM=1
LP_ENABLE_SUDO=1
LP_ENABLE_RUNTIME=1
LP_RUNTIME_THRESHOLD=2
LP_ENABLE_ERROR=1
LP_ENABLE_SHORTEN_PATH=1
LP_PATH_LENGTH=30
LP_PATH_KEEP=2
LP_ENABLE_TITLE=1
LP_ENABLE_SCREEN_TITLE=1
LP_ENABLE_TERMINAL_TITLE=1
LP_HOSTNAME_ALWAYS=-1
LP_USER_ALWAYS=0
LP_ENABLE_COLOR=1

# Markers
LP_MARK_DEFAULT="❯"
LP_MARK_ROOT="#"
LP_MARK_BATTERY="⌁"
LP_MARK_LOAD="⌂"
LP_MARK_TEMP="θ"
LP_MARK_GIT="±"
LP_MARK_JOBS="∹"
LPRC
    echo -e "${GREEN}✓ Config written to $rc${RESET}"

    # ── Shell init ──
    if [[ -n "$cf" ]]; then
        local init_line="[[ -f $lp_dir/liquidprompt ]] && source $lp_dir/liquidprompt"
        [[ "$sh" == "fish" ]] && init_line="source $lp_dir/liquidprompt"
        add_to_shell_config "$cf" "Liquid Prompt Init" "$init_line"
        echo -e "${AQUA}→ Run: source $cf${RESET}"
    fi
    echo -e "${GREEN}✓ Liquid Prompt complete${RESET}"
}

# ─────────────────────────────────────────────
# Menu
# ─────────────────────────────────────────────
show_menu() {
    clear
    echo -e "${YELLOW}╔══════════════════════════════════════════════════╗${RESET}"
    echo -e "${YELLOW}║         Shell Prompt Installer                  ║${RESET}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${AQUA} System: $(detect_os_id) ($(detect_arch))${RESET}"
    echo -e "${AQUA} Shell:  $(basename $SHELL)${RESET}"
    echo
    echo -e "${GREEN}  1) Install Starship Prompt${RESET}"
    echo -e "${AQUA}     → Theme: Catppuccin Mocha${RESET}"
    echo
    echo -e "${PURPLE}  2) Install Oh My Posh${RESET}"
    echo -e "${AQUA}     → Theme: TokyoNight Storm${RESET}"
    echo
    echo -e "${YELLOW}  3) Install Liquid Prompt${RESET}"
    echo -e "${AQUA}     → Theme: Clean Default${RESET}"
    echo
    echo -e "${ORANGE}  4) Install All Three${RESET}"
    echo
    echo -e "${RED}  b) Back${RESET}"
    echo
    echo -ne "${AQUA}  → ${RESET}"
}

while true; do
    show_menu
    read -r choice
    case "$choice" in
        1) install_starship ;;
        2) install_ohmyposh ;;
        3) install_liquidprompt ;;
        4) install_starship; echo; install_ohmyposh; echo; install_liquidprompt ;;
        b|B|"") clear; exit 0 ;;
        *) echo -e "${RED}Invalid${RESET}"; sleep 1 ;;
    esac
    echo -e "\n${GRAY}Press Enter...${RESET}"; read -r
done
