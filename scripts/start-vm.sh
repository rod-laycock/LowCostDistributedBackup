#!/bin/bash

function usage () {
    APP_NAME=$(basename "$0")
    cat <<EOT

NAME

   $APP_NAME

USAGE

   $APP_NAME -n MACHINE_NAME [-s MACHINE_SIZE] [-i IMAGE] [-c CLOUD_INIT_FILE]

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


EXAMPLE

In this example we'll start an machine name "invenio" and
if it does not exist it will be created with a size of xlarge
utilizing ubuntu 20.04 (focal).

    $APP_NAME invenio xlarge focal

EOT
}

# Get parameters from the command line arguments
while getopts 'n:s:i:c:h' OPTION; do
  case "$OPTION" in
    n)
      MACHINE_NAME="$OPTARG"
      ;;
    s)
      MACHINE_SIZE="$OPTARG"
      ;;
    i)
      IMAGE="$OPTARG"
      ;;
    c)
      CLOUD_INIT_FILE="$OPTARG"
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

echo "Machine Name: $MACHINE_NAME"
echo "Machine Size: $MACHINE_SIZE"
echo "Machine Image: $IMAGE"
echo "Cloud Image File: $CLOUD_INIT_FILE"


#
# Check if we're providing a machine name or using the existing primary name
#
if [ "$MACHINE_NAME" = "" ]; then
    usage
    exit 0
fi

#
# Machine size is based on AWS T4g ARM machine sizes
# See https://aws.amazon.com/ec2/instance-types/
#
if [ "$MACHINE_SIZE" = "" ]; then
    MACHINE_SIZE="--cpus 2 --memory 8G --disk 50G"
else
    case "$MACHINE_SIZE" in
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
if [ "$IMAGE" = "" ]; then
	IMAGE="jammy"
fi

#
# Figure out if we're launching, starting or machine is already active
#
if multipass list | grep "$MACHINE_NAME" >/dev/null; then
    VM_STATE=$(multipass info "$MACHINE_NAME" | grep -i State)
    case "${VM_STATE}" in
        *Stopped)
        multipass start "$MACHINE_NAME"
        ;;
        *Running)
        echo "$MACHINE_NAME is already running"
        ;;
        *)
        echo "VM is $VM_STATE, wait and run again"
        exit 1
    esac
else 
    echo "Launching $MACHINE_NAME";
    multipass -v launch \
		--name "${MACHINE_NAME}" \
        --cloud-init "${CLOUD_INIT_FILE}" \
		$MACHINE_SIZE \
		$IMAGE
	  echo "Restart ${MACHINE_NAME}"
    multipass restart "${MACHINE_NAME}"
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
# Include install-software.sh if exists
#
if [ -f scripts/install-software.sh ]; then
  multipass transfer scripts/install-software.sh "$MACHINE_NAME:."
fi
#if [ -f scripts/setup-self-signed-SSL-certs.bash ]; then
#  multipass transfer scripts/setup-self-signed-SSL-certs.bash "$MACHINE_NAME:."
#fi

# 
# Display state of machine
#
multipass info "$MACHINE_NAME"
