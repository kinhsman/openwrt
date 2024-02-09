# OpenWRT Ookla Speedtest Installer

This script automates the installation process of Ookla Speedtest on OpenWRT OS.

## Prerequisites:
Ensure the following packages are installed: wget, curl, and bash.

```bash
opkg update
opkg install wget curl bash
```
# Installation:
Execute the following command in your terminal:
```
curl -fsSL https://raw.githubusercontent.com/kinhsman/openwrt/main/speedtest-install.sh | bash
```

# Usage:
After installation, simply run the following command to perform a speed test:
```
speedtest
```
# License:
For licensing information, refer to [Speedtest CLI License.](https://www.speedtest.net/apps/cli)
