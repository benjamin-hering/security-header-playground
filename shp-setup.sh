#!/bin/bash

# A script for setting up a demo server to show the benefits of security headers on a Raspberry PI
# Cobbled together from http://blog.claytonn.com/raspberry-pi-creating-access-point/
# and https://andrewmichaelsmith.com/2013/08/raspberry-pi-wi-fi-honeypot/
# Tested on Raspberry Pi 3 with the built in wifi card

# Making sure this is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Starting with the Apache sites setup
bash ./apache-sites/apache-setup.sh

# Install hostapd (for the access point), dnsmasq (to handle DNS) & apache2 (to serve our pages)
sudo apt install hostapd dnsmasq -y

# Setup simple config for hostapd
cat > /etc/hostapd/hostapd.conf << EOL
interface=wlan0
driver=nl80211
ssid=Evil WiFi
channel=3
EOL

# Point hostapd daemon to the config file
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

# Add dnsmasq config
cat >> /etc/dnsmasq.conf << EOL
log-facility=/var/log/dnsmasq.log
address=/#/192.168.66.1
interface=wlan0
dhcp-range=192.168.66.10,192.168.66.250,12h
no-resolv
log-queries
EOL

# Add interface configuration
cat >> /etc/dhcpcd.conf << EOL
interface wlan0
static ip_address=192.168.66.1/24
denyinterfaces wlan0
EOL

# Setting hostapd to start by default
sudo update-rc.d hostapd defaults
sudo update-rc.d dnsmasq defaults

# Reboot to take affect
sudo reboot
