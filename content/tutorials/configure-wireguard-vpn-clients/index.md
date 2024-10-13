---
title: "Configure WireGuard VPN Clients"
description: "Information about how to import your WireGuard VPN config to your Android, iOS, MacOS, Windows and Linux machine."
summary: "This article contains information about how to import your WireGuard VPN config to your Android, iOS/iPhone, macOS, Windows and Linux machine."
# linkTitle:
date: 2023-06-06T23:51:13+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
series:
    - WireGuard VPN
categories:
    - Privacy
    - Networking
tags:
    - WireGuard
    - iPhone
    - Android
    - Linux
    - Windows
    - MacOS
images:
authors:
    - ditatompel
---

This article is part of [**WireGuard VPN** series](https://insights.ditatompel.com/en/series/wireguard-vpn/). If you haven't read the previous series, you might be interested to [set up your own **WireGuard VPN server** using cheap ~$6 VPS]({{< ref "/tutorials/how-to-setup-your-own-wireguard-vpn-server/index.md" >}}) or [installing **WireGuard-UI** to manage your **WireGuard VPN server**]({{< ref "/tutorials/installing-wireguard-ui-to-manage-your-wireguard-vpn-server/index.md" >}}).

[WireGuard](https://www.wireguard.com/) was initially released for the **Linux kernel**, it is now _cross-platform_ (**Windows**, **macOS**, **BSD**, **iOS**, and **Android**). When you buy a **WireGuard VPN** from _VPN providers_, you will usually receive a configuration file (some providers also give you **QR Code** image). This configuration file is all you need.

For Windows, macOS, Android, and iOS, all you have to do is import the configuration file into the [official WireGuard application](https://www.wireguard.com/install/). For Linux who use `wg-quick` tool even simpler, you just have to copy the configuration file to the `/etc/wireguard` folder.

Even though the setup method is quite easy, I still want to write the steps on how to install or import the WireGuard configuration file here.

The WireGuard configuration file given by _VPN provider_ (or your **Sysadmins**) is just a text file, will usually look like this:

```plain
[Interface]
Address = 10.10.88.5/32
PrivateKey = gJc2XC/D2op6Y37at6tW1Sjl8gY/O/O4Apw+MDzAZFg=
DNS = 1.1.1.1
MTU = 1450

[Peer]
PublicKey = dW7TUSnRylgpo+rbNr1a55Wmg1lCBgjYnluiJhDuURI=
PresharedKey = Ps4+a+xQfwKFBx+yWHKF7grUP3rzilOCQDftZ5A3z08=
AllowedIPs = 0.0.0.0/0
Endpoint = xx.xx.xx0.246:51822
PersistentKeepalive = 15
```

> _Parts of IP address from `[Peer] Endpoint` above removed for privacy and security reason._

## iPhone / iOS

Download [official WireGuard client for iOS from App Store](https://apps.apple.com/us/app/wireguard/id1441195209?ls=1), make sure that the app comes from **"[WireGuard Development Team](https://apps.apple.com/us/developer/wireguard-development-team/id1441195208)"**.

You can import configuration file by pressing <kbd>+</kbd> button from the top right of the app.

### Using QR Code

1. If your VPN provider gives you **QR Code** image for your configuration, choose **"Create from QR code"** and scan your WireGuard configuration QR Code.
2. When promoted to enter **name of the scanned tunnel** ([_example image_](wg-ios1.png)), fill with anything you can easily remember. _Avoid using character other than `-` and `[a-z]`_. Your new VPN connection profile will be added to your WireGuard app.

### Using import file or archive

1. To import configuration from `.conf` file, you need to download the configuration file to your device.
2. After configuration file is downloaded to your device, select **"Create from file or archive"** and pick file of your WireGuard configuration file.
   _Remember to avoid using character other than `-` and `[a-z]` for the interface **"name"**_.

After your configuration was imported, simply tap **"Active" toggle button** of your desired VPN profile to **on** to connect [[_example image of connected WireGuard VPN in iOS app_](wg-ios2.png)].

## Android

Download [official WireGuard client for Android from Play Store](https://play.google.com/store/apps/details?id=com.wireguard.android), make sure that the app comes from **"[WireGuard Development Team](https://play.google.com/store/apps/developer?id=WireGuard+Development+Team)"**.

You can import configuration file by pressing <kbd>+</kbd> button from the bottom right of the app.

### Using QR Code

1. If your _VPN provider_ gives you **QR Code** image for your configuration, choose **"Scan from QR code"** and scan your WireGuard configuration QR Code.
2. When promoted to enter **Tunnel Name** ([_example image_](wg-android1.png)), fill with anything you can easily remember. _Avoid using character other than `-` and `[a-z]`_. Your new VPN connection profile will be added to your WireGuard app.

### Using import file or archive

1. To import configuration from `.conf` file, you need to download the configuration file to your device.
2. After configuration file is downloaded to your device, select **"Import from file or archive"** and pick file of your WireGuard configuration file.
   _Remember to avoid using character other than `-` and `[a-z]` for the interface **"name"**_.

After your configuration was imported, simply tap **"Active" toggle button** of your desired VPN profile to **on** to connect [[_example image of connected WireGuard VPN in Android app_](wg-android2.png)].

## Windows and macOS

I'll put Windows and macOS in the same section because importing WireGuard config on those OSes is pretty similar. After [official WireGuard application](https://www.wireguard.com/install/) for your OS is installed:

1. Click "**Add Tunnel**" button (or it's dropdown icon) and "**Import tunnel(s) from file…**", then pick file of your WireGuard configuration file.
2. After connected to your VPN profile, try to check your IP address. Your VPN server should appear as your public IP, not your ISP IP address.
   ![WireGuard VPN connected on Windows](wg-windows-connected.png#center)

## Linux

For Linux users, you need to install `wireguard` _package_ to your system. Find how to install WireGuard package from [official WireGuard](https://www.wireguard.com/install/) site or your _distribution_ documentation page.

### Using wg-quick

The easiest and simplest way to use WireGuard is using `wg-quick` tool that comes from `wireguard` _package_. Put your WireGuard configuration file from your VPN provider to `/etc/wireguard` and start WireGuard connection with:

```shell
sudo systemctl start wg-quick@<interface-name>.service.
```

Replace `<interface-name>` above with filename (without the `.conf` extension) of WireGuard config given by your VPN provider.

For example, If you rename the `wg0.conf` to `wg-do1.conf` in your `/etc/wireguard` directory, you can connect to that VPN network using `sudo systemctl start wg-quick@wg-do1.service`.

Try to check your WireGuard connection by check your public IP from your browser or terminal using `curl ifconfig.me`. If your IP address is not changed, your first command to troubleshot is `sudo wg show` or `sudo systemctl status wg-quick@wg-do1.service`.

> _**Note 1**: By default `wg-quick` uses `resolvconf` to register new **DNS** entries. This will cause issues with network managers and DHCP clients that do not use `resolvconf`, as they will overwrite `/etc/resolv.conf` thus removing the DNS servers added by `wg-quick`._  
> _The solution is to use networking software that supports `resolvconf`._

> _**Note 2**: Users of `systemd-resolved` should make sure that `systemd-resolvconf` is installed._

### Using NetworkManager

**NetworkManager** on _bleeding-edge_ _distros_ such as **Arch Linux** has native support for setting up WireGuard interface.

#### Using NetworkManager TUI & GUI

![NetworkManager tui](wg-nmtui.png#center)

You can easily configure WireGuard connection and _peers_ using **NetworkManager TUI** or **GUI**. In this example, I'll use **NetworkManager GUI**.

1. Open your **NetworkManager** GUI, click <kbd>+</kbd> to add new connection.
2. Choose "**Import a saved VPN configuration**" and pick file of your WireGuard configuration file.
3. Then, you can change "**Connection name**" and "**Interface name**" to anything you can easily remember. But, **avoid using character other than** `-` and `[a-z]` for "**Interface name**". It won't work if you use special character like _spaces_.

![NetworkManager gui](wg-nmgui.png#center)

#### Using nmcli

`nmcli` can import a `wg-quick` configuration file. For example, to import WireGuard configuration from `/etc/wireguard/t420.conf`:

```shell
nmcli connection import type wireguard file /etc/wireguard/t420.conf
```

Even though `nmcli` can create a WireGuard connection profile, but it does not support configuring peers.
The following examples configure WireGuard via the keyfile format `.nmconnection` files under `/etc/NetworkManager/system-connections/` for multiple peers and specific routes:

```plain
[connection]
id=WG-<redacted>
uuid=<redacted-uuid-string>
type=wireguard
autoconnect=false
interface-name=wg-<redacted>
timestamp=1684607233

[wireguard]
private-key=<redacted_base64_encoded_private_key>

[wireguard-peer.<redacted_base64_encoded_public_key>]
endpoint=<redacted_ip_address>:<redacted_port>
persistent-keepalive=15
allowed-ips=0.0.0.0/0;

[wireguard-peer.<redacted_base64_encoded_public_key>]
endpoint=<redacted_ip_address>:<redacted_port>
persistent-keepalive=15
allowed-ips=<redacted_specific_ip_network_routes_separated_by_semicolon>

[ipv4]
address1=10.10.88.2/24
dns=192.168.1.105;192.168.1.252;
method=manual

[ipv6]
addr-gen-mode=stable-privacy
method=ignore
```

![nmcli WireGuard connection example](wg-nmcli.png#center)

## Notes

-   You can't connect to the same VPN server from 2 or more different devices with same key. **You every device MUST have its own unique key**.
-   For some operating system such as Windows, if you can't import your WireGuard configuration file from your WireGuard app, make sure that your WireGuard configuration file is ended with `.conf`.

