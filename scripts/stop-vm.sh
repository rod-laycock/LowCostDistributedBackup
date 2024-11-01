#!/bin/bash

function usage() {
    APP_NAME=$(basename $0)
    cat<<EOT
NAME
   ${APP_NAME}

SYSNOPSIS

   ${APP_NAME}  [VM_NAME]

DESCRIPTION

Stops and unmounts the VM_NAME in multipass.

If the VM_NAME is "all" then all VMs will be stopped and unmounted.

EOT
}


if [ "$1" = "?" ]; then
    usage()
    return 0
fi

if [ "$1" = "" ]; then
    MACHINE=$(multipass get client.primary-name)
else
    MACHINE="$1"
fi
multipass unmount $MACHINE
multipass stop $MACHINE
multipass info $MACHINE