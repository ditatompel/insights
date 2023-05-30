---
title: "How to Install self-hosted Commento and Use Nginx as Reverse Proxy"
description: "Guide to install Commento and it's required dependencies like PostgreSQL, setting up required Commento configuration and it's SystemD and use Nginx as reverse proxy to serve Commento instance using HTTPS."
# linkTitle:
date: 2022-09-14T03:09:19+07:00
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
  - SysAdmin
tags:
  - Commento
  - PostgreSQL
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

**Commento** is *open-source privacy-focused* commenting platform, It's fast, *bloat-free* and can be *self-hosted*. This article guide you to install required dependencies like **PostgreSQL** (Ubuntu 20.04), setting up required Commento configuration and it's **SystemD** to start the server automatically on when the system boot up. Additionally (but recommended), use Nginx as reverse proxy to serve Commento instance using HTTPS.

<!--more-->

**UPDATES:**

> _**WARNING**: I've been using Commento for a long time, but since 1 year ago until this article was written, I didn't find any updates or commits to their git master repository. You can try [Commento++](https://github.com/souramoo/commentoplusplus) as replacement._

## Hardware requirements
Commento is pretty *lightweight*, but it's recommend having at least 64MB of free RAM and at least 30MB of free disk space. This requirement does not include the requirements for running the PostgreSQL server. You may, of course, choose to use a separate server or a cloud PostgreSQL provider for the database.

Commento binary release has been verified to be working on the following hardware architectures: `amd64`, `x86`.

## Software requirements
To run Commento, you need to have a PostgreSQL database version `9.6` or later. There aren't any other software requirements, unless you're compiling from source.

### Install PostgreSQL
Let's assume you use **Ubuntu** `20.04` which provide **PostgreSQL** >= `9.6` from their official repository package.

To install PostgreSQL, first refresh your server’s local package index:
```shell
sudo apt update
```
Then, install the Postgres package along with a `-contrib` package that adds some additional utilities and functionality:
```shell
sudo apt install postgresql postgresql-contrib
```
By default, Postgres uses a concept called `roles` to handle authentication and authorization. These are, in some ways, similar to regular *Unix-style* users and groups.

Upon installation, Postgres is set up to use ident authentication, meaning that it associates Postgres roles with a matching Unix/Linux system account. If a role exists within Postgres, a Unix/Linux username with the same name is able to sign in as that role.

The installation procedure created a user account called `postgres` that is associated with the default Postgres role. There are a few ways to utilize this account to access Postgres. One way is to switch over to the postgres account on your server by running the following command:
```shell
sudo -i -u postgres
```
### Creating a New Role
If you are logged in as the `postgres` account, you can create a new role by running the following command:
```shell
createuser --interactive
```

If you prefer to use `sudo` for each command without switching from your normal account, run:
```shell
sudo -u postgres createuser --interactive
```

```plain
Enter name of role to add: commento
Shall the new role be a superuser? (y/n) n
Shall the new role be allowed to create databases? (y/n) n
Shall the new role be allowed to create more new roles? (y/n) n
```

### Creating a New Database
Another assumption that the Postgres authentication system makes by default is that for any role used to log in, that role will have a database with the same name which it can accessed.

This means that if the user you created in the last section is called `ditatompel`, that role will attempt to connect to a database which is also called `ditatompel` by default. You can create the appropriate database with the `createdb` command.

If you are logged in as the `postgres` account, you would type something like the following:
```shell
createdb commento
```
If, instead, you prefer to use `sudo` for each command without switching from your normal account, you would run:
```shell
sudo -u postgres createdb commento
```

### Create User Password
```shell
sudo -u postgres psql
```

```sql
ALTER USER postgres PASSWORD '[ChangeThisWithYourSecretPassword]';
```

If successful, Postgres will output a confirmation of `ALTER ROLE` as seen above.

## Download Commento Binary
Find the [latest Commento release](https://vr4.me/g/OyQAY) binary archive from the releases page and download it to your server.

```shell
wget https://dl.commento.io/release/commento-v1.8.0-linux-glibc-amd64.tar.gz
```

Extract to desired Commento installation, in this example `/opt/commento`.
```shell
mkdir /opt/commento
tar -xvzf commento-v1.8.0-linux-glibc-amd64.tar.gz -C /opt/commento/
```

## Launching Commento
You need to set up some **required** configuration before starting Commento and *optionally* additional configuration like **SMTP** and **OAuth**. In this example, let's assume our Commento instance will be running on server `localhost` port `8088` and will be available at `https://commento.ditatompel.com` via Nginx reverse proxy.

Before you launch Commento, you will also need a usable PostgreSQL server. Let's say the server is available at `localhost` on port `5432` using database named `commento` with the user credentials commento and password `commentoPassword`.

Set up the environment variables to start the Commento server on `127.0.0.1` on port `8088`. You can create `.env` file under `/etc/commento/commento.env` for easier management.
```env
COMMENTO_ORIGIN=https://commento.ditatompel.com
#COMMENTO_CDN_PREFIX=https://commento.ditatompel.com
# Set binding values
COMMENTO_BIND_ADDRESS=127.0.0.1
COMMENTO_PORT=8088

# Set PostgreSQL settings
COMMENTO_POSTGRES=postgres://commento:commentoPassword@127.0.0.1:5432/commento?sslmode=disable

#
# Below configuration is optional
# Uncomment and edit to fit your needs
#

# Prevent registration
#COMMENTO_FORBID_NEW_OWNERS=false # default true

# If set to true, all static content will be served GZipped if the client's browser supports compression. Defaults to false.
#COMMENTO_GZIP_STATIC=true


# Set the SMTP credentials
#COMMENTO_SMTP_HOST=mail.example.com
#COMMENTO_SMTP_PORT=587
#COMMENTO_SMTP_USERNAME=notification@example.com
#COMMENTO_SMTP_PASSWORD=examplePassword
#COMMENTO_SMTP_FROM_ADDRESS=notification@example.com

# Set Google OAuth credentials
#COMMENTO_GOOGLE_KEY=some-random-string-key.apps.googleusercontent.com
#COMMENTO_GOOGLE_SECRET=somerandomsecret
```

Set `COMMENTO_CDN_PREFIX` to the appropriate URL if you are serving static content from a CDN. Otherwise, set it to the same value as `COMMENTO_ORIGIN`.

Then, create `systemd` *service* file located on `/etc/systemd/system/commento.service`:
```systemd
[Unit]
Description=Commento daemon service
After=network.target postgresql.service

[Service]
Type=simple
ExecStart=/opt/commento/commento
Environment=COMMENTO_CONFIG_FILE=/etc/commento/commento.env

[Install]
WantedBy=multi-user.target
```

Reload systemd unit files configuration and start Commento service.
```shell
sudo systemctl daemon-reload
sudo systemctl start commento
sudo systemctl enable commento
```


## Setting up Nginx reverse proxy for Commento (sub)domain
Now, time to configure **Nginx** in front of Commento. Nginx server block configuration below is basic example to use Nginx as reverse proxy to serve Commento using SSL (HTTPS).
```nginx
server {
    listen 80;
    server_name commento.ditatompel.com;
    root /var/www/default;
    # in case you use certbot...
    location /.well-known/acme-challenge/ { allow all; }
    location / { return 301 https://$host$request_uri; }
}

server {
    listen 443 ssl http2;
    server_name commento.ditatompel.com;
	
    # Edit to fit with your server environment and path
    ssl_certificate     /path/to/your/cert/fullchain.pem;
    ssl_certificate_key /path/to/your/cert/privkey.pem;
    ssl_dhparam         /path/to/your/cert/dhparam.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    root /var/www/default;

    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_pass http://127.0.0.1:8088/;
    }
}
```

Restart Nginx service and try to access your Commento instance.

## Resources
- [https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart](https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart)
- [https://docs.commento.io/](https://docs.commento.io/)