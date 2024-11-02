#!/bin/bash

#
# This file adds some Staff favorites developer tools and 
# optimization including, e.g. emacs, tcsh.
#
sudo apt-get update

sudo nextcloud.manual-install user nextcloud
sudo nextcloud.occ config:system:set trusted_domains 1 --value= example.com
sudo ufw allow 80,443/tcp

