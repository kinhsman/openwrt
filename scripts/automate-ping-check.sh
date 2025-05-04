#!/bin/bash

# Prompt user for the ping destination
read -rp "Enter the IP address to ping for VPN check (e.g., 10.5.0.1): " PING_IP

# Step 1: Download the script
echo "Downloading ping check script..."
wget -q https://raw.githubusercontent.com/kinhsman/openwrt/main/scripts/vpn_ping_check_and_restart.sh -O /usr/bin/pingcheck

# Step 2: Make it executable
chmod +x /usr/bin/pingcheck

# Step 3: Replace the default IP with the user's input
echo "Updating ping destination in script to $PING_IP..."
sed -i "s/^TARGET_IP=.*/TARGET_IP=\"$PING_IP\"/" /usr/bin/pingcheck

# Step 4: Add to crontab if not already added
CRON_JOB="* * * * * /usr/bin/pingcheck"
(crontab -l 2>/dev/null | grep -qF "$CRON_JOB") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# Step 5: Restart cron
echo "Restarting cron service..."
/etc/init.d/cron restart

# Step 6: Check cron status
echo "Cron status:"
/etc/init.d/cron status

# Step 7: Prompt to check logs
read -rp "Do you want to view PingCheck logs now? (y/n): " VIEW_LOGS
if [[ "$VIEW_LOGS" =~ ^[Yy]$ ]]; then
    logread | grep PingCheck
else
    echo "You can view logs later with: logread | grep PingCheck"
fi
