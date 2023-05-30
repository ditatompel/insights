---
title: "DNS Sinkhole, AdGuard Home or PiHole?"
description: "Comparing PiHole and AdGuard Home as DNS Sinkhole. Both offer excellent way to block sites, ads, and trackers. But, which one shoud you choose?"
date: 2022-02-19T00:55:55+07:00
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
  - TIL
tags:
  - DNS
  - PiHole
  - AdGuard
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

Regarding my previous post about [MikroTik, DNS-over-HTTPS and AdGuard]({{< ref "/tutorials/homelab-mikrotik-doh-proxmox-ve-adguard-home-surf-the-web-freely-ad-free-and-safely/index.md" >}}), there is one product that I actually used several years before.

I was using **PiHole** as DNS forwarder and DNS sinkhole of my main DNS servers (**BIND**). During 4 years using PiHole, I rarely experienced significant problems in maintenance, upgrade or troubleshoot process. In terms of reliability, I think PiHole definitely deserves a mention.

<!--more-->

Installed on **LXC** with just 4 cores of Xeon CPU and 4GB of RAM it can easily handle 10 million queries per day (although on average, my PiHole only serves 2.5 - 5 million requests per day). The installation process also quite straightforward like AdGuard Home installation process. Just run PiHole install script (`curl -sSL https://install.pi-hole.net | bash`) and you are ready to go.

## Performance
I can't compare PiHole and AdGuard performance (my previous article) with my current resources. Yes, I install them with same virtualization technology, but hardware and infrastructure where my PiHole and AdGuard installed is different.

My PiHole use enterprise grade server and located at data center, it meant to serve tens of millions of requests in a day while my AdGuard use old *small-form-factor* PC and way far from Indonesia Data Center. But I think PiHole still have the upper hand in term of performance compared with AdGuard even though they use the same infrastructure.

## Features, UX and UI
Both can be configured to use any DNS resolver you wish. PiHole support regular DNS query over UDP, but if you want to use DNS-over-HTTPS, you need additional tools like `cloudflared` – though AdGuard Home comes with DNS-over-TLS and DNS-over-HTTPS out of the box.

AdGuard Home can easily block certain services or website like TikTok, Tinder, Facebook, etc with single click, while in PiHole, you need to specify domain and subdomains you want to block. Although both serve almost the same content from web interface, AdGuard looks more modern than PiHole web interface.

## Which one shoud you choose?
Either PiHole and AdGuard Home offer excellent way to block sites, ads, and trackers. If you like everything just work out of the box with rich features, AdGuard Home may be more suitable for you.

But if you confortable working with terminal, like simplicity and highly configurable service, you may choose PiHole as your DNS sinkhole. I personally like PiHole, very well documented, more audited codebase and wider range of usage.