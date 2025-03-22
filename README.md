# OpenWRT Ookla Speedtest Installer

This script automates the installation process of Ookla Speedtest on OpenWRT OS.

## Prerequisites:
Ensure `wget` is installed

```bash
opkg update
opkg install wget
```
# Installation:
Execute the following command in your terminal:
```
wget -qO- https://raw.githubusercontent.com/kinhsman/openwrt/main/speedtest-install.sh | ash
```

# Usage:
After installation, simply run the following command to perform a speed test:
```
speedtest
```
# License:
For licensing information, refer to [Speedtest CLI License.](https://www.speedtest.net/apps/cli)
