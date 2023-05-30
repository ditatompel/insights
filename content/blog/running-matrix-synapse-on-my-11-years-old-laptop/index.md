---
title: "Running Matrix Synapse on my 11 years old laptop"
description: "I'm running public Matrix Synapse server on HP Pavilion g7 Notebook PC (g7-1260us), 11 years old laptop with just 4GB DDR3 RAM and Sandy Bridge CPU."
date: 2022-06-16T01:55:47+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Self-Hosted
tags:
  - Matrix
  - Synapse
  - Arch Linux
  - PostgreSQL
  - Nginx
  - Prometheus
  - Grafana
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

Dear future me who read this: Yes, you read it right. I'm running Matrix **Synapse** on [HP Pavilion g7 Notebook PC (g7-1260us)](https://support.hp.com/id-en/document/c02996675). When this article is published, it's 11 years old laptop with broken battery, 4GB DDR3-1333 RAM and **Sandy Bridge** CPU (i3-2330M), plus the *fan* on the CPU *headsink* is not working.

<!--more-->

## Problems
* I can't easily run "reboot" command remotely because I need to press "enter" at startup when the BIOS gives a warning regarding a faulty fan. It means I need to be physically "at home" to perform reboot.
* Still on the problem of a broken fan, I use a SFF PC fan (connected to 1 of laptop USB port), then [I placed above the keyboard](hpg7-external-fan-lmao.jpg) to deal with the heat and [it's works](cpu-temp-hpg7.jpg)! (for now, LMAO!)
* Due to the very low specs of the laptop, I needed to use a fairly minimal operating system. Arch Linux being my first choice. Yes, I installed **Xserver** and **Openbox** as my *window manager* for this laptop. But I only do `startx` when I need (or want) it.
* Because my home connection doesn't have a public IP, I have to connect my laptop to my VPS using a VPN so that *Synapse* can be publicly accessible. In short:   
You -> Nginx as reverse proxy on my VPS -> Synapse on my laptop via VPN.
* Electricity / power loss: I don't use power backup at home.

## Installation
Follow installation and configuration process from [ArchWiki](https://wiki.archlinux.org/title/Matrix).

```shell
sudo pacman -S matrix-synapse
```
After installation, a configuration file needs to be generated. It should be readable by the `synapse` user (You don't need to create synapse user if you install `matrix-synapse` community package, it already creates a *synapse* user) :

```shell
cd /var/lib/synapse
sudo -u synapse python -m synapse.app.homeserver \
  --server-name my.domain.name \
  --config-path /etc/synapse/homeserver.yaml \
  --report-stats=yes \
  --generate-config
```

I want to use **PosgreSQL** instead of **SQLite** as my database for Synapse. So, install `postgresql` and it's client library:
```shell
sudo pacman -S postgresql postgresql-libs python-psycopg2
```
Setup postgresql database for Synapse (change `<synapse_db_user>` and `<synapse_db_name>` as needed)

```shell
su - postgres
# this will prompt for a password for the new user
createuser --pwprompt <synapse_db_user>
createdb --encoding=UTF8 --locale=C --template=template0 --owner=<synapse_db_user> <synapse_db_name>
```

Exit from *postgres user* and edit the `database` section in synapse config file to match the following lines: (you may need to uncomment the `sqlite3` one)
```yaml
database:
  name: psycopg2
  args:
    user: <synapse_db_user>
    password: <synapse_user_db_password>
    database: <synapse_db_name>
    host: localhost
    cp_min: 5
    cp_max: 10
```

### Setting up Matrix server_name (for delegation)
> _**IMPORTANT**: choose the name for synapse server before run Synapse because it can't be changed later._

The `server_name` configured in the Synapse configuration file (often `homeserver.yaml`) defines how resources (users, rooms, etc.) will be identified (eg: `@user:ditatompel.com`, `#room:ditatompel.com`). By default, it is also the domain that other servers will use to try to reach your server (via port `8008` or `8448` for TLS).

I want my server known as ditatompel.com, NOT matrix.ditatompel.com, so set `server_name` to `ditatompel.com` on Synapse configuration file. (`homeserver.yaml`). We will set up `.well_known` delegation latter.

Start the `synapse.service` *systemd* service, check if everything is ok and enable service at start up:
```shell
sudo systemctl start synapse.service
sudo systemctl status synapse.service
sudo systemctl enable synapse.service
```

My synapse server is up, but it's lonely here. Let's create one as normal non-root user with the command:
```shell
register_new_matrix_user -c /etc/synapse/homeserver.yaml http://127.0.0.1:8008
```
> Change port `8008` to `8448` if you use TLS

### Setting up Nginx reverse proxy
It is recommended to put a reverse proxy such as Nginx in front of Synapse. One advantage of doing so is that it means that we can expose the default https port (443) to Matrix clients without needing to run Synapse with root privileges.

You should configure your reverse proxy to forward requests to `/_matrix` or `/_synapse/client` to Synapse, and have it set the `X-Forwarded-For` and `X-Forwarded-Proto` request headers.

Because I expect clients to connect to my server at matrix.ditatompel.com, I just need to proxy pass the whole path under that `server_name` subdomain. Add upstream configuration to Nginx `http` block (take advantage of upstream `keepalive` feature):

```nginx
http {
    # ...
    
    upstream my_matrix_backend {
        keepalive 2;
        server <synapse_ip:port> fail_timeout=0;
    }
}
```

Then create server block configuration for matrix subdomain:

```nginx
server {
    listen 443 ssl http2;
    server_name matrix.ditatompel.com;
    
    ssl_certificate     /path/to/fullchain.pem;
    ssl_certificate_key /path/to/privkey.pem;
    
    add_header Strict-Transport-Security "max-age=31536000";
    # add your another headers and ssl params
    
    # Deny all access to /_synapse/admin from public unless you have a good reason for that.
    location /_synapse/admin {
        deny            all;
    }

    location / {
        try_files $uri @proxy_matrix;
    }

    location @proxy_matrix {
        # Increase client_max_body_size to match max_upload_size defined in homeserver.yaml
    	client_max_body_size 80m;
    	
    	proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        proxy_pass http://my_matrix_backend;
        
    }
}
```
> _**NOTE**: Your reverse proxy must not `canonicalise` or `normalise` the requested URI in any way (for example, by decoding `%xx` escapes). Beware that Apache will canonicalise URIs unless you specify `nocanon`._

The HTTP configuration will need to be updated for Synapse to correctly record client IP addresses and generate redirect URLs while behind a reverse proxy.

In `homeserver.yaml` set `x_forwarded: true` in the port 8008 section and consider setting `bind_addresses: ['0.0.0.0']` so that the server listens to any address on my local machine (I need to do this so my VPS where I connect my machine using VPN can reach the Synapse server).

### Setting up .well-known delegation
Delegation is a Matrix feature allowing a homeserver admin to retain a `server_name` of `ditatompel.com` so that user IDs, room aliases, etc continue to look like `*:ditatompel.com`, whilst having federation traffic routed to a different server and/or port (e.g. `matrix.ditatompel.com:443`).

I create file named `server` and place it somewhere on my main domain. Fill the `server` file with json similar to this json (Change `m.server` value to your Nginx reverse proxy for your Synapse server).

```json
{
  "m.server": "matrix.ditatompel.com:443"
}
```
Then, I add this `location` block on my **main domain** `server` block so it can be accessed and parsed as json:

```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name ditatompel.com;
    
    
    location /.well-known/matrix {
        types { } default_type "application/json; charset=utf-8";
        alias  /path/to/.well-known/matrix;
    }
    
    # ...
}
```

Check your federation config at [matrix federation tester site](https://federationtester.matrix.org/).

Basic Synapse server is now done. Say hai to me: [https://matrix.to/#/#general:ditatompel.com?via=ditatompel.com](https://matrix.to/#/#general:ditatompel.com?via=ditatompel.com).

## Optional features (but worth to have)
This features is optional, but worth to have or try.

### Enable Spider Webcrawler
To enable the webcrawler, for server generated link previews, the additional packages `python-lxml` and `python-netaddr` have to be installed. After that the option `url_preview_enabled: True` can be set in your `homeserver.yaml`. To prevent the synapse server from issuing arbitrary GET requests to internal hosts the `url_preview_ip_range_blacklist:` has to be set.

> _**Warning**: The blacklist is blank by default: without configuration the synapse server can crawl all your internal hosts._

There are some examples that can be uncommented. Add your local IP ranges to that list to prevent the synapse server from trying to crawl them. After changing the `homeserver.yaml` the service has to be restarted.

### Monitoring Synapse metrics using Prometheus
First, make sure that that `enable_metrics` is set to `True` in `homeserver.yaml` config. Then add the `metrics` resource to the existing listener as such:

```yaml
listeners:
  - port: 8008
    tls: false
    type: http
    x_forwarded: true
    bind_addresses: ['0.0.0.0']

    resources:
      - names: [client, federation, metrics]
        compress: false
```

Add this `location` block to Nginx reverse proxy for Synapse and add filter (allow) access only from your Prometheus servers:

```nginx
    location /_synapse/metrics {
        allow 192.168.1.2;    # Fill with your prometheus server IP address
        deny  all;
        try_files $uri @proxy_matrix;
    }
```
Add this configuration to your Prometheus (`prometheus.yml`) config:
```yml
  - job_name: "synapse"
    metrics_path: "/_synapse/metrics"
    scheme: https
    static_configs:
      - targets: ["matrix.ditatompel.com"]
```
Get [Grafana dashboard for Synapse](https://raw.githubusercontent.com/matrix-org/synapse/master/contrib/grafana/synapse.json).

## What else?
There are so many things we can still do, such as adding modules, bots, or bridges. I run 3 bridges on the same machine: [mautrix/instagram](https://github.com/mautrix/instagram), [mautrix/whatsapp](https://github.com/mautrix/whatsapp), and [mautrix/telegram](https://github.com/mautrix/telegram). A few [maubot](https://github.com/maubot/maubot) plugins, and some Synapse modules such as [synapse-s3-storage-provider](https://github.com/matrix-org/synapse-s3-storage-provider). Maybe I'll talk about the installation process at another time.

## Resources
- [https://wiki.archlinux.org/title/Matrix](https://wiki.archlinux.org/title/Matrix)
- [https://matrix-org.github.io/synapse/latest/setup/installation.html](https://matrix-org.github.io/synapse/latest/setup/installation.html)

