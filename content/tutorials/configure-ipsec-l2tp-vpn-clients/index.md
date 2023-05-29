---
title: "Configure IPsec/L2TP VPN Clients"
description: "This is the next part after you successfully set up your own IPsec VPN server. Following these steps allow you to configure your Android, iOS, MacOS, and Linux machine using IPsec/L2TP VPN."
# linkTitle:
date: 2019-07-01T03:44:00+07:00
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
  - MacOS
  - iPhone
  - Android
  - Linux
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

This is the next part after you successfully [set up your own IPsec VPN server]({{< ref "/tutorials/ipsec-l2tp-xauth-ikev2-vpn-server-auto-setup/index.md">}}). Following these steps allow you to configure your **Android**, **iOS**, **MacOS**, and **Linux** machine using **IPsec/L2TP** VPN.

**IPsec/L2TP** is natively supported by Android, iOS, OS X, and Windows, so there is no additional software to install for them. Setup should only take a few minutes. For Linux users, additional [L2TP network manager](https://github.com/nm-l2tp/NetworkManager-l2tp?ref=rtd.ditatompel.com) package needs to be installed.

<!--more-->

> **Note**:
> * You may also connect using the faster [IPsec/XAuth mode]({{< ref "/tutorials/ipsec-l2tp-xauth-ikev2-vpn-server-auto-setup/index.md" >}}), or [set up IKEv2]({{< ref "/tutorials/set-up-ikev2-vpn-server-and-clients/index.md" >}}).
> * To avoid connection issues when connecting multiple devices simultaneously from behind the same NAT (e.g. home router), use [IPsec/XAuth mode]({{< ref "/tutorials/ipsec-l2tp-xauth-ikev2-vpn-server-auto-setup/index.md" >}}).

## MacOS Clients Configuration
- Go to **Network** section in **System Preferences**.
- Click the <kbd>+</kbd> button in the bottom-left corner of the window.
- Select **VPN** from the **Interface** drop-down menu.
- Select **L2TP over IPSec** from the **VPN Type** drop-down menu.
- S**ervice Name**: enter anything you like (usually name of the VPN connection).
- Click **Create**.
- **Server Address**: Your VPN `Server IP`.
- **Account Name**: Your VPN `Username`.
- **Show VPN status in menu bar** checked.
- Click the **Authentication Settings** button.
- In the **User Authentication** section, select the **Password** radio button and enter Your VPN `Password`.
- In the **Machine Authentication** section, select the **Shared Secret** radio button and enter Your VPN `IPsec PSK`.
![L2TP MacOS setting 1](l2tp-mac-auth-2.png#center)
- (**Important**) Click the **Advanced** button and make sure the **Send all traffic over VPN connection** checkbox is checked.
![L2TP MacOS setting 2](l2tp-mac-all-con.png#center)
- Click the **TCP/IP** tab, and make sure **Link-local only** is selected in the **Configure IPv6** section.
- Click **OK** to close the Advanced settings, and then click **Apply** to save the VPN connection information.

To connect to the VPN: Use the menu bar icon, or go to the **Network** section of **System Preferences**, select the VPN and choose **Connect**. You can verify that your traffic is being routed properly by [looking up your IP address on DuckDuckGo](https://duckduckgo.com/?q=ip&ia=answer).

## iOS (iPhone/iPad) Clients Configuration
- Go to **Settings** -> **General** -> **VPN**.
- Tap **Add VPN Configuration**....
- Tap **Type**. Select **L2TP** and go back.
- Description: enter anything you like (usually name of the VPN connection).
- **Server**: Your VPN `Server IP`.
- **Account**: Your VPN `Username`.
- **Password**: Your VPN `Password`.
- **Secret**: Your VPN `IPsec PSK`.
- Make sure the **Send All Traffic** switch is **ON**.
- Tap **Done** and slide **VPN** switch **ON**.
![L2TP iPhone setting](l2tp-iphone.jpg#center)

Once connected, you will see a VPN icon in the status bar. You can verify that your traffic is being routed properly by [looking up your IP address on DuckDuckGo](https://duckduckgo.com/?q=ip&ia=answer).

## Android Clients Configuration
- Go to **Settings** > **Wireless & Networks** > **VPN**.
- **Add VPN Profile** by tapping the <kbd>+</kbd> icon at top-right of screen.
- **Name**: enter anything you like (usually name of the VPN connection).
- **Type**: Choose **L2TP/IPSec PSK**.
- **Server address**: Your VPN `Server IP`.
- Leave **L2TP secret** & **IPSec identifier** field blank.
- I**PSec pre-shared key**: Your VPN `IPsec PSK`.
- Tap **Save**.
- Tap the new VPN connection.
- **Username**: Your VPN `Username`.
- **Password**: Your VPN `Password`.
- Check the **Save account information** checkbox.
- Tap **Connect**.
![L2TP Android setting](l2tp-android.jpg#center)

Once connected, you will see a VPN icon in the notification bar. You can verify that your traffic is being routed properly by [looking up your IP address on DuckDuckGo](https://duckduckgo.com/?q=ip&ia=answer).

## Linux Clients Configuration
First check [here](https://github.com/nm-l2tp/network-manager-l2tp/wiki/Prebuilt-Packages) to see if the `network-manager-l2tp` and `network-manager-l2tp-gnome` packages are available for your Linux distribution. If yes, install them (Use **strongSwan**). After packages installation done, add your VPN connection.

- Go to **Settings** -> **Network** -> **VPN**. Click the <kbd>+</kbd> button.
- Select **Layer 2 Tunneling Protocol (L2TP)**.
- **Name**: enter anything you like (usually name of the VPN connection).
- **Gateway**: Your VPN `Server IP`.
- **User name**: Your VPN `Username`.
- **Password**: Your VPN `Password` (click the <kbd>?</kbd> in the password field, select **Store the password only for this user**)
- Leave the **NT Domain** field blank.
- Click the **IPsec Settings**... button.
![L2TP Linux 1](l2tp-linux-1.png#center)
- **Enable IPsec tunnel to L2TP host**: **checked**.
- Leave the **Gateway ID** field blank.
- **Pre-shared key**: Your VPN `IPsec PSK`.
- Expand the **Advanced** section.
- Enter `aes128-sha1-modp2048!` for the **Phase1 Algorithms** and **Phase2 Algorithms**.
![L2TP Linux 2](l2tp-linux-2.png#center)

For **Fedora** > `28` and **CentOS 7** users can connect using the faster [IPsec/XAuth mode]({{< ref "/tutorials/ipsec-l2tp-xauth-ikev2-vpn-server-auto-setup/index.md" >}}). Alternatively, you may [configure Linux VPN L2TP clients using the command line](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#configure-linux-vpn-clients-using-the-command-line).

## Windows Clients Configuration
Since I don't have any Windows machine, you can follow [source documentation](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#windows) by Lin Song.

## Credits
- All articles credits belongs to [Lin Song](https://www.linkedin.com/in/linsongui/) and [contributors](https://github.com/hwdsl2/setup-ipsec-vpn/graphs/contributors).
- Feature Image credit to [Richard Patterson](http://www.comparitech.com/).

## Links and Resources
* [https://github.com/hwdsl2/setup-ipsec-vpn](https://github.com/hwdsl2/setup-ipsec-vpn)
* [https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#troubleshooting](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#troubleshooting)