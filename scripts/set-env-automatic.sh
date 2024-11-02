#!/bin/bash

# Function to pull values back from the .secrets file
get_secret() {
    # Find the value in the .secrets file
    SECRET=$(cat $ROOT_DIR/.secrets | grep $1)
    
    # Check to see if it is prefixed with a #, if so it's a comment
    if [[ $SECRET =~ "#" ]]; then
        unset SECRET
    else
        SECRET=$(cat $ROOT_DIR/.secrets | grep $1 | cut -d '=' -f 2)
    fi
}

if [ ! -f $ROOT_DIR/.secrets ]; then
    echo -e "${ERROR}ERROR: ${NC} No .secrets file found in the root folder - please create one or run the installation in manual mode.\n"
    exit 1
fi
    
# Read Secrets from .secrets file and set up environment variables
echo "Loading secrets from file"

get_secret "@USERNAME"
USERNAME=$SECRET

if [[ -z "${USERNAME}" ]]; then
    echo -e "${ERROR} ERROR: ${NC} no USERNAME specified in .secrets file - please create one or run the installation in manual mode.\n"
    exit 1
fi

get_secret "@MACHINE_NAME"
MACHINE_NAME=$SECRET
if [[ -z "${MACHINE_NAME}" ]]; then
    echo -e "${ERROR} ERROR: ${NC} no MACHINE_NAME specified in .secrets file - please create one or run the installation in manual mode.\n"
    exit 1
fi

get_secret "@MACHINE_SIZE"
MACHINE_SIZE=$SECRET

if [[ -z "${MACHINE_SIZE}" ]]; then

    get_secret "@MACHINE_CPU"
    MACHINE_CPU=$SECRET

    if [[ -z "${MACHINE_CPU}" ]]; then
        echo -e "${ERROR} ERROR: ${NC} no MACHINE_CPU specified in .secrets file - please create them, or specify a MACHINE_SIZE or run the installation in manual mode.\n"
        exit 1
    fi

    get_secret "@MACHINE_RAM"
    MACHINE_RAM=$SECRET

    if [[ -z "${MACHINE_RAM}" ]]; then
        echo -e "${ERROR} ERROR: ${NC} no MACHINE_RAM specified in .secrets file - please create them, or specify a MACHINE_SIZE or run the installation in manual mode.\n"
        exit 1
    fi

    get_secret "@MACHINE_DISK"
    MACHINE_DISK=$SECRET

    if [[ -z "${MACHINE_DISK}" ]]; then
        echo -e "${ERROR} ERROR: ${NC} no MACHINE_DISK specified in .secrets file - please create them, or specify a MACHINE_SIZE or run the installation in manual mode.\n"
        exit 1
    fi
fi

if [[ -z "${UBUNTU_VERSION}" ]]; then
    UBUNTU_VERSION=$(cat /etc/os-release | grep "UBUNTU_CODENAME" | cut -d '=' -f 2)
    echo -e "${WARN} WARN: ${NC} no UBUNTU_VERSION specified in .secrets file, defaulting to $UBUNTU_VERSION.\n"
fi

exit 0
