#!/bin/bash

# Important: This script is executed after BirdNetPi is installed and it must be executed in the directory ~/BirdNET-Pi!
# It uses the default WiFi interface and creates an access point that allows everyone to connect who know the password.
# For details check the config below.

INTERFACE=wlan0

DHCP_START=10.10.10.2
DHCP_END=10.10.10.254
DHCP_MASK=255.255.255.0
DHCP_MASK_NBR=24

AP_IP=10.10.10.1
AP_COUNTRY_CODE=DE
AP_SSID=BirdNetwork
AP_PW=BirdNetwork
AP_CHANNEL=8  # if channel is already used by other ap, this scripot might fail. in that case try other channel

# --- Install AP and Management Software --- #
sudo apt install hostapd
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo apt install dnsmasq

# --- Configure the DHCP and DNS services for the wireless network --- #
printf "interface $INTERFACE\nstatic ip_address=$AP_IP/$DHCP_MASK_NBR\nnohook wpa_supplicant\n" >> /etc/dhcpcd.conf
if test -f "/etc/dnsmasq.conf.orig"; then
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
fi
printf "interface=wlan0\ndhcp-range=$DHCP_START,$DHCP_END,$DHCP_MASK,24h\ndomain=wlan\naddress=/gw.wlan/$AP_IP" > /etc/dnsmasq.conf

# --- Ensure Wireless Operation | Configure the AP Software --- #
sudo rfkill unblock wlan
printf "country_code=$AP_COUNTRY_CODE\ninterface=$INTERFACE\nssid=$AP_SSID\nhw_mode=g\nchannel=$AP_CHANNEL\nmacaddr_acl=0\nauth_algs=1\nignore_broadcast_ssid=0\nwpa=2\nwpa_passphrase=$AP_PW\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP\nrsn_pairwise=CCMP" > /etc/hostapd/hostapd.conf

# --- Set URL to IP address of AP --- #
sed -i "s/BIRDNETPI_URL=/BIRDNETPI_URL=http:\/\/$AP_IP/g" birdnet.conf

sudo systemctl reboot
