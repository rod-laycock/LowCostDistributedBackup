#!/bin/bash

function usage () {
    APP_NAME=$(basename "$0")
    cat <<EOT

NAME

   $APP_NAME

USAGE

   $APP_NAME -n MACHINE_NAME -u USER

SYNOPSIS

$APP_NAME will log into the SSH terminal on a Multipass virtual machine.

MACHINE NAME

The name of the machine you would like to log into, the IP will be pulled by calling `Multipass info`.

USER

The user of you wish to login as.

CLOUD_INIT_FILE

EOT
}

while getopts 'n:u:h' OPTION; do
  case "$OPTION" in
    n)
      MACHINE_NAME="$OPTARG"
      ;;
    u)
      LOGIN="$OPTARG"
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

# TODO - check to see if a machine / user were passed in.

# TODO - check to see if Multipass is running.
IPV4_ADDRESS=$(multipass info $MACHINE_NAME | grep IPv4 | cut -b 17-)

# TODO - check to see if we have an IP address
ssh $LOGIN@$IPV4_ADDRESS -i ./ssh-keys/$LOGIN -o StrictHostKeyChecking=no


