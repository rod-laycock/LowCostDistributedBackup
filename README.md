# Introduction
The idea behind this is to create a solution which performs the following:

- Backup/File Store
  - Local backup for all devices in my house (phone, laptop, tablet, desktop) for all users.
    - All files encrypted on a per user basis.
  - Remote / off site copy of this backup.
- File streaming
- VPN to allow connectivity from anywhere to stash, pull my files.
- Docker server to run apps, containers, etc.
- LAMP stack. Hey I'm a dev at heart!
- OwnCloud / NextCloud to allow applications to be run.
  - Could OC/NC connect and pull files from the store?
- SSH control.
- PiHole.

## Backup/File Store
The primary purpose for this is to regain control of my own data without submitting to Google, Microsoft or whoever else.

### Local backup
I have tried using a remote server to pull my files from, it's sometimes slow. We need this to be local so it's as fast as possible. 

### Remote backup
Should the worst happen (disk failure, flood, fire, theft, etc) we need a copy of my data offsite. I want this to be achievable via copying all files to cloud storage, BLOB storage, external hard disk or another instance of this solution via the a VPN connection and end to end encryption.  We should be able to set multiple locations (copy to Amazon, Ext Hard disk and another copy of this).

This should be done on a per user basis, as not all users have the same offsite storage requirements, e.g. Android users might want to clone to Google Drive, Apple users to iCloud.

Cloning to another version of this can be done in a symbiotic solution where 2 people run the same solution, both of them dedicate a disk to the other persons backup. Starting with a small disk and increasing as necessary.

![Symbiotic Backup](symbioticbackup.png)

## File Streaming
I don't pay for a TV license, as I don't watch British TV. So all my entertainment is done through streaming services, but if the Internet goes down, I'm stuck for things to watch.

I'd like a library of films, etc I can watch without the need for Internet access.

## VPN 
Allow me access to my files whilst on the move, not essential as it could synchronise only when on local network.

As I have a mistrust of public wifi - essentially this would allow me secure access to the internet as well.

Either way - the symbiotic solution must use VPN to synchronise files.

## Server which can run docker, websites

I have need of adhoc stiuff - call me geeky.

## Owncloud / Next cloud

I presently pay per month for a NextCloud instance.  Enough said.

## Marketing / tracker blocking
It must run a PiHole to avoid tracking and other marketing bullshit - no questions, this is a must.

# Proof of Concept

So I am doing a POC using Ubuntu and [Multipass](https://multipass.run/). Start by installing Multipass to allow us to stand up / stop servers pretty quickly

    $ sudo snap install multipass


Now we have Multipass, I have added a public / private key pair into the POC folder of this project.

> Username:  user
> 
> Password:  

Thats right - there is no password, secure I know, but I wouldnt put this into production.

Now I have created public/private keys for the user and a config yaml file - so let's fire up the server using:

    $ multipass launch -n LocalServer --cloud-init server-init.yaml
    $ multipass launch -n RemoteServer --cloud-init server-init.yaml
    

If you need any help with Multipass commands, check out their [documentation](https://multipass.run/docs). 

Once we have the servers up and running we will need the IP addresses.

    $ multipass list

will give you something like the following:

    Name                    State             IPv4             Image
    LocalServer             Running           10.61.187.229    Ubuntu 22.04 LTS
    RemoteServer            Running           10.61.187.177    Ubuntu 22.04 LTS

The IP address is right there, 3rd column.

Now we can connect to it using the following:

    $ ssh user@<IP ADDRESS> -i multipass-ssh-key -o StrictHostKeyChecking=no

This will then log you into the Ubuntu 22.04 server.

## Next Steps
Using the --cloud-init file format, we can initialise users, groups, install packages, etc.  This can then allow you to play with the configuration.

## Next Next Steps

Once we have it working in a POC, we want to scale it so it's usable:

- Create a VM image
- Create an ISO
- Create a set of scripts you can amend and run once a suitable OS has been procured - we don't want to limit you to just Ubuntu.


# Conmponents
A computer
- Ultra low power to run 24x7 or shutdown at certain times and startup at certain times.

Looking at one of these as it takes 1..9 watts of power when in use:

https://www.odroid.co.uk/H3-Plus

Hard disk(s)
- One for the OS, fast
- One for the local backup
- One for the backup of the twin system
Operating System - Ubuntu Server, it's small and fast.
Software - This wil be a combination of things, configured properly to allow all this to work.
 - Docker
 - Nextcloud / Owncloud instance

 

https://www.odroid.co.uk/H3-Plus
