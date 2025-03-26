# Upgrading OpenWrt Firmware for Mobile-AP

This guide outlines the steps to upgrade the firmware of an OpenWrt instance running as a mobile access point (Mobile-AP) on a virtual machine (VM). Follow these steps carefully to ensure a smooth upgrade process.

---

## Step 1: Back Up the Current Configuration
1. Navigate to:  
   `http://10.16.10.2/cgi-bin/luci/admin/system/flash`  
2. Download the backup:  
   Click **Generate archive** to save the configuration as `backup-mobile-AP-2025-03-23.tar.gz`.

---

## Step 2: Install SFTP Server and List Installed Packages
1. Go to:  
   `http://10.16.10.2/cgi-bin/luci/admin/system/package-manager`  
2. Update package lists:  
   Click **Update lists...**  
3. Install the SFTP server:  
   Install the package `openssh-sftp-server`.  
4. SSH into the OpenWrt shell:  
   ```bash
   ssh root@10.16.10.2
   ```
5. Export the list of installed packages:
   ```
   opkg list-installed > /root/installed-packages.txt
   ```
6. From your macOS terminal, copy the package list to your local machine:
   ```
   scp root@10.16.10.2:/root/installed-packages.txt .
   ```
   Resulting Files for Restoration:
    - `backup-mobile-AP-2025-03-23.tar.gz`
    - `installed-packages.txt`

---

## Step 3: Copy the New Firmware Download URL
1. Visit:
   `https://downloads.openwrt.org/releases/24.10.0/targets/x86/64/`
2. Locate the file `generic-ext4-combined.img.gz`
3. Right-click and copy the download link:
   `https://downloads.openwrt.org/releases/24.10.0/targets/x86/64/openwrt-24.10.0-x86-64-generic-ext4-combined.img.gz`

---

## Step 4: Import Firmware to the VM
1. Download and prepare the firmware:
   ```
   wget https://downloads.openwrt.org/releases/24.10.0/targets/x86/64/openwrt-24.10.0-x86-64-generic-ext4-combined.img.gz
   gunzip openwrt-24.10.0-x86-64-generic-ext4-combined.img.gz
   qemu-img resize -f raw openwrt-24.10.0-x86-64-generic-ext4-combined.img 512M
   qm importdisk 10002 openwrt-24.10.0-x86-64-generic-ext4-combined.img local-zfs
   ```
2. Configure the new disk in the VM:
   - Go to VM → Hardware.
   - Double-click Unused Disk 0 (the newly imported disk).
   - Set it to VirtIO with Discard and IO Thread enabled, then click OK.
   
3. Set the boot order:
   - Go to VM → Options → Boot Order.
   - Check the box for the new disk and uncheck all other options.

---
## Step 5: Boot the VM and Configure Networking
1. Start the VM.
2. SSH into the OpenWrt instance:
   ```
   ssh root@10.16.10.2
   ```
3. Edit the network configuration:
   ```
   vi /etc/config/network
   ```
   Edit the lan interface as:
   ```
   config interface 'lan'
    option ifname 'eth0'
    option proto 'static'
    option ipaddr '10.16.10.2'
    option netmask '255.255.255.0'
    option gateway '10.16.10.1'
    list dns '10.16.10.1'
    list dns '8.8.8.8'
   ```
4. Save and exit vi (press Esc, then type :wq and hit Enter).
5. Restart networking and reboot:
   ```
   /etc/init.d/network restart
   reboot
   ```

---

## Step 6: Reinstall Packages
1. SSH into the OpenWrt instance:
2. Update the package lists and install the SFTP server:
   ```
   opkg update
   opkg install openssh-sftp-server
   exit
   ```
3. From your macOS terminal, upload the package list:
   ```
   scp installed-packages.txt root@10.16.10.2:/root/installed-packages.txt
   ```
4. SSH back into the instance and reinstall all packages:
   ```
   opkg update
   cat /root/installed-packages.txt | awk '{print $1}' | while read pkg; do opkg install $pkg || echo "Failed to install $pkg"; done
   reboot
   ```

---

## Step 7: Restore the Backup
1. Access the web UI:
   `http://10.16.10.2/cgi-bin/luci/admin/system/flash`
2. Restore the backup:
   - Click Restore backup.
   - Browse to backup-mobile-AP-2025-03-23.tar.gz and upload it.
3. Reboot

---

### Done!


### Notes:
- The instructions have been rewritten for clarity and consistency.
- Markdown formatting (headings, code blocks, and lists) ensures it renders nicely on GitHub.
- Commands are grouped logically and formatted as code blocks for easy copy-pasting.
- The structure is broken into clear steps with descriptive titles.
