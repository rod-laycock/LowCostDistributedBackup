#!/bin/bash

function usage () {
    APP_NAME=$(basename "$0")
    cat <<EOT

NAME

   $APP_NAME

USAGE

   $APP_NAME -n MACHINE_NAME -u USER

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

while getopts 'n:u:h' OPTION; do
  case "$OPTION" in
    n)
      MACHINE_NAME="$OPTARG"
      ;;
    u)
      USER="$OPTARG"
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

IPV4_ADDRESS=$(multipass info $MACHINE_NAME | grep IPv4 | cut -b 17-)

ssh $USER@$IPV4_ADDRESS -i ./ssh-keys/$USER -o StrictHostKeyChecking=no


