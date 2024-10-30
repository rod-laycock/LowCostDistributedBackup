#!/bin/bash

function usage () {
    APP_NAME=$(basename "$0")
    cat <<EOT

NAME

   $APP_NAME

USAGE

   $APP_NAME -n MACHINE_NAME [-s MACHINE_SIZE] [-v UBUNTU_VERSION] [-i CLOUD_INIT_FILE] [-k PRIVATE_SSH_KEY_NAME]

SYNOPSIS

$APP_NAME will start a Multipass virtual machine or
create it if it does not exist. It looks for a cloud init
YAML file using the machine name followed by "-init.yaml".

MACHINE SIZES

The machine sizes are based on AWS T4g series of machine
sizes.  Sizes include nano, micro, small, medium, large,
xlarge and 2xlarge.  The CPU count and memory settings
see https://aws.amazon.com/ec2/instance-types/ or read
the source file for $APP_NAME.

IMAGE

A specific image we'll be using. The current use case is to 
indicate a specific version of ubuntu.

CLOUD_INIT_FILE

The location of a Cloud Init file

PRIVATE_SSH_KEY_NAME

If this is specified, it will attempt to obtain the IP and log 
you onto the SSH instance of the server.

EXAMPLE

In this example we'll start an machine name "invenio" and
if it does not exist it will be created with a size of xlarge
utilizing ubuntu 20.04 (focal).

    $APP_NAME invenio xlarge focal

EOT
}

# Get parameters from the command line arguments
while getopts 'n:s:v:i:k:h' OPTION; do
  case "$OPTION" in
    n)
      P_MACHINE_NAME="$OPTARG"
      ;;
    s)
      P_MACHINE_SIZE="$OPTARG"
      ;;
    v)
      P_UBUNTU_VERSION="$OPTARG"
      ;;
    i)
      P_INIT_FILE="$OPTARG"
      ;;
    k)
        P_KEY_FILE="$OPTARG"
      ;;
    h)
        usage
        exit 0
        ;;
    ?)
      usage
      exit 0
      ;;
  esac
done
shift "$(($OPTIND -1))"

#
# Check if we're providing a machine name or using the existing primary name
#
if [ "$P_MACHINE_NAME" = "" ]; then
    # MACHINE=$(multipass get client.primary-name)
    usage
    exit 0
else
    MACHINE="$P_MACHINE_NAME"
fi

SERVER_INIT="./server-init"


#
# Machine size is based on AWS T4g ARM machine sizes
# See https://aws.amazon.com/ec2/instance-types/
#
if [ "$P_MACHINE_SIZE" = "" ]; then
    MACHINE_SIZE="--cpus 2 --memory 8G --disk 50G"
else
    case "$2" in
        nano)
        MACHINE_SIZE="--cpus 2 --memory 512M --disk 50G"
        ;;
        micro)
        MACHINE_SIZE="--cpus 2 --memory 1G --disk 50G"
        ;;
        small)
        MACHINE_SIZE="--cpus 2 --memory 2G --disk 50G"
        ;;
        medium)
        MACHINE_SIZE="--cpus 2 --memory 4G --disk 50G"
        ;;
        large)
        MACHINE_SIZE="--cpus 2 --memory 8G --disk 50G"
        ;;
        xlarge)
        MACHINE_SIZE="--cpus 4 --memory 16G --disk 100G"
        ;;
        2xlarge)
        MACHINE_SIZE="--cpus 8 --memory 32G --disk 150G"
        ;;
    esac
fi

#
#Third cli option is what image we're using
#
if [ "$P_UBUNTU_VERSION" != "" ]; then
	IMAGE="$P_UBUNTU_VERSION"
else
	IMAGE="jammy"
fi

#
# Figure out if we're launching, starting or machine is already active
#
if multipass list | grep "$MACHINE" >/dev/null; then
    VM_STATE=$(multipass info "$MACHINE" | grep -i State)
    case "${VM_STATE}" in
        *Stopped)
        multipass start "$MACHINE"
        ;;
        *Running)
        echo "$MACHINE is already running"
        ;;
        *)
        echo "VM is $VM_STATE, wait and run again"
        exit 1
    esac
else 
    if [ "$P_INIT_FILE" != "" ]; then
        CLOUD_INIT="$P_INIT_FILE"
        if [ ! -f "$CLOUD_INIT" ]; then
            echo "Cannot locate cloud init file $CLOUD_INIT"
            echo "Please specify a valid cloud init file."
            exit -1
        fi
    else
        CLOUD_INIT="$SERVER_INIT/$MACHINE.yaml"
        if [ ! -f "$CLOUD_INIT" ]; then
            CLOUD_INIT="$SERVER_INIT/server-init-master.yaml"
            if [ ! -f "$CLOUD_INIT" ]; then
                echo "Cannot locate any of the following server init files in $SERVER_INIT/"
                echo "   - $MACHINE.yaml"
                echo "   - server-init-master.yaml"
                echo ""
                echo "Please create one of them so they can be used in the above order."
                exit -1
            else
                cp $SERVER_INIT/server-init-master.yaml $SERVER_INIT/$MACHINE.yaml
                CLOUD_INIT="$SERVER_INIT/$MACHINE.yaml"
            fi
        fi
    fi
    echo "Launching $MACHINE";
    multipass -v launch \
		--name "${MACHINE}" \
        --cloud-init "${CLOUD_INIT}" \
		$MACHINE_SIZE \
		$IMAGE
	echo "Restart ${MACHINE}"
    multipass restart "${MACHINE}"
fi

#
# If a src directory exists mount it
#
#if [ -d src ]; then
#  multipass mount src "$MACHINE:src"
#fi

#
# If a Sites directory exists mount it
#
#if [ -d Sites ]; then
#  multipass mount Sites "$MACHINE:Sites"
#fi

#
# Include staff-favorites.bash if exists - TODO: Look at this?
#
# if [ -f scripts/staff-favorites.bash ]; then
#   multipass transfer scripts/staff-favorites.bash "$MACHINE:."
# fi
#if [ -f scripts/setup-self-signed-SSL-certs.bash ]; then
#  multipass transfer scripts/setup-self-signed-SSL-certs.bash "$MACHINE:."
#fi

# 
# Display state of machine
#
multipass info "$MACHINE"

if [ "$P_KEY_FILE" != "" ]; then
    LOCALSERVER_IP=$(multipass info $MACHINE | grep IPv4 | cut -b 17-)
    USER=$(cat $P_KEY_FILE.pub | cut -d ' ' -f 3)
    ssh $USER@$LOCALSERVER_IP -i $P_KEY_FILE -o StrictHostKeyChecking=no
fi
