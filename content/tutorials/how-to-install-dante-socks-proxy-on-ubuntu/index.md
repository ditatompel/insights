---
title: "How to Install and Configure Dante as Private SOCKS Proxy in Ubuntu"
description: "This article helps you setting up and configuring Dante as a private SOCKS proxy on Debian based Linux distribution."
# linkTitle:
date: 2023-11-10T19:56:43+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
# nav_icon:
#   vendor: bootstrap
#   name: toggles
#   color: '#e24d0e'
series:
#  - Tutorial
categories:
  - Privacy
  - Self-Hosted
  - SysAdmin
  - Networking
tags:
  - SOCKS
  - Proxy
  - Dante
images:
# menu:
#   main:
#     weight: 100
#     params:
#       icon:
#         vendor: bs
#         name: book
#         color: '#e24d0e'
authors:
  - jasmerah1966
---

This article helps you setting up and configuring **Dante** as a **private SOCKS proxy** (with authentication) on **Debian** based Linux distribution.

<!--more-->
---
[Dante](https://www.inet.no/dante/) is a _mature_ and stable **SOCKS proxy** developed by **Inferno Nettverk A/S proxy**. This article helps you installing **Dante** as your _**private SOCKS proxy**_ with _username_ and _password_ (`pam`) authentication system.

## Preparing system

Before starting, there are several prerequisites that must be met to follow this article:
- Comfortable using Linux terminal.
- A Linux server with a **Debian** based distribution.

Because what we are going to create is a *private proxy* which requires _username_ and _password_ authentication from a user account on the Linux system, we need to create a Linux user on the server which will be used for the authentication process.

```shell
# Create new user
sudo useradd -r -s /bin/false myproxyuser
# set the user password
sudo passwd myproxyuser
```

> _Note: Change `myproxyuser` above with the user you want to use for authentication._

## Install Dante server

Because **Dante** is a very mature and popular **SOCKS proxy**, you can easily install Dante server with the built-in Debian or Ubuntu package manager.

```shell
sudo apt install dante-server
systemctl status danted.service
```

After the installation process is complete, the system will automatically try to run _danted.service_, but the _service_ will be failed to run because there is no authentication method that must be configured.

## Configuring Dante server

Dante configuration file are located at `/etc/danted.conf`. There is an example of a configuration along with a very complete explanation of what the parameters or configuration variables are used for in that default configuration file.

Backup the default configuration file with `sudo cp /etc/danted.conf /etc/danted.conf.bak` command, then change the configuration in `/etc/danted.conf` with the following example configuration:

```plain
# log configuration
logoutput: stderr

# danted service will listen to any available IP addresses on port 1080
internal: 0.0.0.0 port=1080

# which interface will be used for outgoing connection
external: eth0

clientmethod: none
socksmethod: username
user.privileged: root
user.unprivileged: nobody
user.libwrap: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}
```

From the example configuration above, **Dante** will listen to any available IP addresses on port `1080` and all outgoing traffic will be passed through `eth0` interface.

You can change the _port_ and you must adjust the `external` _interface_ with your default server interface.

After adjusting the **Dante** configuration to fit with your needs, restart the service using `sudo systemctl restart danted.service` command.

Then, check whether `danted.service` is running properly with `sudo systemctl status danted.service` command:

```plain
● danted.service - SOCKS (v4 and v5) proxy daemon (danted)
     Loaded: loaded (/lib/systemd/system/danted.service; enabled; preset: enabled)
     Active: active (running) since Thu 2023-11-09 16:51:01 WIB; 1 day 1h ago
       Docs: man:danted(8)
             man:danted.conf(5)
    Process: 885 ExecStartPre=/bin/sh -c        uid=`sed -n -e "s/[[:space:]]//g" -e "s/#.*//" -e "/^user\.privileged/{s/[^:]*://p;q;}" /etc/danted.conf`;     >
   Main PID: 935 (danted)
      Tasks: 21 (limit: 9304)
     Memory: 18.5M
        CPU: 2.701s
     CGroup: /system.slice/danted.service
             ├─    935 /usr/sbin/danted
             ├─    955 "danted: monitor"
             ├─1494108 "danted: io-chil"
             ├─1494116 "danted: io-chil"
             ├─1494127 "danted: request"
             ├─1495807 "danted: request"
             ├─1496272 "danted: negotia"
             ├─1496273 "danted: request"
             .... snip

Nov 09 16:51:01 aws-ec2 systemd[1]: Starting danted.service - SOCKS (v4 and v5) proxy daemon (danted)...
Nov 09 16:51:01 aws-ec2 systemd[1]: Started danted.service - SOCKS (v4 and v5) proxy daemon (danted).
Nov 09 16:51:02 aws-ec2 danted[935]: Nov  9 16:51:02 (1699523462.105152) danted[935]: info: Dante/server[1/1] v1.4.2 running
```

## Test your server

After all the processes above are complete, it's time to try using your **proxy server**. One of the easiest way to test is using `curl` from your local computer:

```shell
curl -x socks5://myproxyuser:myproxy_password@server_ip:proxy_port http://ifconfig.me
```

> _Change `myproxyuser`, `myproxy_password`, `server_ip`, and `proxy_port` with the authentication and configuration you have done before._

From the `curl` command above, your public IP address should become your proxy server IP address, not your home ISP IP address.

## Troubleshooting

If you cannot establish a `SOCKS5` connection to your _proxy server_, make sure the _port_ used by Dante is open. run the following `ufw` command (for Debian-based systems) to open a port from the firewall:

```shell
ufw allow proto tcp to any port 1080
```

> Note: _Change port `1080` and adjust it to your proxy server configuration._
