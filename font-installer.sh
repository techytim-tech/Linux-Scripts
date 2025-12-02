#!/bin/bash

# Define a new color palette
RESET="\033[0m"
BOLD="\033[1m"
BRIGHT_GREEN="\033[1;32m" # For success messages
BRIGHT_YELLOW="\033[1;33m" # For warning messages and prompts
BRIGHT_BLUE="\033[1;34m"   # For headers
BRIGHT_MAGENTA="\033[1;35m" # For menu options
BRIGHT_RED="\033[1;31m"    # For error messages
BRIGHT_CYAN="\033[1;36m"    # For general info and user input prompts

# --- Global Variables ---
USER_NAME=$(whoami) # Get the current system username
OS_NAME="Unknown"
OS_ICON="❓"

# --- Helper Functions ---

print_header() {
  clear
  echo -e "${BRIGHT_BLUE}${BOLD}--- $1 ---${RESET}\n"
}

print_success() {
  echo -e "${BRIGHT_GREEN}${BOLD}✓ $1${RESET}"
}

print_warning() {
  echo -e "${BRIGHT_YELLOW}${BOLD}! $1${RESET}"
}

print_error() {
  echo -e "${BRIGHT_RED}${BOLD}✗ $1${RESET}"
}

press_any_key() {
  echo -e "\n${BRIGHT_CYAN}Press any key to continue...${RESET}"
  read -n 1 -s
}

# --- System Detection ---

detect_os() {
  if [ -f "/etc/os-release" ]; then
    . /etc/os-release
    OS_NAME="$NAME"
    case "$ID" in
      debian|ubuntu|pop|linuxmint) OS_ICON="🐧";;
      fedora|centos|rhel) OS_ICON="🎩";;
      arch|manjaro|endeavouros) OS_ICON="🏹";;
      opensuse) OS_ICON="🦎";;
      *) OS_ICON="❓";;
    esac
  else
    OS_NAME=$(uname -s)
    OS_ICON="❓"
  fi
}

# --- Font Data ---

# Nerd Fonts details (name and download URL suffix for latest release)
declare -A NERD_FONTS
NERD_FONTS=(
  ["FiraCode Nerd Font"]="FiraCode"
  ["FiraCodeMono Nerd Font"]="FiraCodeMono"
  ["JetBrainsMono Nerd Font"]="JetBrainsMono"
  ["MartianMono Nerd Font"]="MartianMono"
  ["Hack Nerd Font"]="Hack"
  ["DroidSansMono Nerd Font"]="DroidSansMono"
  ["RobotoMono Nerd Font"]="RobotoMono"
  ["UbuntuMono Nerd Font"]="UbuntuMono"
  ["MesloLGS Nerd Font"]="Meslo" # Often MesloLGS NF is referred to as Meslo
  ["CascadiaCode Nerd Font"]="CascadiaCode"
  ["Monoid Nerd Font"]="Monoid"
  ["SourceCodePro Nerd Font"]="SourceCodePro"
)

NERD_FONTS_BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/"

# --- Installation Functions ---

install_nerd_font() {
  local font_name="$1"
  local font_archive_name="$2" # e.g., FiraCode.zip
  local install_dir="${HOME}/.local/share/fonts/NerdFonts/${font_archive_name}"

  print_warning "Attempting to install ${font_name}..."

  # Check for dependencies
  if ! command -v curl &> /dev/null; then
    print_error "curl is not installed. Please install it to download fonts (e.g., 'sudo apt install curl' or 'sudo dnf install curl')."
    return 1
  fi
  if ! command -v unzip &> /dev/null; then
    print_error "unzip is not installed. Please install it to extract font archives (e.g., 'sudo apt install unzip' or 'sudo dnf install unzip')."
    return 1
  fi

  # Create directory if it doesn't exist
  mkdir -p "${install_dir}" || { print_error "Failed to create directory: ${install_dir}"; return 1; }

  # Download the font
  echo -e "${BRIGHT_CYAN}Downloading ${font_name} from ${NERD_FONTS_BASE_URL}${font_archive_name}.zip ...${RESET}"
  if ! curl -L "${NERD_FONTS_BASE_URL}${font_archive_name}.zip" -o "${install_dir}/${font_archive_name}.zip"; then
    print_error "Failed to download ${font_name}."
    rm -rf "${install_dir}" # Clean up
    return 1
  fi

  # Unzip and move files
  echo -e "${BRIGHT_CYAN}Extracting ${font_name}...${RESET}"
  if ! unzip -q "${install_dir}/${font_archive_name}.zip" -d "${install_dir}"; then
    print_error "Failed to extract ${font_name}."
    rm -rf "${install_dir}" # Clean up
    return 1
  fi

  # Clean up the zip file
  rm "${install_dir}/${font_archive_name}.zip"

  # Update font cache
  echo -e "${BRIGHT_CYAN}Updating font cache...${RESET}"
  fc-cache -fv &> /dev/null

  print_success "${font_name} installed successfully!"
  return 0
}

install_microsoft_fonts() {
  print_header "Installing Microsoft Core Fonts"
  print_warning "This will attempt to install 'ttf-mscorefonts-installer' or similar packages."
  print_warning "You might be prompted for your sudo password."

  press_any_key

  if command -v apt-fast &> /dev/null; then
    print_warning "Detected apt-fast. Using apt-fast for installation."
    sudo apt-fast update || { print_error "Failed to update apt-fast package list."; return 1; }
    sudo apt-fast install -y ttf-mscorefonts-installer || { print_error "Failed to install ttf-mscorefonts-installer via apt-fast."; return 1; }
  elif command -v apt-get &> /dev/null; then
    print_warning "Detected apt-get. Using apt-get for installation."
    sudo apt-get update || { print_error "Failed to update apt package list."; return 1; }
    sudo apt-get install -y ttf-mscorefonts-installer || { print_error "Failed to install ttf-mscorefonts-installer via apt-get."; return 1; }
  elif command -v dnf &> /dev/null; then
    print_warning "Detected DNF. Attempting to install 'mscore-fonts' or 'msttcorefonts' if available."
    sudo dnf install -y mscore-fonts || sudo dnf install -y msttcorefonts || { print_error "Failed to install Microsoft fonts via DNF. Please check your distribution's package manager."; return 1; }
  elif command -v zypper &> /dev/null; then
    print_warning "Detected Zypper. Attempting to install 'fetchmsttfonts' if available."
    print_warning "On openSUSE, you might need to add a repository first if this fails (e.g., 'sudo zypper addrepo https://download.opensuse.org/repositories/openSUSE:/Factory/standard/openSUSE:Factory.repo')."
    sudo zypper install -y fetchmsttfonts || { print_error "Failed to install fetchmsttfonts via Zypper. You may need to add a repository or install manually."; return 1; }
  elif command -v pacman &> /dev/null; then
    print_warning "Detected Pacman. Microsoft fonts are typically installed manually on Arch-based systems or from AUR."
    print_warning "Consider installing 'ttf-ms-fonts' from AUR (e.g., using an AUR helper like 'yay -S ttf-ms-fonts')."
    print_error "Automatic installation not supported for Pacman in this script."
    return 1
  else
    print_error "No supported package manager (apt, apt-fast, dnf, zypper, pacman) found for automatic Microsoft font installation."
    print_error "Please refer to your distribution's documentation for installing Microsoft fonts."
    return 1
  fi
  
  fc-cache -fv &> /dev/null
  print_success "Microsoft Core Fonts installed successfully (if available for your system)!"
  press_any_key
  return 0
}

# --- Menu Functions ---

show_nerd_font_selection_menu() {
  local selected_fonts=()
  local selection_type="$1" # "single" or "multiple"

  while true; do
    print_header "Select Nerd Fonts to Install (${selection_type^} Selection) - Welcome, ${USER_NAME}!"
    echo -e "${BRIGHT_CYAN}Detected OS: ${OS_ICON} ${OS_NAME}${RESET}\n"

    local i=1
    local font_keys=()
    for key in "${!NERD_FONTS[@]}"; do
      font_keys+=("$key")
      local status=""
      if [[ " ${selected_fonts[*]} " =~ " ${key} " ]]; then
        status="${BRIGHT_GREEN}(Selected)${RESET}"
      fi
      echo -e "${BRIGHT_MAGENTA}${BOLD}[$i]${RESET} ${key} ${status}"
      ((i++))
    done

    echo -e "\n${BRIGHT_CYAN}${BOLD}[c]${RESET} Confirm Selection and Install"
    echo -e "${BRIGHT_RED}${BOLD}[b]${RESET} Back to Main Menu"

    read -n 1 -p "$(echo -e "\n${BRIGHT_YELLOW}Enter your choice: ${RESET}")" choice
    echo

    if [[ "$choice" == "c" || "$choice" == "C" ]]; then
      break
    elif [[ "$choice" == "b" || "$choice" == "B" ]]; then
      return 1 # Signal to go back
    elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice < i )); then
      local selected_key="${font_keys[$((choice - 1))]}"
      if [[ " ${selected_fonts[*]} " =~ " ${selected_key} " ]]; then
        # Deselect
        local new_selected_fonts=()
        for f in "${selected_fonts[@]}"; do
          if [[ "$f" != "$selected_key" ]]; then
            new_selected_fonts+=("$f")
          fi
        done
        selected_fonts=("${new_selected_fonts[@]}")
        print_warning "${selected_key} deselected."
      else
        if [[ "$selection_type" == "single" ]]; then
          selected_fonts=("$selected_key") # Replace previous single selection
          print_success "${selected_key} selected."
          break # For single selection, exit after one choice
        else
          selected_fonts+=("$selected_key")
          print_success "${selected_key} selected."
        fi
      fi
      sleep 1
    else
      print_error "Invalid choice. Please try again."
      sleep 1
    fi
  done

  if [[ ${#selected_fonts[@]} -eq 0 ]]; then
    print_warning "No fonts selected for installation."
    press_any_key
    return 1
  fi

  print_header "Initiating Nerd Font Installation"
  for font_key in "${selected_fonts[@]}"; do
    install_nerd_font "$font_key" "${NERD_FONTS[$font_key]}"
  done
  press_any_key
  return 0
}

install_all_nerd_fonts() {
  print_header "Installing All Nerd Fonts - Welcome, ${USER_NAME}!"
  echo -e "${BRIGHT_CYAN}Detected OS: ${OS_ICON} ${OS_NAME}${RESET}\n"
  print_warning "This will download and install all listed Nerd Fonts. This may take some time."
  press_any_key

  local success_count=0
  local fail_count=0

  for font_key in "${!NERD_FONTS[@]}"; do
    if install_nerd_font "$font_key" "${NERD_FONTS[$font_key]}"; then
      ((success_count++))
    else
      ((fail_count++))
    fi
    echo # Newline for readability
  done

  print_header "Nerd Font Installation Summary - Welcome, ${USER_NAME}!"
  echo -e "${BRIGHT_CYAN}Detected OS: ${OS_ICON} ${OS_NAME}${RESET}\n"
  print_success "${success_count} fonts installed successfully."
  if [[ "$fail_count" -gt 0 ]]; then
    print_error "${fail_count} fonts failed to install. Check logs above."
  fi
  press_any_key
}

# --- Main Menu ---

main_menu() {
  detect_os # Detect OS once at the start

  while true; do
    print_header "Nerd & Microsoft Font Installer Menu - Welcome, ${USER_NAME}!"
    echo -e "${BRIGHT_CYAN}Detected OS: ${OS_ICON} ${OS_NAME}${RESET}\n"
    echo -e "${BRIGHT_MAGENTA}${BOLD}[1]${RESET} Install a Single Nerd Font"
    echo -e "${BRIGHT_MAGENTA}${BOLD}[2]${RESET} Install Multiple Nerd Fonts"
    echo -e "${BRIGHT_MAGENTA}${BOLD}[3]${RESET} Install All Nerd Fonts"
    echo -e "${BRIGHT_MAGENTA}${BOLD}[4]${RESET} Install Microsoft Core Fonts"
    echo -e "${BRIGHT_RED}${BOLD}[q]${RESET} Quit\n"

    read -n 1 -p "$(echo -e "${BRIGHT_YELLOW}Enter your choice: ${RESET}")" choice
    echo

    case $choice in
      1) show_nerd_font_selection_menu "single" ;;
      2) show_nerd_font_selection_menu "multiple" ;;
      3) install_all_nerd_fonts ;;
      4) install_microsoft_fonts ;;
      q|Q)
        print_header "Goodbye, ${USER_NAME}!"
        exit 0
        ;;
      *)
        print_error "Invalid choice. Please try again."
        press_any_key
        ;;
    esac
  done
}

# --- Start Script ---
main_menu