#!/bin/sh

# Enable verbose output (optional)
set -x

# Define the VPN provider's hostname
VPN_HOSTNAME="google1.sangnetworks.com"

# Define the custom DNS server
DNS_SERVER="10.11.10.11"

# Path to store the last known IP
LAST_IP_FILE="/tmp/last_vpn_ip"

logger "Starting DNS lookup for $VPN_HOSTNAME using server $DNS_SERVER..."

# Get the current IP of the VPN provider using the specified DNS server
NEW_IP=$(nslookup $VPN_HOSTNAME $DNS_SERVER | grep 'Address' | tail -n 1 | awk '{print $2}')

# Check if we were able to resolve the IP
if [ -z "$NEW_IP" ]; then
    logger "Error: Could not resolve IP for $VPN_HOSTNAME using DNS server $DNS_SERVER."
    exit 1
else
    logger "Resolved IP: $NEW_IP"
fi

# Read the last known IP from the file
if [ -f "$LAST_IP_FILE" ]; then
    OLD_IP=$(cat "$LAST_IP_FILE")
    logger "Last known IP from file: $OLD_IP"
else
    OLD_IP=""
    logger "No previous IP found, treating as first run."
fi

# Compare the new IP with the old IP
if [ "$NEW_IP" != "$OLD_IP" ]; then
    logger "IP has changed. Updating stored IP and restarting WireGuard..."
    
    # If the IP has changed, update the file with the new IP and restart WireGuard
    echo "$NEW_IP" > "$LAST_IP_FILE"
    /etc/init.d/network restart
    
    # Output status after restarting WireGuard
    if [ $? -eq 0 ]; then
        logger "WireGuard has been successfully restarted."
    else
        logger "Error: Failed to restart WireGuard."
    fi
else
    logger "No change in IP. No action needed."
fi

# End verbose output
set +x
