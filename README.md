# Introduction
The idea behind this is to create a solution which performs the following:

- Local backup for all devices in my house (phone, laptop, desktop) for all users
- Remote / off site copy of this backup
- VPN to allow connectivity from anywhere
- Server which can run docker / websites / etc
- OwnCloud / NextCloud to allow applications to be run

More importantlt - this allows me to control my own data, securely.


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
