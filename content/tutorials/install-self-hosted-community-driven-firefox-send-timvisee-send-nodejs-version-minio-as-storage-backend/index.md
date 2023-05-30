---
title: "Install self-hosted community-driven Firefox Send (timvisee/send) NodeJS version + Minio as storage backend"
description: "How to install self-hosted NodeJS timvisee/send (formerly Firefox Send) on Ubuntu and use Minio as it&#x27;s storage backend."
# linkTitle:
date: 2023-01-07T05:49:56+07:00
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
  - NodeJS
  - NVM
  - Send
  - Minio
  - S3
  - PM2
  - Nginx
  - Redis
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

`timvisee/send` is a fork Mozilla's discontinued [Firefox Send](https://github.com/mozilla/send), a file sharing experiment which allows users to send encrypted files to other users. So, this fork is a community effort to keep the project *up-to-date* and alive.

<!--more-->

Although there is a [docker version of timvisee/send](https://github.com/timvisee/send/blob/master/docs/docker.md), I'm not that comfortable running containerized app inside of my already containerized ecosystem (Linux Container or LXC). Especially on an apps that is not that hard to install and run. So, this article is my snippets to install **Send NodeJS version** on Ubuntu using **Minio** as storage backend.

## Requirements
- **NodeJS** `v16.x` (We'll use `nvm` for this)
- `pm2` as NodeJS process manager
- **Nginx** as a HTTP reverse proxy
- **Redis** (optional)
- **Minio** / another **S3 compatible** storage (optional)

## Installation
Before all the installation process begin, it's always good idea to make your current system *up-to-date* by running `apt update && apt upgrade`.

### Install NVM, NodeJS and pm2
Download and install the [latest release from nvm official repository](https://github.com/nvm-sh/nvm/releases) (`v0.39.3` when this article was written).
```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
```
After installation process is done, simply exit and *re-enter* from your current `tty` shell to activate NVM environment.

Install required NodeJS version (`v16.x`) by running `nvm install 16`.

Install `pm2` and `pm2-logrotate`.
```shell
npm install pm2 -g
pm2 install pm2-logrotate
```

![PM2 Logrotate](pm2-logrotate.jpg#center)

Enable pm2 run on system startup: `pm2 startup`. You'll get output similar like this:
```plain
[PM2] Init System found: systemd
[PM2] To setup the Startup Script, copy/paste the following command:
sudo env PATH=$PATH:/home/ditatompel/.nvm/versions/node/v16.19.0/bin /home/ditatompel/.nvm/versions/node/v16.19.0/lib/node_modules/pm2/bin/pm2 startup systemd -u ditatompel --hp /home/ditatompel
```

Follow the instruction above by executing the last line command it's suggested. Eg:
```shell
sudo env PATH=$PATH:/home/ditatompel/.nvm/versions/node/v16.19.0/bin /home/ditatompel/.nvm/versions/node/v16.19.0/lib/node_modules/pm2/bin/pm2 startup systemd -u ditatompel --hp /home/ditatompel
```
This will create systemd service for your current user.

### Install and run Send service
Clone `timvisee/send` official repository:
```shell
git clone https://github.com/timvisee/send.git && cd send
```
Install required packages and build the production assets:

```shell
npm install
npm run build
```

Now, specify your Send environment variable and run the app using pm2 :
```shell
BASE_URL=https://send.example.com \
DETECT_BASE_URL=true \
REDIS_HOST=<your_redis_host> \
REDIS_PORT=6379 \
REDIS_DB=0 \
AWS_ACCESS_KEY_ID=<your_aws_key_id> \
AWS_SECRET_ACCESS_KEY=<your_aws_secret_key> \
S3_BUCKET=<your_aws_secret_key> \
S3_ENDPOINT=<your_aws_endpoint> \
S3_USE_PATH_STYLE_ENDPOINT=true \
pm2 start npm --name "Send" --update-env -- run prod
```

- If you didn't want to use Redis, remove `REDIS_*` environment variables.
- If you want to use local storage instead, remove `AWS_*` and `S3_*` variables, then add `FILE_DIR=/path/to/local/storage` variable.

Make sure to save the pm2 process by running `pm2 save`. To see list of app managed by **pm2**, run `pm2 ps` and to monitor pm2 processed run `pm2 monit`.

## Nginx Configuration
Now, create new server block on your Nginx configuration:
```nginx
server {
  listen 80;
  server_name send.example.com;
  root /var/www/nginx/default;
  location /.well-known/acme-challenge/ { allow all; }
  location / { return 301 https://$host$request_uri; }
}

server {
  listen 443 ssl http2;
  server_name send.example.com;
  
  # put your SSL confs here
  ssl_certificate     /path/to/ssl/fullchain.pem; 
  ssl_certificate_key /path/to/ssl/privkey.pem;
  
  root /var/www/nginx/default;

  sendfile             on;
  client_max_body_size 3000m;

  location / {
    try_files $uri @proxysend;
  }

  location @proxysend {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Proxy "";
    proxy_pass_header Server;

    proxy_pass http://127.0.0.1:1443;
    proxy_buffering on;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;

    tcp_nodelay on;
  }

  location /api {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Proxy "";

    proxy_pass http://127.0.0.1:1443;
    proxy_buffering off;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;

    tcp_nodelay on;
  }
}
```

## Resources
- [https://github.com/timvisee/send](https://github.com/timvisee/send)

