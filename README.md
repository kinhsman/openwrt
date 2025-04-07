## Prerequisites:
Ensure `wget` is installed

```bash
opkg update
opkg install wget
```
# OpenWRT Ookla Speedtest Installer

```
wget -qO- https://raw.githubusercontent.com/kinhsman/openwrt/main/scripts/speedtest-install.sh | ash
```
```
speedtest
```

# OpenWRT Import and Replace Wireguard config of a VPN Concentrator
```sh
wget -O /usr/bin/import_wg https://raw.githubusercontent.com/kinhsman/openwrt/main/scripts/import_wg.sh && chmod +x /usr/bin/import_wg
```
