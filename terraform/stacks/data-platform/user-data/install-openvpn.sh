#!/bin/bash
#
apt update && apt -y install wget    
curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
chmod +x openvpn-install.sh
export AUTO_INSTALL="y"
export CLIENT="admin"
./openvpn-install.sh
