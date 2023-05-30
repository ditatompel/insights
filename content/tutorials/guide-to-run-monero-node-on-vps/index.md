---
title: "Guide to Run Monero Node on VPS"
description: "Supporting Monero by building new public nodes on VPS or virtual machine."
# linkTitle:
date: 2021-03-30T21:29:45+07:00
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
  - Privacy
tags:
  - Monero
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

About a month ago, [I host Monero node that is free to use for everyone]({{< ref "/blog/indonesia-public-monero-node/index.md" >}}) as a remote RPC. Until this article was written, there were only 2 public nodes from Indonesia and both nodes were run by me.

<!--more-->

Hopefully this article can help those of you who want to support Monero by building new public nodes, especially if only a few nodes available in your area or country.

## Requirements
As a prerequisite to using this guide, I assume that you already have at least:

- 1 Virtual Machine (off course) with **public IP address**.
- **1GB** of **RAM** (minimum)
- **160GB** of **Storage**
- Ubuntu `18.04` (this guide)

> _I suggest that your VPS use **SSD storage**, because **downloading and verifying the entire blockchains to the spinning hard disk can take 4 - 8 days**._

## Installation
We need to compile Monero from source.

### Dependencies
Build `ibgtest-dev` binary manually because on Debian/Ubuntu `libgtest-dev` only includes sources and headers.

```bash
sudo apt-get install libgtest-dev && cd /usr/src/gtest && sudo cmake . && sudo make && sudo mv libg* /usr/lib/
```
Install remaining dependencies :
```bash
sudo apt update && sudo apt install build-essential cmake pkg-config libboost-all-dev libssl-dev libzmq3-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libldns-dev libexpat1-dev doxygen graphviz libpgm-dev qttools5-dev-tools libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libudev-dev
```

### Clone the repository and build
Clone recursively to pull-in needed submodule(s):
```bash
git clone --recursive https://github.com/monero-project/monero
```
Initialize and update:
```bash
cd monero && git submodule init && git submodule update
```

change to the most recent release branch (`v0.17` when this article is written), and build:
```bash
git checkout release-v0.17
make
```

> _Tips: If your machine has several cores and enough memory, enable parallel build by running `make -j<number of threads>` or `make -j$(nproc)` instead of `make`. For this to be worthwhile, the machine should have one core and about 2GB of RAM available per thread._

The resulting executables can be found in `build/Linux/release-v0.17/release/bin`.

Copy compiled binary to `/opt/monero/bin` and change binary files permission:
```bash
mkdir -p /opt/monero
cp -rv build/Linux/release-v0.17/release/bin /opt/monero/
chmod -R 775 /opt/monero/bin
```

### Create user and systemd for Monero daemon
Create new user who should run Monero daemon:

```bash
useradd -s /bin/sh -m monerodaemon
```

Create Monero systemd service file `/etc/systemd/system/monero.service` and add these following config:

```systemd
[Unit]
Description=Monero Daemon
After=network.target

[Service]
Type=forking
GuessMainPID=no
ExecStart=/opt/monero/bin/monerod \
    --rpc-bind-ip 127.0.0.1 \
    --rpc-restricted-bind-ip [SERVER_PUBLIC_IP_ADDRESS] \
    --rpc-restricted-bind-port [RPC_RESTRICTED_PORT] \
    --confirm-external-bind \
    --public-node \
    --detach
Restart=always
User=monerodaemon

[Install]
WantedBy=multi-user.target
```

Change `[SERVER_PUBLIC_IP_ADDRESS]` above with your server public IP address and `[RPC_RESTRICTED_PORT]` with your desired port (recommended `18089`).

Reload, start and enable daemon on startup:
```bash
systemctl daemon-reload
systemctl enable --now monero.service
```
Make sure monero daemon is running: `systemctl status monero.service`.

### Firewall
Make sure your firewall for port `18080` and `18089` (`[RPC_RESTRICTED_PORT]` from systemd config above) is open, if not:
```bash
ufw allow 18080
ufw allow 18089
```

## Link and Resources
- [https://github.com/monero-project/monero](https://github.com/monero-project/monero)
- [https://www.getmonero.org/get-started/contributing/](https://www.getmonero.org/get-started/contributing/)
- [https://community.xmr.to/network/](https://community.xmr.to/network/)