# Introduction
The idea behind this is to create a solution which performs the following:

- Local backup for all devices in my house (phone, laptop, desktop) for all users
- Remote / off site copy of this backup
- VPN to allow connectivity from anywhere
- Server which can run docker / websites / etc
- OwnCloud / NextCloud to allow applications to be run

More importantly - this allows me to control my own data, securely.

## Local backup
Remote storage is too slow, it needs to be local so it's as fast as LAN. 

## Remote backup
Should the worst happen (disk failure, flood, fire, etc) this neeeds a copy offsite. I want this to be achievable via cloning files to cloud storage, BLOB storage, external hard disk or another instance of this solution via the VPN connection and end to end encryption.

This can be done in a symbiotic solution where 2 people run the same solution, both of them dedicate a disk to the other persons backup. Starting with a small disk and increasing as necessary.

## VPN 
Allow me access to my files whilst on the move, not essential as it could synchronise only when on local network.

As I have a mistrust of public wifi - essentially this would allow me secure access to the internet as well.

## Server which can run docker, websites

I have need of adhoc stiuff - call me geeky.

## Owncloud / Next cloud

I presently pay per month for a NextCloud instance.  Enough said.

## Marketing / tracker blocking
It must run a PiHole - no questions.

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
