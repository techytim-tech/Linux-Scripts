#!/bin/bash

# Fedora Theme Colors (inspired by Fedora's blue and white branding)
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

# Background colors
BG_DARK="\033[48;2;45;52;64m"

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
    echo -e "\n${FEDORA_LIGHT_BLUE}${BOLD}▶ $1${RESET}"
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

# Function to print a table
print_table() {
    local col1_width=30
    local col2_width=45
    
    # Top border
    echo -e "${FEDORA_BLUE}┌$(printf '─%.0s' $(seq 1 $col1_width))┬$(printf '─%.0s' $(seq 1 $col2_width))┐${RESET}"
    
    # Header
    printf "${FEDORA_BLUE}│${RESET} ${FEDORA_LIGHT_BLUE}${BOLD}%-${col1_width}s${RESET}${FEDORA_BLUE}│${RESET} ${FEDORA_LIGHT_BLUE}${BOLD}%-${col2_width}s${RESET}${FEDORA_BLUE}│${RESET}\n" "$1" "$2"
    
    # Middle border
    echo -e "${FEDORA_BLUE}├$(printf '─%.0s' $(seq 1 $col1_width))┼$(printf '─%.0s' $(seq 1 $col2_width))┤${RESET}"
    
    # Content rows
    shift 2
    while [ $# -gt 0 ]; do
        printf "${FEDORA_BLUE}│${RESET} ${WHITE}%-${col1_width}s${RESET}${FEDORA_BLUE}│${RESET} ${LIGHT_GRAY}%-${col2_width}s${RESET}${FEDORA_BLUE}│${RESET}\n" "$1" "$2"
        shift 2
    done
    
    # Bottom border
    echo -e "${FEDORA_BLUE}└$(printf '─%.0s' $(seq 1 $col1_width))┴$(printf '─%.0s' $(seq 1 $col2_width))┘${RESET}"
}

# Function to check if Flatpak is installed
check_flatpak() {
    if command -v flatpak &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if Flathub repo is added
check_flathub() {
    if flatpak remote-list 2>/dev/null | grep -q "flathub"; then
        return 0
    else
        return 1
    fi
}

# Detect operating system for installation
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID=$ID
        OS_NAME=$NAME
    else
        OS_ID="unknown"
        OS_NAME="Unknown"
    fi
}

# Function to install Flatpak based on OS
install_flatpak() {
    detect_os
    
    print_section "Installing Flatpak"
    print_status "Detected OS: $OS_NAME"
    
    case $OS_ID in
        ubuntu|debian|linuxmint|pop)
            print_status "Installing Flatpak via APT..."
            if sudo apt update && sudo apt install -y flatpak; then
                print_success "Flatpak installed successfully"
                return 0
            else
                print_error "Failed to install Flatpak"
                return 1
            fi
            ;;
        fedora)
            print_status "Installing Flatpak via DNF..."
            if sudo dnf install -y flatpak; then
                print_success "Flatpak installed successfully"
                return 0
            else
                print_error "Failed to install Flatpak"
                return 1
            fi
            ;;
        arch|manjaro)
            print_status "Installing Flatpak via Pacman..."
            if sudo pacman -S --noconfirm flatpak; then
                print_success "Flatpak installed successfully"
                return 0
            else
                print_error "Failed to install Flatpak"
                return 1
            fi
            ;;
        opensuse-tumbleweed|opensuse-leap|opensuse)
            print_status "Installing Flatpak via Zypper..."
            if sudo zypper install -y flatpak; then
                print_success "Flatpak installed successfully"
                return 0
            else
                print_error "Failed to install Flatpak"
                return 1
            fi
            ;;
        rhel|centos|rocky|almalinux)
            print_status "Installing Flatpak via YUM/DNF..."
            if sudo yum install -y flatpak || sudo dnf install -y flatpak; then
                print_success "Flatpak installed successfully"
                return 0
            else
                print_error "Failed to install Flatpak"
                return 1
            fi
            ;;
        *)
            print_error "Unsupported operating system: $OS_NAME"
            print_info "Please install Flatpak manually from: https://flatpak.org/setup/"
            return 1
            ;;
    esac
}

# Function to add Flathub repository
add_flathub() {
    print_section "Adding Flathub Repository"
    print_status "Adding Flathub remote repository..."
    
    if flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>&1 | while IFS= read -r line; do 
        echo -e "${GRAY}  $line${RESET}"
    done; then
        print_success "Flathub repository added successfully"
        return 0
    else
        print_error "Failed to add Flathub repository"
        return 1
    fi
}

# Function to show system status
show_status() {
    clear
    print_header "Flatpak Manager"
    
    print_section "System Status"
    
    local flatpak_status="Not Installed"
    local flatpak_version="N/A"
    local flathub_status="Not Added"
    local installed_apps="0"
    
    if check_flatpak; then
        flatpak_status="✓ Installed"
        flatpak_version=$(flatpak --version | awk '{print $2}')
        installed_apps=$(flatpak list --app 2>/dev/null | wc -l)
    fi
    
    if check_flathub; then
        flathub_status="✓ Added"
    fi
    
    echo ""
    print_table "Component" "Status" \
        "Flatpak" "$flatpak_status" \
        "Flatpak Version" "$flatpak_version" \
        "Flathub Repository" "$flathub_status" \
        "Installed Apps" "$installed_apps"
    echo ""
}

# Function to install Flatpak and Flathub
option_install() {
    clear
    print_header "Install Flatpak & Flathub"
    
    local needs_flatpak=false
    local needs_flathub=false
    
    if ! check_flatpak; then
        needs_flatpak=true
        print_warning "Flatpak is not installed"
    else
        print_success "Flatpak is already installed"
    fi
    
    if ! check_flathub; then
        needs_flathub=true
        print_warning "Flathub repository is not added"
    else
        print_success "Flathub repository is already added"
    fi
    
    if [ "$needs_flatpak" = false ] && [ "$needs_flathub" = false ]; then
        echo ""
        print_success "Everything is already set up!"
        print_info "You can proceed to Option 2 to update Flatpak apps"
    else
        echo ""
        echo -e "${FEDORA_BLUE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${FEDORA_BLUE}${BOLD}║${RESET}              ${YELLOW}${BOLD}Proceed with Installation?${RESET}                  ${FEDORA_BLUE}${BOLD}║${RESET}"
        echo -e "${FEDORA_BLUE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        
        if [ "$EUID" -eq 0 ]; then
            echo -e "${CYAN}${BOLD}  Running as root user${RESET} - No password needed"
        else
            echo -e "${ORANGE}${BOLD}  Running as regular user${RESET} - You will be prompted for sudo password"
        fi
        
        echo ""
        echo -e "${GREEN}${BOLD}  [y]${RESET} ${WHITE}Press 'y' to${RESET} ${GREEN}${BOLD}INSTALL${RESET}"
        echo -e "${RED}${BOLD}  [q]${RESET} ${WHITE}Press 'q' to${RESET} ${RED}${BOLD}RETURN TO MENU${RESET}"
        echo ""
        echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}"
        
        while true; do
            read -n 1 -s choice
            case $choice in
                y|Y)
                    echo -e "${GREEN}${BOLD}y${RESET}\n"
                    
                    if [ "$needs_flatpak" = true ]; then
                        if ! install_flatpak; then
                            echo ""
                            print_error "Installation failed"
                            echo -e "\n${WHITE}Press any key to return to menu...${RESET}"
                            read -n 1 -s
                            return
                        fi
                    fi
                    
                    if [ "$needs_flathub" = true ]; then
                        if ! add_flathub; then
                            echo ""
                            print_error "Failed to add Flathub repository"
                            echo -e "\n${WHITE}Press any key to return to menu...${RESET}"
                            read -n 1 -s
                            return
                        fi
                    fi
                    
                    print_header "Installation Complete!"
                    print_success "Flatpak and Flathub are now set up"
                    print_info "You can now install apps from Flathub"
                    
                    echo ""
                    print_info "Restart your session for changes to take full effect"
                    
                    break
                    ;;
                q|Q)
                    echo -e "${RED}${BOLD}q${RESET}\n"
                    print_info "Returning to main menu"
                    sleep 1
                    return
                    ;;
                *)
                    continue
                    ;;
            esac
        done
    fi
    
    echo -e "\n${WHITE}Press any key to return to menu...${RESET}"
    read -n 1 -s
}

# Function to update Flatpak apps
option_update() {
    clear
    print_header "Update Flatpak Apps"
    
    # Check if Flatpak is installed
    if ! check_flatpak; then
        print_error "Flatpak is not installed"
        print_info "Please use Option 1 to install Flatpak first"
        echo -e "\n${WHITE}Press any key to return to menu...${RESET}"
        read -n 1 -s
        return
    fi
    
    # Check if Flathub is added
    if ! check_flathub; then
        print_warning "Flathub repository is not added"
        print_info "Please use Option 1 to add Flathub repository"
        echo -e "\n${WHITE}Press any key to return to menu...${RESET}"
        read -n 1 -s
        return
    fi
    
    print_section "Checking for Updates"
    print_status "Fetching available updates..."
    
    # Get list of updates
    UPDATE_LIST=$(flatpak remote-ls --updates 2>/dev/null)
    UPDATE_COUNT=$(echo "$UPDATE_LIST" | grep -v "^$" | wc -l)
    
    # Show summary
    print_section "Update Summary"
    echo ""
    
    if [ "$UPDATE_COUNT" -gt 0 ]; then
        print_table "Component" "Status" \
            "Flatpak Apps to Update" "$UPDATE_COUNT apps" \
            "Update Source" "Flathub"
        echo ""
        
        print_info "Available updates:"
        echo -e "${GRAY}"
        echo "$UPDATE_LIST" | head -10 | sed 's/^/  /'
        if [ "$UPDATE_COUNT" -gt 10 ]; then
            echo -e "  ${DARK_GRAY}... and $((UPDATE_COUNT-10)) more${RESET}"
        fi
        echo -e "${RESET}"
        
        # Ask for confirmation
        echo ""
        echo -e "${FEDORA_BLUE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${FEDORA_BLUE}${BOLD}║${RESET}              ${YELLOW}${BOLD}Proceed with Update?${RESET}                       ${FEDORA_BLUE}${BOLD}║${RESET}"
        echo -e "${FEDORA_BLUE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        
        if [ "$EUID" -eq 0 ]; then
            echo -e "${CYAN}${BOLD}  Running as root user${RESET} - No password needed"
        else
            echo -e "${ORANGE}${BOLD}  Running as regular user${RESET} - You may be prompted for sudo password"
        fi
        
        echo ""
        echo -e "${GREEN}${BOLD}  [y]${RESET} ${WHITE}Press 'y' to${RESET} ${GREEN}${BOLD}UPDATE${RESET}"
        echo -e "${RED}${BOLD}  [q]${RESET} ${WHITE}Press 'q' to${RESET} ${RED}${BOLD}RETURN TO MENU${RESET}"
        echo ""
        echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}"
        
        while true; do
            read -n 1 -s choice
            case $choice in
                y|Y)
                    echo -e "${GREEN}${BOLD}y${RESET}\n"
                    
                    print_section "Updating Flatpak Apps"
                    print_status "Installing updates..."
                    
                    if flatpak update -y 2>&1 | while IFS= read -r line; do
                        if echo "$line" | grep -qE "Installing|Updating|Downloading"; then
                            echo -e "${ORANGE}  ⟳ $line${RESET}"
                        else
                            echo -e "${GRAY}  $line${RESET}"
                        fi
                    done; then
                        print_success "Flatpak apps updated successfully"
                    else
                        print_warning "Update completed with some issues"
                    fi
                    
                    print_header "Update Complete!"
                    print_success "Your Flatpak apps are now up to date"
                    
                    break
                    ;;
                q|Q)
                    echo -e "${RED}${BOLD}q${RESET}\n"
                    print_info "Update cancelled - returning to main menu"
                    sleep 1
                    return
                    ;;
                *)
                    continue
                    ;;
            esac
        done
    else
        print_table "Component" "Status" \
            "System Status" "✓ Up to date" \
            "Updates Available" "0 apps" \
            "Action Required" "None"
        echo ""
        
        print_success "All Flatpak apps are already up to date!"
        print_info "No updates need to be installed"
    fi
    
    echo -e "\n${WHITE}Press any key to return to menu...${RESET}"
    read -n 1 -s
}

# Main menu
show_menu() {
    show_status
    
    print_section "Menu Options"
    echo ""
    echo -e "${FEDORA_BLUE}${BOLD}  [1]${RESET} ${WHITE}Install Flatpak & Flathub Repository${RESET}"
    echo -e "${FEDORA_BLUE}${BOLD}  [2]${RESET} ${WHITE}Update Flatpak Apps${RESET}"
    echo -e "${RED}${BOLD}  [q]${RESET} ${WHITE}Quit${RESET}"
    echo ""
    echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}"
}

# Main loop
main() {
    while true; do
        show_menu
        read -n 1 choice
        echo ""
        
        case $choice in
            1)
                option_install
                ;;
            2)
                option_update
                ;;
            q|Q)
                clear
                print_header "Goodbye!"
                echo -e "${WHITE}Thank you for using Flatpak Manager${RESET}\n"
                exit 0
                ;;
            *)
                print_warning "Invalid option. Please press 1, 2, or q"
                sleep 1
                ;;
        esac
    done
}

# Start the script
main