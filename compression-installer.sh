#!/bin/bash

# ─────────────────────────────────────────────
# Compression Tools Installer
# Detects OS, platform (x86_64 / ARM), and
# package manager, then installs the correct
# package for each compression tool.
# Supports: apt, dnf, yum, pacman, zypper, apk,
#           eopkg, emerge, xbps-install
# ─────────────────────────────────────────────

# Colors
RESET="\033[0m"
BOLD="\033[1m"
BRIGHT_GREEN="\033[1;32m"
BRIGHT_YELLOW="\033[1;33m"
BRIGHT_BLUE="\033[1;34m"
BRIGHT_MAGENTA="\033[1;35m"
BRIGHT_RED="\033[1;31m"
BRIGHT_CYAN="\033[1;36m"

# ─── Global Variables ────────────────────────
ARCH=""
OS_ID=""
OS_NAME=""
PKG_MGR=""
INSTALL_CMD=""

# ─── Helper Functions ───────────────────────

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

# ─── System Detection ───────────────────────

detect_arch() {
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64|amd64)  ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    armv7l|armv6l) ARCH="armv7"  ;;
    *)             ARCH="$ARCH"   ;;
  esac
}

detect_os_and_pkg_mgr() {
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    OS_NAME="$NAME"
    OS_ID="$ID"
  else
    OS_NAME=$(uname -s)
    OS_ID="unknown"
  fi

  if command -v apt &>/dev/null; then
    PKG_MGR="apt"
    INSTALL_CMD="sudo apt install -y"
    REMOVE_CMD="sudo apt remove -y"
  elif command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
    INSTALL_CMD="sudo dnf install -y"
    REMOVE_CMD="sudo dnf remove -y"
  elif command -v yum &>/dev/null; then
    PKG_MGR="yum"
    INSTALL_CMD="sudo yum install -y"
    REMOVE_CMD="sudo yum remove -y"
  elif command -v pacman &>/dev/null; then
    PKG_MGR="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    REMOVE_CMD="sudo pacman -Rs --noconfirm"
  elif command -v zypper &>/dev/null; then
    PKG_MGR="zypper"
    INSTALL_CMD="sudo zypper install -y"
    REMOVE_CMD="sudo zypper remove -y"
  elif command -v apk &>/dev/null; then
    PKG_MGR="apk"
    INSTALL_CMD="sudo apk add"
    REMOVE_CMD="sudo apk del"
  elif command -v eopkg &>/dev/null; then
    PKG_MGR="eopkg"
    INSTALL_CMD="sudo eopkg install"
    REMOVE_CMD="sudo eopkg remove"
  elif command -v emerge &>/dev/null; then
    PKG_MGR="emerge"
    INSTALL_CMD="sudo emerge --ask=n"
    REMOVE_CMD="sudo emerge --unmerge"
  elif command -v xbps-install &>/dev/null; then
    PKG_MGR="xbps-install"
    INSTALL_CMD="sudo xbps-install -Sy"
    REMOVE_CMD="sudo xbps-remove -y"
  else
    PKG_MGR="unknown"
    INSTALL_CMD=""
    REMOVE_CMD=""
  fi
}

# ─── Package Name Resolution ────────────────

# Returns the correct package name(s) for each tool based on OS / pkg manager.
get_package_name() {
  local tool="$1"
  case "$PKG_MGR" in
    apt)
      case "$tool" in
        unzip)   echo "unzip" ;;
        p7zip)   echo "p7zip-full" ;;
        bzip)    echo "bzip2" ;;
        xz)      echo "xz-utils" ;;
        tar)     echo "tar" ;;
        gzip)    echo "gzip" ;;
      esac
      ;;
    dnf|yum)
      case "$tool" in
        unzip)   echo "unzip" ;;
        p7zip)   echo "p7zip p7zip-plugins" ;;
        bzip)    echo "bzip2" ;;
        xz)      echo "xz" ;;
        tar)     echo "tar" ;;
        gzip)    echo "gzip" ;;
      esac
      ;;
    pacman)
      case "$tool" in
        unzip)   echo "unzip" ;;
        p7zip)   echo "p7zip" ;;
        bzip)    echo "bzip2" ;;
        xz)      echo "xz" ;;
        tar)     echo "tar" ;;
        gzip)    echo "gzip" ;;
      esac
      ;;
    zypper)
      case "$tool" in
        unzip)   echo "unzip" ;;
        p7zip)   echo "p7zip" ;;
        bzip)    echo "bzip2" ;;
        xz)      echo "xz" ;;
        tar)     echo "tar" ;;
        gzip)    echo "gzip" ;;
      esac
      ;;
    apk)
      case "$tool" in
        unzip)   echo "unzip" ;;
        p7zip)   echo "p7zip" ;;
        bzip)    echo "bzip2" ;;
        xz)      echo "xz" ;;
        tar)     echo "tar" ;;
        gzip)    echo "gzip" ;;
      esac
      ;;
    eopkg)
      case "$tool" in
        unzip)   echo "unzip" ;;
        p7zip)   echo "p7zip" ;;
        bzip)    echo "bzip2" ;;
        xz)      echo "xz" ;;
        tar)     echo "tar" ;;
        gzip)    echo "gzip" ;;
      esac
      ;;
    emerge)
      case "$tool" in
        unzip)   echo "app-arch/unzip" ;;
        p7zip)   echo "app-arch/p7zip" ;;
        bzip)    echo "app-arch/bzip2" ;;
        xz)      echo "app-arch/xz-utils" ;;
        tar)     echo "app-arch/tar" ;;
        gzip)    echo "app-arch/gzip" ;;
      esac
      ;;
    xbps-install)
      case "$tool" in
        unzip)   echo "unzip" ;;
        p7zip)   echo "p7zip" ;;
        bzip)    echo "bzip2" ;;
        xz)      echo "xz" ;;
        tar)     echo "tar" ;;
        gzip)    echo "gzip" ;;
      esac
      ;;
    *)
      # Fallback – same name works on most distros
      echo "$tool"
      ;;
  esac
}

# ─── Tool Display Names ─────────────────────

get_display_name() {
  case "$1" in
    unzip) echo "unzip" ;;
    p7zip) echo "p7zip (7-Zip)" ;;
    bzip)  echo "bzip2" ;;
    xz)    echo "xz-utils" ;;
    tar)   echo "tar" ;;
    gzip)  echo "gzip" ;;
  esac
}

# ─── Installation Functions ─────────────────

install_tool() {
  local tool_key="$1"
  local display_name
  display_name=$(get_display_name "$tool_key")
  local pkg_name
  pkg_name=$(get_package_name "$tool_key")

  # Check if already installed (the main binary exists)
  if command -v "$tool_key" &>/dev/null; then
    print_success "$display_name is already installed."
    return 0
  fi

  # Special case: p7zip's binary might be '7z' or '7za'
  if [[ "$tool_key" == "p7zip" ]]; then
    if command -v 7z &>/dev/null || command -v 7za &>/dev/null; then
      print_success "$display_name is already installed."
      return 0
    fi
  fi

  # Special case: bzip binary might be 'bzip2'
  if [[ "$tool_key" == "bzip" ]]; then
    if command -v bzip2 &>/dev/null; then
      print_success "$display_name is already installed."
      return 0
    fi
  fi

  print_warning "Installing $display_name..."
  echo -e "${BRIGHT_CYAN}Detected: ${OS_NAME} | ${ARCH} | ${PKG_MGR}${RESET}"
  echo -e "${BRIGHT_CYAN}Package: $pkg_name${RESET}"

  if [[ -z "$INSTALL_CMD" ]]; then
    print_error "No supported package manager found! Cannot install $display_name."
    return 1
  fi

  if $INSTALL_CMD $pkg_name; then
    print_success "$display_name installed successfully!"
    return 0
  else
    print_error "Failed to install $display_name. See error above."
    return 1
  fi
}

# ─── Uninstallation Functions ────────────────

uninstall_tool() {
  local tool_key="$1"
  local display_name
  display_name=$(get_display_name "$tool_key")
  local pkg_name
  pkg_name=$(get_package_name "$tool_key")

  if [[ -z "$REMOVE_CMD" ]]; then
    print_error "No supported package manager found! Cannot remove $display_name."
    return 1
  fi

  print_warning "Removing $display_name..."

  if $REMOVE_CMD $pkg_name; then
    print_success "$display_name removed successfully!"
    return 0
  else
    print_error "Failed to remove $display_name."
    return 1
  fi
}

uninstall_all_tools() {
  print_header "Removing All Compression Tools"
  print_warning "This will remove: unzip, p7zip, bzip2, xz-utils, tar, gzip"
  press_any_key

  local tools=("unzip" "p7zip" "bzip" "xz" "tar" "gzip")
  local success_count=0
  local fail_count=0

  for tool in "${tools[@]}"; do
    echo
    if uninstall_tool "$tool"; then
      ((success_count++))
    else
      ((fail_count++))
    fi
  done

  echo
  print_header "Removal Summary"
  print_success "$success_count tool(s) removed successfully."
  if [[ "$fail_count" -gt 0 ]]; then
    print_error "$fail_count tool(s) failed to remove."
  fi
  press_any_key
}

install_all_tools() {
  print_header "Installing All Compression Tools"
  echo -e "${BRIGHT_CYAN}Platform: ${OS_NAME} | ${ARCH} | ${PKG_MGR}${RESET}\n"
  print_warning "This will install: unzip, p7zip, bzip2, xz-utils, tar, gzip"
  press_any_key

  local tools=("unzip" "p7zip" "bzip" "xz" "tar" "gzip")
  local success_count=0
  local fail_count=0

  for tool in "${tools[@]}"; do
    echo
    if install_tool "$tool"; then
      ((success_count++))
    else
      ((fail_count++))
    fi
  done

  echo
  print_header "Installation Summary"
  print_success "$success_count tool(s) installed successfully."
  if [[ "$fail_count" -gt 0 ]]; then
    print_error "$fail_count tool(s) failed to install."
  fi
  press_any_key
}

# ─── Menu ───────────────────────────────────

show_menu() {
  detect_arch
  detect_os_and_pkg_mgr

  while true; do
    print_header "Install Compression Tools"
    echo -e "${BRIGHT_CYAN}Platform: ${OS_NAME} | ${ARCH} | ${PKG_MGR}${RESET}\n"

    echo -e "${BRIGHT_MAGENTA}${BOLD}[1]${RESET} $(get_display_name unzip)"
    echo -e "${BRIGHT_MAGENTA}${BOLD}[2]${RESET} $(get_display_name p7zip)"
    echo -e "${BRIGHT_MAGENTA}${BOLD}[3]${RESET} $(get_display_name bzip)"
    echo -e "${BRIGHT_MAGENTA}${BOLD}[4]${RESET} $(get_display_name xz)"
    echo -e "${BRIGHT_MAGENTA}${BOLD}[5]${RESET} $(get_display_name tar)"
    echo -e "${BRIGHT_MAGENTA}${BOLD}[6]${RESET} $(get_display_name gzip)"
    echo -e "${BRIGHT_GREEN}${BOLD}[7]${RESET} Install All Compression Tools"
    echo -e "${BRIGHT_RED}${BOLD}[r]${RESET} Remove a Compression Tool"
    echo -e "${BRIGHT_RED}${BOLD}[a]${RESET} Remove All Compression Tools"
    echo -e "${BRIGHT_RED}${BOLD}[b]${RESET} Back to Main Menu"
    echo

    read -p "$(echo -e "${BRIGHT_YELLOW}Enter your choice: ${RESET}")" choice
    echo

    case "$choice" in
      1) install_tool "unzip"; press_any_key ;;
      2) install_tool "p7zip"; press_any_key ;;
      3) install_tool "bzip";  press_any_key ;;
      4) install_tool "xz";    press_any_key ;;
      5) install_tool "tar";   press_any_key ;;
      6) install_tool "gzip";  press_any_key ;;
      7) install_all_tools ;;
      r|R)
        echo; read -p "Enter tool name to remove (unzip/p7zip/bzip/xz/tar/gzip): " rtool
        case "$rtool" in
          unzip|p7zip|bzip|xz|tar|gzip) uninstall_tool "$rtool" ;;
          *) print_error "Unknown tool: $rtool" ;;
        esac
        press_any_key ;;
      a|A) uninstall_all_tools ;;
      b|B) return 0 ;;
      *) print_error "Invalid choice. Please try again."; sleep 1 ;;
    esac
  done
}

# ─── Start ──────────────────────────────────
show_menu
