#!/bin/sh

# This script will ping the VPN server and if there is packet loss, it will restart the network service

# IP to ping
TARGET_IP="10.5.0.1"

# Number of pings to send
PING_COUNT=3

# Log tag for logread
LOG_TAG="PingCheck"

# Run ping and extract packet loss percentage correctly
LOSS_PERCENT=$(ping -c $PING_COUNT -q $TARGET_IP | awk -F'%' '/packet loss/ {print $(NF-1)}' | awk '{print $NF}')

# Ensure LOSS_PERCENT is a number
if [ -z "$LOSS_PERCENT" ] || ! [ "$LOSS_PERCENT" -eq "$LOSS_PERCENT" ] 2>/dev/null; then
    LOSS_PERCENT=100
fi

# Check if all pings failed (100% packet loss)
if [ "$LOSS_PERCENT" -eq 100 ]; then
    MESSAGE="All pings to $TARGET_IP failed! Restarting network..."
    echo "$(date): $MESSAGE" >> /var/log/ping_check.log
    logger -t $LOG_TAG "$MESSAGE"
    /etc/init.d/network restart
else
    MESSAGE="Network OK. $LOSS_PERCENT% packet loss, no restart needed."
    echo "$(date): $MESSAGE" >> /var/log/ping_check.log
    logger -t $LOG_TAG "$MESSAGE"
fi
