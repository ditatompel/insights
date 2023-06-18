---
title: "Indonesia Public Monero Node"
description: "I host a Monero node that is free to use for everyone as a remote RPC for wallet usage located on Indonesia Data Center 3D in Jakarta, Indonesia."
date: 2021-02-22T21:18:10+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Privacy
tags:
  - Monero
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

**TLDR**; I host a Monero node that is free to use for everyone as a remote RPC for wallet usage located on Indonesia Data Center 3D in Jakarta, Indonesia.

<!--more-->

**UPDATE**: Node address was changed. For more information and other Monero node network (stagenet and testnet) pelase visit [https://www.ditatompel.com/monero](https://www.ditatompel.com/monero).

- Mainnet Wallet RPC : `xmrnode1.ditatompel.com:18089`
- Mainnet Wallet RPC (SSL) : `xmrnode1.ditatompel.com:443`
- Mainnet Wallet RPC (TOR) : `xmrnodfez4ryr4khacshh4uet2u7rjvnqkuv6j474wasjbvx2pespnad.onion:18089`
- Mainnet P2P: `xmrnode1.ditatompel.com:18080`

> **UPDATE 2**: I will **permanently close** this Monero Public Node service, please read: [Permanently Shutdown Services and Public Nodes]({{< ref "/blog/announcement-permanently-shutdown-services-and-public-nodes/index.md" >}}).

## Motives
First, Monero is secure, private, untraceable, an open-source, community-driven project.

> _With Monero, you are your own bank. You can spend safely, knowing that others cannot see your balances or track your activity. (getmonero.org)_

That's why I choose Monero over the others cryptocurrency.

**Second**, the average computer used by Indonesians is quite old and many of them still use spinning hard drives or low storage capacity of SSD. This can be a problem when someone wants to have a Monero wallet with a local node. Downloading the entire blockchains to the spinning hard disk can take 3 - 8 days.

**Third**, support the network by running a node. Nodes ensure the network keeps running safe and decentralized. A simple fully synchronized node is enough to help the network, and by allowing other people to connect to my node may solve the **second** problem above.

Please see this following [guide how to connect to remote node within GUI wallet](https://www.getmonero.org/resources/user-guides/remote_node_gui.html).

## Node Technical Specifications
This public node is running on VM, the physical server is located on Indonesia Data Center Duren Tiga (IDC-3D) in Jakarta, Indonesia. Only data center technican and several company sysadmin have access to rack server.

- Node Host / Address : `xmrnode1.ditatompel.com`
- Node Port (restricted RPC): `443`

VM spec:
- CPU: **8 cores** from 2 sockets Intel(R) Xeon(R) x5660 @2.80GHz.
- Memory: **16GB** of ECC RAM
- Storage Capacity: **300GB** on RAID5 SAS HDD
- Bandwidth: **1Gbps** (Indonesia), **100Mbps** (outside Indonesia)

Please note that VM also serve Nginx as reverse proxy for some of my web services.

## General Recomendation
> I quote alot from moneroworld.com for this general recomendation, Please read [https://moneroworld.com/](https://moneroworld.com/) for more details.

Public nodes should be considered a **last resort** if you can't get your own node working. The entire value of a decentralized cryptocurrency is its decentralized nature. Please, take the time to **try running your own node, or perhaps just use a remote node until your daemon is synchronized**.

Also see [Guide to Run Monero Node on VPS]({{< ref "/tutorials/guide-to-run-monero-node-on-vps/index.md" >}}).

## Security Note
Using a public remote node has its risks. The primary risk is that a public remote node can get your IP address. If a public remote node is malicious, the node operator now can associate a transaction with an IP address. They could also know that there is a user of monero with an ACTIVE wallet at a given IP address.They could then scan your IP address to try and identify any open ports.

If they find any open ports, they can test these ports to see if they can get in to your computer. Granted, this is true of ANY IP address that can be obtained from the monero peerlists. TL;DR, run your own node. If you can't, make sure you have good firewalls, wallet passwords, and malware scanners.

## Resources
- [getmonero.org](https://www.getmonero.org/) | (Official Monero Website)
- [Monero SubReddit](https://www.reddit.com/r/Monero/)
- [mymonero.com](https://mymonero.com/) | (Web Wallet, deemed safe by respected members of the community)
- [moneroworld.com](https://moneroworld.com/) | Great resource about Monero and nodes.
- [monero.how](https://www.monero.how/) | great website with lots of tutorials and source of main image of this post.
- [miningpoolstats.stream/monero](https://miningpoolstats.stream/monero) | List of Monero mining pools