#!/bin/bash

clear
distro=$(grep -w "NAME" /etc/os-release | cut -d= -f2 | tr -d '"' | cut -d' ' -f1)
location=$(find / -type f -name "*.ovpn" 2>/dev/null)

if [ "$distro" = "Debian" ] || [ "$distro" = "Ubuntu" ]; then
    if dpkg -l | grep -q "openvpn"; then
        echo "openvpn is installed on your system already"
        exit 1
    else
        echo "OpenVPN is Not installed on your system yet"
    fi
elif [ "$distro" = "Arch" ]; then
    if pacman -Q | grep -q "openvpn"; then
        echo "OpenVPN is installed on your system already"
        exit 1
    else
        echo "OpenVPN is Not installed on your system yet"
    fi
else
    echo "Your Distro can not be installed using this install script sorry!"
    echo "Distros that can be installed include (Debian / Ubuntu / Arch)"
    exit 1
fi

clear

if [ -z "$location" ]; then
    echo "Not able to find .ovpn file try again when you have one"
    exit 1
else
    echo "Is this your .ovpn file? (Y/N)"
    echo "$location"
    read -r answer
    clear
    if [ "$answer" = "Y" ]; then
        echo "Okay Cool!"
    elif [ "$answer" = "N" ]; then
        echo "Okay what is your .ovpn file called, including the .ovpn at the end?"
        read -r ovpn
        location=$(sudo find / -name "$ovpn" 2>/dev/null)
        if [ -z "$location" ]; then
            echo "Your .ovpn was not found. Try again later."
            exit 1
        fi
    fi
fi

echo "# Are you ready to install OpenVPN? (Y/N) #"
read -r install
clear

echo "# Would you like to install the OpenVPN GUI APP? (Y/N)"
read -r app
clear

echo "# What would you like to call your OpenVPN command? #"
read -r command
clear

if [ "$install" = "Y" ]; then
    if [ "$distro" = "Debian" ] || [ "$distro" = "Ubuntu" ]; then
        sudo apt update && sudo apt upgrade -y && sudo apt install openvpn -y
    elif [ "$distro" = "Arch" ]; then
        sudo pacman -Syu && sudo pacman -S openvpn
    else
        exit
    fi

else
    echo "# Okay, run the script again when you are ready to install! #"
    exit
fi

location=$(sudo find / -name "$ovpn" 2>/dev/null)
sudo mv "$location" "/etc/openvpn/client/$ovpn"
sudo chmod 660 "/etc/openvpn/client/$ovpn"
clear

sudo touch "/usr/local/bin/$command"
sudo chmod 777 "/usr/local/bin/$command"
cat << EOM | sudo tee -a "/usr/local/bin/$command" >/dev/null
#!/bin/bash

start_vpn() {
    echo "Starting OpenVPN..."
    nohup sudo openvpn "/etc/openvpn/client/$ovpn" > /dev/null 2>&1 &
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
        echo "Unknown option: \$1"
        echo "Usage: \$0 {start/stop}"
        exit 1
        ;;
esac
EOM

if [ "$app" = "Y" ]; then
    echo "Installing OpenVPN to system!"
else
    echo "###### To Connect to the VPN run the command $command ######"
    exit 1
fi

sudo mkdir -p /opt/OpenVPN
sudo mv Images /opt/OpenVPN
sudo touch /opt/OpenVPN/ovpn_app.conf
sudo touch "/home/$USER/.local/share/applications/OpenVPN.desktop"
sudo chmod 777 /opt/OpenVPN/OpenVPN.py
sudo chmod 777 "/home/$USER/.local/share/applications/OpenVPN.desktop"
sudo mv OpenVPN.py /opt/OpenVPN

cat << EOM | sudo tee -a "/opt/OpenVPN/ovpn_app.conf" >/dev/null
## ovpn_app.conf

The name of the .ovpn files ( 
    $ovpn
)

The name of the Commands (
    $command
)
EOM

cat << EOM | sudo tee -a "/home/$USER/.local/share/applications/OpenVPN.desktop" >/dev/null
[Desktop Entry]
Type=Application
Name=OpenVPN
Comment=OpenVPN
Icon=/opt/OpenVPN/Images/openvpn.png
Exec=/opt/OpenVPN/OpenVPN.py
Terminal=false
EOM

echo "###### To Connect to the VPN run the command $command ######"

