---
title: "Configure IPsec/XAuth VPN Clients"
description: "Following these steps allow you to configure your Android, iOS, MacOS, and Linux machine using IPsec/XAuth (Cisco IPsec) VPN."
# linkTitle:
date: 2019-07-01T03:50:10+07:00
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
  - XAuth
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

**IPsec/XAuth** mode is also called **"Cisco IPsec"**. This mode is generally **faster than IPsec/L2TP** with less overhead. **IPsec/XAuth** ("**Cisco IPsec**") is natively supported by **Android**, **iOS**, and **MacOS**. There is no additional software to install for them.

<!--more-->

> _**NOTICE**: You should [upgrade Libreswan](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/README.md#upgrade-libreswan) to the latest version due to **IKEv1** informational exchange packets not integrity checked ([CVE-2019-10155](https://libreswan.org/security/CVE-2019-10155))._

As a prerequisite to using this guide, and before continuing, you must make sure that you have successfully [set up your own IPsec VPN server]({{< ref "/tutorials/ipsec-l2tp-xauth-ikev2-vpn-server-auto-setup/index.md">}}). Following these steps allow you to configure your Android, iOS, MacOS, and Linux machine using **IPsec/XAuth** ("**Cisco IPsec**").

## MacOS Clients Configuration
- Go to **Network** section in **System Preferences**.
- Click the <kbd>+</kbd> button in the bottom-left corner of the window.
- Select **VPN** from the **Interface** drop-down menu.
- Select **Cisco IPSec** from the **VPN Type** drop-down menu.
![MacOS XAuth Config](xauth-mac-conf.png#center)
- **Service Name**: enter anything you like (usually name of the VPN connection).
- Click **Create**.
- **Server Address**: Your VPN `Server IP`.
- **Account Name**: Your VPN `Username`.
- **Password**: Your VPN `Password`.
- Click the **Authentication Settings** button.
- In the **Machine Authentication** section, select the **Shared Secret** radio button and enter Your VPN `IPsec PSK`.
- Leave the **Group Name** field blank.
- Click **OK**.
- **Show VPN status in menu bar** checked.
- Click **Apply** to save the VPN connection information.

To connect to the VPN: Use the menu bar icon, or go to the Network section of System Preferences, select the VPN and choose Connect. You can verify that your traffic is being routed properly by [looking up your IP address on DuckDuckGo](https://duckduckgo.com/?q=ip&ia=answer).

## iOS (iPhone/iPad) Clients Configuration
- Go to **Settings** -> **General** -> **VPN**.
- Tap **Add VPN Configuration**....
- Tap **Type**. Select **IPSec** and go back.
- **Description**: enter anything you like (usually name of the VPN connection).
- **Server**: Your VPN `Server IP`.
- **Account**: Your VPN `Username`.
- **Password**: Your VPN `Password`.
- Leave the **Group Name** field blank.
- **Secret**: Your VPN `IPsec PSK`.
- Tap **Done** and slide **VPN** switch **ON**.
![iPhone XAuth config](xauth-iphone.jpg#center)

Once connected, you will see a VPN icon in the status bar. You can verify that your traffic is being routed properly by [looking up your IP address on DuckDuckGo](https://duckduckgo.com/?q=ip&ia=answer).

## Android Clients Configuration
- Go to **Settings** > **Wireless & Networks** > **VPN**.
- **Add VPN Profile** by tapping the <kbd>+</kbd> icon at top-right of screen.
- **Name**: enter anything you like (usually name of the VPN connection).
- **Type**: Choose **IPSec Xauth PSK**.
- **Server address**: Your VPN `Server IP`.
- Leave the **IPSec identifier** field blank.
- **IPSec pre-shared key**: Your VPN `IPsec PSK`.
- Tap **Save**.
- Tap the new VPN connection.
- **Username**: Your VPN `Username`.
- **Password**: Your VPN `Password`.
- Check the **Save account information** checkbox.
- Tap **Connect**.
![Android XAuth config](xauth-android.jpg#center)

Once connected, you will see a VPN icon in the notification bar. You can verify that your traffic is being routed properly by [looking up your IP address on DuckDuckGo](https://duckduckgo.com/?q=ip&ia=answer).

## Linux Clients Configuration
### Fedora and CentOS
**Fedora** > `28` and **CentOS 7** users can install the [NetworkManager-libreswan-gnome](https://apps.fedoraproject.org/packages/s/libreswan) package, then configure the IPsec/XAuth VPN client using the GUI.

- Go to **Settings** -> **Network** -> **VPN**. Click the <kbd>+</kbd> button.
- Select **IPsec based VPN**.
- **Name**: enter anything you like (usually name of the VPN connection).
- **Gateway**: Your VPN `Server IP`.
- **Type**: Select **IKEv1 (XAUTH)**.
- **User name**: Your VPN `Username`.
- **Password**: Your VPN `Password` (click the <kbd>?</kbd> in the password field, select **Store the password only for this user**)
- Leave the **Group name** field blank.
- **Secret**: Your VPN `IPsec PSK` (click the <kbd>?</kbd> in the password field, select **Store the password only for this user**)
- Leave the **Remote ID** field blank.
- Click **Add** to save the VPN connection information.
- Turn the **VPN** switch ON.

Once connected, you will see a VPN icon in the notification bar. You can verify that your traffic is being routed properly by [looking up your IP address on DuckDuckGo](https://duckduckgo.com/?q=ip&ia=answer).

### Other Linux
Other Linux users can connect using [IPsec/L2TP]({{< ref "/tutorials/configure-ipsec-l2tp-vpn-clients/index.md" >}}) mode.

## Windows Clients Configuration
Since I don't have any **Windows** machine, you can follow [source documentation](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#windows) by Lin Song.

## Credits
- All articles credits belongs to [Lin Song](https://www.linkedin.com/in/linsongui/) and [contributors](https://github.com/hwdsl2/setup-ipsec-vpn/graphs/contributors).
- Feature image credit to [Tyler Franta](https://unsplash.com/@tfrants) on **Unsplash**.

## Links and Resources
- [https://github.com/hwdsl2/setup-ipsec-vpn](https://github.com/hwdsl2/setup-ipsec-vpn)
- [https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients-xauth.md](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients-xauth.md)
- [https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#troubleshooting](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#troubleshooting)