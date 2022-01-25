#!/bin/bash
clear
echo "ISW"
echo "Fan control tool for MSI gaming series laptops"
echo "installing isw v1.10"
echo "battery_charging_threshold is set to 80%"
echo "Required root previlages."
sudo cp ./etc/isw.conf /etc/isw.conf
echo "."
sudo cp ./etc/modprobe.d/isw-ec_sys.conf /etc/modprobe.d/isw-ec_sys.conf
echo "."
sudo cp ./etc/modules-load.d/isw-ec_sys.conf /etc/modules-load.d/isw-ec_sys.conf
echo "."
sudo cp ./usr/lib/systemd/system/isw@.service /usr/lib/systemd/system/isw@.service
echo "."
sudo cp ./usr/lib/systemd/system/isw@.service /usr/lib/systemd/system/isw@.service
echo "."
sudo cp ./isw /usr/bin/isw
sudo modprobe ec_sys write_support=1
echo "done!"
echo "Now please disable secureboot from BIOS to this application to work."
echo "Applying systemctl for isw@.service."
echo "Please choose laptop series"
cat ./devices.txt
echo "Enter device id ( contained within [] ):  "
read devid
echo "systemctl enable isw@".$devid.".service">service.sh
chmod +x ./service.sh
sudo ./service.sh
echo "Restarting Now..."
sudo reboot