Run the following commands to enable auto restart on VPN via ping check
```
wget https://raw.githubusercontent.com/kinhsman/openwrt/main/vpn_ping_check_and_restart.sh -O /root/vpn_ping_check_and_restart.sh
```

```
chmod +x /root/vpn_ping_check_and_restart.sh
```

***STOP: and edit the ping dedtination within the script***
```
nano /root/vpn_ping_check_and_restart.sh
```

```
echo "* * * * * /root/vpn_ping_check_and_restart.sh" | crontab - && /etc/init.d/cron restart
```

```
/etc/init.d/cron status
```
### ***Check logs***
```
logread | grep PingCheck
```
