---
title: "Menginstall Wakapi, Sebuah Self-Hosted Koding Statistik yang Kompatible Dengan WakaTime Client API"
description: "Tutorial cara install Wakapi, sebuah self-hosted koding statistik yang kompatible dengan WakaTime Client API"
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
  - Privasi
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

**Wakapi** adalah sebuah _self-Hosted_ koding statistik yang kompatible dengan **WakaTime client**. Dapat diinstall di Windows, MacOS, maupun Linux. Karena Anda yang memegang server, maka data benar-benar milik Anda. Artikel ini berisi cara untuk menjalankan Wakapi di sistem operasi Linux.

<!--more-->
---

## Pengantar

Saya yang sehari-harinya banyak berinteraksi dengan komputer, terutama melakukan _maintenance server_ dan koding selalu ingin tahu apa saja yang sudah saya kerjakan, projek mana yang paling banyak menyita waktu, dan bahasa program apa yang paling banyak saya gunakan. Ada beberapa jasa yang pernah saya cobaselama setahun terakhir, dari [Activity Watch](https://activitywatch.net/), [CodeStats](https://codestats.net/), hingga [WakaTime](https://wakatime.com/).

Untuk **Activity Watch**, memang _backend_ bisa diinstall di lokal / _remote server_, tetapi saya rasa cukup berat dijalankan. Untuk **CodeStats** dan **WakaTime** cukup memuaskan, tetapi ada yang kurang, yaitu data statistik koding dikirimkan ke server mereka. Tentu saja hal tersebut cukup mengganggu pikiran saya.

Beruntungnya, beberapa hari yang lalu ketika saya melakukan *"window shopping"* ke **GitHub** menemukan solusi dari yang selama ini saya inginkan yaitu [Wakapi](https://wakapi.dev/); sebuah _endpoint_ API yang kompatibel dengan **WakaTime client** yang bisa di-_self-hosted_.

Wakapi server dibuat dengan bahasa program **Go**, dan dapat dijalankan di sistem operasi Windows, MacOS (baik `ARM` maupun `x86_64`), maupun Linux (baik `ARM` maupun `x86_64`). Di artikel kali ini saya ingin berbagi pengalaman menginstall dan menjalankan Wakapi di Linux server.

## Installasi Server
Sebelum memulai, ada beberapa prasyarat yang harus dipenuhi untuk mengikuti artikel ini:
- Nyaman menggunakan Linux terminal
- Salah satu WakaTime client sudah terinstall dan berjalan dengan baik
- Sebuah Linux server / Laptop / PC
- Sebuah Web Server (pada artikel ini saya menggunakan **Nginx**. Optional, tapi __recommended__ jika Wakapi dapat diakses dari publik)

Ada beberapa cara menjalankan Wakapi server sendiri:
1. Menggunakan _precompiled binary_
2. menggunakan **Docker**
3. _Compile_ dari _source-code_

Karena di server saya sudah terinstall Go, maka pada artikel ini saya akan menggunakan opsi ketiga, yaitu melakukan _compile_ langsung dari __source-code__-nya.

### Mempersiapkan Sistem & Compile Executable Binary
Pertama, persiapkan sistem dengan membuat sistem user baru:
```shell
sudo useradd -r -m --system -d /opt/wakapi -s /bin/bash wakapi
```

_Clone_ repositori [mutey/wakapi](https://github.com/muety/wakapi) dan lakukan _compile executable binary_-nya:
```shell
# clone repo
git clone https://github.com/muety/wakapi.git

# build executable binary
cd wakapi
go build -o wakapi
```

### Setting Konfigurasi Wakapi
Setelah proses _compile_ selesai, pindahkan _executable binary_ ke `$HOME` milik user `wakapi` yang sudah kita buat sebelumnya.
```shell
sudo mv wakapi /opt/wakapi/
```
Download contoh konfigurasi
```shell
sudo curl -o /opt/wakapi/wakapi.yml https://raw.githubusercontent.com/muety/wakapi/master/config.default.yml
# ubah kepemilikan file ke user wakapi
sudo chown wakapi:wakapi /opt/wakapi/wakapi.yml /opt/wakapi/wakapi
```

Kemudian edit file konfigurasi `/opt/wakapi/wakapi.yml` sesuai dengan yang dibutuhkan. Misalnya, saya akan menggunakan subdomain `wakapi.example.com` dengan Nginx sebagai _reverse proxy_ untuk Wakapi, maka saya set `listen_ipv4` nya ke `127.0.0.1` dan `public_url` nya ke `https://wakapi.example.com`. Sesuaikan konfigurasi yang lain seperti koneksi database, SMTP email, dan lain-lain.

### Membuat Systemd Service
Setelah konfigurasi sudah disesuaikan dengan kebutuhan, buat **Systemd service** Wakapi untuk mempermudah manajemen dalam menjalankan atau merestart _Wakapi service_.

Buat file `/etc/systemd/system/wakapi.service` dengan isi kurang lebih seperti berikut:
```systemd
[Unit]
Description=Wakatime Wakapi
StartLimitIntervalSec=400
StartLimitBurst=3

# Optional, dan jika menggunakan SQL / PostgreSQL dengan Systemd
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

Kemudian _reload_ dan jalankan wakapi _service_:
```shell
sudo systemctl daemon-reload
sudo systemctl enable wakapi.service --now

# cek apakah service berjalan dengan baik
systemctl status wakapi.service
```
Jika semua berjalan dengan baik, masuk ke langkah selanjutnya untuk Nginx _reverse proxy_.

### Nginx Reverse Proxy
Untuk konfigurasi Nginx, tidak memerlukan konfigurasi khusus. Cukup gunakan konfigurasi _reverse proxy_ pada umumnya. Contoh:

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

Sesuaikan `proxy_pass` dengan konfigurasi `listen_ipv4` dan `port` dari `/opt/wakapi/wakapi.yml` milik Anda.

Kemudian coba akses dari Wakapi server Anda dan lakukan registrasi. Setelah berhasil melakukan registrasi, Anda akan mendapatkan **API key** yang nantinya Anda perlukan untuk setting **WakaTime client**.

## Konfigurasi WakaTime Client
Server sudah siap dan siap menerima _"heartbeat"__ Anda. Selanjutnya sesuaikan konfigurasi WakaTime client Anda ke _self-hosted_ Wakapi Anda.
Ubah konfigurasi `api_url` dan `api_key` di `.wakatime.cfg` Anda ke server milik Anda. Misalnya:

```ini
[settings]

api_url = https://wakapi.example.com/api
api_key = API-Key-Anda-Dari-Wakapi-Server-Anda
```

Coba lakukan aktifitas koding dan cek aktifitas koding Anda dari Dashboard Wakapi.

Jika Anda kurang puas dengan tampilan dashboard pada Wakapi web UI, anda bisa mengekspose _metrics_ ke format **Prometheus** kemudian [memvisualisasikannya menggunakan **Grafana**](https://grafana.com/grafana/dashboards/12790-wakatime-coding-stats/).

![Contoh Wakapi Grafana Dashboard](grafana-wakapi.png#center)

Anda juga bisa mengintegrasikannya dengan [GitHub Readme Stats](https://github.com/anuraghazra/github-readme-stats) sehingga aktifitas koding Anda dapat tampil di halaman Profile gitHub Anda.

Sekian pengalaman saya menginstall Wakapi server, semoga dapat menjadi inspirasi.
