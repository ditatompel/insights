---
title: "Homelab: Mikrotik + DoH + Proxmox VE + AdGuard Home = Surf the Web Freely, Ad-Free and Safely"
description: "The goals is to surf the web freely without any censorship, Ad-Free browsing, keep on track of your child activity on the internet."
# linkTitle:
date: 2022-02-19T00:15:15+07:00
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
  - Self-Hosted
  - SysAdmin
  - Privacy
tags:
  - AdGuard
  - DNS
  - Proxmox
  - MikroTik
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

Before I begin, I'd like to tell you that in Indonesia, every ISP need to follow government policy. One of those policy is to block millions of website which _**according to them**_ fall into specific category like porn, pirates, gambling, hate speech, scam and drugs.

<!--more-->

Unfortunately, not all sites on their list that should be blocked fall into that category. Some sites that I think are good like reddit.com are blocked. Sure, I know that Reddit have NSFW subreddits, but I don't think it's wise decision to block entire domain just because it contains certain topic you don't like. Especially if it sacrifices useful information and knowledge that may be obtained from that site. If you like to create an environment for you and your family to surf the web freely, ad-free and safely, this article might be suitable for you.

## Goals
- [ ] Surf the web freely without any censorship
- [ ] Ad-Free browsing
- [ ] Browse safely (avoid malware and adult contents) with more reliable source.
- [ ] Keep on track of your child activity on the internet (which services or website they are using) and act wisely.
- [ ] Bonus: With Ad-Free browsing, you may save a lot of bandwidth and surf the internet faster.

> _The most common method used by Indonesia ISPs is blocking websites using DNS. You can't use any external DNS provider, you can only use the DNS owned by the ISP you are using._

Actually you can easily use the **DoH** (DNS-over-HTTPS) feature to bypass DNS blocking. Most modern browsers like [Chrome, Firefox, Edge already have a DoH feature](https://www.zdnet.com/article/dns-over-https-will-eventually-roll-out-in-all-major-browsers-despite-isp-opposition/). However, it will be very inconvenient if you have to setup every device that you or your family own. Therefore, with a **MikroTik** router and a PC (or any devices running with *amd64*/*i386*/*armv5*/*armv6*/*armv7*/*arm64*, some *mips* and *mips64* CPU), you can create your DNS for you and your family. I use these following hardware to build the environment:

- **MikroTik** Router (`v6.47` or above)
- **HP Compaq 8200 Elite USFF** running **Proxmox VE**

## Mikrotik Router Configuation
First, let's configure the router to use DoH instead of ISP DNS so it can bypass censorship. In this article, **let's assume my router IP address is 192.168.4.1** and this is my network configuration:

```plain
[ditatompel@Router 850Gx2] > /ip addr pr  
Flags: X - disabled, I - invalid, D - dynamic 
 #   ADDRESS            NETWORK         INTERFACE
 0   192.168.4.1/22     192.168.4.0     bridge_home
 1   10.5.50.1/24       10.5.50.0       ether1
 2 D 10.182.16.100/32   10.182.16.1     pppoe-out1
```
Configure the DoH server (Eg: **Cloudflare**):
```plain
/ip dns set use-doh-server=https://dns.cloudflare.com/dns-query verify-doh-cert=no servers=1.1.1.1,1.0.0.1 allow-remote-requests=yes
```

> It is advised to import the root CA certificate of the DoH server you have chosen and set `verify-doh-cert=yes` for increased security.

> There are various ways to find out what root CA certificate is necessary. The easiest way is by using your WEB browser, navigating to the DoH site and checking the websites security. You can download the certificate straight from the browser or fetch the certificate from a trusted source.

Then, you need at least one regular DNS server configured for the router to resolve the DoH *hostname* itself. If you do not have any dynamical or static DNS server configured, you can configure a static DNS entry like this:

```plain
/ip dns static add name=dns.cloudflare.com address=104.16.133.229 ttl=1d
/ip dns static add name=dns.cloudflare.com address=104.16.132.229 ttl=1d
/ip dns static add name=dns.google address=8.8.8.8 ttl=1d
/ip dns static add name=dns.google address=8.8.4.4 ttl=1d
/ip dns static add name=dns.adguard.com address=94.140.15.15 ttl=1d
/ip dns static add name=dns.adguard.com address=94.140.14.14 ttl=1d
/ip dns static add name=dns10.quad9.net address=9.9.9.10 ttl=1d
```

Check if your router is able to perform DNS query simply using ping to several domains. If all goes well, you should be able to surf the internet without censorship using your Router IP address as DNS server.

> - [x] Surf the web freely without any censorship achieved

If you want one step further, for example, browsing websites without ads, blocking sites indicated by malware and others, you can proceed to the next step, which is installing **AdGuard Home**.

## Install AdGuard Home
In this example, I install **AdGuard Home** on **Ubuntu** `18.04` (**LXC**) under **Proxmox VE** along with other *Linux Container*. I allocated 2GB of RAM and 20GB storage space for AdGuard Home. It should be more than enough to serve 2 - 3 millions daily DNS query. I give AdGuard Home IP address **192.168.4.2**.

> _Your VM / LXC where your AdGuard Home is running should using your router DNS server which we are already configure before using DoH (in this example 192.168.4.1). This allow you to perform DNS query from the system itself._

First, make sure your **Ubuntu** system is up to date:

```shell
apt-get update && apt-get upgrade
```
Download and execute AdGuard Home install script.

```shell
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
```

The script checks whether your system is compatible with AdGuard Home, downloads the **AdGuardHome** binary file and install `AdGuardHome.service` *systemd*.

Check if AdGuardHome has been successfully installed on your system using `/opt/AdGuardHome/AdGuardHome -s` status or `systemctl status AdGuardHome`.service.

You can access and configure your AdGuard Home using web interface (you can find which port the AdGuard Home is listening using `ss -tlnp` command or read directly from `/opt/AdGuardHome/AdGuardHome.yaml`).

### Configure AdGuard Home
You can configure AdGuard Home from either directly edit `/opt/AdGuardHome/AdGuardHome.yaml` file or using web interface. The easiest way is using web interface. Go to **Settings** > **DNS Settings**.

Under **Upstream DNS Server**, fill your desired upstream DNS servers, example :

```plain
https://dns.google/dns-query
https://dns.cloudflare.com/dns-query
https://dns10.quad9.net/dns-query
https://dns.adguard.com/dns-query
```

Note from list I choose above:
- `dns.adguard.com/dns-query` : Provide blocking ads, tracking and phishing.
- `dns.google/dns-query`, `dns.cloudflare.com/dns-query`, `dns10.quad9.net/dns-query`: Global DNS resolution service that you can use as an alternative to your current DNS provider, no filtering.

here [list of known DNS providers you can use](https://kb.adguard.com/en/general/dns-providers).

Under Bootstrap DNS Servers, fill your router IP address (and additional backup DNS servers ...just in case) :

```plain
192.168.4.1
9.9.9.10
149.112.112.10
```

The basic AdGuard Home configuration is done.

You may need to force those who connect to your **MikroTik router** using DHCP to use AdGuard Home DNS.

```plain
/ip dhcp-server network set <i> dns-server=<adguard ip address>
```

Replace `<i>` and `<adguard ip address>` with your network where `<i>` is the number (dns-server network id) from `/ip dhcp-server network print` command.

```plain
[ditatompel@Router 850Gx2] > ip dhcp-server network print
Flags: D - dynamic
 #   ADDRESS            GATEWAY         DNS-SERVER
 0   10.5.50.0/24       10.5.50.1                      
 1   192.168.4.0/22     192.168.4.1     192.168.4.2
```

With this configuration, every devices that connect to your network using DHCP (which 99% regular users do) will use AdGuard DNS.

> * [x] Ad-Free browsing achieved with dns.adguard.com/dns-query
> * [x] Browse safely (avoid tracking, malware and phishing) with reliable source achieved with dns.adguard.com/dns-query
> * [x] Save a lot of bandwidth and surf the internet faster. 

## Keep on track of every devices connected to your network
So, if you want to go even further, for example, you have child and you want to keep on eye of what website your child is visiting or what services they are using. You can do this basic steps.

### Find every devices connected to your router via DHCP.   
You have several ways to find that, using AdGuard dashboard interface or using Mikrotik DHCP server lease. I personally like using Mikrotik, make them DHCP static because it's easier to memorize IP address than MAC Address. `/ip dhcp-server lease print`.

```plain
[ditatompel@Router 850Gx2] > /ip dhcp-server lease print
Flags: X - disabled, R - radius, D - dynamic, B - blocked 
 #   ADDRESS        MAC-ADDRESS       HOST-NAME           SERVER       RATE-LIMIT    STATUS  LAST-SEEN
 0   192.168.4.2    6E:B2:17:xx:xx:xx adguard-home        dhcp_home                  bound   1m10s
 1   192.168.4.3    FC:EC:DA:xx:xx:xx APUniFiF1           dhcp_home                  bound   5m22s
 2   192.168.4.4    FC:EC:DA:xx:xx:xx APUniFiF2           dhcp_home                  bound   5m25s
 3 D 192.168.4.5    AE:8D:E9:xx:xx:xx someone-Iphone      dhcp_home                  bound   5m54s
 4 D 192.168.4.6    9C:8E:99:xx:xx:xx someone-MBP         dhcp_home                  bound   7m4s
 5 D 192.168.4.7    00:15:18:xx:xx:xx Galaxy-Something    dhcp_home                  bound   1m24s
 
 [...snip...]
```

### Add them to Client list on AdGuard Home
Write down the MAC Address of the device and add them to **AdGuard Home** > **Settings** > **Client Settings** > **Add Client**

After you done mapping every devices, you can inspect each devices from Query Log page.

![AdGuard Query Log](query-log-adguard.jpg#center)

You can also prevent each devices to use specific services like TikTok, Tinder, etc or even force them to use specific upstreams DNS.

For example, if I want **"someone-iPhone"** from DHCP lease above (which is my child for example) for accessing **TikTok** and use Malware and **Adult Content blocking** DNS servers, I can Edit Client configuration.

In **Block specific services** tab > Check **TikTok**, in Upstream DNS servers add `https://family.cloudflare-dns.com/dns-query` to use Cloudflare Malware and adult content blocking. That's it.

> * [x] Keep on track of your child activity on the internet (which services or website they are using) achieved

> **Just reminder**: Tracking others activity hurt their privacy, always act wisely, blocking content you don't like to your child is not wise decision to make, you can't control every information that come to your child, from their friends, school, social media etc. If they want to watch porn, the will get it, if they want to learn something they like from the internet, they will get it too. Internet is beautiful, **Pope Francis** once declared the Internet is "a gift from God", and it is!
>
> In my opinion, the best way to protect your child from sea of information it educate them how to deal it. Educate how to deal with negative contents, educate how to deal with false information and hoaxes. And see how your child become more mature from average immature social media users.

And as always from the usual lecture from sysadmin:
- Respect the privacy of others.
- Think before you type.
- With great power comes great responsibility.

![usual lecture from sysadmin](great-power-great-responsibility.jpg#center)
