#!/bin/sh

echo "Attempting to update Tailscale..."
# Run the update command and capture its output and exit status
UPDATE_OUTPUT=$(tailscale update --yes 2>&1)
UPDATE_STATUS=$?

# Print the output from the update command
echo "$UPDATE_OUTPUT"

# Check if the update command was successful
if [ "$UPDATE_STATUS" -eq 0 ]; then
    # Check if the output indicates Tailscale is already up to date or no update was needed
    if echo "$UPDATE_OUTPUT" | grep -qE "already running stable version|no update needed"; then
        echo "Tailscale is already up to date. Skipping service restart."
    else
        echo "Tailscale update completed successfully. Restarting service."
        service tailscale restart
        if [ $? -eq 0 ]; then
            echo "Tailscale service restarted successfully."
        else
            echo "Failed to restart Tailscale service."
        fi
    fi
else
    echo "Tailscale update failed or encountered issues. Attempting to restart service anyway."
    service tailscale restart
    if [ $? -eq 0 ]; then
        echo "Tailscale service restarted successfully."
    else
        echo "Failed to restart Tailscale service."
    fi
fi

echo "Script finished."
