---
title: "Running Wakapi, a Self-Hosted WakaTime Compatible Backend for Coding Stats"
description: "A guide to install Wakapi, a self-hosted WakaTime compatible backend for your coding stats"
# linkTitle:
date: 2023-08-21T01:18:54+07:00
lastmod:
draft: false
noindex: false
featured: false
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
  - Programming
  - SysAdmin
  - Privacy
tags:
  - WakaTime
  - Wakapi
  - Nginx
  - Go
  - ActivityWatch
  - CodeStats
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

**Wakapi** is a minimalist, __self-hosted__ **WakaTime**-compatible backend for coding statistics. It's cross platform (Windows, MacOS, Linux) and can be self-hosted to your local computer or your own server, so your data is really yours. This article will guide you how to run Wakapi on Linux operating system.

<!--more-->
---

## Introduction

As someone who extensively use computers on a daily basis, particularly performing server maintenance and coding, I'm always curious about what I've been working on, which projects consume the most of my time, and which programming languages I use the most. Over the past year, I've tried several services, from [Activity Watch](https://activitywatch.net/), [CodeStats](https://codestats.net/) to [WakaTime](https://wakatime.com/).

With **Activity Watch**, while the backend can be installed on a local or remote server, I found it to be somewhat _resource-intensive_. While **CodeStats** and **WakaTime** were really good, the coding statistics data was sent to their servers; this aspect was a concern for me.

A few days ago, I found a solution for that problem: [Wakapi](https://wakapi.dev/). It's an API endpoint **compatible with the WakaTime client**, and it can be _self-hosted_.

The **Wakapi server** is built using the **Go** programming language and can be run on various operating systems, including Windows, MacOS (both `ARM` and `x86_64`), and Linux (both `ARM` and `x86_64`). In this article, I want to share my experience installing and running Wakapi on a Linux server.

## Server Installation

Before we begin, there are some prerequisites to meet in order to follow this article:
- Comfortable using Linux terminal
- A WakaTime client already installed and working properly
- A Linux server / laptop / PC
- A web server (for this article, I'm using Nginx. _Optional, but **recommended if Wakapi will be accessed publicly**_)

There are a few ways to run your own Wakapi server:
1. Using precompiled binary
2. Using Docker
3. Compiling from source code

Since **Go** is already installed on my server, I'll be using the third option here — compiling directly from source code.
 
 ### System Preparation & Compiling Executable Binary

First, prepare the system by creating a new system user:

```shell
sudo useradd -r -m --system -d /opt/wakapi -s /bin/bash wakapi
```

Clone the [mutey/wakapi repository](https://github.com/muety/wakapi) and compile the executable binary:

```shell
# clone repo
git clone https://github.com/muety/wakapi.git

# build executable binary
cd wakapi
go build -o wakapi
```

### Wakapi Configuration Setup

After the compilation process is complete, move the executable binary to the `wakapi`'s `$HOME` directory that we created earlier:
```shell
sudo mv wakapi /opt/wakapi/
```

Download a sample configuration:

```shell
sudo curl -o /opt/wakapi/wakapi.yml https://raw.githubusercontent.com/muety/wakapi/master/config.default.yml
# Change file ownership to the wakapi user
sudo chown wakapi:wakapi /opt/wakapi/wakapi.yml /opt/wakapi/wakapi
```

Then, edit the `/opt/wakapi/wakapi.yml` configuration file as needed. For instance, if I'm using the subdomain `wakapi.example.com` with **Nginx** as a _reverse proxy_ for Wakapi, I'd set the `listen_ipv4` to `127.0.0.1` and `public_url` to `https://wakapi.example.com`. Adjust other configurations such as database connection, SMTP email, etc if you need to.

### Creating a Systemd Service

Creating **Systemd** service making it easy to start or restart the Wakapi service.

Create `/etc/systemd/system/wakapi.service` and adapt from these following example configuration:

```systemd
[Unit]
Description=Wakatime Wakapi
StartLimitIntervalSec=400
StartLimitBurst=3

# Optional, and if you using MySQL or PostgreSQL
Requires=mysql.service
After=mysql.service

[Service]
Type=simple

WorkingDirectory=/opt/wakapi
ExecStart=/opt/wakapi/wakapi -config /opt/wakapi/wakapi.yml

User=wakapi
Group=wakapi
RuntimeDirectory=wakapi # creates /run/wakapi, useful to place your socket file there

Restart=on-failure
RestartSec=90

# Security hardening
PrivateTmp=true
PrivateUsers=true
NoNewPrivileges=true
ProtectSystem=full
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectKernelLogs=true
ProtectControlGroups=true
PrivateDevices=true
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
ProtectClock=true
RestrictSUIDSGID=true
ProtectHostname=true
ProtectProc=invisible

[Install]
WantedBy=multi-user.target

```

Then, reload and start the wakapi service:

```shell
sudo systemctl daemon-reload
sudo systemctl enable wakapi.service --now

# Check if the service is running properly
systemctl status wakapi.service
```

If everything is running smoothly, proceed to the next step for Nginx reverse proxy configuration.

### Nginx Reverse Proxy

For the Nginx configuration, no special adjustments are needed. You can simply use a standard reverse proxy configuration. For example:

```nginx
server {
    listen 80;
    server_name wakapi.example.com;
    root /opt/wakapi;
    access_log  off;
    location /.well-known/acme-challenge/ { allow all; }
    location / { return 301 https://$host$request_uri; }
}

server {
    listen 443 ssl http2;
    server_name wakapi.example.com;
    access_log  off;

    ssl_certificate     /path/to/fullchain.pem;
    ssl_certificate_key /path/to/privkey.pem;
    
    # bla bla bla

    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_pass http://127.0.0.1:3000;
    }
}

```

Adjust the `proxy_pass` to match with the `listen_ipv4` and `port` configurations from your `/opt/wakapi/wakapi.yml`.

Now, try accessing your Wakapi server and register for an account. You'll receive an API key that you'll need to set in your **WakaTime client**.

## WakaTime Client Configuration

Your server is ready to accept your __"heartbeat"__, configure your **WakaTime client** to connect to your __self-hosted__ **Wakapi instance**.

To do so, modify the `api_url` and `api_key` in your `.wakatime.cfg` to match with your server configuration. For example:

```ini
[settings]
api_url = https://wakapi.example.com/api
api_key = Your-API-Key-From-Your-Wakapi-Server
```

Start coding and check your coding activity on the Wakapi Dashboard.

Wakapi also have a feature to export metrics to **Prometheus** format and then [visualize them with Grafana](https://grafana.com/grafana/dashboards/12790-wakatime-coding-stats/).

![Example Wakapi Grafana Dashboard](grafana-wakapi.png#center)

You can also integrate it with [GitHub Readme Stats](https://github.com/anuraghazra/github-readme-stats#wakatime-week-stats) to display your coding activity on your GitHub profile page.

