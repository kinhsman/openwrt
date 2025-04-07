#!/bin/sh

# Function to determine CPU architecture
get_cpu_architecture() {
    arch=$(uname -m)
    case "$arch" in
        x86_64) echo "x86_64";;
        aarch64) echo "aarch64";;  # Changed from arm64 to match URL
        *) echo "unknown"; return 1;;
    esac
}

# Exit on any error
set -e

# Check if script is run as root (required for /usr/bin installation)
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)" >&2
    exit 1
fi

echo "Installing Speedtest CLI..."

# Get CPU architecture
cpu_arch=$(get_cpu_architecture) || {
    echo "Error: Unsupported CPU architecture" >&2
    exit 1
}

# Check and install dependencies using opkg
for cmd in wget tar; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Installing $cmd..."
        if ! opkg update || ! opkg install "$cmd"; then
            echo "Error: Failed to install $cmd" >&2
            exit 1
        fi
    fi
done

# Version and download information
VERSION="1.2.0"
BASE_URL="https://install.speedtest.net/app/cli"
DOWNLOAD_FILE="ookla-speedtest-${VERSION}-linux-${cpu_arch}.tgz"  # Will now use aarch64 correctly

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || {
    echo "Error: Failed to create/change to temp directory" >&2
    exit 1
}

# Download Speedtest CLI
if ! wget -O "speedtest.tar.gz" "${BASE_URL}/${DOWNLOAD_FILE}"; then
    echo "Error: Failed to download Speedtest CLI" >&2
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Extract archive
if ! tar zxvf "speedtest.tar.gz"; then
    echo "Error: Failed to extract archive" >&2
    rm -f "speedtest.tar.gz"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Install to /usr/bin and set permissions
if [ -f "speedtest" ]; then
    mv "speedtest" /usr/bin/speedtest
    chmod +x /usr/bin/speedtest
else
    echo "Error: Speedtest binary not found in archive" >&2
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Clean up
cd /
rm -rf "$TEMP_DIR"

echo -e "\e[32mSpeedtest CLI installed successfully to /usr/bin/speedtest!"
echo -e "You can now run 'speedtest' from any terminal.\e[0m"
