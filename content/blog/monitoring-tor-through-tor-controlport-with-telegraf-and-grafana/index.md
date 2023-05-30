---
title: "Monitoring Tor through Tor ControlPort with Telegraf and Grafana"
description: "I found a python script written by bentasker that takes data from Tor ControlPort and converts it to InfluxDB format."
date: 2022-06-18T02:34:36+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - SysAdmin
tags:
  - Tor
  - InfluxDB
  - Telegraf
  - Grafana
  - Python
images:
#  - 
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

Sometime, I get a problem when running **Tor** daemon under **Linux Container**, usually related to [AppArmor](https://forum.proxmox.com/threads/tor-inside-lxc-blocked-by-apparmor.57141/) after I upgrade the system. Meanwhile, my Tor service needs to be turned on all the time and reachable to all my *"workers"* who fetch `.onion` addresses listed on my [Monero remote node monitoring](https://www.ditatompel.com/monero/remote-node) service.

<!--more-->

Lucky for me, a few days ago I found a *python script* written by [bentasker](https://www.bentasker.co.uk/). The script takes data from **Tor ControlPort** and converts it to **InfluxDB format** (it also support relay / exit node metrics if you run one, cool isn't it?). It's very easy to set up, just [download tor-daemon.py](https://github.com/bentasker/telegraf-plugins/tree/master/tor-daemon) and follow the instructions given on that page and you're done.

## TLDR
1. Generate password hash using `tor --hash-password <your_secret_password>`.
2. Copy generated hash, enable Tor `ControlPort` and add (or replace) `HashedControlPassword` to your generated hash (don't forget to **restart Tor service** after you change `torrc` config).
3. Download [tor-daemon.py](https://github.com/bentasker/telegraf-plugins/blob/master/tor-daemon/tor-daemon.py) script and place it somewhere, edit `CONTROL_H`, `CONTROL_P`, and `AUTH` variable so it fit with your configured Tor `ControlPort` settings.
4. Add **Telegraf** `input.exec` configuration to trigger the script.

Please read detailed information about how to configure and [monitoring the Tor daemon with Telegraf](https://www.bentasker.co.uk/posts/documentation/general/monitoring-tor-daemon-with-telegraf.html) on Ben's website (and I'm sure you'll love reading all the posts on his website, like I do).

## Resources
- [https://github.com/bentasker/telegraf-plugins/tree/master/tor-daemon](https://github.com/bentasker/telegraf-plugins/tree/master/tor-daemon)
- [https://www.bentasker.co.uk/posts/documentation/general/monitoring-tor-daemon-with-telegraf.html](https://www.bentasker.co.uk/posts/documentation/general/monitoring-tor-daemon-with-telegraf.html)
