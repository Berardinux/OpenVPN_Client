#!/bin/bash

echo "# Are you ready to install OpenVPN? (Y/N) #"
read -r one

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

clear

echo "########## What is your .ovpn file called? ###############"
echo "# Remember to include the .ovpn at the end of the file!! #"
read -r ovpn
clear

location=$(sudo find / -name $ovpn 2>/dev/null)

sudo mv "$location" "/etc/openvpn/client/$ovpn"
clear

echo "# What would you like to call your OpenVPN command? #"
read -r command
clear

 
sudo touch "/usr/local/bin/$command"
sudo chmod 777 /usr/local/bin/$command
cat << 'EOM' | sudo tee -a "/usr/local/bin/$command" >/dev/null
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

if [ $# -eq 0 ]; then
    echo "Usage: {start/stop}"
    exit 1
fi

case "$1" in
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
echo "# What would you like the permissions to be for the .ovpn file? (Suggested = 660) #"
echo "#################### Read permission: Numeric value of 4 ##########################"
echo "################### Write permission: Numeric value of 2 ##########################"
echo "################### Execute permission: Numeric value of 1 ########################"
echo "############### Press (Enter) to use suggested permissions ########################"
read -r mod

if [ -z "$mod" ]; then
    sudo chmod 660 "/etc/openvpn/client/$ovpn"
else
    sudo chmod "$mod" "/etc/openvpn/client/$ovpn"
fi

clear

echo "###### To Connect to the VPN run the command $command ######"
