---
title: "LibreNMS Distributed Poller on Low-end Server Resources"
description: "A personal snippets to run distributed LibreNMS poller on low-end server resources to monitor hundreds of devices and sensors."
# linkTitle:
date: 2020-10-18T20:41:57+07:00
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
  - SysAdmin
  - Self-Hosted
tags:
  - LibreNMS
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

A personal snippets to run distributed **LibreNMS** poller on low-end server resources to monitor hundreds of devices and sensors.

<!--more-->

> _A normal **LibreNMS** install contains all parts of LibreNMS: - Poller/Discovery workers - RRD (Time series data store) - Database - Webserver (Web UI/API)_

Devices monitored with LibreNMS can be grouped together into a `poller_group` to pin these devices to a single or a group of designated pollers.

Distributed Polling allows the workers to be spread across additional servers for horizontal scaling. All pollers need to write to the same set of RRD files, shared NFS storage can be used, but I prefer using RRDcached.

It is a required that all pollers can access the central memcached to communicate with each other.

## Topology
Actually, the distributed poller setup is very dynamic and can be configured to fit your need. Below are my current setup on what you need to consider both from the software layer but also connectivity.

![LibreNMS Topology](librenms-topology.png#center)

| Node       | OS          | RAM - CPU    |	Services                                              | Devices |
| ---------- | ----------- | ------------ | ----------------------------------------------------- | ------- |
| nms82      | Ubuntu 18.4 | 4GB - 4 Core |	Web/API, MariaDB, RRDcached, Redis, Memcached, Syslog | < 9     |
| nms83      | Ubuntu 18.4 | 4GB - 4 Core |	Poller, Oxidized Config Backup                        |	62      |
| nms84      | Ubuntu 18.4 | 4GB - 4 Core |	Poller, Discovery Module                              | 19      |
| bsd-007-c7 | CentOS 7    | 2GB - 4 Core |	Poller                                                | 128     |

All machines above is run under Proxmox Linux Container across different location.

![LibreNMS Stats](librenms-stats.png#center)

For now, this resource (4 core Xeon and 4GB RAM each node) seem to be overkill to monitor about 200 devices, 1800 ports and 1000 sensors including processor, storages, applications, and disk I/O. The master host (nms82) only use about 1.5% of CPU resource and 600 - 1.200 MiB of RAM.

![LibreNMS instance on Proxmox](stat-proxmox-nms82.jpg#center)

But you may be need to switch from 7,000 RPM HDD to 15,000 RPM SAS drive or SSD for better performance since disk write is pretty high.

![LibreNMS instance DiskIO](disk-io-nms82.png#center)

## Requirements
All this setup need a working LibreNMS install, plus:
- `rrdtool` version `1.7.0` above
- `php-memcached` module
- a `memcached` server (nms82)
- a `rrdcached` server (nms82)
- a `redis` server (nms82)

Python Modules:
- Python 3 `python-memcached`
- `PyMySQL`
- `python-dotenv` .env loader
- `redis-py` > `3.0`
- `psutil`

These can be obtained from OS package manager, or from **PyPI** with command below (under librenms root directory):
```bash
pip3 install -r requirements.txt
```

## Master Host (Web UI, API, MariaDB, Redis, RRDcached, Memcached) (nms82)
This node become one of most important part which contain additional required server running on this node: Web UI / API, Memcached, RRDcached and Redis server.

### Web / API Layer
Based on topology above, the web / API layer will respond to Nginx reverse proxy. This is typically Apache but I prefer using Nginx, here some  Nginx backend configuration example for LibreNMS.

```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name nmshostname.ditatompel.com;
    error_log  /var/log/nginx/nmshostname.ditatompel.com;
    if ($scheme = http) {
        return 301 https://$server_name$request_uri;
    }
    
    # set your ssl certificates
    ssl_certificate /path/to/ssl/cert/nmshostname.ditatompel.com/fullchain.pem;
    ssl_certificate_key /path/to/ssl/cert/nmshostname.ditatompel.com/privkey.pem;
    
    # This SSL config below that can be included in separaded file
    ssl_dhparam /path/to/ssl/dhparam.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # HSTS (ngx_http_headers_module is required) (63072000 seconds)
    add_header Strict-Transport-Security 'max-age=63072000; includeSubDomains; preload';

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Permitted-Cross-Domain-Policies none;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Download-Options noopen;
    # End of SSL config that can be included in separaded file

    root        /opt/librenms/html;
    index       index.php;

    charset utf-8;
    gzip on;
    gzip_types text/css application/javascript text/javascript application/x-javascript image/svg+xml text/plain text/xsd text/xsl text/xml image/x-icon;
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    location /api/v0 {
        try_files $uri $uri/ /api_v0.php?$query_string;
    }
    location ~ \.php {
        include fastcgi.conf;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
    }
    location ~ /\.ht {
        deny all;
    }
}
```

### Database Server
The pollers, web and API layers should all be able to access the database server directly. Make sure that MariaDB listen to server IP address that can be accessed from other nodes instead of unix socket.

Additionally, you can use stable version of [official MariaDB repo](https://downloads.mariadb.org/mariadb/repositories/) instead of distribution repo.

### RRD Storage (via RRDCached)
It is advisable to run RRDCached within this setup so that you don't need to share the rrd folder via a remote file share such as NFS. The web service can then generate rrd graphs via RRDCached.

For this example, I'm running RRDCached to allow all pollers and web/api servers to read/write to the rrd files with the rrd directory.

```bash
apt install rrdcached
```
Edit `/etc/default/rrdcached` :
```plain
DAEMON=/usr/bin/rrdcached
WRITE_THREADS=4
BASE_PATH=/opt/librenms/rrd/
JOURNAL_PATH=/var/lib/rrdcached/journal/
PIDFILE=/var/run/rrdcached.pid
SOCKFILE=/var/run/rrdcached.sock
SOCKGROUP=librenms
DAEMON_GROUP=librenms
DAEMON_USER=librenms
NETWORK_OPTIONS="-L"
BASE_OPTIONS="-B -F -R"
```
Change ownership of journal path to `librenms` user:

```bash
chown librenms:librenms /var/lib/rrdcached/journal/
```

### Memcached
Memcache is required for the distributed pollers to be able to register to a central location and record what devices are polled. Memcache can run from any of the servers so long as it is accessible by all pollers.

Example memcached config on ubuntu `/etc/memcached.conf` :
```plain
# memcached default config file
# 2003 - Jay Bonci <jaybonci@debian.org>
# This configuration file is read by the start-memcached script provided as
# part of the Debian GNU/Linux distribution.

# Run memcached as a daemon. This command is implied, and is not needed for the
# daemon to run. See the README.Debian that comes with this package for more
# information.
-d

# Log memcached's output to /var/log/memcached
logfile /var/log/memcached.log

# Be verbose
# -v

# Be even more verbose (print client commands as well)
# -vv

# Start with a cap of 64 megs of memory. It's reasonable, and the daemon default
# Note that the daemon will grow to this size, but does not start out holding this much
# memory
-m 64

# Default connection port is 11211
-p 11211

# Run the daemon as root. The start-memcached will default to running as root if no
# -u command is present in this config file
-u memcache

# Specify which IP address to listen on. The default is to listen on all IP addresses
# This parameter is one of the only security measures that memcached has, so make sure
# it's listening on a firewalled interface.
#-l 127.0.0.1
-l 0.0.0.0

# Limit the number of simultaneous incoming connections. The daemon default is 1024
# -c 1024

# Lock down all paged memory. Consult with the README and homepage before you do this
# -k

# Return error when memory is exhausted (rather than removing items)
# -M

# Maximize core file limit
# -r

# Use a pidfile
-P /var/run/memcached/memcached.pid
```

Note: You also need `php-memcached` module.

Don't forget to configure server firewall so, only selecred server and poller can access the memcached server.

### Redis
Redis instance needed to coordinate the nodes. It's recommended that you do not share the Redis database with any other system. By default, Redis supports up to 16 databases (numbered 0-15). On this topic, I use database number 4 for LibreNMS and use `chris-lea` PPA for Redis 3+ on Ubuntu:

```bash
add-apt-repository ppa:chris-lea/redis-server
apt install redis-server
```
Edit Ubuntu Redis configuration example: (`/etc/redis/redis.conf`)
```plain
bind 0.0.0.0
requirepass YOURSCRETREDISPASSWORD
```
It's strongly recommended that you deploy a resilient cluster of redis systems, and use `redis-sentinel`.

## Poller Hosts (nms83, nms84, bsd-006-c7)
All poller host need working LibreNMS install. All you need to do after that is reconfigure all poller host config connection (Redis, Database, RRDCached, Memcached) to connect to Master Host (nms82).

## Connection Configuration on All Nodes
Once all required dependency is installed and running on master hosts, reconfigure it in the .env and config.php file on each node.

Connection settings are required in `.env`. The `.env` file is generated after `composer install` and `APP_KEY` and `NODE_ID` are set. Remember that the **`APP_KEY` value must be the same on all pollers** and **leave `NODE_ID` as it**.

```plain
#APP_KEY=   #Required, generated by composer install

DB_HOST=[YOUR_DATABASE_HOST]
DB_DATABASE=[YOUR_DATABASE_NAME]
DB_USERNAME=[YOUR_DATABASE_USER]
DB_PASSWORD=[YOUR_DATABASE_PASS]

#NODE_ID=   #Required, generated by composer install
LIBRENMS_USER=librenms

# Distributed Polling
REDIS_HOST=[YOUR_REDIS_HOST_IP]
REDIS_PORT=6379
REDIS_PASSWORD=[YOURSCRETREDISPASSWORD]
REDIS_DB=4
CACHE_DRIVER=redis
```

`config.php` under LibreNMS directory :
```php
<?php

$config['distributed_poller']                    = true;
$config['distributed_poller_name']               = php_uname('n');
$config['distributed_poller_group']              = '0'; # Set this to your prefered group for each node

$config['distributed_poller_memcached_host'] = "[IP_ADDR_OF_MEMCACHED_SERVER]";
$config['distributed_poller_memcached_port'] = 11211;


$config['service_poller_workers']              = 24;     # Processes spawned for polling
$config['service_services_workers']            = 8;      # Processes spawned for service polling
$config['service_discovery_workers']           = 16;     # Processes spawned for discovery


//Optional Settings
#$config['service_poller_frequency']            = 300;    # Seconds between polling attempts
#$config['service_services_frequency']          = 300;    # Seconds between service polling attempts
#$config['service_discovery_frequency']         = 21600;  # Seconds between discovery runs
#$config['service_billing_frequency']           = 300;    # Seconds between billing calculations
#$config['service_billing_calculate_frequency'] = 60;     # Billing interval
#$config['service_poller_down_retry']           = 60;     # Seconds between failed polling attempts
#$config['service_loglevel']                    = 'WARNING'; # Must be one of 'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'
#$config['service_update_frequency']            = 86400;  # Seconds between LibreNMS update checks

$config['service_watchdog_enabled'] = true;
```
A systemd unit file is provided - the sysv and upstart init scripts could also be used with a little modification.

A systemd unit file can be found in `misc/librenms.service`. To install run `cp /opt/librenms/misc/librenms.service /etc/systemd/system/librenms.service && systemctl enable --now librenms.service`.

