---
title: "How to Setup Your Own WireGuard VPN Server"
description: "How to manually setup your own WireGuard VPN server using ~$6 VPS"
# linkTitle:
date: 2023-06-05T19:04:57+07:00
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
  - WireGuard VPN
categories:
  - Privacy
  - SysAdmin
  - Networking
  - Self-Hosted
tags:
  - VPN
  - WireGuard
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

This article will guide you to setting up your own **WireGuard VPN** server using **Ubuntu 22.04** server on a **cheap ~$6 VPS** and use it as your internet gateway.

<!--more-->
---

After [series of my IPsec VPN article](https://insights.ditatompel.com/en/series/ipsec-vpn/). Today, I want to share how to set up [**WireGuard VPN**](https://www.wireguard.com/) server. Because **WireGuard** use **UDP** instead of **TCP**, it's *extremely fast* compared to [L2TP/xAuth]({{< ref "/tutorials/ipsec-l2tp-xauth-ikev2-vpn-server-auto-setup/index.md" >}}) and [IKEv2 VPN]({{< ref "/tutorials/set-up-ikev2-vpn-server-and-clients/index.md" >}}) (my previous **IPsec VPN** articles).

## Prerequisites
- A **VPS** with Public IP address.
- Comfortable with Linux *command-line*.
- Basic knowledge of _**IPv4** subnetting_ (_to be honest, I'm not familiar with IPv6 subnetting, so this article is for **IPv4** only_).

It doesn't matter which *cloud provider* you choose. in this article, I will use [**DigitalOcean**](https://m.do.co/c/42d4ba96cc94) (*refferal link*) **Droplet** for my **WireGuard VPN server** (You can get your **free $200** in credit over 60 days by registering using my *refferal code*).

> _**NOTE**: You should know that **cloud providers usually charge extra amount of `$` for every GB of overuse bandwidth**. So, know your needs and your limits!_

> _VPS server I use for this article will be destroyed when this article is published._

## Deploying your new VPS (DigitalOcean Droplet, optional)
> _If you already have your own VPS running, you can skip this step and go to next step: "[Setup your WireGuard Server](#setup-your-wireguard-server)"._

1. Go to your project and **Create new Droplet**.
2. Choose **droplet region closest to you** to avoid any potential network latency. In this example, I'll choose **Frankfurt** datacenter.
3. Choose your **Droplet OS**, for this article, I'll use **Ubuntu** `22.04 LTS`.
4. Choose your **Droplet size**. I'll start with basic, **1 CPU** with **1GB of RAM** and **1TB network transfer** ($6/month).   
Adapt the VPS size to fit with your need to avoid extra charge of overuse bandwidth (1TB monthly transfer is enough for me).
![DigitalOcean VPS size](do1.png#center)
5. Set up your prefered *authentication method*, I **prefer using SSH public and private key** rather than *password auth*.
6. Set any other options as *default*. _I'm sure you **don't need backup and managed database options** for this setup_.

> _**WireGuard** did **NOT need high disk I/O, so NVMe disk is NOT necessary**._

## Setup your WireGuard Server
> _**IMPORTANT NOTE**: Since I'm not familiar with **IPv6** subnetting, I'll only use use IPv4._

Once your VPS ready and running, it's recommended to update your OS first using `apt update && apt upgrade` command and `reboot` your VPS.

### Install WireGuard
Install WireGuard using `sudo apt install wireguard` command. Once WireGuard is installed, we need to generate private and public key pairs for our WireGuard server.

> _Tips: You can create **vanity** public key address for **WireGuard** using tool like [warner/wireguard-vanity-address](https://github.com/warner/wireguard-vanity-address)._

#### Generate Private Key
You can use `wg genkey` command to generate your private key. Place your private key to somewhere save, for example: `/etc/wireguard/do_private.key`.
```shell
wg genkey | sudo tee /etc/wireguard/do_private.key
```
Write down the output, we'll need that later to generate our WireGuard Server public key. Example of my WireGuard server private key:
```
uO0GDXBc+ZH5QsLmf+qRyCtFmUV1coadJvQp8iM0mEg=
```
Change `/etc/wireguard/do_private.key` file permission with `sudo chmod 600 /etc/wireguard/do_private.key`.

#### Generate Public Key
Now, generate server public key from previously generated private key:

```shell
sudo cat /etc/wireguard/do_private.key | wg pubkey | sudo tee /etc/wireguard/do_public.key
```
Write down the output, we'll need that later to configure WireGuard connection for *peers* (clients). Example of my WireGuard server public key:
```
7c023YtKepRPNNKfGsP5f2H2VtfPvVptn8Hn6jjmaz8=
```

### Configuring WireGuard Server
Before configuring your **WireGuard** server, you need to **decide your private network address range for your WireGuard** connection (*tunnel* interface). You should choose valid [private network IP ranges](https://en.wikipedia.org/wiki/Private_network#Private_IPv4_addresses). For example:
- Between `10.0.0.0` - `10.255.255.255` (`10.0.0.0/8`)
- Between `172.16.0.0` - `172.31.255.255` (`172.16.0.0/12`)
- Between `192.168.0.0` - `192.168.255.255` (`192.168.0.0/16`)

> _Tips: Avoid using your current used private IP ranges and commonly used private IP range. For example: Docker uses `172.17.0.0/16` ip range by default. If you use Docker, you must use another IP range for your WireGuard IP range to avoid conflict._

In this article, I only use **IPv4** and use `10.10.88.0/24` for my WireGuard network.

You'll also need to decide which **UDP** port WireGuard should listen to. Many *network appliance* out there (such as **Netgate**, **QNAP**, etc) set **UDP** port **51280** as their default WireGuard listen port. But, in this article, I'll use `UDP` port `51822`.

Now, we have all (basic) required information for WireGuard server to run:
- Server Public IP: `xxx.xx.xx0.246`
- Server Private key: `uO0GDXBc+ZH5QsLmf+qRyCtFmUV1coadJvQp8iM0mEg=`
- Server Public Key: `7c023YtKepRPNNKfGsP5f2H2VtfPvVptn8Hn6jjmaz8=`
- Server Listen Port: `UDP` port `51822`
- WireGuard Network: `10.10.88.0/24`

Create file named `wg0.conf` for your WireGuard configuration under `/etc/wireguard` directory and fill with this example configuration:
```plain
# /etc/wireguard/wg0.conf

[Interface]
PrivateKey = <YOUR_SERVER_PRIVATE_KEY> # This example: uO0GDXBc+ZH5QsLmf+qRyCtFmUV1coadJvQp8iM0mEg=
Address = <YOUR_SERVER_WG_IP_ADDRESS>  # This example: 10.10.88.1/24
ListenPort = <SERVER_UDP_LISTEN_PORT>  # This example: 51822
SaveConfig = true
```
> _**Note**: From the configuration above, notice that I pick `10.10.88.1` as my server IP address for WireGuard network._

Replace `<YOUR_SERVER_PRIVATE_KEY>`, `<YOUR_SERVER_IP_ADDRESS>`, `<SERVER_UDP_LISTEN_PORT>` with your prefered configuration.

#### Allowing IP forward
In this article, we'll allow this WireGuard server as our default *gateway* for *peers* (clients), so any outgoing network traffic (except to your **LAN/WLAN** network) can go trough this WireGuard server. If you use WireGuard as *peer-to-peer* connection, yo don't need to do this.

Edit `/etc/sysctl.conf` and add `net.ipv4.ip_forward=1` to the end of the file, then run `sudo sysctl -p` to load the new `/etc/sysctl.conf` values.
```shell
sudo sysctl -p
```

After that, you need to add firewall rules to allow peers (clients) to connect to server and routed properly.

#### Setting up Firewall
By default, Ubuntu system use comes with **UFW** to manage system firewall. You need to **add WireGuard listen port to firewall allow list**.
```shell
sudo ufw allow OpenSSH
sudo ufw allow proto udp to any port 51822
```
> _Note that I also add **OpenSSH** to allow list to avoid losing connection to SSH if you didn't configure / activate it before._

Replace `51822` to your configured **WireGuard listen port**.

Enable / restart your `ufw` service using:
```shell
ufw enable # to enable firewall, or
ufw reload # to reload firewall
```

Next, you need to know which network interface used by your server as its *default route*. You can use `ip route list default` to see that. Example output of my `ip route list default` command:

```plain
default via 164.90.160.1 dev eth0 proto static
```
Write down the word after `dev` output, that's your default network interface. We will need that infromation later. In this example, my default network interface is `eth0`. 

Now add this following configuration to your `/etc/wireguard/wg0.conf` under `[Interface]` section:
```plain
PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

Replace `eth0` from above configuration with your server default network interface.

Your `/etc/wireguard/wg0.conf` shoud look like this:
```plain
# /etc/wireguard/wg0.conf

[Interface]
PrivateKey = <YOUR_SERVER_PRIVATE_KEY> # This example: uO0GDXBc+ZH5QsLmf+qRyCtFmUV1coadJvQp8iM0mEg=
Address = <YOUR_SERVER_WG_IP_ADDRESS>  # This example: 10.10.88.1/24
ListenPort = <SERVER_UDP_LISTEN_PORT>  # This example: 51822
SaveConfig = true

PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

Now our WireGuard server is ready. Try to start your WireGuard server using `systemd`:
```shell
sudo systemctl start wg-quick@wg0.service
```

Note that `wg0` above is taken from your configuration file under `/etc/wireguard` directory (but without `.conf` file extension). If your configuration file is named `internal.conf`, you can start that configuration using `systemctl start wg-quick@internal.service`.

Check that your WireGuard server is running using `systemctl status wg-quick@wg0.service` command:

```plain
● wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0
     Loaded: loaded (/lib/systemd/system/wg-quick@.service; enabled; vendor preset: enabled)
     Active: active (exited) since Mon 2023-06-05 14:52:31 UTC; 2h 2min ago
       Docs: man:wg-quick(8)
             man:wg(8)
             https://www.wireguard.com/
             https://www.wireguard.com/quickstart/
             https://git.zx2c4.com/wireguard-tools/about/src/man/wg-quick.8
             https://git.zx2c4.com/wireguard-tools/about/src/man/wg.8
    Process: 714 ExecStart=/usr/bin/wg-quick up wg0 (code=exited, status=0/SUCCESS)
   Main PID: 714 (code=exited, status=0/SUCCESS)
        CPU: 131ms

Jun 05 14:52:30 fra1-do1 systemd[1]: Starting WireGuard via wg-quick(8) for wg0...
Jun 05 14:52:30 fra1-do1 wg-quick[714]: [#] ip link add wg0 type wireguard
Jun 05 14:52:30 fra1-do1 wg-quick[714]: [#] wg setconf wg0 /dev/fd/63
Jun 05 14:52:30 fra1-do1 wg-quick[714]: [#] ip -4 address add 10.10.88.1/24 dev wg0
Jun 05 14:52:30 fra1-do1 wg-quick[714]: [#] ip link set mtu 1420 up dev wg0
Jun 05 14:52:31 fra1-do1 wg-quick[714]: [#] ufw route allow in on wg0 out on eth0
Jun 05 14:52:31 fra1-do1 wg-quick[790]: Skipping adding existing rule
Jun 05 14:52:31 fra1-do1 wg-quick[790]: Skipping adding existing rule (v6)
Jun 05 14:52:31 fra1-do1 wg-quick[714]: [#] iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
Jun 05 14:52:31 fra1-do1 systemd[1]: Finished WireGuard via wg-quick(8) for wg0.
```

![WireGuard systemd](wireguard-systemd.png#center)

To automatically start WireGuard service when the system start, you can execute `sudo systemctl enable wg-quick@wg0.service` command.

## Setup WireGuard Peer (*client*)
In this section, I'll use Linux machine to connect to our configured WireGuard server using `systemd` service. For other method such as connecting using **NetworkManager** GUI, Different OS and mobile devices, I'll add that later to another article.

Configuring WireGuard peer (client) in Linux using `systemd` is almost the same as setting up WireGuard server. The different is you didn't need to configure firewall and IP forward for peers. All you need to do is install WireGuard, create private and public key, configure DNS server you want to use, add start the service.

### Generating Private and Public Key Pairs (Client Side)
If you already have your own WireGuard key pairs, you can use that keys, skip this step and go to the next step: "[Configuring WireGuard Peer (client)](#configuring-wireguard-peer-client)".

> _Tips: You can create **vanity** public key address for **WireGuard** using tool like [warner/wireguard-vanity-address](https://github.com/warner/wireguard-vanity-address)._

#### Generate Peer Private key
You can use `wg genkey` command to generate your private key. Place your private key to somewhere save, for example: `/etc/wireguard/do_private.key`.
```shell
wg genkey | sudo tee /etc/wireguard/do_private.key
```
Write down the output, we'll need that later to generate WireGuard peer public Key. Example of my WireGuard peer public key:
```
WApLrVqFvXMbvsn+62DxfQCY8rsFqmHCEFAabAeA5WY=
```
Change `/etc/wireguard/do_private.key` file permission with `sudo chmod 600 /etc/wireguard/do_private.key`.

#### Generate Peer Public Key
Generate peer public key from previously generated peer private key:

```shell
sudo cat /etc/wireguard/do_private.key | wg pubkey | sudo tee /etc/wireguard/do_public.key
```
Write down the output, we'll need that public key later to be added to our WireGuard server. Example of my WireGuard peer public key:
```
6gnV+QU7jG7BzwWrBbqiYpKQDGePYQunebkmvmFrxSk=
```

### Configuring WireGuard Peer (client)
Before configuring your **WireGuard** peer (client), you need to **decide your WireGuard private IP address for your peer** connection (*tunnel* interface). You should use unused IP address for peer(s) from your WireGuard network IP range. In this article, `10.10.88.1/24` already used by my WireGuard server, so I can't use that IP for peer(s). I'll use `10.10.88.2/24` (or `10.10.88.2/32`) instead.

Now, we have all (basic) required information for WireGuard peer (client) to run:
- Server Public IP: `xxx.xx.xx0.246`
- Server Public Key: `7c023YtKepRPNNKfGsP5f2H2VtfPvVptn8Hn6jjmaz8=`
- Server Listen Port: `UDP` port `51822`
- WireGuard Network: `10.10.88.0/24`
- Client IP address: `10.10.88.2/24`

Create file named `wg-do1.conf` for your WireGuard configuration under `/etc/wireguard` directory and fill with this configuration example:
```plain
# /etc/wireguard/wg-do1.conf

[Interface]
PrivateKey = <YOUR_PEER_PRIVATE_KEY> # This example: WApLrVqFvXMbvsn+62DxfQCY8rsFqmHCEFAabAeA5WY=
Address = <YOUR_PEER_IP_ADDRESS>     # This example: 10.10.88.2/24
DNS = 1.1.1.1 8.8.8.8                # You can use any public / your own DNS resolver if you want

[Peer]
PublicKey = <YOUR_SERVER_PUBLIC_KEY> # This example: 7c023YtKepRPNNKfGsP5f2H2VtfPvVptn8Hn6jjmaz8=
AllowedIPs = 0.0.0.0/0               # Route all external traffic to here
Endpoint = <YOUR_SERVER_PUBLIC_IP_ADDRESS>:<SERVER_UDP_LISTEN_PORT> # This example: xxx.xx.xx0.246:51822
PersistentKeepalive = 15
```

Replace `<YOUR_PEER_PRIVATE_KEY>`, `<YOUR_PEER_IP_ADDRESS>`, `<YOUR_SERVER_PUBLIC_KEY>`, `<YOUR_SERVER_PUBLIC_IP_ADDRESS>`, and `<SERVER_UDP_LISTEN_PORT>` with yours.

Note:
- `AllowedIPs` = `0.0.0.0/0` means all traffic will go trough that peer (in this case, our WireGuard server).   
You can specify / selective routing specific IP to specific peer (if you connected to multiple peers / servers).   
For example, if you only want to route traffic to IP 1.0.0.1 and 8.8.4.4 using specific peer and use your current internet connection as default route, you can remove `0.0.0.0/0` and add `1.0.0.1/32,8.8.4.4/32` (separated by comma) to `AllowedIPs` value.
- `PersistentKeepalive` = `15` : How many seconds for peer send *ping* to the server regularly, so the server can reach the peer sitting behind **NAT**/firewall.
- `DNS` You can also specify DNS servers you want to use in your `DNS` configuration value.

Now, our peer (client) configuration is complete. you can try to connect your device to your WireGuard server using `systemd` service.

```shell
sudo systemctl start wg-quick@wg-do1.service
```
> _**Note 1**: `wg-do1` above is taken from your configuration file under `/etc/wireguard` directory (but without `.conf` file extension). If your configuration file is named `vpn-wireguard.conf`, you can start that configuration using `systemctl start wg-quick@vpn-wireguard.service`._

> _**Note 2**: By default `wg-quick` uses `resolvconf` to register new DNS entries. This will cause issues with network managers and DHCP clients that do not use `resolvconf`, as they will overwrite `/etc/resolv.conf` thus removing the DNS servers added by `wg-quick`._   
> _The solution is to use networking software that supports `resolvconf`._

> _**Note 3**: Users of `systemd-resolved` should make sure that `systemd-resolvconf` is installed._

To verify your configurations is properly configured, try to check your public IP from your browser or terminal using `sudo wg show` or `curl ifconfig.me`.

![wg show](wg-show.png#center)

![What is my IP](wg-vpn-do-ip.png#center)

## Conclusion
WireGuard is my favorite VPN protocol. It's fast and less resource usage compared with other VPN protocols. It's highly configurable and works with multiple environments. It can be used for *peer-to-peer* connection, *client-server* connection, or creating secure *mesh network*.

When combined with **Nginx** as *reverse proxy*, you can even exposing your local HTTP server (and mostly any services) sitting behind **NAT**/firewall to the internet.

Anyway, managing large scale of WireGuard network can be very dificult. But, there are a tool to help you managing large scale WireGuard networks, such as [Netmaker](https://www.netmaker.io/).

### Additional Notes
- If you have some technical difficulties setting up your own WireGuard server, I can help you to set that up for small amount of **IDR** (_I accept **Monero XMR** for **credits** if you don't have Indonesia Rupiah_).
- To find out how to contact me, please visit [https://www.ditatompel.com/pages/contact](https://www.ditatompel.com/pages/contact).
