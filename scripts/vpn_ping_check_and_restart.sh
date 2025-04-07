#!/bin/sh

# This script will ping the VPN server and if there is packet loss, it will restart the network service

# IP to ping
TARGET_IP="10.5.0.1"

# Number of pings to send
PING_COUNT=3

# Log tag for logread
LOG_TAG="PingCheck"

# Print status when running manually
echo "Checking connectivity to $TARGET_IP with $PING_COUNT pings..."

# Run ping and extract packet loss percentage
PING_OUTPUT=$(ping -c $PING_COUNT -q $TARGET_IP)
LOSS_PERCENT=$(echo "$PING_OUTPUT" | awk -F'%' '/packet loss/ {print $(NF-1)}' | awk '{print $NF}')

# Show raw ping output (for debugging)
echo "Ping output:"
echo "$PING_OUTPUT"

# Ensure LOSS_PERCENT is a number
if [ -z "$LOSS_PERCENT" ] || ! [ "$LOSS_PERCENT" -eq "$LOSS_PERCENT" ] 2>/dev/null; then
    echo "Warning: Failed to extract packet loss percentage! Assuming 100% loss."
    LOSS_PERCENT=100
fi

# Display extracted packet loss
echo "Packet loss detected: $LOSS_PERCENT%"

# Check if all pings failed (100% packet loss)
if [ "$LOSS_PERCENT" -eq 100 ]; then
    MESSAGE="All pings to $TARGET_IP failed! Restarting network..."
    echo "$(date): $MESSAGE"
#    echo "$(date): $MESSAGE" >> /var/log/ping_check.log
    logger -t $LOG_TAG "$MESSAGE"
    /etc/init.d/network restart
else
    MESSAGE="Network OK. $LOSS_PERCENT% packet loss, no restart needed."
    echo "$(date): $MESSAGE"
#    echo "$(date): $MESSAGE" >> /var/log/ping_check.log
    logger -t $LOG_TAG "$MESSAGE"
fi
