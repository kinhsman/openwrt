Run the following commands to enable auto restart on VPN via ping check
```
wget https://raw.githubusercontent.com/kinhsman/openwrt/main/vpn_ping_check_and_restart.sh -O /usr/bin/pingcheck
```

```
chmod +x /usr/bin/pingcheck
```

***STOP: and edit the ping dedtination within the script***
```
nano /usr/bin/pingcheck
```

```
(crontab -l; echo "* * * * * /usr/bin/pingcheck") | crontab - && /etc/init.d/cron restart
```

```
/etc/init.d/cron status
```
### ***Check logs***
```
logread | grep PingCheck
```
