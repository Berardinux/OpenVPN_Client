#!/bin/bash

distro=$(grep -w "NAME" /etc/os-release | cut -d= -f2 | tr -d '"' | cut -d' ' -f1)
desktop=$(find / -name "OpenVPN.desktop" 2>/dev/null)
command=$(sed -n '3p' /opt/OpenVPN/ovpn_app.conf)

echo "Would you like to uninstall OpenVPN? (Y/n)"
read -r uninstall

if [ -z "$uninstall" ] || [ "$uninstall" = "Y" ]; then
	if [ "$distro" = "Debian" ] || [ "$distro" = "Ubuntu" ]; then
    	sudo apt purge openvpn
	elif [ "$distro" = "Arch" ]; then
		sudo pacman -Rns openvpn
	else
		echo "This Uninstall script will not work on you Distro."
		exit 1
	fi
elif [ "$uninstall" = "n" ]; then
	echo "Okay then."
	exit 1
else
	echo "That was not a option try again later."
	exit 1
fi

sudo rm $desktop
sudo rm /usr/local/bin/$command
sudo rm -r /etc/openvpn
sudo rm -r /opt/OpenVPN
