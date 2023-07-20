#!/bin/bash

clear
distro=$(grep -w "NAME" /etc/os-release | cut -d= -f2 | tr -d '"' | cut -d' ' -f1)
location=$(find / -type f -name "*.ovpn" 2>/dev/null)
command=$(echo "$location" | rev | cut -d'/' -f1 | rev | cut -d'.' -f1)

if [ $(id -u) -eq 0 ]; then
	current_user=$SUDO_USER
else
	current_user=$USER
fi

if [ "$distro" = "Debian" ] || [ "$distro" = "Ubuntu" ]; then
    if dpkg -l | grep -q "openvpn"; then
        echo "openvpn is aready installed on your system already"
        sudo chmod 777 scripts/Uninstall.sh
	sudo ./scripts/Uninstall.sh
	exit 1
    else
        echo "OpenVPN is Not installed on your system yet"
    fi
elif [ "$distro" = "Arch" ]; then
    if pacman -Q openvpn >/dev/null 2>&1; then
        echo "OpenVPN is installed on your system already"
	sudo chmod 777 scripts/Uninstall.sh
        sudo ./scripts/Uninstall.sh
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
    echo "Is this your .ovpn file? (Y/n)"
    echo "$location"
    read -r answer
    clear
    if [ -z $answer ] || [ "$answer" = "Y" ]; then
        echo "Okay Cool!"
        ovpn=$(echo "$location" | rev | cut -d'/' -f1 | rev)
    elif [ "$answer" = "n" ]; then
        echo "Okay what is your .ovpn file called, including the .ovpn at the end?"
        read -r ovpn
        location=$(sudo find / -name "$ovpn" 2>/dev/null)
        if [ -z "$location" ]; then
            echo "Your .ovpn was not found. Try again later."
            exit 1
        fi
    fi
fi

echo "# Are you ready to install OpenVPN? (Y/n) #"
read -r install
clear

echo "# Would you like to install the OpenVPN GUI APP? (Y/n)"
read -r app
clear

if [ -z $install ]; then
    install=Y
    if [ "$install" = "Y" ]; then
        if [ "$distro" = "Debian" ] || [ "$distro" = "Ubuntu" ]; then
            sudo apt update && sudo apt upgrade -y && sudo apt install openvpn -y
        elif [ "$distro" = "Arch" ]; then
            sudo pacman -Syu && sudo pacman -S --noconfirm openvpn
        else
            exit
        fi
    fi
else
    echo "# Okay, run the script again when you are ready to install! #"
    exit
fi

sudo mv "$location" "/etc/openvpn/client"
sudo chmod 660 "/etc/openvpn/client/$ovpn"
clear

sudo touch "/usr/local/bin/$command"
sudo chmod 777 "/usr/local/bin/$command"
cat << EOM | sudo tee -a "/usr/local/bin/$command" >/dev/null
#!/bin/bash

start_vpn() {
    echo "Starting OpenVPN..."
    nohup sudo openvpn "/etc/openvpn/client/$ovpn" > /dev/null 2>&1 &
    PID=\$!
    sleep 5
    if ps -p \$PID >/dev/null; then
        echo "OpenVPN started. You can now close the terminal."
        echo "The command to stop the VPN is {$command stop}"
    else
        echo "Failed to start OpenVPN. Please check the VPN configuration and try again."
    fi
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
if [ -z "app" ]; then
    app=y
    if [ "$app" = "Y" ]; then
        echo "Installing OpenVPN to system!"
    else
        echo "###### To Connect to the VPN run the command $command ######"
        exit 1
    fi
fi

sudo mkdir -p /opt/OpenVPN
sudo cp -r * /opt/OpenVPN
sudo touch /opt/OpenVPN/ovpn_app.conf
touch "/home/$current_user/.local/share/applications/OpenVPN.desktop"
sudo chmod -R 777 /opt/OpenVPN/
chmod 777 "/home/$current_user/.local/share/applications/OpenVPN.desktop"

cat << EOM | sudo tee -a "/opt/OpenVPN/ovpn_app.conf" >/dev/null
## ovpn_app.conf
## The name of the Commands (
$command
)
EOM

cat << EOM | sudo tee -a "/home/$current_user/.local/share/applications/OpenVPN.desktop" >/dev/null
[Desktop Entry]
Type=Application
Name=OpenVPN
Comment=OpenVPN
Icon=/opt/OpenVPN/Images/openvpn.png
Exec=/opt/OpenVPN/OpenVPN
Terminal=false
EOM

echo "###### To Connect to the VPN run the command $command start ######"

