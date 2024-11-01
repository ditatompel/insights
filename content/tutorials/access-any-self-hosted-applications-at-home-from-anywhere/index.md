---
title: Access Any Self-Hosted Applications at Home From Anywhere
description: The goal of this article is to demonstrate how I can access my photos and videos at home from anywhere, using a network tunnel to connect to my local Immich server.
summary: How I can access my Immich application at home from anywhere.
# linkTitle:
date: 2024-10-23T07:50:00+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
categories:
    - Self-Hosted
tags:
    - Immich
    - WireGuard
    - Nginx
    - Cloudflare
    - DNS
    - MikroTik
    - AdGuard
images:
authors:
    - ditatompel
---

There are many ways to expose HTTP services behind NAT so that they can be
accessed from the internet. The technique commonly employed involves setting
up a network tunnel using VPN and an HTTP reverse proxy. [Cloudflare
Tunnel][cloudflare-tunnel] is one example.

In this article, I want to share my experience and how I expose HTTP services
on a local network to the internet using WireGuard VPN tunnel and Nginx as an
HTTP reverse proxy. The HTTP service I will expose is [Immich][immich-web].
For those who don't know, Immich is a self-hosted photo and video management
solution; an alternative to [Google Photos][google-photos].

I won't discuss the details of how to install Immich because [installing Immich
using Docker][immich-docker-install] is very easy to do. Instead, I'll focus on
the configuration of Nginx and VPN tunnel, as well as the [topology
used](#topology).

{{< youtube RIiSldGZuD0 >}}

## Prerequisites

Before we get started, there are a few conditions that need to be met:

1. A domain name or subdomain that uses Cloudflare as its authoritative DNS
   server.
2. A VPS with a public IP address (WireGuard and Nginx installed, which will
   later be used for reverse proxying the local network).
3. A PC, VM, or LXC on the local network to run Immich, Nginx, Docker, and
   Certbot.

## Topology

When writing this article, I used the following network topology:

![network topology image](topology.jpg#center)

To provide further context, let me break down the components of the above
topology:

-   The subdomain used for Immich is `i.arch.or.id`.
-   The public IP address of the VPS server is `154.26.xxx.xx`.
-   The VPS server's WireGuard tunnel IP address is `10.88.88.51`.
-   The local area network (LAN) uses the `192.168.2.0/24` subnet.
-   Immich is installed on an LXC container located on the local network,
    with an IP address of `192.168.2.105`.
-   The Immich LXC is connected to the VPS server and utilizes the IP tunnel
    `10.88.88.105`.
-   Nginx and Certbot are also installed on the Immich LXC.

The ultimate goal of this article is to demonstrate how I can access my photos
and videos at home from anywhere, using a network tunnel to connect to my local
Immich server. This setup allows me to synchronize or upload files faster when
I'm at home, while still being able to access my media remotely through the
Immich application.

## Configuration

### Cloudflare: DNS records & Edge Certificates

To configure Cloudflare, you need to delegate the authoritative DNS server and
add or point the `A`/`AAAA` record for the subdomain that will be used by
Immich to your VPS public IP. In this article, I pointed the `A` record
`i.arch.or.id` to the IP `154.26.xxx.xx`.

![](cf-dns-record.jpg#center)

To ensure that LXC on your local network can make a smooth request for SSL
certificates using Certbot, you'll need to modify several default Cloudflare
settings:

1. Update the **encryption mode** to `Full`. To do this, navigate to domain
   management -> **SSL/TLS** -> **Overview**, and modify the **"SSL/TLS
   encryption"** to `Full`. This is necessary for Cloudflare to accept the
   _"self-signed certificate"_ from the _origin server_.
   ![](cf-encryption-mode.jpg#center)
2. Disable both **"Always Use HTTPS"** and **"Automatic HTTPS Rewrites"**. To
   achieve this, go to domain management -> **Edge Certificates**, and ensure
   that these features are not active. This is necessary for the SSL request
   verification from LXC to the **Let's Encrypt** server to run smoothly.
   ![](cf-automatic-https.jpg#center)

### VPS: WireGuard & Nginx

You need to set up and run WireGuard on the VPS server which will be used to
communicate with the LXC server on the local network. If you're new to
WireGuard configuration, I recommend reviewing my previous articles on [setting
up a WireGuard VPN server manually]({{< ref "/tutorials/how-to-setup-your-own-wireguard-vpn-server/index.id.md" >}})
or [using WireGuard-UI]({{< ref "/tutorials/installing-wireguard-ui-to-manage-your-wireguard-vpn-server/index.id.md" >}}).

Here's an example of my WireGuard configuration on my VPS server:

```plain
[Interface]
PrivateKey = SomeRandomStringThatShouldBePrivate
Address = 10.88.88.51/22
ListenPort = 51822

# Immich LXC server
[Peer]
PublicKey = SomeRandomStringThatPublicMayKnow
AllowedIPs = 10.88.88.105/32
```

Next, I configured Nginx on the VPS server as a reverse proxy to the LXC
server. My Nginx configuration is similar to the following:

```nginx
upstream immich_app {
    server 10.88.88.105:443;
}

server {
    listen 80;
    listen 443 ssl;
    server_name i.arch.or.id;

    # Self-signed certificates
    ssl_certificate /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;

    # Acme challenge handler
    location /.well-known/acme-challenge/ {
        allow all;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        # This avoid SSL_do_handshake() failed on HTTPS upstream
        proxy_ssl_name $host;
        proxy_ssl_server_name on;
        proxy_ssl_verify off;

        proxy_pass https://immich_app;
    }

    keepalive_timeout    70;
    sendfile             on;
    client_max_body_size 100m;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        # This avoid SSL_do_handshake() failed on HTTPS upstream
        proxy_ssl_name $host;
        proxy_ssl_server_name on;
        proxy_ssl_verify off;

        # enable websockets: http://nginx.org/en/docs/http/websocket.html
        proxy_http_version 1.1;
        proxy_set_header   Upgrade    $http_upgrade;
        proxy_set_header   Connection "upgrade";
        proxy_redirect     off;

        proxy_pass https://immich_app;
    }
}
```

It's worth noting that Nginx virtual host configuration for `i.arch.or.id` on
the VPS server uses _Self-signed certificates_ for SSL/TLS encryption. This
isn't an issue, as we've previously configured Cloudflare's SSL/TLS
**encryption mode** to `Full`.

With this configuration in place, HTTP requests from the internet are routed
through Cloudflare and utilize a valid SSL certificate from Cloudflare. The
request is then forwarded to the VPS server and subsequently to the LXC server
via the WireGuard VPN tunnel.

### Local LXC: WireGuard, Immich (Docker), Nginx, Certbot

Install WireGuard and configure it to connect to the WireGuard server on the
VPS. Here's an example of my WireGuard configuration on my LXC server:

```plain
[Interface]
PrivateKey = SomeRandomStringThatShouldBePrivateII
Address = 10.88.88.105/22

# VPS server
[Peer]
PublicKey = SomeRandomStringThatPublicMayKnowII
AllowedIPs = 10.88.88.51/32
Endpoint = 154.26.xxx.xxx:51822
PersistentKeepalive = 15
```

Next, install Immich by following the process outlined on its official website
for [installing Immich using Docker][immich-docker-install]. By default,
Immich will use TCP port `2283`.

Create an Nginx virtual host configuration for Immich. On my local LXC server,
Nginx will function as a reverse proxy and handle Acme challenges to obtain a
valid certificate. Here's an example of the Nginx virtual host configuration
for Immich:

```nginx
upstream immich_app {
    server 127.0.0.1:2283;
}

server {
    listen 80;
    server_name i.arch.or.id;
    root /srv/http/default;

    location /.well-known/acme-challenge/ {
        allow all;
    }
    location / { return 301 https://$host$request_uri; }
}

server {
    listen 443 ssl;
    server_name i.arch.or.id;
    ssl_certificate /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;

    # allow large file uploads
    client_max_body_size 50000M;

    location / {
        # Set headers
        proxy_set_header Host              $http_host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # enable websockets: http://nginx.org/en/docs/http/websocket.html
        proxy_http_version 1.1;
        proxy_set_header   Upgrade    $http_upgrade;
        proxy_set_header   Connection "upgrade";
        proxy_redirect     off;

        proxy_pass http://immich_app;
    }
}
```

From the configuration above, it is clear that I initially uses a self-signed
certificate. Later, the certificate will be automatically replaced with a valid
one from Let's Encrypt, utilizing Certbot.

> **Note**: Before requesting an SSL certificate, ensure that the connection
> between the VPS server and LXC via the WireGuard tunnel is running smoothly.
> Also, verify that the Nginx configuration on both the VPS server and LXC
> server is correctly set up.

Install the Certbot Nginx plugin. On Ubuntu-based systems, you can install the
certbot Nginx plugin using `sudo apt install python3-certbot-nginx`. After
installing the plugin, request an SSL certificate from the XLC server:

```shell
sudo certbot --nginx -d i.arch.or.id
```

Replace `i.arch.or.id` with your (sub)domain.

### LAN: Local DNS resolver

The final step is to configure devices on the local area network (LAN) so that
the subdomain `i.arch.or.id` resolves to the local IP address of the LXC server
(`192.168.2.105`). A reliable approach is to use a local DNS resolver that can
be utilized by all devices within the LAN network. The configuration for this
DNS resolver will depend on the specific characteristics of each LAN network.

For my LAN setup, I have two DNS resolvers. The first one is located on my
Router (MikroTik), and the second is AdGuard Home running on a Linux Container.
In addition, I utilize AdGuard home as a DHCP server for my local network.

Here's a capture of the DNS resolver configuration on my MikroTik router and
AdGuard Home:

![](lan-dns-resolver.jpg#center)

With this setup, all devices on the local network that obtain their IP
addresses via DHCP will immediately use the IP `192.168.2.105` when attempting
to access the subdomain `i.arch.or.id`.

## Limitations

-   Due to the 100MB per request upload limit imposed by Cloudflare (for its
    free version), the Immich synchronization process from the internet is
    likely to fail, particularly when synchronizing videos.

[cloudflare-tunnel]: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/ "Cloudflare Tunnel"
[immich-web]: https://immich.app/ "Immich website"
[immich-docker-install]: https://immich.app/docs/install/docker-compose "Install Immich using Docker"
[google-photos]: https://photos.google.com/ "Google Photos website"
