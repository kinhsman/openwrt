#!/bin/sh

# Download the Speedtest CLI
wget -O speedtest.tar.gz https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz

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

# Source the .ashrc or .profile file to apply the changes immediately
source ~/.ashrc || source ~/.profile

echo "Speedtest CLI has been installed. You can now use 'speedtest' command."
