#!/bin/bash

set -E
trap '[ "$?" -ne -1 ] || exit -1' ERR

function usage() {
    APP_NAME=$(basename $0)
    cat<<EOT
NAME
   ${APP_NAME}

SYSNOPSIS

   ${APP_NAME}  (automatic | auto | a) | (manual | man | m)

DESCRIPTION

Runs the installation script in either "automatic" or "manual" mode.

AUTOMATIC mode must have a .secrets file in the root folder.

TODO: Cite example

MANUAL mode will ignore the .secrets file and ask a set of guided questions

EOT
}

# Set colours
ERROR='\e[0;31m' # Red
WARN='\e[0;33m' # Yellow
NC='\e[0m' # No Color

TEST_STRING="Test"

# Define the folders to be used.
echo "Initialising the script"
ROOT_DIR=$(pwd)
SCRIPTS_DIR="$ROOT_DIR/scripts"
SSH_KEYS_DIR="$ROOT_DIR/ssh-keys"
SERVER_INIT_DIR="$ROOT_DIR/server-init"

# Decide if this is manual or automatic install
case $1 in
    a | auto | automatic)
    source $SCRIPTS_DIR/set-env-automatic.sh || exit 1
    ;;
    m | man | manual)
    source $SCRIPTS_DIR/set-env-manual.sh || exit 1
    ;;
    *)
    usage
    exit 0
    ;;
esac


# Define the master init file
MASTER_INIT_FILE="$SERVER_INIT_DIR/server-init-master.yaml"

# Define non secret Environment Variables
CLOUD_INIT_FILE="$SERVER_INIT_DIR/$MACHINE_NAME-init.yaml"
PRIVATE_SSH_KEY_NAME="$SSH_KEYS_DIR/$USERNAME"
PUBLIC_SSH_KEY="$SSH_KEYS_DIR/$USERNAME.pub"

echo "Setting Next Cloud domain"
NC_DOMAIN="nextcloud.local"

echo "Setting timezone"
TIMEZONE="Europe/London"

APACHE_IP_BINDING=$(multipass info $MACHINE | grep IPv4 | cut -b 17-)
APACHE_MAX_SIZE=100
APACHE_PORT=80

COLLABORA_DICTIONARIES="/data/dictionaries"

NEXTCLOUD_ADDITIONAL_APKS=""
NEXTCLOUD_ADDITIONAL_PHP_EXTENSIONS=""
NEXTCLOUD_DATADIR="/data/nextcloud"
NEXTCLOUD_MAX_TIME=60
NEXTCLOUD_MEMORY_LIMIT=512
NEXTCLOUD_MOUNT=""
NEXTCLOUD_STARTUP_APPS=""
NEXTCLOUD_TRUSTED_CACERTS_DIR="/data/ca-certs"
NEXTCLOUD_UPLOAD_LIMIT=100

TALK_PORT=19302

# DO NOT EDIT PAST THIS POINT

# Create SSH Keys
echo "Creating SSH Key"
$SCRIPTS_DIR/create-keys.sh $USERNAME $PRIVATE_SSH_KEY_NAME

# Check to see if we have an init file already, if so delete it.
if [ -f $CLOUD_INIT_FILE ]; then
    echo "Removing existing Cloud Init configuration"
    rm $CLOUD_INIT_FILE
fi

# Clone the master init script
if [ -f $MASTER_INIT_FILE ]; then
    echo "Cloning Master Cloud Init configuration "
    cp $MASTER_INIT_FILE $CLOUD_INIT_FILE
else
    echo "Cannot locate the master init file - $MASTER_INIT_FILE"
    exit -2
fi

# Import the user and SSH Keys into the init script
if [ -f "$PUBLIC_SSH_KEY" ]; then

    echo "Adding SSH Key to Cloud Init configuration"
    PUBLIC_KEY=$(cat $PUBLIC_SSH_KEY)
    tee -a $CLOUD_INIT_FILE <<EOF
# Define users
#  Username: $USERNAME
users:
  - name: $USERNAME
    groups:
      - sudo
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
    - $PUBLIC_KEY
EOF
else
    echo "Cannot locate public ssh key file."
    exit -2
fi

# Create Server
echo "Creating server instance"
#$("$SCRIPTS_DIR/start-vm.sh -n $MACHINE_NAME -s $MACHINE_SIZE -i $UBUNTU_VERSION -c $CLOUD_INIT_FILE")

$SCRIPTS_DIR/start-vm.sh -n $MACHINE_NAME -s $MACHINE_SIZE -i $UBUNTU_VERSION -c $CLOUD_INIT_FILE

# Log onto server
# if [ "$P_KEY_FILE" != "" ]; then
#     LOCALSERVER_IP=$(multipass info $MACHINE | grep IPv4 | cut -b 17-)
#     USER=$(cat $P_KEY_FILE.pub | cut -d ' ' -f 3)
#     ssh $USER@$LOCALSERVER_IP -i $P_KEY_FILE -o StrictHostKeyChecking=no
# fi