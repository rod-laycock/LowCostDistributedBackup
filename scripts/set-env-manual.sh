#!/bin/bash

until [ $USERNAME != "" ]
do
    zenity --entry --title="Local User" --text="Enter a local username to create on the machine."
    USERNAME=$?
done

until [ $MACHINE_NAME != "" ]
do
    zenity --entry --title="Machine Name" --text="Enter name of the virtual machine to create."
    MACHINE_NAME=$?
done

zenity --list --title="Choose a pre-defined machine size" --column="Size" --column="Description" "none" "Manually specify the machine" "nano" "2 CPUs, 512Mb RAM, 50Gb Disk" "micro" "2 CPUs, 1Gb RAM, 50Gb Disk" "small" "2 CPUs, 2Gb RAM, 50Gb Disk" "medium" "2 CPUs, 4Gb RAM, 50Gb Disk" "large" "2 CPUs, 8Gb RAM, 50Gb Disk" "xlarge" "4 CPUs, 16Gb RAM, 100Gb Disk" "2xlarge" "8 CPUs, 32Gb RAM, 150Gb Disk"
MACHINE_SIZE=$?

echo $MACHINE_SIZE
if [ $MACHINE_SIZE == "0" ]; then

    zenity --forms --add-entry="CPUs" --add-entry="RAM (in Gb)" --add-entry="Disk Space (in Gb)" --separator=";"
    MANUAL_MACHINE=$?
    MACHINE_CPU=$(echo $MANUAL_MACHINE | cut -d ";" -f 1)
    MACHINE_RAM=$(echo $MANUAL_MACHINE | cut -d ";" -f 2)
    
    if [ $MACHINE_RAM = "0.5" ]; then
        MACHINE_RAM="512M"
    else
        MACHINE_RAM="${MACHINE_RAM}G"
    fi
    
    MACHINE_DISK=$(echo $MANUAL_MACHINE | cut -d ";" -f 3)
    MACHINE_DISK="${MACHINE_DISK}G"
fi

zenity --list --title="Choose a version of ubuntu to use" --column="Codename" --column="Version" "Noble" "Numbat 24.04" "Jammy" "Jellyfish 22.04" "Focal" "Fossa 20.04" 
UBUNTU_VERSION=$?

exit 0