#!/bin/bash

clear
echo "# Are you ready to install OpenVPN? (Y/N) #"
read -r one
clear

echo "# Would you like to install the OpenVPN GUI Button? (Y/N)"
read -r button

echo "########## What is your .ovpn file called? ###############"
echo "# Remember to include the .ovpn at the end of the file!! #"
read -r ovpn
clear

echo "# What would you like to call your OpenVPN command? #"
read -r command
clear

if [ "$one" == "Y" ]; then
    echo "######## What distro are you on? #######"
    echo "# Your options are ( Debian ) ( Arch ) #"
    read -r distro
    if [ "$distro" == "Debian" ]; then
        sudo apt update && sudo apt upgrade -y && sudo apt install openvpn -y
    elif [ "$distro" == "Arch" ]; then
        sudo pacman -Syu && sudo pacman -S openvpn
    else
        echo "# That was not a option would you like to restart? #"
        echo "################# ( Y / N ) ########################"
        read -r var
        if [ "$var" == "Y" ]; then
            sudo ./openvpn_client.sh
        else
            exit
        fi
    fi
else
    echo "# Okay, run the script again when you are ready to install! #"
    exit
fi

location=$(sudo find / -name $ovpn 2>/dev/null)
sudo mv "$location" "/etc/openvpn/client/$ovpn"
sudo chmod 660 "/etc/openvpn/client/$ovpn"
clear

sudo touch "/usr/local/bin/$command"
sudo chmod 777 /usr/local/bin/$command
cat << EOM | sudo tee -a "/usr/local/bin/$command" >/dev/null
#!/bin/bash

start_vpn() {
    echo "Starting OpenVPN..."
    nohup sudo openvpn /etc/openvpn/client/$ovpn > /dev/null 2>&1 &
    echo "OpenVPN started. You can now close the terminal."
    echo "The command to stop the VPN is {$command stop}"
}

stop_vpn() {
    echo "Stopping OpenVPN..."
    sudo killall openvpn
    echo "OpenVPN stopped."
}

if [ \$# -eq 0 ]; then
    echo "Usage: {start/stop}"
    exit 1
fi

case "\$1" in
    start)
        start_vpn
        ;;
    stop)
        stop_vpn
        ;;
    *)
        echo "Unknown option: $1"
        echo "Usage: $0 {start/stop}"
        exit 1
        ;;
esac
EOM

if [ "$button" == "Y" ]; then
	echo "Installing OVPN_APP to system!"
else
	echo "###### To Connect to the VPN run the command $command ######"
	exit 1
fi

sudo mkdir /opt/OVPN_APP
sudo mv PICS /opt/OVPN_APP
sudo touch /opt/OVPN_APP/ovpn_app.conf
sudo chmod 777 OVPN_APP.py
sudo mv OVPN_APP.py /opt/OVPN_APP

cat << EOM | sudo tee -a "/opt/OVPN_APP/ovpn_app.conf" >/dev/null
## ovpn_app.conf

The name of the .ovpn files ( 
	$ovpn
)

The name of the Commands (
	$command
)
EOM

cat << EOM | sudo tee -a "/home/$USER/.local/share/applications" >/dev/null
[Desktop Entry]
Encoding=UTF-8
Type=Application
Terminal=false
Exec=/opt/OVPN_APP/OVPN_APP.py
Name OpenVPN
Icon=/opt/OVPN_APP/PICS/openvpn.png
EOM
echo "###### To Connect to the VPN run the command $command ######"
