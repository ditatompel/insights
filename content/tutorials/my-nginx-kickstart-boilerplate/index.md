---
title: "My Nginx Setup Kickstart / Boilerplate"
description: "My mandatory settings for Nginx as a web server, reverse proxy; including VTS module, analysis, and logging."
# linkTitle:
date: 2024-04-25T00:00:09+07:00
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
  - Snippets
tags:
  - Nginx
#  - 
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

Since the first time I used [**Nginx**](https://nginx.org/) in mid-2011, Nginx immediately became my favorite web server. I am slowly starting to leave [Apache](https://httpd.apache.org/) behind, which was previously the _"standard" web server_ on the Linux operating system.

As time went by, several new _web servers_ began to appear, such as [Caddy](https://caddyserver.com/) and [Traefik](https://traefik.io/traefik/). As a _system administrator_, of course I have tried to use it, although only to the extent of using personal projects.

However, my heart always seems to return to Nginx. Applications, services, or **anything that I can expose via Nginx, I will expose that using Nginx**. Maybe because I'm become too comfortable with the configuration and pleasant experience with Nginx. XD

## My use case

Because I have very **limited IPv4**, I mostly use Nginx as a **reverse proxy** for services that don't have a public IP (VMs with local / internal networks). This really helps save public IP allocation. Using Nginx as reverse proxy, I played a lot with `proxy_cache` and `http upstream` to implement _load balancing_ or _failover_.

Back then, when I created programs using **PHP**, I used Nginx and PHP-FPM without Apache (`.htaccess`) behind it. So I play a lot with Nginx `rewrite` and `fastcgi_cache`. When I started making applications using **Rust** and **Go**, Nginx always act as _reverse proxy_ while also performing _SSL termination_.

Besides HTTP _reverse proxy_, I sometimes use the Nginx `stream` _module_ for TCP, UDP, and _Unix socket_ data streams.

Regarding traffic monitoring, I always use [**Nginx VTS module**](https://github.com/vozlt/nginx-module-vts). There are [nginx-vts-exporter](https://github.com/sysulq/nginx-vts-exporter) for [Prometheus](https://prometheus .io/) which is very easy to operate to process data from Nginx VTS module. Meanwhile, for _logging_, some logs for _virtual hosts_ that I consider crucial are sent in _real-time_ to the **remote syslog server**.

It's perfect, all the features I need are met by Nginx. And it's time for me to start documenting the installation and configuration process.

{{< bs/alert info >}}
{{< bs/alert-heading "INFO:" >}}
I have an open-source project called {{< bs/alert-link "nginx-kickstart" "https://github.com/ditatompel/nginx-kickstart" >}} (boilerplate) to make it easier to install Nginx from the official repository and compile the Nginx VTS module on a FRESH Debian 12 or Ubuntu 22.04 server.
{{< /bs/alert >}}

## Installing Nginx official repo

This documentation was created for **Debian 12** and **Ubuntu 22.04**, and I used the official repository from Nginx, not the distribution-provided package.

First and foremost, always make sure the system is _up-to-date_ by running `sudo aptget update && sudo apt-get dist-upgrade`. Then install required packages.

For **Debian**:

```shell
apt install sudo curl gnupg2 ca-certificates lsb-release debian-archive-keyring
```
For **Ubuntu**:

```shell
apt install sudo curl gnupg2 ca-certificates lsb-release ubuntu-keyring
```

Then, import the official Nginx signing key:

```shell
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
```

Set up the apt repository for stable nginx packages:

```shell
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
```

Set up repository pinning to prefer official packages over distribution-provided ones:

```shell
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx
```

Then, install `nginx` and `nginx-module-geoip`:

```shell
sudo apt update && sudo apt install nginx nginx-module-geoip
```

Load the following `http_geoip_module` and `stream_geoip_module`. Put the `load_module` **above** `event{}` _block_ and `geoip_country` inside `http{}` block:

```nginx
load_module modules/ngx_http_geoip_module.so;
load_module modules/ngx_stream_geoip_module.so;

event {
    worker_connections 65535; # Nginx default: 1024
}

http {
    geoip_country /usr/share/GeoIP/GeoIP.dat;

    # ...
}

```

## Preparing the Nginx directory structure

Create the `sites-available`, `sites-enabled`, `ssl`, `snippets` directories inside the `/etc/nginx` directory:

```shell
sudo mkdir -p /etc/nginx/{sites-available,sites-enabled,ssl,snippets}
```

Create a _self-signed_ certificate (only used as an initial configuration which will later be replaced by `certbot`):

```shell
sudo openssl req -x509 -newkey rsa:4096 -days 365 -nodes \
    -keyout /etc/nginx/ssl/privkey.pem                   \
    -out /etc/nginx/ssl/fullchain.pem                    \
    -subj '/CN=example.local/O=My Organization/C=US'
```

Create _DH-param_ by running:

```shell
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
```

## Cloudflare's IPs trusted proxy

If there is a virtual host behind a Cloudflare reverse proxy, it is highly recommended to add the Cloudflare IP addreses to the _trusted proxy_ in the Nginx configuration.

Create the following _executable shell script_ `/etc/nginx/cloudflare-ips.sh`:

```shell
#!/usr/bin/env bash
# Nginx setup for cloudflare's IPs.
# https://github.com/ditatompel/nginx-kickstart/blob/main/etc/nginx/cloudflare-ips.sh
# This is modified version of itsjfx's cloudflare-nginx-ips
# Ref of original script:
# https://github.com/itsjfx/cloudflare-nginx-ips/blob/master/cloudflare-ips.sh

set -e

[ "$(id -u)" -ne 0 ] && echo "This script must be run as root" && exit 1

CF_REAL_IPS_PATH=/etc/nginx/snippets/cloudflare_real_ips.conf
CF_WHITELIST_PATH=/etc/nginx/snippets/cloudflare_whitelist.conf
CF_GEOIP_PROXY_PATH=/etc/nginx/snippets/cloudflare_geoip_proxy.conf

for file in $CF_REAL_IPS_PATH $CF_WHITELIST_PATH $CF_GEOIP_PROXY_PATH; do
    echo "# https://www.cloudflare.com/ips" > $file
    echo "# Generated at $(LC_ALL=C date)" >> $file
done

echo "geo \$realip_remote_addr \$cloudflare_ip {
    default 0;" >> $CF_WHITELIST_PATH

for type in v4 v6; do
    for ip in `curl -sL https://www.cloudflare.com/ips-$type`; do
        echo "set_real_ip_from $ip;" >> $CF_REAL_IPS_PATH;
        echo "    $ip 1;" >> $CF_WHITELIST_PATH;
        echo "geoip_proxy $ip;" >> $CF_GEOIP_PROXY_PATH;
    done
done

echo "}
# if your vhost is behind CloudFlare proxy and you want your site only
# accessible from Cloudflare proxy, add this in your server{} block:
# if (\$cloudflare_ip != 1) {
#    return 403;
# }" >> $CF_WHITELIST_PATH

nginx -t && systemctl reload nginx

# vim: set ts=4 sw=4 et:
```

The shell script above will fetch Cloudflare's IP list to be processed and stored in `/etc/nginx/snippets/cloudflare_*.conf`. Please create a `cronjob` to run the script periodically (per week / per month).

For the Nginx configuration, add the following configuration to the `http{}` block in `/etc/nginx/nginx.conf`:

```nginx
http {
    # ...

    # Cloudflare IPs
    ################
    include /etc/nginx/snippets/cloudflare_real_ips.conf;
    real_ip_header X-Forwarded-For; # atau CF-Connecting-IP jika menggunakan Cloudflare
    # cloudflare map
    include /etc/nginx/snippets/cloudflare_whitelist.conf;

    # ...
```

## Logging

The _logging_ feature may slowing down server performance (mainly due to high **DISK I/O**) on high traffic sites. However, logging is also very important for monitoring and analyzing server activity.

### Log format

There are several log formats that are commonly used and can be integrated with _3rd-party_ applications, for example the `(V)COMMON` or `(V)COMBINED` format.

#### VCOMBINED format

Add the following configuration to the `http{}` block:

```nginx
http {
    # ...

    # VCOMBINED log format style
    log_format vcombined '$host:$server_port '
        '$remote_addr - $remote_user [$time_local] '
        '"$request" $status $body_bytes_sent '
        '"$http_referer" "$http_user_agent"';

    # ...
```

> I usually use `VCOMBINED` format logs which I then integrate with [GoAccess](https://goaccess.ditatompel.com/).

#### Custom JSON log format

For some cases, I use **Nginx integration** in **Grafana Cloud** which uses _custom access log format_ (JSON):

```nginx
http {
    # ...

    # JSON style log format
    log_format json_analytics escape=json '{'
        '"msec": "$msec", ' # request unixtime in seconds with a milliseconds resolution
        '"connection": "$connection", ' # connection serial number
        '"connection_requests": "$connection_requests", ' # number of requests made in connection
        '"pid": "$pid", ' # process pid
        '"request_id": "$request_id", ' # the unique request id
        '"request_length": "$request_length", ' # request length (including headers and body)
        '"remote_addr": "$remote_addr", ' # client IP
        '"remote_user": "$remote_user", ' # client HTTP username
        '"remote_port": "$remote_port", ' # client port
        '"time_local": "$time_local", '
        '"time_iso8601": "$time_iso8601", ' # local time in the ISO 8601 standard format
        '"request": "$request", ' # full path no arguments if the request
        '"request_uri": "$request_uri", ' # full path and arguments if the request
        '"args": "$args", ' # args
        '"status": "$status", ' # response status code
        '"body_bytes_sent": "$body_bytes_sent", ' # the number of body bytes exclude headers sent to a client
        '"bytes_sent": "$bytes_sent", ' # the number of bytes sent to a client
        '"http_referer": "$http_referer", ' # HTTP referer
        '"http_user_agent": "$http_user_agent", ' # user agent
        '"http_x_forwarded_for": "$http_x_forwarded_for", ' # http_x_forwarded_for
        '"http_host": "$http_host", ' # the request Host: header
        '"server_name": "$server_name", ' # the name of the vhost serving the request
        '"request_time": "$request_time", ' # request processing time in seconds with msec resolution
        '"upstream": "$upstream_addr", ' # upstream backend server for proxied requests
        '"upstream_connect_time": "$upstream_connect_time", ' # upstream handshake time incl. TLS
        '"upstream_header_time": "$upstream_header_time", ' # time spent receiving upstream headers
        '"upstream_response_time": "$upstream_response_time", ' # time spent receiving upstream body
        '"upstream_response_length": "$upstream_response_length", ' # upstream response length
        '"upstream_cache_status": "$upstream_cache_status", ' # cache HIT/MISS where applicable
        '"ssl_protocol": "$ssl_protocol", ' # TLS protocol
        '"ssl_cipher": "$ssl_cipher", ' # TLS cipher
        '"scheme": "$scheme", ' # http or https
        '"request_method": "$request_method", ' # request method
        '"server_protocol": "$server_protocol", ' # request protocol, like HTTP/1.1 or HTTP/2.0
        '"pipe": "$pipe", ' # "p" if request was pipelined, "." otherwise
        '"gzip_ratio": "$gzip_ratio", '
        '"geoip_country_code": "$geoip_country_code"'
        '}';

    # ...
}
```

### Conditional (dynamic) logging

With `map`, and `if` _keyword_, we can determine what to log and what not to log. For example, I don't do _logging_ if the URI contains the word _"local"_ or _User Agent_ contains the word _"Uptime-Kuma"_:

```nginx
http {
    # ...
    
    map $request_uri$http_user_agent $is_loggable {
        ~*local          0;
        ~*Uptime-Kuma.*  0;
        default          1;
    }

    access_log     /var/log/nginx/access-vcombined.log vcombined if=$is_loggable;

    # ...
}
```

### Remote log UDP (rsyslog)

For me, log centralization really makes my job easier in carrying out server analysis and troubleshooting.

In Nginx, we can easily send logs to _remote servers_ in _real-time_. For example, we can send logs to a remote `rsyslog` server** (UDP) with the following example configuration:

```nginx
http {
    # ...

    access_log     syslog:server=192.168.0.7:514,facility=local7,tag=nginx,severity=info vcombined if=$is_loggable;
    access_log     syslog:server=192.168.0.7:514,facility=local7,tag=nginx_grafana,severity=info json_analytics if=$is_loggable;

    # ...
}
```

## Compiling Nginx VTS module

**Nginx VTS module** is not available in the Official Nginx repository, so we cannot install it using `apt`. To compile the VTS module requires `C` _compiler_, `git`, `libpcre`, `libssl`, and `zlib`. Install the required packages by running this command:

```shell
sudo apt install git build-essential libpcre3-dev zlib1g-dev libssl-dev
```

This is a very important part, if you want to use a *dynamically linked module*, the compile module option must be the same as the Nginx _binary file_ that will be used, as well as the version of Nginx used. To find out the information we need, run `nginx -V` command. Example output:

```plain
nginx version: nginx/1.26.0
built by gcc 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04)
built with OpenSSL 3.0.2 15 Mar 2022
TLS SNI support enabled
configure arguments: --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.26.0/debian/debuild-base/nginx-1.26.0=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie'
```

Download Nginx source with a version that is **exactly the same** with the one we are using, in this example `1.26.0`.

```shell
curl -O https://nginx.org/download/nginx-1.26.0.tar.gz
```

Extract the Nginx _source code_ archive, then go to it's directory:

```shell
tar -xvzf nginx-1.26.0.tar.gz
cd nginx-1.26.0
```
Clone the `vozlt/nginx-module-vts` repository and use the [latest release tag](https://github.com/vozlt/nginx-module-vts/tags). When this article was written, the last tag release was `v0.2.2`, so:

```shell
git clone -b v0.2.2 https://github.com/vozlt/nginx-module-vts.git
```

Configure with the same arguments from the `nginx -V` output above and add `--add-dynamic-module=./nginx-module-vts/`. Examples in this article:

```shell
./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.26.0/debian/debuild-base/nginx-1.26.0=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' -add-dynamic-module=./nginx-module-vts/
```

Build, then copy the VTS module you just compiled to `/etc/nginx/modules/`:

```shell
make -j$(nproc)
sudo cp objs/ngx_http_vhost_traffic_status_module.so /etc/nginx/modules/
```

### Nginx VTS module configuration

Edit the `/etc/nginx/nginx.conf` file and load the `host_traffic_status_module`. Place `load_module` **above** `event{}` _block_:

```nginx
load_module modules/ngx_http_vhost_traffic_status_module.so;
```

Then inside `http{}` block, add the following configuration:

```nginx
http {
    # ...

    geoip_country /usr/share/GeoIP/GeoIP.dat;
    vhost_traffic_status_zone;
    vhost_traffic_status_filter_by_set_key $geoip_country_code country::*;

    # ...
}
```

To display the **VTS traffic status** page, add the following example configuration to the `server{}` block (for example in `/etc/nginx/conf.d/default.conf`):

```nginx
server {
    # ...

    # example Nginx VTS display page
    location /status {
        vhost_traffic_status_bypass_limit on;
        vhost_traffic_status_bypass_stats on;
        vhost_traffic_status_display;
        vhost_traffic_status_display_format html;
        access_log off;
        # Example restricting VTS access to specific IP
        allow 127.0.0.1;
        allow 192.168.0.0/24;
        deny  all;
    }

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    # ...
}
```

## Final configuration

As a final configuration reference, please look at [https://github.com/ditatompel/nginx-kickstart/tree/main/etc/nginx](https://github.com/ditatompel/nginx-kickstart/tree/main/etc/nginx).

## Credit and references

- [https://nginx.org/en/linux_packages.html](https://nginx.org/en/linux_packages.html).
- [https://github.com/vozlt/nginx-module-vts](https://github.com/vozlt/nginx-module-vts).
- [https://github.com/itsjfx/cloudflare-nginx-ips](https://github.com/itsjfx/cloudflare-nginx-ips).
- [https://github.com/ditatompel/nginx-kickstart](https://github.com/ditatompel/nginx-kickstart).

