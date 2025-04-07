#!/bin/sh
###This script will import and replace the current wireguard config of openwrt-vpn-concentrator
### A wg0.conf must be obtained before running this script
### To run the script: `import_wg wg0.conf`
# Check if a config file argument is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a WireGuard config file as an argument."
    echo "Usage: $0 <config-file>"
    exit 1
fi

# Define paths
CONFIG_FILE="/etc/config/network"
NEW_CONFIG="$1"
BACKUP_FILE="/etc/config/network.bak"

# Check if new config file exists
if [ ! -f "$NEW_CONFIG" ]; then
    echo "Error: New WireGuard config file ($NEW_CONFIG) not found."
    exit 1
fi

# Debug: Check file readability and contents
echo "Debug: Checking file $NEW_CONFIG"
if [ ! -r "$NEW_CONFIG" ]; then
    echo "Error: Cannot read $NEW_CONFIG (check permissions)"
    exit 1
fi
if [ ! -s "$NEW_CONFIG" ]; then
    echo "Error: $NEW_CONFIG is empty"
    exit 1
fi
echo "Debug: File exists and is readable. Contents:"
cat "$NEW_CONFIG"

# Backup existing config
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Backed up current config to $BACKUP_FILE"

# Remove existing wireguard_vpn interface and peer sections
uci delete network.wireguard_vpn 2>/dev/null
uci delete network.@wireguard_wireguard_vpn[0] 2>/dev/null

# Parse the new config file and update UCI
while read -r line; do
    # Skip empty lines or comments
    case "$line" in
        "" | "#"*) continue ;;
    esac

    # Split at the first '=' only
    key=$(echo "$line" | cut -d'=' -f1 | xargs)
    value=$(echo "$line" | cut -d'=' -f2- | xargs)

    case "$key" in
        "[Interface]") current_section="interface" ;;
        "[Peer]") current_section="peer" ;;
        "PrivateKey")
            if [ "$current_section" = "interface" ]; then
                uci set network.wireguard_vpn=interface
                uci set network.wireguard_vpn.proto="wireguard"
                uci set network.wireguard_vpn.private_key="$value"
            fi
            ;;
        "Address")
            if [ "$current_section" = "interface" ]; then
                uci add_list network.wireguard_vpn.addresses="$value"
            fi
            ;;
        "DNS")
            if [ "$current_section" = "interface" ]; then
                uci add_list network.wireguard_vpn.dns="$value"
            fi
            ;;
        "PublicKey")
            if [ "$current_section" = "peer" ]; then
                uci set network.wg_peer=wireguard_wireguard_vpn
                uci set network.wg_peer.public_key="$value"
            fi
            ;;
        "PresharedKey")
            if [ "$current_section" = "peer" ]; then
                uci set network.wg_peer.preshared_key="$value"
            fi
            ;;
        "AllowedIPs")
            if [ "$current_section" = "peer" ]; then
                echo "$value" | tr ',' '\n' | while read -r ip; do
                    uci add_list network.wg_peer.allowed_ips="$(echo "$ip" | xargs)"
                done
            fi
            ;;
        "Endpoint")
            if [ "$current_section" = "peer" ]; then
                endpoint_host=$(echo "$value" | cut -d':' -f1)
                endpoint_port=$(echo "$value" | cut -d':' -f2)
                uci set network.wg_peer.endpoint_host="$endpoint_host"
                uci set network.wg_peer.endpoint_port="$endpoint_port"
            fi
            ;;
        "PersistentKeepalive")
            if [ "$current_section" = "peer" ]; then
                uci set network.wg_peer.persistent_keepalive="$value"
            fi
            ;;
    esac
done < "$NEW_CONFIG"

# Set route_allowed_ips (optional, enable if needed)
uci set network.wg_peer.route_allowed_ips="1"

# Commit changes
uci commit network

# Restart network service to apply changes
/etc/init.d/network restart

echo "WireGuard configuration updated and network restarted."
