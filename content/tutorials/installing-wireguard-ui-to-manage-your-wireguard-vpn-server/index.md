---
title: "Installing WireGuard-UI to Manage Your WireGuard VPN Server"
description: "To manage WireGuard peers (client) on a single server easily, you can use WireGuard-UI, a web-based user interface to manage your WireGuard setup written in Go."
# linkTitle:
date: 2023-06-06T04:20:43+07:00
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
  - WireGuard
  - WireGuard UI
  - Nginx
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

To manage **WireGuard** *peers* (client) on a single server easily, you can use **WireGuard-UI**, a web-based user interface to manage your WireGuard setup written in **Go**.

<!--more-->
---

[Wireguard-UI](https://github.com/ngoduykhanh/wireguard-ui) is a *web-based* user interface to manage your **WireGuard** server setup written by [ngoduykhanh](https://github.com/ngoduykhanh) using **Go** programming language. This is an alternative way to install and easily manage your WireGuard VPN server. 

If you prefer to install WireGuard server *"from scratch"* and manage it manually, you can follow my previous article about "[How to Setup Your Own WireGuard VPN Server]({{< ref "/tutorials/how-to-setup-your-own-wireguard-vpn-server/index.md" >}})".

## Prerequisites
- A **VPS** (**Ubuntu** `22.04 LTS`) with Public IP address and **Nginx** installed.
- Comfortable with Linux *command-line*.
- Basic knowledge of _**IPv4** subnetting_ (_to be honest, I'm not familiar with IPv6 subnetting, so this article is for **IPv4** only_).
- Able to configure **Nginx** *Virtual Host*.

In this guide, our goals:
- Server run _**WireGuard** daemon_ listen on port `51822/UDP`.
- **WireGuard UI** run from `127.0.0.1` on port `5000`.
- **Nginx** act as *reverse proxy* and serve **WireGuard UI** service using **HTTPS**.

## Prepare Your Server
First, make sure your system is *up-to-date* and **WireGuard is installed** on your server. 
```shell
sudo apt update && sudo apt upgrade
sudo apt install wireguard
```

Edit `/etc/sysctl.conf` and add `net.ipv4.ip_forward=1` to the end of the file, then run `sudo sysctl -p` to load the new `/etc/sysctl.conf` values.
```shell
sudo sysctl -p
```
This is required to allow **IP forwarding** on your server.

### Setting up Firewall
By default, **Ubuntu** system use comes with **UFW** to manage system *firewall*. You need to **add WireGuard listen port to firewall allow list**.
```shell
sudo ufw allow OpenSSH
sudo ufw allow 80 comment "allow HTTP" # will be used by Nginx
sudo ufw allow 443 comment "allow HTTPS" # will be used by Nginx
sudo ufw allow proto udp to any port 443  comment "allow QUIC" # If your Nginx support QUIC
sudo ufw allow proto udp to any port 51822 comment "WireGuard listen port"
```
> _Note that I also add **OpenSSH** to allow list to avoid losing connection to SSH if you didn't configure / activate it before._

Enable / restart your `ufw` service using:
```shell
sudo ufw enable # to enable firewall, or
sudo ufw reload # to reload firewall
```


## Download & Configure WireGuard-UI
Download [Wireguard-UI from its latest release page](https://github.com/ngoduykhanh/wireguard-ui/releases) to your server. Choose the one that match with your **server OS** and **CPU architecture**.

Extract downloaded `.tar.gz` file:
```shell
tar -xvzf  wireguard-ui-*.tar.gz
```

Create new directory `/opt/wireguard-ui` and move the `wireguard-ui` *binary* (from extracted `.tar.gz` file) to `/opt/wireguard-ui`.

```shell
mkdir /opt/wireguard-ui
mv wireguard-ui /opt/wireguard-ui/
```

Create environment file for WireGuard-UI (This will be loaded using `EnvironmentFile` from `systemd` unit file later):
```plain
# /opt/wireguard-ui/.env
SESSION_SECRET=<YOUR_STRONG_RANDOM_SECRET_KEY>
WGUI_USERNAME=<YOUR_WIREGUARD_UI_USERNAME>
WGUI_PASSWORD=<YOUR_WIREGUARD_UI_PASSWORD>
```

If you want to enable email feature, you need to set up your `SMTP_*` environment variable. See [WireGuard UI Environment Variables details](https://github.com/ngoduykhanh/wireguard-ui#environment-variables) for more information.

### Finding Server Default Interface
Then, find out which network interface used by your server as its *default route*. You can use `ip route list default` to see that. Example output of my `ip route list default` command:
```plain
default via 164.90.160.1 dev eth0 proto static
```
Write down the word after `dev` output, that's your default network interface. We will need that information later. In this example, my default network interface is `eth0`. 

Create `/opt/wireguard-ui/postup.sh`, and fill with this example config:
```bash
#!/usr/bin/bash
# /opt/wireguard-ui/postup.sh
ufw route allow in on wg0 out on eth0
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
```
The `postup.sh` bash script above will be executed when WireGuard service is **started**.

Create `/opt/wireguard-ui/postdown.sh`. and fill with this example config:
```bash
#!/usr/bin/bash
# /opt/wireguard-ui/postdown.sh
ufw route delete allow in on wg0 out on eth0
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```
The `postdown.sh` bash script above will be executed when WireGuard service is **stopped**.

Replace `eth0` value from those two bash script above with your default network interface (*see [Finding Server Default Interface section](#finding-server-default-interface) above*).

Then, make those two bash script (`/opt/wireguard-ui/postup.sh` and `/opt/wireguard-ui/postdown.sh`) executable:
```shell
chmod +x /opt/wireguard-ui/post*.sh
```

### WireGuard-UI daemon SystemD
To manage **WireGuard-UI** daemon (Web UI) using `systemd`, create `/etc/systemd/system/wireguard-ui-daemon.service` systemd file, and fill with this following configuration:
```systemd
[Unit]
Description=WireGuard UI Daemon
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
WorkingDirectory=/opt/wireguard-ui
EnvironmentFile=/opt/wireguard-ui/.env
ExecStart=/opt/wireguard-ui/wireguard-ui -bind-address "127.0.0.1:5000"

[Install]
WantedBy=multi-user.target
```
The `systemd` configuration will run WireGuard UI daemon on `127.0.0.1:5000`.

Now reload your `systemd` daemon configuration and try to start `wireguard-ui-daemon.service`.
```shell
sudo systemctl daemon-reload
sudo systemctl start wireguard-ui-daemon.service
```

Verify your `wireguard-ui-daemon.service` is running properly by using `systemctl status wireguard-ui-daemon.service`:
```plain
● wireguard-ui-daemon.service - WireGuard UI Daemon
     Loaded: loaded (/etc/systemd/system/wireguard-ui-daemon.service; disabled; vendor preset: enabled)
     Active: active (running) since Mon 2023-06-05 23:57:47 UTC; 5s ago
   Main PID: 4388 (wireguard-ui)
      Tasks: 4 (limit: 1115)
     Memory: 17.1M
        CPU: 1.243s
     CGroup: /system.slice/wireguard-ui-daemon.service
             └─4388 /opt/wireguard-ui/wireguard-ui -bind-address 127.0.0.1:5000

Jun 05 23:57:47 fra1-do1 wireguard-ui[4388]: Git Ref                : refs/tags/v0.5.1
Jun 05 23:57:47 fra1-do1 wireguard-ui[4388]: Build Time        : 06-05-2023 23:57:47
Jun 05 23:57:47 fra1-do1 wireguard-ui[4388]: Git Repo        : https://github.com/ngoduykhanh/wireguard-ui
Jun 05 23:57:47 fra1-do1 wireguard-ui[4388]: Authentication        : true
Jun 05 23:57:47 fra1-do1 wireguard-ui[4388]: Bind address        : 127.0.0.1:5000
Jun 05 23:57:47 fra1-do1 wireguard-ui[4388]: Email from        :
Jun 05 23:57:47 fra1-do1 wireguard-ui[4388]: Email from name        : WireGuard UI
Jun 05 23:57:47 fra1-do1 wireguard-ui[4388]: Custom wg.conf        :
Jun 05 23:57:47 fra1-do1 wireguard-ui[4388]: Base path        : /
Jun 05 23:57:49 fra1-do1 wireguard-ui[4388]: ⇨ http server started on 127.0.0.1:5000
```

If everything works well, you can see that **WireGuard-UI** is listening on `127.0.0.1:5000` (but, for now, you cannot access the web UI from remote machine until you finished the *[Configuring Nginx for WireGuard-UI section](#configuring-nginx-for-wireguard-ui)* below). 

Make `wireguard-ui-daemon.service` run at start up:
```shell
sudo systemctl enable wireguard-ui-daemon.service
```


### Auto Restart WireGuard Daemon
Because **WireGuard-UI** only takes care of WireGuard configuration generation, you need another `systemd` to watch for the changes and restart the **WireGuard** service. Create `/etc/systemd/system/wgui.service` and fill with this following example:
```systemd
[Unit]
Description=Restart WireGuard
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl restart wg-quick@wg0.service

[Install]
RequiredBy=wgui.path
```

Then, create `/etc/systemd/system/wgui.path`:
```systemd
[Unit]
Description=Watch /etc/wireguard/wg0.conf for changes

[Path]
PathModified=/etc/wireguard/wg0.conf

[Install]
WantedBy=multi-user.target
```

Apply `systemd` configurations changes by issuing this following commands:
```shell
systemctl daemon-reload
systemctl enable wgui.{path,service}
systemctl start wgui.{path,service}
```

### Configuring Nginx for WireGuard-UI
If **Nginx** not installed on your server, you need to install it first. You can use Nginx from **Ubuntu default repository** or using [Nginx official repository for Ubuntu](https://nginx.org/en/linux_packages.html#Ubuntu).

After Nginx installed, create **Nginx virtual host server block** for WireGuard UI:

```nginx
server {
    listen 80;
    server_name wgui.example.com;
    root /usr/share/nginx;
    access_log off;
    location /.well-known/acme-challenge/ { allow all; }
    location / { return 301 https://$host$request_uri; }
}

server {
    listen 443 ssl http2;
    server_name wgui.example.com;
    access_log off;

    ssl_certificate     /path/to/your/ssl/cert/fullchain.pem;
    ssl_certificate_key /path/to/your/ssl/cert/privkey.pem;

    root /usr/share/nginx;
    location / {
        add_header Cache-Control no-cache;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_pass http://127.0.0.1:5000/;
    }
}
```
- Replace `wgui.example.com` with your (sub)domain name.
- Replace `ssl_certificate` and `ssl_certificate_key` with your certificate files.

Now restart your nginx configuration `sudo systemctl restart nginx`.

**Please note** that Nginx server block configuration above is **very basic config**. If you need recommended SSL configuration for Nginx, follow this [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/). If you want to use [Let's Encrypt](https://letsencrypt.org/) certificate, install `python3-certbot-nginx` and request your certificate using `certbot --nginx -d wgui.example.com`.

## Using WireGuard-UI
Now after configuring all those required services, it's time to **configure our WireGuard config using WireGuard-UI**. Go to your WireGuard-UI (sub)domain and login with username and password you've configured before from `/etc/wireguard-ui/.env`.

> _**Do not** press **"Apply Config"** before you finished configuring your WireGuard setting from WireGuard UI._

Go to **"WireGuard Server"** page and configure WireGuard config:
- **Server Interface Addresses**: `10.10.88.1/24`
- **Listen Port**: `51822`
- **Post Up Script**: `/opt/wireguard-ui/postup.sh`
- **Post Down Script**: `/opt/wireguard-ui/postup.sh`

![WireGuard- UI Server Settings](wg-ui-server-config.png#center)

Then go to **"Global Settings"**, verify that all your config is correct (especially for **"Endpoint Address"** and **"Wireguard Config File Path"**).

After that, try to **Apply** your configuration.

Verify that everything is running (try to check using `wg show` or `ss -ulnt` from *command-line*).

### Creating Peer (client)
Creating peers using WireGuard UI is pretty simple, all you need to do is press **"+ New Client"** button from the top right of the page and fill required information. You only need to fill **"Name"** field for most use case.

After adding your peers (clients), press **"Apply Config"** and try to connect to your WireGuard VPN server from your devices. The configuration file for your devices can be downloaded from **WireGuard UI**. You can also easily scan configuration for your mobile devices by scanning configuration **QR code**.

![WireGuard UI clients page](wg-ui-clients.png#center)

What next? How about [Configure WireGuard VPN Clients]({{< ref "/tutorials/configure-wireguard-vpn-clients/index.md" >}})?

### Notes
- If you have some technical difficulties setting up your own WireGuard server, I can help you to set that up for small amount of **IDR** (_I accept **Monero XMR** for **credits** if you don't have Indonesia Rupiah_).
- To find out how to contact me, please visit [https://www.ditatompel.com/pages/contact](https://www.ditatompel.com/pages/contact).