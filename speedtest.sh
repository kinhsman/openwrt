#!/bin/sh


# Download the Speedtest CLI
wget -O speedtest.tar.gz https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-x86_64.tgz

# Extract the downloaded archive
tar zxvf speedtest.tar.gz

# Run the Speedtest CLI
./speedtest
