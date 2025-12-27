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

# Check if Flatpak is installed
check_flatpak() {
    if ! command -v flatpak &> /dev/null; then
        clear
        print_header "Flatpak App Remover"
        echo ""
        print_error "Flatpak is not installed on your system"
        print_info "There are no Flatpak apps to remove"
        echo ""
        echo -e "${WHITE}Press any key to exit...${RESET}"
        read -n 1 -s
        exit 1
    fi
}

# Arrays to store installed apps
declare -a APP_IDS=()
declare -a APP_NAMES=()
declare -a APP_VERSIONS=()
declare -a APP_BRANCHES=()

# Function to load installed apps
load_installed_apps() {
    APP_IDS=()
    APP_NAMES=()
    APP_VERSIONS=()
    APP_BRANCHES=()
    
    # Get list of installed apps
    while IFS=$'\t' read -r name id version branch rest; do
        if [[ -n "$id" ]]; then
            APP_IDS+=("$id")
            APP_NAMES+=("$name")
            APP_VERSIONS+=("$version")
            APP_BRANCHES+=("$branch")
        fi
    done < <(flatpak list --app --columns=name,application,version,branch 2>/dev/null)
}

# Function to get app size
get_app_size() {
    local app_id="$1"
    local size=$(flatpak info "$app_id" 2>/dev/null | grep "Installed size" | awk '{print $3, $4}')
    echo "${size:-Unknown}"
}

# Function to display installed apps
show_installed_apps() {
    clear
    print_header "Flatpak App Remover"
    
    # Reload apps to get current state
    load_installed_apps
    
    local app_count=${#APP_IDS[@]}
    
    if [ $app_count -eq 0 ]; then
        echo ""
        print_table "Status" "Message" \
            "Installed Apps" "0 applications" \
            "Action Required" "None"
        echo ""
        print_success "No Flatpak apps are installed"
        print_info "Nothing to remove"
        echo ""
        echo -e "${FEDORA_BLUE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${FEDORA_BLUE}${BOLD}║${RESET}                  ${GREEN}${BOLD}All clean!${RESET}                              ${FEDORA_BLUE}${BOLD}║${RESET}"
        echo -e "${FEDORA_BLUE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
        echo ""
        echo -e "${RED}${BOLD}  [q]${RESET} ${WHITE}Press 'q' to${RESET} ${RED}${BOLD}QUIT${RESET}"
        echo ""
        echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}"
        
        while true; do
            read -n 1 choice
            case $choice in
                q|Q)
                    echo -e "${RED}${BOLD}q${RESET}\n"
                    exit 0
                    ;;
                *)
                    continue
                    ;;
            esac
        done
    fi
    
    print_section "Installed Applications ($app_count apps)"
    echo ""
    
    for i in "${!APP_IDS[@]}"; do
        printf "${RED}${BOLD}%2d.${RESET} ${WHITE}%-35s${RESET} ${GRAY}%s${RESET}\n" $((i + 1)) "${APP_NAMES[$i]}" "${APP_IDS[$i]}"
    done
    
    echo ""
    print_section "Actions"
    echo ""
    echo -e "${RED}${BOLD}  Enter app number (1-$app_count)${RESET} ${WHITE}to view details and remove${RESET}"
    echo -e "${ORANGE}${BOLD}  Press 'a'${RESET} ${WHITE}to remove${RESET} ${ORANGE}${BOLD}ALL${RESET} ${WHITE}apps${RESET}"
    echo -e "${RED}${BOLD}  Press 'q'${RESET} ${WHITE}to quit${RESET}"
    echo ""
    echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}"
}

# Function to show app details and remove
show_app_details() {
    local app_index=$1
    
    local app_id="${APP_IDS[$app_index]}"
    local app_name="${APP_NAMES[$app_index]}"
    local app_version="${APP_VERSIONS[$app_index]}"
    local app_branch="${APP_BRANCHES[$app_index]}"
    
    clear
    print_header "App Details"
    
    echo ""
    echo -e "${FEDORA_LIGHT_BLUE}${BOLD}Application:${RESET} ${WHITE}$app_name${RESET}"
    echo -e "${FEDORA_LIGHT_BLUE}${BOLD}App ID:${RESET} ${LIGHT_GRAY}$app_id${RESET}"
    echo -e "${FEDORA_LIGHT_BLUE}${BOLD}Version:${RESET} ${LIGHT_GRAY}$app_version${RESET}"
    echo -e "${FEDORA_LIGHT_BLUE}${BOLD}Branch:${RESET} ${LIGHT_GRAY}$app_branch${RESET}"
    
    print_section "Additional Information"
    print_status "Fetching app size..."
    local app_size=$(get_app_size "$app_id")
    echo -e "${FEDORA_LIGHT_BLUE}${BOLD}Installed Size:${RESET} ${LIGHT_GRAY}$app_size${RESET}"
    
    echo ""
    echo -e "${FEDORA_BLUE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${FEDORA_BLUE}${BOLD}║${RESET}              ${RED}${BOLD}Remove this application?${RESET}                  ${FEDORA_BLUE}${BOLD}║${RESET}"
    echo -e "${FEDORA_BLUE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    print_warning "This will uninstall $app_name and free up disk space"
    echo ""
    echo -e "${RED}${BOLD}  [y]${RESET} ${WHITE}Press 'y' to${RESET} ${RED}${BOLD}REMOVE${RESET}"
    echo -e "${FEDORA_BLUE}${BOLD}  [b]${RESET} ${WHITE}Press 'b' to go${RESET} ${FEDORA_BLUE}${BOLD}BACK${RESET}"
    echo ""
    echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Your choice: ${RESET}"
    
    while true; do
        read -n 1 choice
        echo ""
        case $choice in
            y|Y)
                remove_app "$app_id" "$app_name"
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
    
    echo ""
    echo -e "${WHITE}Press any key to return to app list...${RESET}"
    read -n 1 -s
}

# Function to remove an app
remove_app() {
    local app_id="$1"
    local app_name="$2"
    
    print_section "Removing $app_name"
    print_status "Uninstalling application..."
    echo ""
    
    if flatpak uninstall -y "$app_id" 2>&1 | while IFS= read -r line; do
        if echo "$line" | grep -qE "Uninstalling|Removing"; then
            echo -e "${RED}  ✗ $line${RESET}"
        else
            echo -e "${GRAY}  $line${RESET}"
        fi
    done; then
        echo ""
        print_success "$app_name removed successfully!"
        print_info "Disk space has been freed"
    else
        echo ""
        print_error "Failed to remove $app_name"
        print_info "The app may be in use or there was a permission issue"
    fi
}

# Function to remove all apps
remove_all_apps() {
    clear
    print_header "Remove All Apps"
    
    local app_count=${#APP_IDS[@]}
    
    echo ""
    print_warning "WARNING: This will remove ALL $app_count Flatpak applications!"
    echo ""
    print_section "Apps to be removed:"
    echo ""
    
    for i in "${!APP_IDS[@]}"; do
        echo -e "${RED}  ✗${RESET} ${WHITE}${APP_NAMES[$i]}${RESET}"
    done
    
    echo ""
    echo -e "${FEDORA_BLUE}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${FEDORA_BLUE}${BOLD}║${RESET}      ${RED}${BOLD}Are you SURE you want to remove ALL apps?${RESET}       ${FEDORA_BLUE}${BOLD}║${RESET}"
    echo -e "${FEDORA_BLUE}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${WHITE}  Type ${RED}${BOLD}YES${RESET}${WHITE} (in capitals) to confirm or ${FEDORA_BLUE}${BOLD}n${RESET}${WHITE} to cancel${RESET}"
    echo -n -e "${FEDORA_LIGHT_BLUE}${BOLD}Confirm: ${RESET}"
    
    read confirm
    
    if [ "$confirm" = "YES" ]; then
        echo ""
        print_section "Removing All Applications"
        print_status "This may take a few minutes..."
        echo ""
        
        local removed=0
        local failed=0
        
        for i in "${!APP_IDS[@]}"; do
            local app_id="${APP_IDS[$i]}"
            local app_name="${APP_NAMES[$i]}"
            
            print_status "Removing $app_name..."
            
            if flatpak uninstall -y "$app_id" &>/dev/null; then
                print_success "$app_name removed"
                ((removed++))
            else
                print_error "Failed to remove $app_name"
                ((failed++))
            fi
        done
        
        echo ""
        print_section "Summary"
        echo ""
        print_table "Result" "Count" \
            "Successfully Removed" "$removed apps" \
            "Failed" "$failed apps" \
            "Total Processed" "$app_count apps"
        echo ""
        
        if [ $removed -eq $app_count ]; then
            print_success "All applications removed successfully!"
        elif [ $removed -gt 0 ]; then
            print_warning "Some applications were removed, but $failed failed"
        else
            print_error "Failed to remove applications"
        fi
        
        # Clean up unused runtimes
        echo ""
        print_status "Cleaning up unused runtimes and dependencies..."
        flatpak uninstall --unused -y &>/dev/null
        print_success "Cleanup completed"
        
    else
        echo ""
        print_info "Removal cancelled - no apps were removed"
    fi
    
    echo ""
    echo -e "${WHITE}Press any key to return to app list...${RESET}"
    read -n 1 -s
}

# Main function
main() {
    # Check prerequisites
    check_flatpak
    
    # Load installed apps
    load_installed_apps
    
    while true; do
        show_installed_apps
        read choice
        
        # Check if user wants to quit
        if [[ "$choice" == "q" ]] || [[ "$choice" == "Q" ]]; then
            clear
            print_header "Goodbye!"
            echo -e "${WHITE}Thank you for using Flatpak App Remover${RESET}\n"
            exit 0
        fi
        
        # Check if user wants to remove all
        if [[ "$choice" == "a" ]] || [[ "$choice" == "A" ]]; then
            remove_all_apps
            continue
        fi
        
        # Validate numeric input
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            local app_index=$((choice - 1))
            
            # Check if choice is within valid range
            if [ $app_index -ge 0 ] && [ $app_index -lt ${#APP_IDS[@]} ]; then
                show_app_details $app_index
            else
                print_warning "Invalid choice. Please select a number between 1 and ${#APP_IDS[@]}"
                sleep 1
            fi
        else
            print_warning "Invalid input. Please enter a number, 'a' for all, or 'q' to quit"
            sleep 1
        fi
    done
}

# Start the script
main