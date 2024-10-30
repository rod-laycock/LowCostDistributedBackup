#!/bin/bash

function usage () {
    APP_NAME=$(basename "$0")
    cat <<EOT

NAME

   $APP_NAME

USAGE

   $APP_NAME USER SSH_KEY_NAME

SYNOPSIS

$APP_NAME will create a new SSH Key with the username specified

EXAMPLE

The following will create a new key private key called my-key and a public key called my-key.pub

    $APP_NAME user my-key

The following will create a new key private key called my-other-key and a public key called my-other-key.pub in the directory /keys/my-other-key

    $APP_NAME user /keys/my-other-key

EOT
}

if [ "$1" = "" ] || [ "$2" = "" ]; then
    usage
    exit 0
else
    if ! type "ssh-keygen" > /dev/null; then
        echo "ssh-keygen command not found. Please install it."
        return -1
    else
        ssh-keygen -C $1 -f $2
        if [ ! -f "$2.pub" ]; then
            echo "Failed to create public key"
            exit -1
        fi
        
        PUBLIC_KEY=$(cat $2.pub)
        chmod 644 $2.pub
        chmod 600 $2

    fi
fi
