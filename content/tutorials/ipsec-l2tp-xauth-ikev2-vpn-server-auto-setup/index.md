---
title: "IPsec (L2TP, XAuth, IKEv2) VPN Server Auto Setup"
description: "A few years ago, I've found this gem which allow us to set up our own IPsec VPN server with L2TP, XAuth and IKEv2 on Ubuntu, Debian, RHEL, and CentOS."
# linkTitle:
date: 2019-07-01T03:06:07+07:00
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
  - IPsec VPN
categories:
  - Networking
  - SysAdmin
tags:
  - VPN
  - IPsec
  - L2TP
  - XAuth
  - IKEv2
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
  - ditatompel
---

A few years ago, I've found [this gem](https://gist.github.com/hwdsl2/e9a78a50e300d12ae195) which allow us to [set up our own IPsec VPN server](https://github.com/hwdsl2/setup-ipsec-vpn) with **L2TP**, **XAuth** and **IKEv2** on **Ubuntu**, **Debian** and **CentOS** distro.

<!--more-->

> _**Note**: This is my personal snippets, if you need a complete documentation, please go to [hwdsl2/setup-ipsec-vpn](https://github.com/hwdsl2/setup-ipsec-vpn) GitHub repository, it's really well documented! A pre-built [Docker image](https://github.com/hwdsl2/docker-ipsec-vpn-server) of the VPN server is also available, go and get it._

> _**NOTICE**: You should [upgrade Libreswan](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/README.md) to the latest version due to IKEv1 informational exchange packets not integrity checked ([CVE-2019-10155](https://libreswan.org/security/CVE-2019-10155/))._

## Intro
Since **PPTP** VPN no longer supported by Apple's built-in VPN client on **macOS Sierra** and **iOS 10** due to many [well-known security issues](https://en.wikipedia.org/wiki/Point-to-Point_Tunneling_Protocol), I have to use other VPN communications protocols to access my internal company networks. And here [Lin Song](https://www.linkedin.com/in/linsongui/) and [contributors](https://github.com/hwdsl2/setup-ipsec-vpn/graphs/contributors) with their bash scripts become an Angel. All I need to do is download and execute the *bash script* on my servers, and let the script configure the rest **IPsec** VPN server setup.

In short: this script download, compile and configure [Libreswan](https://libreswan.org/) as the **IPsec** server, and [**xl2tpd**](https://github.com/xelerance/xl2tpd) as the **L2TP** provider. This script also writes changes to `sysctl.conf` to improve performance, mask `firewalld` (on **CentOS**), updating `iptables` *firewall* and configure simple **Fail2Ban** rules on `sshd` *daemon*.

> _**NOTE**: **This script are mean to be executed on server(s)**. **DO NOT** run auto install scripts on your personal PC or Mac!_

## Requirements
A dedicated server or Virtual Private Server (VPS) with one of these OSes:
- **Ubuntu** `16.04` (**Xenial**) / `18.04` (**Bionic**)
- **Debian** `8` (**Jessie**) / `9` (**Stretch**)
- **CentOS** `6`/`7` (`x86_64`)
- **Red Hat Enterprise Linux** (**RHEL**) `6`/`7`
- Open **UDP** ports `500` and `4500` (if your machine is running behind external firewall)

> _**Note**: **OpenVZ VPS** is not supported._

## Installation
First (this is not necessary but recommended), make sure system is up to date with `apt-get update && apt-get dist-upgrade` for **Debian** and **Ubuntu** or `yum update` for **RHEL** and **CentOS**.

To install the VPN we have 3 options described [here](https://github.com/hwdsl2/setup-ipsec-vpn): I'd love to use the **first option** with 1 line command to configure and generate random VPN credentials (will be displayed when finished) because I love to manage VPN users and **PSK** manually latter. So :
For **Debian** and **Ubuntu**:
```bash
wget https://git.io/vpnsetup -O vpnsetup.sh && sudo sh vpnsetup.sh
```
For **RHEL** and **CentOS**:
```bash
wget https://git.io/vpnsetup-centos -O vpnsetup.sh && sudo sh vpnsetup.sh
```
After installation script done, VPN login details will be randomly generated, and displayed on the screen.

## Default Configurations
VPN **DNS Client** is set to use [Google Public DNS](https://developers.google.com/speed/public-dns/). You can replace with your server provider DNS if you want by editing `8.8.8.8` and `8.8.4.4` in both `/etc/ppp/options.xl2tpd` and `/etc/ipsec.conf`, then *reboot* the server.

When connecting via `IPsec/L2TP`, the VPN server has IP `192.168.42.1` within the VPN *subnet* `192.168.42.0/24`.

The same VPN account can be used by multiple devices. However, to avoid connection issues when connecting multiple devices simultaneously from behind the same **NAT** (e.g. home router), use **IPsec/XAuth mode**.

To modify the iptables rules after install, edit `/etc/iptables.rules` and/or `/etc/iptables/rules.v4` (**Ubuntu**/**Debian**), or `/etc/sysconfig/iptables` (**CentOS**/**RHEL**). Then reboot your server.

## Manage VPN Users and PSK
You can use [this helper scripts](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/manage-users.md#using-helper-scripts) to make it easier to manage VPN users. But I love to manage my VPN users manually. Content below describe how to manage **IPsec/L2TP** and **IPsec/XAuth** manually.

The **IPsec PSK** (*pre-shared key*) is stored in `/etc/ipsec.secrets`. All VPN users will share the same IPsec PSK. If PSK changed, `ipsec` and `xl2tpd` *service* need to be restarted.

### IPsec/L2TP Users
For `IPsec/L2TP`, VPN users are stored in `/etc/ppp/chap-secrets`. The format of this file is:
```plain
"username1"  l2tpd  "password1"  *
"username2"  l2tpd  "password2"  *
... ...
```
You can add more users, use one line for each user. DO NOT use these special characters within values: `\ " '`.

### IPsec/XAuth Users
For `IPsec/XAuth` ("**Cisco IPsec**"), VPN users are stored in `/etc/ipsec.d/passwd`. The format of this file is:
```plain
username1:password1hashed:xauth-psk
username2:password2hashed:xauth-psk
... ...
```
Passwords in this file are *salted* and *hashed*. You need to use `openssl` command to generate IPsec/XAuth user password:
```bash
openssl passwd -1 'your_password'
```
As I mentioned before, you must restart services if changing the PSK. For add/edit/remove VPN users, this is normally not required.
```bash
service ipsec restart
service xl2tpd restart
```

## Next Steps
Get your computer and devices to use the VPN service:
- [Configure IPsec/L2TP VPN Clients]({{< ref "/tutorials/configure-ipsec-l2tp-vpn-clients/index.md" >}})
- [Configure IPsec/XAuth "Cisco IPsec" VPN Clients]({{< ref "/tutorials/configure-ipsec-xauth-vpn-clients/index.md" >}})
- [Set Up IKEv2 VPN Server and Clients]({{< ref "/tutorials/set-up-ikev2-vpn-server-and-clients/index.md" >}}) (Advanced)

## Credits
- All articles credits belongs to [Lin Song](https://www.linkedin.com/in/linsongui/) and [contributors](https://github.com/hwdsl2/setup-ipsec-vpn/graphs/contributors).
- Feature Image credit to [Mike MacKenzie](https://www.vpnsrus.com/).

## Links and Resources
- [https://github.com/hwdsl2/setup-ipsec-vpn](https://github.com/hwdsl2/setup-ipsec-vpn)
- [https://gist.github.com/hwdsl2/9030462#comments](https://gist.github.com/hwdsl2/9030462#comments)
- [https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#troubleshooting](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#troubleshooting)
- [https://github.com/StreisandEffect/streisand](https://github.com/StreisandEffect/streisand)
- [https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/ikev2-howto.md#known-issues](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/ikev2-howto.md#known-issues)