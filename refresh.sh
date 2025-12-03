#!/bin/bash
# Refresh Linux-Scripts and end up inside the folder

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration Variables ---
REPO_URL="https://github.com/techytim-tech/Linux-Scripts.git"
REPO_NAME="Linux-Scripts"
SCRIPT_NAME="refresh.sh" # The name of this script file
ALIAS_NAME="lsr" # Short for linux-script-refresh
INSTALL_DIR="${HOME}/.local/bin" # Common user binary directory for executables
USER_NAME=$(whoami) # Dynamically get the current username

# --- Helper Functions ---

# Function to check if a command exists
command_exists () {
  command -v "$1" &>/dev/null
}

# Function to add the alias to the appropriate shell RC file
add_alias() {
    local rc_file=""
    if [ -f "${HOME}/.bashrc" ]; then
        rc_file="${HOME}/.bashrc"
    elif [ -f "${HOME}/.zshrc" ]; then
        rc_file="${HOME}/.zshrc"
    else
        echo "Warning: Neither .bashrc nor .zshrc found in your home directory."
        echo "Cannot automatically add the alias '${ALIAS_NAME}'. Please add it manually if desired."
        echo "Example: alias ${ALIAS_NAME}='${INSTALL_DIR}/${SCRIPT_NAME}'"
        return 1
    fi

    # Check if the alias already exists in the RC file
    if ! grep -q "alias ${ALIAS_NAME}=" "${rc_file}"; then
        echo "Adding alias '${ALIAS_NAME}' to ${rc_file}..."
        echo "" >> "${rc_file}" # Add a newline for separation
        echo "# Alias for Linux-Scripts refresh script" >> "${rc_file}"
        echo "alias ${ALIAS_NAME}='${INSTALL_DIR}/${SCRIPT_NAME}'" >> "${rc_file}"
        echo "Alias '${ALIAS_NAME}' added. Please run 'source ${rc_file}' or open a new terminal for the alias to take effect."
    else
        echo "Alias '${ALIAS_NAME}' already exists in ${rc_file}. Skipping alias creation."
    fi
}

# --- Self-Installation Logic ---
# Check if the script is currently running from its intended install directory
if [[ "$(realpath "$0")" != "$(realpath "${INSTALL_DIR}/${SCRIPT_NAME}")" ]]; then
    echo "Hello ${USER_NAME}!"
    echo "This script ('${SCRIPT_NAME}') is designed to keep your '${REPO_NAME}' repository updated."
    echo "This Script removes the existing '${REPO_NAME}' directory and re-downloads an Updated Version from GitHub."
    echo ""
    read -p "Would you like to install '${SCRIPT_NAME}' to '${INSTALL_DIR}' and add an alias ('${ALIAS_NAME}') to your shell configuration (.bashrc or .zshrc)? (y/N): " -n 1 -r
    echo "" # Newline after prompt

    if [[ ${REPLY} =~ ^[Yy]$ ]]; then
        echo "Installing '${SCRIPT_NAME}'..."
        mkdir -p "${INSTALL_DIR}" # Create the install directory if it doesn't exist
        cp "$0" "${INSTALL_DIR}/${SCRIPT_NAME}" # Copy this script to the install directory
        chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}" # Make the copied script executable

        add_alias # Add the alias to the shell RC file

        echo "Installation complete. The script will now run from its installed location."
        # Use 'exec' to replace the current shell process with the newly installed script
        exec "${INSTALL_DIR}/${SCRIPT_NAME}" "$@"
    else
        echo "Installation skipped. Running the script from its current location."
        echo "You can manually run it later or move it to a convenient location if you wish."
    fi
fi

# --- Main Script Logic ---

echo "Starting refresh process for ${REPO_NAME}..."

# Pre-check: Ensure Git is installed
if ! command_exists git; then
    echo "Error: Git is not installed. Please install Git to continue."
    exit 1
fi

# Navigate to the home directory
echo "Navigating to home directory (~)..."
cd ~ || { echo "Error: Could not navigate to home directory. Aborting."; exit 1; }

# Remove existing repository to ensure a fresh clone
if [ -d "${REPO_NAME}" ]; then
    echo "Removing existing '${REPO_NAME}' directory to get a fresh copy..."
    rm -rf "${REPO_NAME}" || { echo "Error: Could not remove existing '${REPO_NAME}'. Please check permissions. Aborting."; exit 1; }
fi

# Download fresh Linux-Scripts
echo "Cloning fresh '${REPO_NAME}' from ${REPO_URL}..."
git clone "${REPO_URL}" || { echo "Error: Could not clone '${REPO_NAME}'. Please check the URL or your network connection. Aborting."; exit 1; }

# Navigate into the cloned repository
echo "Changing directory into '${REPO_NAME}/'..."
cd "${REPO_NAME}/" || { echo "Error: Could not change directory into '${REPO_NAME}'. Aborting."; exit 1; }

# Make all .sh files executable
echo "Making all .sh scripts executable..."
chmod +x *.sh || { echo "Warning: Could not make all .sh files executable. You may need to do this manually for specific scripts."; }

echo ""
echo "Successfully refreshed ${REPO_NAME}!"
echo "You are now inside the directory: $(pwd)"
echo "Contents of the directory:"
ls -F # Lists files and directories with indicators for types (e.g., / for directories, * for executables)
echo ""
