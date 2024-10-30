#!/bin/bash

# Function to pull values back from the .secrets file
get_secret() {
    SECRET=$(cat .secrets | grep $1 | cut -d '=' -f 2)
}

# Define the folders to be used.
SCRIPTS_DIR="./scripts"
SSH_KEYS_DIR="./ssh-keys"
SERVER_INIT_DIR="./server-init"

# Define the master init file
MASTER_INIT_FILE="$SERVER_INIT_DIR/server-init-master.yaml"

# Read Secrets from .secrets file and set up environment variables
get_secret "@USERNAME"
USERNAME=$SECRET

get_secret "@WHITEBOARD_SECRET"
WHITEBOARD_SECRET=$SECRET

get_secret "@REDIS_PASSWORD"
REDIS_PASSWORD=$SECRET

get_secret "@ONLYOFFICE_SECRET"
ONLYOFFICE_SECRET=$SECRET

get_secret "@TALK_INTERNAL_SECRET"
TALK_INTERNAL_SECRET=$SECRET

get_secret "@COLLABORA_SECCOMP_POLICY"
COLLABORA_SECCOMP_POLICY=""

get_secret "@DATABASE_PASSWORD"
DATABASE_PASSWORD=$SECRET

get_secret "@NEXTCLOUD_PASSWORD"
NEXTCLOUD_PASSWORD=$SECRET

# Define non secret Environment Variables
MACHINE_NAME="LocalServer"
MACHINE_SIZE="xlarge"
UBUNTU_VERSION="jammy"
CLOUD_INIT_FILE="$SERVER_INIT_DIR/$MACHINE_NAME-init.yaml"
PRIVATE_SSH_KEY_NAME="$USER"
PUBLIC_SSH_KEY="$USER.pub"

NC_DOMAIN="nextcloud.local"
TIMEZONE="Europe/London"

APACHE_IP_BINDING=$(multipass info $MACHINE | grep IPv4 | cut -b 17-)
APACHE_MAX_SIZE=100
APACHE_PORT=80

COLLABORA_DICTIONARIES=/data/dictionaries

NEXTCLOUD_ADDITIONAL_APKS=""
NEXTCLOUD_ADDITIONAL_PHP_EXTENSIONS=""
NEXTCLOUD_DATADIR=/data/nextcloud
NEXTCLOUD_MAX_TIME=60
NEXTCLOUD_MEMORY_LIMIT=512
NEXTCLOUD_MOUNT=""
NEXTCLOUD_STARTUP_APPS=""
NEXTCLOUD_TRUSTED_CACERTS_DIR=/data/ca-certs
NEXTCLOUD_UPLOAD_LIMIT=100

TALK_PORT=19302

# DO NOT EDIT PAST THIS POINT

# Create SSH Keys
$SCRIPTS_DIR/create-keys.sh $USERNAME ./ssh-keys/$PRIVATE_SSH_KEY_NAME

# Check to see if we have an init file already, if so delete it.
if [ -f $CLOUD_INIT_FILE ]; then
    rm $CLOUD_INIT_FILE
fi

# Clone the master init script
if [ -f $MASTER_INIT_FILE ]; then
    cp $MASTER_INIT_FILE $CLOUD_INIT_FILE
else
    echo "Cannot locate the master init file - $MASTER_INIT_FILE"
    exit -2
fi

# Import the user and SSH Keys into the init script
if [ -f "$SSH_KEYS_DIR/$PUBLIC_SSH_KEY" ]; then
    PUBLIC_KEY=$(cat $SSH_KEYS_DIR/$PUBLIC_SSH_KEY)
    tee -a $CLOUD_INIT_FILE <<EOF
# Define users
#  Username: $USERNAME
users:
  - default
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
"$SCRIPTS_DIR/start-vm.sh -n $MACHINE_NAME -s $MACHINE_SIZE -v $UBUNTU_VERSION -i $CLOUD_INIT_FILE -k $SSH_KEYS_DIR/$PUBLIC_SSH_KEY"

# Log onto server
# if [ "$P_KEY_FILE" != "" ]; then
#     LOCALSERVER_IP=$(multipass info $MACHINE | grep IPv4 | cut -b 17-)
#     USER=$(cat $P_KEY_FILE.pub | cut -d ' ' -f 3)
#     ssh $USER@$LOCALSERVER_IP -i $P_KEY_FILE -o StrictHostKeyChecking=no
# fi