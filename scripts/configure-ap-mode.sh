#!/bin/sh

# Check if radio argument is provided
if [ -z "$1" ]; then
    echo "Please specify the radio interface (e.g., radio0):"
    read -r radio
    if [ -z "$radio" ]; then
        echo "Error: No radio interface provided. Exiting."
        exit 1
    fi
else
    radio="$1"
fi

# Validate radio interface (basic check for format)
if ! echo "$radio" | grep -q "^radio[0-9]\+$"; then
    echo "Error: Invalid radio interface format. Expected 'radioX' (e.g., radio0)."
    exit 1
fi

# Check if radio exists
if ! uci show wireless."$radio" >/dev/null 2>&1; then
    echo "Error: Radio interface $radio not found in wireless configuration."
    exit 1
fi

# Wireless configuration
uci set wireless."$radio".channel='48'
uci set wireless."$radio".htmode='VHT80'
uci set wireless."$radio".txpower='20'
uci set wireless."$radio".country='US'
uci set wireless."$radio".legacy_rates='0'
uci set wireless."$radio".short_preamble='1'
uci set wireless."$radio".ampdu='1'

# Disable and stop dnsmasq
/etc/init.d/dnsmasq disable >/dev/null 2>&1
/etc/init.d/dnsmasq stop >/dev/null 2>&1

# Install irqbalance if not already installed
if ! opkg list-installed | grep -q irqbalance; then
    opkg install irqbalance >/dev/null 2>&1
fi
/etc/init.d/irqbalance enable >/dev/null 2>&1

# Disable and stop firewall
/etc/init.d/firewall disable >/dev/null 2>&1
/etc/init.d/firewall stop >/dev/null 2>&1

# System tweaks
echo 10 > /proc/sys/vm/swappiness

# Wireless encryption
uci set wireless.default_"$radio".encryption='sae-mixed'

# Logging settings
uci set system.@system[0].log_size='0'
uci set system.@system[0].conloglevel='4'

# Remove unnecessary packages if they exist
opkg remove luci-app-statistics collectd >/dev/null 2>&1

# Apply changes
uci commit
wifi reload >/dev/null 2>&1 || echo "Warning: wifi reload failed, check wireless configuration."

echo "Configuration applied successfully for $radio."
