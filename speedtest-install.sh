#!/bin/sh

# Function to determine the CPU architecture
get_cpu_architecture() {
    arch=$(uname -m)
    case "$arch" in
        x86_64) echo "x86_64";;
        aarch64) echo "arm64";;
        *) echo "unknown";;
    esac
}

# Get CPU architecture
cpu_arch=$(get_cpu_architecture)

# Download and install necessary utilities if not already installed
if ! command -v wget &> /dev/null; then
    opkg update
    opkg install wget
fi

if ! command -v tar &> /dev/null; then
    opkg update
    opkg install tar
fi


# Download the appropriate Speedtest CLI based on CPU architecture
case "$cpu_arch" in
    x86_64)
        download_url="https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz"
        ;;
    arm64)
        download_url="https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz"
        ;;
    *)
        echo "Unsupported CPU architecture."
        exit 1
        ;;
esac

# Download the Speedtest CLI
wget -O speedtest.tar.gz "$download_url"

# Extract the downloaded archive
tar zxvf speedtest.tar.gz

# Check if .ashrc or .profile exists, if not, create it
if [ ! -f ~/.ashrc ]; then
    touch ~/.ashrc
fi

if [ ! -f ~/.profile ]; then
    touch ~/.profile
fi

# Add an alias for speedtest
echo "alias speedtest=\"$(pwd)/speedtest\"" >> ~/.ashrc
echo "alias speedtest=\"$(pwd)/speedtest\"" >> ~/.profile

# Print the installation message
echo -e "\e[32mSpeedtest CLI has been installed. You can now use 'speedtest' command.\e[0m"

# Print the logout message
echo -e "\e[32mPlease log out and log back in to apply the changes.\e[0m"
