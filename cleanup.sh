#!/bin/bash

echo "TODO - Cleanup routine"
rm ./ssh-keys/user*
rm ./server-init/LocalServer*

./scripts/remove-vm.sh LocalServer