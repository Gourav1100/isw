#!/bin/bash
if [ ! -f run_post ]; then
    sudo echo "ISW"
    echo "Fan control tool for MSI gaming series laptops"
    echo "battery_charging_threshold is set to 80%"
    echo "Looking for previous installation..."
    similar_service=$(sudo systemctl | grep isw@ | cut -d ' ' -f2)
    if [ "$similar_service" != "" ]; then
        echo "Deleting $similar_service"
        sudo systemctl stop "$similar_service"
        sudo systemctl disable "$similar_service"
        sudo systemctl daemon-reload
        sudo systemctl reset-failed
    fi
    echo "Installing dependencies..."
    sudo cp ./etc/isw.conf /etc/isw.conf
    echo "/etc/isw.conf"
    sudo cp ./etc/modprobe.d/isw-ec_sys.conf /etc/modprobe.d/isw-ec_sys.conf
    echo "/etc/modprobe.d/isw-ec_sys.conf"
    sudo cp ./etc/modules-load.d/isw-ec_sys.conf /etc/modules-load.d/isw-ec_sys.conf
    echo "/etc/modules-load.d/isw-ec_sys.conf"
    sudo cp ./usr/lib/systemd/system/isw@.service /usr/lib/systemd/system/isw@.service
    echo "/usr/lib/systemd/system/isw@.service"
    sudo cp ./isw /usr/bin/isw
    echo "/usr/bin/isw"


    ec_sys_failure=0
    echo "Checking for ec_sys module compatibility..."
    # check if linux kernel version is greater then 5.11 then set flag else run the command
    if [ "$(uname -r | cut -d '.' -f1)" -gt 5 ] || ([ "$(uname -r | cut -d '.' -f1)" -eq 5 ] && [ "$(uname -r | cut -d '.' -f2)" -ge 11 ]); then
        echo "Linux kernel version is greater than 5.11."
        echo "Checking for ec_sys module..."
        if [ ! -f /sys/kernel/debug/ec/ec0/io ]; then
            echo "ec_sys module not found."
            ec_sys_failure=1
        else
            echo "ec_sys module found."
            sudo modprobe ec_sys write_support=1
            touch run_post
        fi
    else
        echo "Linux kernel version is less than 5.11."
        echo "Checking for ec_sys module..."
        if [ ! -f /sys/kernel/debug/ec/ec0/io ]; then
            echo "ec_sys module not found. Please install ec_sys module."
            ec_sys_failure=1
        else
            echo "ec_sys module found."
            sudo modprobe ec_sys write_support=1
            touch run_post
        fi
    fi
    if [ "$ec_sys_failure" -eq 1 ]; then
        current_dir=$(pwd)
        cd /opt
        if [-d acpi_ec]; then
            sudo rm -rf acpi_ec
        fi
        sudo git clone https://github.com/musikid/acpi_ec.git
        cd acpi_ec
        sudo ./uninstall.sh &>/dev/null
        sudo apt remove -y acpi-ec 2>/dev/null
        sudo apt install dkms
        sudo ./install.sh
        sudo ./scripts/keys-setup.sh
        touch $current_dir/run_post
        cat install.sh | grep 'VERSION=\"' | cut -d '=' -f2 | cut -d '"' -f2 >> $current_dir/run_post
    fi 
    sudo reboot
else
    version=$(cat run_post)
    rm run_post
    kernel_version=$(uname -r)
    # if version is empty then skip these steps
    if [[ "$version" != "" ]]; then
        sudo /usr/src/linux-headers-"$kernel_version"/scripts/sign-file sha512 /opt/acpi_ec/scripts/mok.priv /opt/acpi_ec/scripts/mok.der /var/lib/dkms/acpi_ec/"$version"/"$kernel_version"/x86_64/module/acpi_ec.ko
        sudo /usr/src/linux-headers-"$kernel_version"/scripts/sign-file sha512 /opt/acpi_ec/scripts/mok.priv /opt/acpi_ec/scripts/mok.der /usr/lib/modules/"$kernel_version"/updates/dkms/acpi_ec.ko
    fi

    echo "Please choose laptop series"
    devices=$(cat devices.json)
    while true; do
        read -p "Enter device name: " device_name
        count=$(echo "$devices" | jq -r --arg name "$device_name" '[.devices[] | select(.model[] | contains($name))] | unique | length')
        echo "Found $count device id/s."
        if [ "$count" -eq 1 ]; then
            dev_id=$(echo "$devices" | jq -r --arg name "$device_name" '[.devices[] | select(.model[] | contains($name))] | unique | .[0].id')
            echo "Selecting $dev_id."
            break
        elif [ "$count" -gt 1 ]; then
            echo "Multiple devices found. Please choose one."
            echo "$devices" | jq -r --arg name "$device_name" '[.devices[] | select(.model[] | contains($name))] | unique | .[] | "\(.id) - \(.model)"'
        else
            echo "Device not found. Please try again."
        fi
    done
    echo "Applying systemctl for isw@$dev_id.service."
    sudo systemctl enable isw@"$dev_id".service
    sudo reboot
fi