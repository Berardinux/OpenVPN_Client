#!/bin/bash

echo "Are you ready to install OpenVPN? (Y/N)"
read -r one

if [ "$one" == "Y" ]; then
    sudo apt update && sudo apt upgrade -y && sudo apt install openvpn -y
else
    echo "Okay, run the script again when you are ready to install!"
    exit
fi

clear

echo "What is your .ovpn file called?"
read -r ovpn

clear

echo "Where is your .ovpn file located?"
read -r location

sudo mv "$location" "/etc/openvpn/client/$ovpn"

clear

echo "What would you like to call your OpenVPN command?"
read -r command

sudo touch "/usr/local/bin/$command"
echo '#!/bin/bash' | sudo tee "/usr/local/bin/$command" >/dev/null
echo "sudo openvpn /etc/openvpn/client/$ovpn" | sudo tee -a "/usr/local/bin/$command" >/dev/null

echo "What would you like the permissions to be for the .ovpn file? (Suggested = 660)"
echo "Read permission: Numeric value of 4"
echo "Write permission: Numeric value of 2"
echo "Execute permission: Numeric value of 1"
echo "Press (Enter) to use suggested permissions"
read -r mod

if [ -z "$mod" ]; then
    sudo chmod 660 "/etc/openvpn/client/$ovpn"
else
    sudo chmod "$mod" "/etc/openvpn/client/$ovpn"
fi

clear

echo "To Connect to the VPN run the command $command"
