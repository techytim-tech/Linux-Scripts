#!/bin/bash
# Refresh Linux-Scripts - clones fresh copy from GitHub

# --- Configuration ---
REPO_URL="https://github.com/techytim-tech/Linux-Scripts.git"
REPO_NAME="Linux-Scripts"
SCRIPT_NAME="refresh.sh"
ALIAS_NAME="lsr"
INSTALL_DIR="${HOME}/.local/bin"

command_exists() { command -v "$1" &>/dev/null; }

add_alias() {
    local rc_file=""
    [[ -f "${HOME}/.bashrc" ]] && rc_file="${HOME}/.bashrc"
    [[ -f "${HOME}/.zshrc" ]] && rc_file="${HOME}/.zshrc"
    [[ -f "${HOME}/.config/fish/config.fish" ]] && rc_file="${HOME}/.config/fish/config.fish"

    if [[ -z "$rc_file" ]]; then
        echo "Warning: No shell config found. Add alias manually:"
        echo "  alias ${ALIAS_NAME}='${INSTALL_DIR}/${SCRIPT_NAME}'"
        return 1
    fi

    if ! grep -q "alias ${ALIAS_NAME}=" "$rc_file" 2>/dev/null; then
        echo "Adding alias '${ALIAS_NAME}' to ${rc_file}..."
        echo "" >> "$rc_file"
        echo "# Alias for Linux-Scripts refresh" >> "$rc_file"
        echo "alias ${ALIAS_NAME}='${INSTALL_DIR}/${SCRIPT_NAME}'" >> "$rc_file"
        echo "Alias added. Run: source ${rc_file}"
    else
        echo "Alias '${ALIAS_NAME}' already exists in ${rc_file}"
    fi
}

# --- Self-Installation ---
if [[ "$(realpath "$0" 2>/dev/null)" != "$(realpath "${INSTALL_DIR}/${SCRIPT_NAME}" 2>/dev/null)" ]]; then
    echo "Hello $(whoami)!"
    echo "This script keeps your '${REPO_NAME}' repository up to date."
    echo "It removes the existing directory and clones a fresh copy."
    echo ""
    read -p "Install to ${INSTALL_DIR} and add alias '${ALIAS_NAME}'? (y/N): " -n 1 -r
    echo

    if [[ ${REPLY} =~ ^[Yy]$ ]]; then
        mkdir -p "${INSTALL_DIR}"
        cp "$0" "${INSTALL_DIR}/${SCRIPT_NAME}"
        chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
        add_alias
        echo "Running from installed location..."
        exec "${INSTALL_DIR}/${SCRIPT_NAME}" "$@"
    else
        echo "Running from current location."
    fi
fi

# --- Main ---
echo "Refreshing ${REPO_NAME}..."

command_exists git || { echo "Error: Git not installed"; exit 1; }

# Navigate to a safe directory first
cd /tmp 2>/dev/null || cd ~ || exit 1

# Backup existing repo in case clone fails
if [[ -d "${HOME}/${REPO_NAME}" ]]; then
    echo "Backing up existing ${REPO_NAME}..."
    cp -r "${HOME}/${REPO_NAME}" "/tmp/${REPO_NAME}.backup.$$" 2>/dev/null
fi

# Remove old and clone fresh
echo "Removing old ${REPO_NAME}..."
rm -rf "${HOME:?}/${REPO_NAME:?}" 2>/dev/null

echo "Cloning fresh ${REPO_NAME} from GitHub..."
if git clone "${REPO_URL}" "${HOME}/${REPO_NAME}" 2>/dev/null; then
    echo "✓ Clone successful"
else
    echo "✗ Clone failed!"
    # Restore backup
    if [[ -d "/tmp/${REPO_NAME}.backup.$$" ]]; then
        echo "Restoring from backup..."
        mv "/tmp/${REPO_NAME}.backup.$$" "${HOME}/${REPO_NAME}"
        echo "✓ Backup restored"
    fi
    exit 1
fi

# Clean up backup
rm -rf "/tmp/${REPO_NAME}.backup.$$" 2>/dev/null

cd "${HOME}/${REPO_NAME}" || exit 1
chmod +x *.sh 2>/dev/null

echo ""
echo "✓ ${REPO_NAME} refreshed successfully!"
echo "Location: $(pwd)"
ls -F
