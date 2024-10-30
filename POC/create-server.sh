#!/bin/bash
multipass launch LocalServer --cloud-init server-init.yaml
multipass info LocalServer
localserver_ip=$(multipass info LocalServer | grep IPv4 | cut -b 17-)
ssh user@$localserver_ip -i multipass-ssh-key -o StrictHostKeyChecking=no