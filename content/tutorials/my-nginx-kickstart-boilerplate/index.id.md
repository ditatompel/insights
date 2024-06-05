---
title: "My Nginx Setup Kickstart / Boilerplate"
description: "Settingan wajib saya untuk Nginx sebagai web server, reverse proxy; termasuk VTS module, analisis, dan logging."
summary: "Settingan wajib saya untuk Nginx sebagai web server, reverse proxy; termasuk VTS module, analisis, dan logging."
keywords:
  - nginx
  - nginx kickstart
  - nginx boilerplate
date: 2024-04-25T00:00:09+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
series:
#  - Tutorial
categories:
  - SysAdmin
  - Snippets
tags:
  - Nginx
images:
authors:
  - ditatompel
---

Sejak pertama kali saya menggunakan [**Nginx**](https://nginx.org/) di pertengahan tahun 2011 lalu, Nginx langsung menjadi _web server_ favorit saya. [Apache](https://httpd.apache.org/) yang sebelumnya merupakan _"standard" web server_ di sistem operasi Linux sedikit demi sedikit mulai saya tinggalkan.

Seiring berjalannya waktu, beberapa _web server_ baru mulai bermunculan, seperti [Caddy](https://caddyserver.com/) dan [Traefik](https://traefik.io/traefik/). Sebagai seorang _system administrator_, tentu saja saya pernah mencoba menggunakannya, meskipun hanya sampai batas di penggunaan projek pribadi.

Namun, hati saya sepertinya selalu kembali ke Nginx. Aplikasi, _service_, atau **apapun itu yang bisa saya _expose_ melalui Nginx, akan saya _expose_ menggunakan Nginx**. Mungkin karena saya sudah terlalu nyaman dengan konfigurasi dan pengalaman menyenangkan bersama Nginx. XD

## _My use case_

Karena saya memiliki **IPv4 yang sangat terbatas**, saya banyak menggunakan Nginx sebagai _reverse proxy_ untuk _service-service_ yang tidak memiliki IP publik (VM dengan jaringan lokal / internal). Hal ini sangat membantu menghemat alokasi IP publik. Di kasus ini, saya banyak bermain dengan `proxy_cache` dan `http upstream` untuk mengimplementasikan _load balancing_ ataupun _failover_.

Ketika saya masih sering membuat program menggunakan **PHP**, saya menggunakan Nginx dan PHP-FPM tanpa adanya Apache (`.htaccess`) dibelakangnya. Jadi saya sering bermain dengan Nginx `rewrite` dan `fastcgi_cache`. Saat saya mulai membuat aplikasi menggunakan **Rust** dan **Go**, Nginx selalu bertugas sebagai _reverse proxy_ sekaligus melakukan _SSL termination_.

Selain HTTP _reverse proxy_, saya kadang menggunakan _module_ Nginx `stream` untuk TCP, UDP, bahkan _Unix socket_ data stream.

Mengenai _monitoring traffic_, saya selalu menggunakan [**Nginx VTS module**](https://github.com/vozlt/nginx-module-vts). Sudah tersedia [nginx-vts-exporter](https://github.com/sysulq/nginx-vts-exporter) untuk [Prometheus](https://prometheus .io/) yang sangat mudah dioperasikan untuk memproses data dari Nginx VTS module. Sedangkan untuk _logging_, beberapa log untuk _virtual host_ yang saya nilai krusial dikirimkan secara _real-time_ ke **remote syslog server**.

Sempurna sudah, semua fitur yang saya butuhkan terpenuhi oleh Nginx. Dan saatnya saya mulai mendokumentasikan proses instalasi dan konfigurasi untuk memenuhi apa yang saya butuhkan diatas.

{{< bs/alert info >}}
{{< bs/alert-heading "INFO:" >}}
Saya memiliki open-source project {{< bs/alert-link "nginx-kickstart" "https://github.com/ditatompel/nginx-kickstart" >}} (boilerplate) untuk mempermudah menginstall Nginx dari repositori officialnya dan mengkompile Nginx VTS module di FRESH Debian 12 atau Ubuntu 22.04 server.
{{< /bs/alert >}}

## Installasi Nginx (Official Repo)

Dokumentasi ini dibuat untuk **Debian 12** dan **Ubuntu 22.04**, dan saya menggunakan official repositori dari Nginx, bukan repositori bawaan dari distro.

Pertama dan utama, selalu pastikan sistem dalam keadaan _up-to-date_ dengan menjalankan perintah `sudo aptget update && sudo apt-get dist-upgrade`. Kemudian install _package-package_ yang dibutuhkan untuk installasi Nginx.

Untuk **Debian**:

```shell
apt install sudo curl gnupg2 ca-certificates lsb-release debian-archive-keyring
```

Untuk **Ubuntu**:

```shell
apt install sudo curl gnupg2 ca-certificates lsb-release ubuntu-keyring
```

Lalu _import_ _official signing key_-nya Nginx:

```shell
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
```

Tambahkan **Nginx stable package** ke **apt source list** repositori kita:

```shell
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
```

Prioritaskan _official Nginx package_:

```shell
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx
```

Kemudian, install `nginx` dan `nginx-module-geoip` dengan menjalankan perintah:

```shell
sudo apt update && sudo apt install nginx nginx-module-geoip
```

_Load_ `http_geoip_module` dan `stream_geoip_module`, letakan `load_module` **diatas** `event{}` _block_ dan `geoip_country` didalam `http{}` block:

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

## Mempersiapkan struktur direktori Nginx

Buat direktori `sites-available`, `sites-enabled`, `certs`, `snippets` di dalam direktori `/etc/nginx` dengan menjalankan perintah:

```shell
sudo mkdir -p /etc/nginx/{sites-available,sites-enabled,certs,snippets}
```

Buat _self-signed certificate_ (hanya digunakan sebagai konfigurasi awal yang nantinya digantikan oleh `certbot`):

```shell
sudo openssl req -x509 -newkey rsa:4096 -days 365 -nodes \
    -keyout /etc/nginx/certs/privkey.pem                 \
    -out /etc/nginx/certs/fullchain.pem                  \
    -subj '/CN=example.local/O=My Organization/C=US'
```

Buat _DH-param_ dengan menjalankan perintah:

```shell
sudo openssl dhparam -out /etc/nginx/certs/dhparam.pem 2048
```

## Cloudflare IP Trusted Proxy

Jika ada _virtual host_ yang berada dibalik Cloudflare _reverse proxy_, sangat disarankan untuk menambahkan IP Cloudflare ke _trusted proxy_ di konfigurasi Nginx.

Buat _executable shell script_ `/etc/nginx/cloudflare-ips.sh` berikut:

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

Shell script diatas akan mendownload list IP milik Cloudflare untuk diproses dan disimpan di `/etc/nginx/snippets/cloudflare_*.conf`. Silahkan buat `cronjob` untuk menjalankan script tersebut secara berkala (per minggu / per bulan).

Untuk konfigurasi Nginx-nya, tambahkan konfigurasi berikut ke dalam `http{}` block di `/etc/nginx/nginx.conf`:

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

Fitur _logging_ dapat memperlambat kinerja server (terutama karena **DISK I/O** yang tinggi) di situs dengan _traffic_ yang tinggi. Namun _logging_ juga sangat penting untuk memonitoring dan menganalisa aktifitas server.

### Log Format

Ada beberapa log format yang umum digunakan dan dapat diintegrasikan dengan aplikasi _3rd-party_, misalnya format `(V)COMMON` atau `(V)COMBINED`.

#### VCOMBINED format

Tambahkan konfigurasi berikut ke dalam `http{}` block:

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

> Saya biasanya menggunakan log format `VCOMBINED` yang kemudian saya integrasikan dengan [GoAccess](https://goaccess.ditatompel.com/).

#### Custom JSON log

Untuk beberapa kasus, saya menggunakan **Nginx integration** di **Grafana Cloud** yang menggunakan _custom access log format_ (JSON):

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

Dengan `map`, dan `if` _keyword_, kita dapat menentukan apa saya yang akan di-log dan apa yang tidak. Misalnya, saya tidak melakukan _logging_ jika URI ada kata _"local"_ atau _User Agent_ mengandung kata _"Uptime-Kuma"_:

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

### Remote Log UDP (rsyslog)

Bagi saya, sentraliasi log sangat mempermudah pekerjaan saya dalam melakukan analisa dan _troubleshooting_ server.

Di Nginx, kita dapat dengan mudah mengirimkan log ke _remote server_ secara _real-time_. Misalnya, kita dapat mengirimkan log ke **remote `rsyslog` server** (UDP) dengan contoh konfigurasi berikut:

```nginx
http {
    # ...

    access_log     syslog:server=192.168.0.7:514,facility=local7,tag=nginx,severity=info vcombined if=$is_loggable;
    access_log     syslog:server=192.168.0.7:514,facility=local7,tag=nginx_grafana,severity=info json_analytics if=$is_loggable;

    # ...
}
```

## Compile Nginx VTS Module

**Nginx VTS module** tidak tersedia di Official Nginx repositori, sehingga kita tidak dapat menginstallnya menggunakan `apt`. Untuk mengkompile VTS module memerlukan `C` _compiler_, `git`, `libpcre`, `libssl`, dan `zlib`. Install _package_ yang dibutuhkan tersebut dengan menjalankan perintah:

```shell
sudo apt install git build-essential libpcre3-dev zlib1g-dev libssl-dev
```

Ini adalah bagian yang sangat penting, jika ingin menggunakan _dynamically linked module_, opsi mengkompile _module_ harus sama dengan Nginx _binary file_ yang akan digunakan, begitu pula dengan versi Nginx yang digunakan. Untuk mengetahui informasi yang kita butuhkan tersebut, jalankan perintah `nginx -V`. Contoh _output_:

```plain
nginx version: nginx/1.26.0
built by gcc 11.4.0 (Ubuntu 11.4.0-1ubuntu1~22.04)
built with OpenSSL 3.0.2 15 Mar 2022
TLS SNI support enabled
configure arguments: --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.26.0/debian/debuild-base/nginx-1.26.0=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie'
```

Download Nginx _source_ dengan versi yang **sama persis** dengan yang sedang kita gunakan, dalam contoh ini `1.26.0`.

```shell
curl -O https://nginx.org/download/nginx-1.26.0.tar.gz
```

Lalu _extract_ arsip Nginx _source code_ tersebut, kemudian masuk ke direktori didalamnya:

```shell
tar -xvzf nginx-1.26.0.tar.gz
cd nginx-1.26.0
```

Kemudian, clone repositori `vozlt/nginx-module-vts` dan gunakan [rilis tag terakhir](https://github.com/vozlt/nginx-module-vts/tags). Saat artikel ini dibuat, rilis tag terakhir adalah `v0.2.2`, maka:

```shell
git clone -b v0.2.2 https://github.com/vozlt/nginx-module-vts.git
```

Configure dengan argumen yang sama dari output `nginx -V` diatas dan tambahkan `--add-dynamic-module=./nginx-module-vts/`. Contoh di artikel ini:

```shell
./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.26.0/debian/debuild-base/nginx-1.26.0=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' -add-dynamic-module=./nginx-module-vts/
```

_Build_, kemudian copy VTS module yang baru saja dicompile ke `/etc/nginx/modules/`:

```shell
make modules -j$(nproc)
sudo cp objs/ngx_http_vhost_traffic_status_module.so /etc/nginx/modules/
```

### Konfigurasi Nginx VTS Module

Edit file `/etc/nginx/nginx.conf` dan _load_ `host_traffic_status_module` berikut **diatas** `event{}` _block_:

```nginx
load_module modules/ngx_http_vhost_traffic_status_module.so;
```

Kemudian didalam `http{}` _block_, tambahkan konfigurasi berikut:

```nginx
http {
    # ...

    geoip_country /usr/share/GeoIP/GeoIP.dat;
    vhost_traffic_status_zone;
    vhost_traffic_status_filter_by_set_key $geoip_country_code country::*;

    # ...
}
```

Untuk menampilkan halaman **VTS traffic status**, tambahkan contoh konfigurasi berikut ke `server{}` block (misalnya di `/etc/nginx/conf.d/default.conf`):

```nginx
server {
    # ...

    # contoh konfigurasi untuk menampilkan halaman Nginx VTS status
    location /status {
        vhost_traffic_status_bypass_limit on;
        vhost_traffic_status_bypass_stats on;
        vhost_traffic_status_display;
        vhost_traffic_status_display_format html;
        access_log off;
        # contoh membatasi akses ke URI dari IP tertentu
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

## Konfigurasi Akhir

Sebagai referensi konfigurasi akhir, silahkan lihat di repositori [https://github.com/ditatompel/nginx-kickstart/tree/main/etc/nginx](https://github.com/ditatompel/nginx-kickstart/tree/main/etc/nginx).

## Kredit dan Referensi

- [https://nginx.org/en/linux_packages.html](https://nginx.org/en/linux_packages.html).
- [https://github.com/vozlt/nginx-module-vts](https://github.com/vozlt/nginx-module-vts).
- [https://github.com/itsjfx/cloudflare-nginx-ips](https://github.com/itsjfx/cloudflare-nginx-ips).
- [https://github.com/ditatompel/nginx-kickstart](https://github.com/ditatompel/nginx-kickstart).
