#!/bin/bash

sudo -v
sudo mv ~/Downloads/cpadu.tar.gz /opt/cpadu.tar.gz || echo "Package not found, please check your downloads folder and try again."
cd /opt
sudo tar -xzf cpadu.tar.gz
cd ~/Desktop


cat <<-EOF > ~/Desktop/cyberaudit.desktop
[Desktop Entry]
Type=Application
Name=cyberaudit
Exec=/opt/cpadu/cp_auditor11.sh
Icon=/opt/cpadu/cyberpatriot_icon.png
Terminal=true
EOF
sudo chmod u+x ~/Desktop/cyberaudit.desktop


cat <<-EOF > ~/Desktop/faillock.desktop
[Desktop Entry]
Type=Application
Name=faillock
Exec=/opt/cpadu/faillock.sh
Icon=/opt/cpadu/cyberpatriot_icon.png
Terminal=true
EOF
sudo chmod u+x ~/Desktop/faillock.desktop

if ! command -v locate >/dev/null 2>&1; then
    sudo apt update &>/dev/null
    sudo apt install -y plocate &>/dev/null && sudo updatedb &>/dev/null || echo "An error occurred."
fi

echo "Installation successfull!"
printf "Auto-removal in 3..."
sleep 1
printf "\r%-80s" "Auto-removal in 2..."
sleep 1
printf "\r%-80s" "Auto-removal in 1..."
sleep 1
printf "\r%-80s" "Auto-removal in 0..."
sleep 1
printf "\r%-80s" ""
echo
sudo rm /opt/cpadu.tar.gz
cd ~/Downloads
rm -- "$0"


