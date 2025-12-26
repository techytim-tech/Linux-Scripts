#!/bin/bash

# Pi-hole & AdBlock Home Updater Script
# A fancy menu-driven script to update Pi-hole and AdBlock Home

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Nerd Font Icons
ICON_PIHOLE="󰍛"
ICON_ADBLOCK="󰓓"
ICON_UPDATE="󰄢"
ICON_CHECK="󰄬"
ICON_SUCCESS="󰄬"
ICON_ERROR="󰅖"
ICON_INFO="󰋼"
ICON_MENU="󰍜"

# Clear screen
clear

# Function to display fancy title
show_title() {
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo -e "║  ${ICON_PIHOLE} ${ICON_ADBLOCK}  ${MAGENTA}Pi-hole & AdBlock Home Updater${CYAN}  ${ICON_UPDATE}  ${ICON_CHECK}  ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Function to check if Pi-hole is installed
check_pihole() {
    if command -v pihole &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if AdBlock Home is installed
check_adblock() {
    if [ -d "/opt/AdGuardHome" ] || [ -f "/usr/local/bin/AdGuardHome" ] || systemctl is-active --quiet AdGuardHome 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to update Pi-hole
update_pihole() {
    echo -e "${YELLOW}${ICON_INFO} Updating Pi-hole...${NC}"
    echo ""
    
    if ! check_pihole; then
        echo -e "${RED}${ICON_ERROR} Pi-hole is not installed!${NC}"
        echo -e "${YELLOW}Would you like to install Pi-hole? (y/n)${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}Installing Pi-hole...${NC}"
            curl -sSL https://install.pi-hole.net | bash
        else
            echo -e "${YELLOW}Installation cancelled.${NC}"
            return 1
        fi
    fi
    
    echo -e "${BLUE}Running Pi-hole update...${NC}"
    if sudo pihole -up; then
        echo -e "${GREEN}${ICON_SUCCESS} Pi-hole updated successfully!${NC}"
        echo ""
        echo -e "${CYAN}Updating gravity (block lists)...${NC}"
        if sudo pihole -g; then
            echo -e "${GREEN}${ICON_SUCCESS} Gravity updated successfully!${NC}"
        else
            echo -e "${YELLOW}Warning: Gravity update had issues.${NC}"
        fi
        return 0
    else
        echo -e "${RED}${ICON_ERROR} Pi-hole update failed!${NC}"
        return 1
    fi
}

# Function to update AdBlock Home (AdGuard Home)
update_adblock() {
    echo -e "${YELLOW}${ICON_INFO} Updating AdBlock Home (AdGuard Home)...${NC}"
    echo ""
    
    if ! check_adblock; then
        echo -e "${RED}${ICON_ERROR} AdGuard Home is not installed!${NC}"
        echo -e "${YELLOW}Would you like to install AdGuard Home? (y/n)${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}Installing AdGuard Home...${NC}"
            echo -e "${YELLOW}Please visit: https://github.com/AdguardTeam/AdGuardHome#installation${NC}"
            echo -e "${YELLOW}Or run the official installer script.${NC}"
        else
            echo -e "${YELLOW}Installation cancelled.${NC}"
            return 1
        fi
    fi
    
    # Try to find AdGuard Home binary
    ADGUARD_BIN=""
    if [ -f "/usr/local/bin/AdGuardHome" ]; then
        ADGUARD_BIN="/usr/local/bin/AdGuardHome"
    elif [ -f "/opt/AdGuardHome/AdGuardHome" ]; then
        ADGUARD_BIN="/opt/AdGuardHome/AdGuardHome"
    elif command -v AdGuardHome &> /dev/null; then
        ADGUARD_BIN=$(command -v AdGuardHome)
    fi
    
    if [ -z "$ADGUARD_BIN" ]; then
        echo -e "${RED}${ICON_ERROR} Could not find AdGuard Home binary!${NC}"
        echo -e "${YELLOW}Please update AdGuard Home manually.${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Stopping AdGuard Home service...${NC}"
    sudo systemctl stop AdGuardHome 2>/dev/null || true
    
    echo -e "${BLUE}Downloading latest AdGuard Home...${NC}"
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            ARCH="amd64"
            ;;
        armv7l)
            ARCH="armv7"
            ;;
        aarch64)
            ARCH="arm64"
            ;;
    esac
    
    LATEST_VERSION=$(curl -s https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo -e "${YELLOW}Could not fetch latest version. Attempting manual update...${NC}"
        echo -e "${CYAN}Please update AdGuard Home manually from: https://github.com/AdguardTeam/AdGuardHome/releases${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Latest version: ${LATEST_VERSION}${NC}"
    DOWNLOAD_URL="https://github.com/AdguardTeam/AdGuardHome/releases/download/${LATEST_VERSION}/AdGuardHome_linux_${ARCH}.tar.gz"
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR" || exit 1
    
    echo -e "${BLUE}Downloading AdGuard Home...${NC}"
    if curl -L -o AdGuardHome.tar.gz "$DOWNLOAD_URL"; then
        echo -e "${BLUE}Extracting...${NC}"
        tar -xzf AdGuardHome.tar.gz
        
        if [ -f "AdGuardHome/AdGuardHome" ]; then
            echo -e "${BLUE}Installing new version...${NC}"
            sudo cp AdGuardHome/AdGuardHome "$ADGUARD_BIN"
            sudo chmod +x "$ADGUARD_BIN"
            
            echo -e "${BLUE}Starting AdGuard Home service...${NC}"
            sudo systemctl start AdGuardHome 2>/dev/null || true
            
            echo -e "${GREEN}${ICON_SUCCESS} AdGuard Home updated successfully!${NC}"
            cd - > /dev/null || exit 1
            rm -rf "$TEMP_DIR"
            return 0
        else
            echo -e "${RED}${ICON_ERROR} Extraction failed!${NC}"
            cd - > /dev/null || exit 1
            rm -rf "$TEMP_DIR"
            return 1
        fi
    else
        echo -e "${RED}${ICON_ERROR} Download failed!${NC}"
        cd - > /dev/null || exit 1
        rm -rf "$TEMP_DIR"
        return 1
    fi
}

# Function to update both
update_both() {
    echo -e "${CYAN}${BOLD}Updating both Pi-hole and AdBlock Home...${NC}"
    echo ""
    update_pihole
    echo ""
    echo -e "${CYAN}─────────────────────────────────────────${NC}"
    echo ""
    update_adblock
}

# Function to check status
check_status() {
    echo -e "${CYAN}${BOLD}${ICON_INFO} Status Check${NC}"
    echo ""
    
    echo -e "${WHITE}Pi-hole Status:${NC}"
    if check_pihole; then
        VERSION=$(pihole -v 2>/dev/null | head -n 1 || echo "Installed")
        echo -e "  ${GREEN}${ICON_SUCCESS} Installed${NC} - $VERSION"
    else
        echo -e "  ${RED}${ICON_ERROR} Not Installed${NC}"
    fi
    
    echo ""
    echo -e "${WHITE}AdGuard Home Status:${NC}"
    if check_adblock; then
        if [ -f "/usr/local/bin/AdGuardHome" ] || [ -f "/opt/AdGuardHome/AdGuardHome" ]; then
            echo -e "  ${GREEN}${ICON_SUCCESS} Installed${NC}"
        else
            echo -e "  ${GREEN}${ICON_SUCCESS} Service Running${NC}"
        fi
    else
        echo -e "  ${RED}${ICON_ERROR} Not Installed${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Main menu
show_menu() {
    show_title
    
    echo -e "${WHITE}${BOLD}${ICON_MENU} Main Menu:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} ${ICON_PIHOLE} Update Pi-hole"
    echo -e "  ${GREEN}2)${NC} ${ICON_ADBLOCK} Update AdBlock Home (AdGuard Home)"
    echo -e "  ${GREEN}3)${NC} ${ICON_UPDATE} Update Both"
    echo -e "  ${GREEN}4)${NC} ${ICON_CHECK} Check Status"
    echo -e "  ${GREEN}5)${NC} ${RED}Exit${NC}"
    echo ""
    echo -e "${CYAN}─────────────────────────────────────────${NC}"
    echo ""
    echo -ne "${YELLOW}Select an option [1-5]: ${NC}"
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1)
            clear
            show_title
            update_pihole
            echo ""
            read -p "Press Enter to continue..."
            clear
            ;;
        2)
            clear
            show_title
            update_adblock
            echo ""
            read -p "Press Enter to continue..."
            clear
            ;;
        3)
            clear
            show_title
            update_both
            echo ""
            read -p "Press Enter to continue..."
            clear
            ;;
        4)
            clear
            show_title
            check_status
            clear
            ;;
        5)
            clear
            echo -e "${GREEN}${ICON_SUCCESS} Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}${ICON_ERROR} Invalid option! Please select 1-5.${NC}"
            sleep 2
            clear
            ;;
    esac
done

