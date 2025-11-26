#!/bin/bash

# Fedora Theme Colors
FEDORA_BLUE="\033[38;2;60;110;180m"
FEDORA_DARK_BLUE="\033[38;2;41;65;114m"
FEDORA_LIGHT_BLUE="\033[38;2;123;159;210m"
WHITE="\033[38;2;255;255;255m"
LIGHT_GRAY="\033[38;2;220;220;220m"
GRAY="\033[38;2;180;180;180m"
DARK_GRAY="\033[38;2;100;100;100m"
GREEN="\033[38;2;115;210;115m"
RED="\033[38;2;240;85;85m"
YELLOW="\033[38;2;250;200;80m"
ORANGE="\033[38;2;250;150;50m"
CYAN="\033[38;2;100;200;230m"
RESET="\033[0m"
BOLD="\033[1m"

# Function to print a fancy header
print_header() {
    local cols=$(tput cols)
    echo -e "\n${FEDORA_BLUE}${BOLD}╔$(printf '═%.0s' $(seq 1 $((cols-2))))╗${RESET}"
    local text="$1"
    local padding=$(( (cols - ${#text} - 2) / 2 ))
    printf "${FEDORA_BLUE}${BOLD}║${RESET}%*s${WHITE}${BOLD}%s${RESET}%*s${FEDORA_BLUE}${BOLD}║${RESET}\n" $padding "" "$text" $padding ""
    echo -e "${FEDORA_BLUE}${BOLD}╚$(printf '═%.0s' $(seq 1 $((cols-2))))╝${RESET}\n"
}

# Function to print a section header
print_section() {
    local title="$1"
    local app_name="$2" # Optional app name

    if [ -n "$app_name" ]; then
        echo -e "\n${FEDORA_LIGHT_BLUE}${BOLD}▶ $title for $app_name${RESET}"
    else
        echo -e "\n${FEDORA_LIGHT_BLUE}${BOLD}▶ $title${RESET}"
    fi
    echo -e "${GRAY}$(printf '─%.0s' $(seq 1 50))${RESET}"
}

# Function to print status messages
print_status() {
    echo -e "${CYAN}➜${RESET} ${WHITE}$1${RESET}"
}

print_success() {
    echo -e "${GREEN}✓${RESET} ${WHITE}$1${RESET}"
}

print_error() {
    echo -e "${RED}✗${RESET} ${WHITE}$1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}⚠${RESET} ${WHITE}$1${RESET}"
}

print_info() {
    echo -e "${CYAN}ℹ${RESET} ${WHITE}$1${RESET}"
}

# Function to prompt for installation type
prompt_for_install_type() {
    local app_name="$1" # Capture app_name for use in messages
    local choice
    local install_option=""

    >&2 echo ""
    >&2 print_section "Choose Installation Type" "$app_name"
    >&2 echo -e "${FEDORA_LIGHT_BLUE}1)${RESET} ${WHITE}System-wide: Installs for all users on your system (requires administrative privileges).${RESET}"
    >&2 echo -e "${FEDORA_LIGHT_BLUE}2)${RESET} ${WHITE}User-specific: Installs only for your current user (no administrative privileges required).${RESET}"
    >&2 echo ""
    >&2 echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Enter your choice (1 or 2): ${RESET}"
    read choice # Read from stdin, prompt manually printed to stderr

    case "$choice" in
        1)
            install_option="--system"
            ;;
        2)
            install_option="--user"
            ;;
        *)
            >&2 print_error "Invalid choice. Defaulting to System-wide."
            install_option="--system" # Default to system-wide if invalid input
            ;;
    esac
    echo "$install_option" # Only the result goes to stdout
}

# Check if Flatpak is installed
check_flatpak() {
    if ! command -v flatpak &> /dev/null; then
        clear
        print_header "Flatpak App Installer"
        echo ""
        print_error "Flatpak is not installed on your system"
        print_info "Please install Flatpak first using flatpak-menu.sh"
        echo ""
        echo -e "${WHITE}Press any key to exit...${RESET}"
        read -n 1 -s
        exit 1
    fi
}

# Check if Flathub is added
check_flathub() {
    if ! flatpak remote-list 2>/dev/null | grep -q "flathub"; then
        clear
        print_header "Flatpak App Installer"
        echo ""
        print_error "Flathub repository is not added"
        print_info "Please add Flathub repository first using flatpak-menu.sh"
        echo ""
        echo -e "${WHITE}Press any key to exit...${RESET}"
        read -n 1 -s
        exit 1
    fi
}

# App database: app_id|display_name|description
declare -a APPS=(
    "com.visualstudio.code|Visual Studio Code|Code editing. Redefined. Free source-code editor with debugging, Git, and extensions"
    "net.mediaarea.MediaInfo|MediaInfo|Display technical and tag data for video and audio files"
    "com.makemkv.MakeMKV|MakeMKV|DVD and Blu-ray to MKV converter and network streamer"
    "fr.handbrake.ghb|HandBrake|Video transcoder for converting videos to work on various devices"
    "com.obsproject.Studio|OBS Studio|Free and open source software for video recording and live streaming"
    "com.google.Chrome|Google Chrome|Fast, secure web browser from Google with sync and extensions"
    "org.videolan.VLC|VLC Media Player|Multimedia player that plays most multimedia files and streams"
    "com.bitwarden.desktop|Bitwarden|Open source password manager with cloud sync and browser integration"
    "io.freetubeapp.FreeTube|FreeTube|Privacy-focused YouTube client with ad-blocking and subscription management"
    "io.gitlab.librewolf-community|LibreWolf|Privacy-focused Firefox fork with enhanced security and no telemetry"
    "com.github.tchx84.Flatseal|Flatseal|Manage Flatpak permissions and overrides with a graphical interface"
    "org.telegram.desktop|Telegram Desktop|Fast and secure messaging app with cloud storage and channels"
    "org.onlyoffice.desktopeditors|ONLYOFFICE|Office suite for documents, spreadsheets, and presentations"
    "org.qbittorrent.qBittorrent|qBittorrent|Free and open source BitTorrent client with search engine"
    "com.microsoft.Edge|Microsoft Edge|Fast and secure browser from Microsoft with vertical tabs"
    "io.missioncenter.MissionCenter|Mission Center|System monitoring tool with CPU, RAM, and GPU statistics"
    "org.chromium.Chromium|Chromium|Open source web browser that Google Chrome is based on"
    "org.kde.kdenlive|Kdenlive|Professional video editing software with multi-track timeline"
    "net.lutris.Lutris|Lutris|Open gaming platform for managing game installations and launchers"
    "com.heroicgameslauncher.hgl|Heroic Games Launcher|Open source launcher for Epic Games and GOG"
    "org.kde.krita|Krita|Professional digital painting and illustration application"
    "com.stremio.Stremio|Stremio|Media center for video entertainment with add-ons"
    "org.inkscape.Inkscape|Inkscape|Professional vector graphics editor for illustrations and designs"
    "io.gitlab.adhami3310.Impression|Impression|Bootable USB disk image writer with a simple interface"
    "com.ranfdev.DistroShelf|Distro Shelf|Browse and download Linux distributions for testing"
    "com.valvesoftware.Steam|Steam|Digital distribution platform for PC gaming"
    "net.davidotek.pupgui2|ProtonUp-Qt|Manage Wine and Proton versions for gaming compatibility"
    "de.haeckerfelix.Shortwave|Shortwave|Internet radio player with station discovery"
)

# Function to check if an app is installed
is_app_installed() {
    local app_id="$1"
    if flatpak list --app 2>/dev/null | grep -q "$app_id"; then
        return 0
    else
        return 1
    fi
}

# Function to get app info
get_app_info() {
    local index=$1
    local app_data="${APPS[$index]}"

    APP_ID=$(echo "$app_data" | cut -d'|' -f1)
    APP_NAME=$(echo "$app_data" | cut -d'|' -f2)
    APP_DESC=$(echo "$app_data" | cut -d'|' -f3)
}

# Function to display app list
show_app_list() {
    clear
    print_header "Flatpak App Installer"

    print_section "Available Applications"
    echo ""

    local index=0
    for app_data in "${APPS[@]}"; do
        get_app_info $index

        local status_icon=""
        if is_app_installed "$APP_ID"; then
            status_icon="${GREEN}✓${RESET}"
        else
            status_icon=" "
        fi

        printf "${FEDORA_BLUE}${BOLD}%2d.${RESET} ${status_icon} ${WHITE}%-30s${RESET} ${GRAY}%s${RESET}\n" $((index + 1)) "$APP_NAME" "$APP_DESC"

        ((index++))
    done

    echo ""
    print_section "Navigation"
    echo ""
    echo -e "${FEDORA_LIGHT_BLUE}${BOLD}  Enter app number (1-${#APPS[@]})${RESET} ${WHITE}to view details and install${RESET}"
    echo -e "${RED}${BOLD}  Press 'q'${RESET} ${WHITE}to quit${RESET}"
    echo ""
    echo -e "${GRAY}  ${GREEN}✓${RESET} = Already installed${RESET}"
    echo ""
    echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}"
}

# Function to show app details and install
show_app_details() {
    local app_index=$1

    get_app_info $app_index

    clear
    print_header "App Details"

    echo ""
    echo -e "${FEDORA_LIGHT_BLUE}${BOLD}Application:${RESET} ${WHITE}$APP_NAME${RESET}"
    echo -e "${FEDORA_LIGHT_BLUE}${BOLD}App ID:${RESET} ${LIGHT_GRAY}$APP_ID${RESET}"
    echo -e "${FEDORA_LIGHT_BLUE}${BOLD}Description:${RESET}"
    echo -e "${WHITE}  $APP_DESC${RESET}"
    echo ""

    # Check if already installed
    if is_app_installed "$APP_ID"; then
        print_success "This app is already installed"
        echo ""
        echo -e "${YELLOW}${BOLD}Actions Available:${RESET}"
        echo -e "${RED}${BOLD}  [r]${RESET} ${WHITE}Reinstall this app${RESET}"
        echo -e "${RED}${BOLD}  [u]${RESET} ${WHITE}Uninstall this app${RESET}"
        echo -e "${FEDORA_BLUE}${BOLD}  [b]${RESET} ${WHITE}Back to app list${RESET}"
        echo ""
        echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}"

        while true; do
            read -n 1 choice
            echo ""
            case $choice in
                r|R)
                    reinstall_app "$APP_ID" "$APP_NAME"
                    break
                    ;;
                u|U)
                    uninstall_app "$APP_ID" "$APP_NAME"
                    break
                    ;;
                b|B)
                    return
                    ;;
                *)
                    continue
                    ;;
            esac
        done
    else
        echo -e "${FEDORA_BLUE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${FEDORA_BLUE}${BOLD}║${RESET}              ${YELLOW}${BOLD}Install this application?${RESET}                   ${FEDORA_BLUE}${BOLD}║${RESET}"
        echo -e "${FEDORA_BLUE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "${GREEN}${BOLD}  [y]${RESET} ${WHITE}Press 'y' to${RESET} ${GREEN}${BOLD}INSTALL${RESET}"
        echo -e "${RED}${BOLD}  [b]${RESET} ${WHITE}Press 'b' to go${RESET} ${RED}${BOLD}BACK${RESET}"
        echo ""
        echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}"

        while true; do
            read -n 1 choice
            echo ""
            case $choice in
                y|Y)
                    install_app "$APP_ID" "$APP_NAME"
                    break
                    ;;
                b|B)
                    return
                    ;;
                *)
                    continue
                    ;;
            esac
        done
    fi

    echo ""
    echo -e "${WHITE}Press any key to return to app list...${RESET}"
    read -n 1 -s
}

# Function to install an app
install_app() {
    local app_id="$1"
    local app_name="$2"

    print_section "Installing" "$app_name"

    local install_scope=$(prompt_for_install_type "$app_name")
    if [ -z "$install_scope" ]; then
        print_error "Installation type not selected. Aborting installation." >&2
        return 1
    fi

    print_status "Downloading and installing $app_name $install_scope from Flathub..."
    echo ""

    if flatpak install -y "$install_scope" flathub "$app_id" 2>&1 | while IFS= read -r line; do
        if echo "$line" | grep -qE "Installing|Downloading|Updating"; then
            echo -e "${ORANGE}  ⟳ $line${RESET}"
        else
            echo -e "${GRAY}  $line${RESET}"
        fi
    done; then
        echo ""
        print_success "$app_name installed successfully!" >&2
        print_info "You can now launch $app_name from your application menu" >&2
    else
        echo ""
        print_error "Failed to install $app_name" >&2
        print_info "Check your internet connection and try again" >&2
        print_info "You might also need to run 'flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo' if Flathub is not properly set up." >&2
    fi
}

# Function to reinstall an app
reinstall_app() {
    local app_id="$1"
    local app_name="$2"

    print_section "Reinstalling" "$app_name"

    local install_scope=$(prompt_for_install_type "$app_name")
    if [ -z "$install_scope" ]; then
        print_error "Installation type not selected for reinstallation. Aborting." >&2
        return 1
    fi

    print_status "Attempting to remove any existing installations for $app_name..."
    echo ""

    local uninstalled_system=0
    local uninstalled_user=0

    if flatpak uninstall -y --system "$app_id" 2>&1 | while IFS= read -r line; do
        echo -e "${GRAY}  (System) $line${RESET}"
    done; then
        uninstalled_system=1
        print_success "System-wide uninstallation for $app_name completed." >&2
    else
        print_warning "No system-wide installation of $app_name found or failed to uninstall system-wide." >&2
    fi
    echo ""

    if flatpak uninstall -y --user "$app_id" 2>&1 | while IFS= read -r line; do
        echo -e "${GRAY}  (User) $line${RESET}"
    done; then
        uninstalled_user=1
        print_success "User-specific uninstallation for $app_name completed." >&2
    else
        print_warning "No user-specific installation of $app_name found or failed to uninstall user-specific." >&2
    fi

    if [ "$uninstalled_system" -eq 0 ] && [ "$uninstalled_user" -eq 0 ]; then
        print_error "Failed to uninstall $app_name from any scope. Reinstallation aborted." >&2
        return 1
    fi

    echo ""
    print_success "Previous installations removed (if any)." >&2
    print_status "Reinstalling $app_name $install_scope from Flathub..."
    echo ""

    if flatpak install -y "$install_scope" flathub "$app_id" 2>&1 | while IFS= read -r line; do
        if echo "$line" | grep -qE "Installing|Downloading|Updating"; then
            echo -e "${ORANGE}  ⟳ $line${RESET}"
        else
            echo -e "${GRAY}  $line${RESET}"
        fi
    done; then
        echo ""
        print_success "$app_name reinstalled successfully!" >&2
    else
        echo ""
        print_error "Failed to reinstall $app_name" >&2
        print_info "Check your internet connection and try again." >&2
    fi
}

# Function to uninstall an app
uninstall_app() {
    local app_id="$1"
    local app_name="$2"

    echo "" >&2
    print_warning "Are you sure you want to uninstall $app_name?" >&2
    print_info "Choose uninstall scope for $app_name:" >&2
    echo -e "${WHITE}1) System-wide only${RESET}" >&2
    echo -e "${WHITE}2) User-specific only${RESET}" >&2
    echo -e "${WHITE}3) Both (if present)${RESET}" >&2
    echo -e "${FEDORA_BLUE}${BOLD}  [n]${RESET} ${WHITE}Press 'n' to go${RED}${BOLD} CANCEL${RESET}" >&2
    echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}" >&2

    local uninstall_scope_choice=""
    while true; do
        read -n 1 choice
        echo "" >&2 # Newline for readability after read
        case $choice in
            1)
                uninstall_scope_choice="--system"
                break
                ;;
            2)
                uninstall_scope_choice="--user"
                break
                ;;
            3)
                uninstall_scope_choice="--both" # Custom internal flag
                break
                ;;
            n|N)
                print_info "Uninstall cancelled" >&2
                return
                ;;
            *)
                print_error "Invalid input. Please enter 1, 2, 3, or n." >&2
                echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}" >&2
                continue
                ;;
        esac
    done

    print_section "Uninstalling" "$app_name"
    echo ""

    local success=0
    if [[ "$uninstall_scope_choice" == "--both" ]]; then
        print_status "Attempting to uninstall $app_name from system-wide scope..."
        # Try to uninstall from system
        if flatpak uninstall -y --system "$app_id" 2>&1 | while IFS= read -r line; do echo -e "${GRAY}  (system) $line${RESET}"; done; then
            print_success "$app_name (system) uninstalled successfully (if present)." >&2
            success=1
        else
            print_info "$app_name not found in system-wide scope or failed to uninstall." >&2
        fi

        print_status "Attempting to uninstall $app_name from user-specific scope..."
        # Try to uninstall from user
        if flatpak uninstall -y --user "$app_id" 2>&1 | while IFS= read -r line; do echo -e "${GRAY}  (user) $line${RESET}"; done; then
            print_success "$app_name (user) uninstalled successfully (if present)." >&2
            success=1
        else
            print_info "$app_id not found in user-specific scope or failed to uninstall." >&2
        fi
    else
        print_status "Attempting to uninstall $app_name $uninstall_scope_choice scope..."
        if flatpak uninstall -y "$uninstall_scope_choice" "$app_id" 2>&1 | while IFS= read -r line; do echo -e "${GRAY}  $line${RESET}"; done; then
            print_success "$app_name uninstalled successfully!" >&2
            success=1
        else
            print_error "Failed to uninstall $app_name. It might not be installed in the chosen scope or at all." >&2
        fi
    fi

    if [[ "$success" -eq 0 ]]; then
        print_error "No instances of $app_name were successfully uninstalled." >&2
    fi
}

# Main function
main() {
    # Check prerequisites
    check_flatpak
    check_flathub

    while true; do
        show_app_list
        read choice

        # Check if user wants to quit
        if [[ "$choice" == "q" ]] || [[ "$choice" == "Q" ]]; then
            clear
            print_header "Goodbye!"
            echo -e "${WHITE}Thank you for using Flatpak App Installer${RESET}\n"
            exit 0
        fi

        # Validate numeric input
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            local app_index=$((choice - 1))

            # Check if choice is within valid range
            if [ $app_index -ge 0 ] && [ $app_index -lt ${#APPS[@]} ]; then
                show_app_details $app_index
            else
                print_warning "Invalid choice. Please select a number between 1 and ${#APPS[@]}"
                sleep 1
            fi
        else
            print_warning "Invalid input. Please enter a number or 'q' to quit"
            sleep 1
        fi
    done
}

# Start the script
main
