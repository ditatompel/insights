---
title: "Menginstall WireGuard-UI untuk Mengatur WireGuard Server Anda"
description: "WireGuard-UI akan sangat mempermudah Anda dalam mengatur WireGuard peers. Artikel ini membahas langkah-langkah menginstall dan mengkonfigurasi WireGuard UI di VPS."
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
  - Privasi
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
  - vie
---

WireGuard-UI akan sangat mempermudah Anda dalam mengatur **WireGuard** *peers* (*clients*). Artikel ini membahas langkah-langkah menginstall dan mengkonfigurasi WireGuard UI di VPS.

<!--more-->
---

[Wireguard-UI](https://github.com/ngoduykhanh/wireguard-ui) adalah GUI berbasis website untu mmengatur konfigurasi WireGuard server yang ditulis oleh [ngoduykhanh](https://github.com/ngoduykhanh) menggunakan bahasa pemrograman **Go**. Ini bisa menjadi alternatif untuk menginstall dan mempermudah pengatur VPN server WireGuard Anda.

Jika Anda lebih memilih untuk menginstall WireGuard server **"from scratch"* dan mengatur dan mengkonfigurasi secara manual, Anda bisa mengikuti artikel saya sebelumnya mengenai "[Cara Setup VPN Server WireGuard Sendiri]({{< ref "/tutorials/how-to-setup-your-own-wireguard-vpn-server/index.id.md" >}})"

## Prasyarat
- Sebuah **VPS** (**Ubuntu** `22.04 LTS`) dengan alamat IP publik dan **Nginx** *webserver* sudah terinstall di VPS tersebut.
- Nyaman dan terbiasa dengan Linux *command-line*.
- Paham dasar-dasar *subnetting* di **IPv4** (_jujur, saya tidak begitu paham dan berpengalaman untuk subnetting di **IPv6**, jadi artikel ini hanya untuk **IPv4**_).
- Mampu mengkonfigurasi **Nginx** *Virtual Host*.

Pada artikel ini, tujuan kita adalah:
- _**WireGuard** daemon_ berjalan di port `51822/UDP`.
- **WireGuard UI** berjalan dari `127.0.0.1` port `5000`.
- **Nginx** bertugas sebagai *reverse proxy* supaya **WireGuard UI** dan WireGuard UI dapat diakses melalui protokol **HTTPS**.

## Mempersiapkan Server Anda
Pertama, pastikan server sudah *up-to-date* dan WireGuard sudah terinstall di server Anda.
```shell
sudo apt update && sudo apt upgrade
sudo apt install wireguard
```

Edit `/etc/sysctl.conf` dan tambahkan konfigurasi `net.ipv4.ip_forward=1` di bagian akhir file tersebut, kemudian jalankan perintah `sudo sysctl -p`.
```shell
sudo sysctl -p
```
Hal tersebut perlu dilakukan supaya *kernel* mengijinkan melakukan **IP forwarding**.

### Mengkonfigrasi Firewall
Anda perlu untuk menambahkan _port_ yang akan digunakan oleh WireGuard _daemon_ ke _allow-list firewall_ Anda. Dari bawaan distro **Ubuntu**, **UFW** sudah terinstall dan dapat digunakan untuk mengkonfigurasi *firewall*.
```shell
sudo ufw allow OpenSSH
sudo ufw allow 80 comment "allow HTTP" # akan digunakan  oleh Nginx
sudo ufw allow 443 comment "allow HTTPS" # akan digunakan  oleh Nginx
sudo ufw allow proto udp to any port 443  comment "allow QUIC" # Jika konfigurasi Nginx Anda mensupport QUIC
sudo ufw allow proto udp to any port 51822 comment "WireGuard listen port"
```
> _Perhatikan bahwa saya juga menambahkan **OpenSSH** ke allow list untuk menghindari terputusnya koneksi SSH jika sebelumnya Anda belum mengkonfigurasi / mengaktifkan UFW._

*Enable* / *restart* `ufw` menggunakan perintah berikut:
```shell
sudo ufw enable # untuk enable firewall, atau
sudo ufw reload # untuk reload firewall
```


## Mendownload & Mengkonfigurasi WireGuard-UI
Download [Wireguard-UI dari halaman _latest release_-nya](https://github.com/ngoduykhanh/wireguard-ui/releases) ke server Anda (pilih sesuai dengan sistem operasi dan arsitektur CPU server Anda).

*Extract* file `.tar.gz` yang baru saja Anda download:
```shell
tar -xvzf  wireguard-ui-*.tar.gz
```

Buat folder `/opt/wireguard-ui` dan pindahkan `wireguard-ui` *binary* (dari hasil *extract* file `.tar.gz`) ke `/opt/wireguard-ui`.

```shell
mkdir /opt/wireguard-ui
mv wireguard-ui /opt/wireguard-ui/
```

Buat *environment file* untuk WireGuard-UI. Environment file tersebut nantinya akan dibaca dari `EnvironmentFile` melalui `systemd`:
```plain
# /opt/wireguard-ui/.env
SESSION_SECRET=<YOUR_STRONG_RANDOM_SECRET_KEY>
WGUI_USERNAME=<YOUR_WIREGUARD_UI_USERNAME>
WGUI_PASSWORD=<YOUR_WIREGUARD_UI_PASSWORD>
```

Jika Anda ingin mengaktifkan fitur email, Anda perlu menambahkan setting `SMTP_*` ke *environment variable* diatas. Baca [WireGuard UI Environment Variables details](https://github.com/ngoduykhanh/wireguard-ui#environment-variables) untuk informasi lebih lanjut.

### Menemukan Default Interface Server
Kemudian, cari tahu *network interface* mana yang digunakan oleh server Anda sebagai *default route*-nya. Anda bisa menggunakan perintah `ip route list default` untuk itu. Sebagai contoh, *output* dari perintah `ip route list default` saya adalah:
```plain
default via 164.90.160.1 dev eth0 proto static
```
Catat kata setelah *output* `dev` diatas, itu adalah *default network interface* server Anda. Kita membutuhkan informasi tersebut nanti. Jika dilihat dari contoh *output* diatas, *default network interface* saya `eth0`.

Buat file `/opt/wireguard-ui/postup.sh`, dan isi dengan contoh konfigurasi berikut:
```bash
#!/usr/bin/bash
# /opt/wireguard-ui/postup.sh
ufw route allow in on wg0 out on eth0
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
```
*Bash script* `postup.sh` diatas akan dieksekusi saat *service* WireGuard **dijalankan (*started*)**.

Buat file `/opt/wireguard-ui/postdown.sh`. dan isi dengan contoh konfigurasi berikut:
```bash
#!/usr/bin/bash
# /opt/wireguard-ui/postdown.sh
ufw route delete allow in on wg0 out on eth0
iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```
*Bash script* `postdown.sh` diatas akan dieksekusi saat *service* WireGuard **diberhentikan (*stopped*)**.

Ubah `eth0` dari dua *bash script* diatas dengan *default network interface* Anda (*lihat pada sesi [Menemukan Default Interface Server](#menemukan-default-interface-server) diatas*).

Kemudian, ubah *file permission* kedua *bash script* tersebut (`/opt/wireguard-ui/postup.sh` and `/opt/wireguard-ui/postdown.sh`) supaya bisa dieksekusi:
```shell
chmod +x /opt/wireguard-ui/post*.sh
```

### WireGuard-UI daemon SystemD
Untuk memanage **WireGuard-UI** daemon (Web UI) menggunakan `systemd`, buat `/etc/systemd/system/wireguard-ui-daemon.service` *systemd service* file, dan isi dengan konfigurasi berikut:
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
> WireGuard UI daemon akan *listen* ke `127.0.0.1:5000` dengan konfigurasi `systemd` service diatas.

Sekarang *reload* konfigurasi `systemd` *daemon* dan cobalah untuk menjalankan `wireguard-ui-daemon.service`.
```shell
sudo systemctl daemon-reload
sudo systemctl start wireguard-ui-daemon.service
```

Periksa dan pastikan `wireguard-ui-daemon.service` Anda berjalan dengan baik dengan menggunakan perintah `systemctl status wireguard-ui-daemon.service`:
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

Jika semuanya berjalan dengan baik, Anda bisa melihat bahwa **WireGuard-UI** sudah *listen* ke `127.0.0.1:5000` (tapi, untuk saat ini, Anda tidak dapat mengakses web UI secara *remote* sampai Anda menelesaikan sesi "*[Mengkonfigurasi Nginx Untuk WireGuard-UI](#mengkonfigurasi-nginx-untuk-wireguard-ui)*" dibawah). 

Supaya `wireguard-ui-daemon.service` otomatis berjalan ketika server *restart*, jalankan perintah berikut:
```shell
sudo systemctl enable wireguard-ui-daemon.service
```

### Auto Restart WireGuard Daemon
Karena **WireGuard-UI** hanya bertugas untuk *menggenerate* konfigurasi WireGuard, Anda perlu `systemd` *service* lainnya untuk mendeteksi adanya perubahan pada konfigurasi WireGuard dan melakukan *restart* WireGuard *service* itu sendiri. Buat `/etc/systemd/system/wgui.service` dan isi dengan contoh konfigurasi berikut:
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

Kemudian, buat `/etc/systemd/system/wgui.path`:
```systemd
[Unit]
Description=Watch /etc/wireguard/wg0.conf for changes

[Path]
PathModified=/etc/wireguard/wg0.conf

[Install]
WantedBy=multi-user.target
```

Reload `systemd` *daemon* dengan menjalankan perintah berikut:
```shell
systemctl daemon-reload
systemctl enable wgui.{path,service}
systemctl start wgui.{path,service}
```

### Mengkonfigurasi Nginx Untuk WireGuard-UI
Jika **Nginx** belum terinstall di server Anda, Anda perlu menginstallnya terlebih dahulu. Anda bisa menginstall Nginx mengunakan **default repositori dari Ubuntu** atau menggunakan [official Nginx repositori untuk Ubuntu](https://nginx.org/en/linux_packages.html#Ubuntu).

Setelah Nginx terinstall, buat **Nginx virtual host server block** untuk WireGuard UI:

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
- Ubah `wgui.example.com` dengan nama (sub)domain Anda.
- Ubah `ssl_certificate` dan `ssl_certificate_key` dengan *SSL certificate* Anda.

Setelah itu, *restart* Nginx menggunakan perintah `sudo systemctl restart nginx`.

**Harap diperhatikan** bahwa konfigurasi Nginx *virtual server block* diatas adalah contoh yang **sangat _basic_**. Jika Anda memerlukan referensi konfigurasi SSL untuk Nginx, Anda bisa menggunakan [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/). Jika Anda ingin menggunakan [Let's Encrypt](https://letsencrypt.org/), install `python3-certbot-nginx` dan lakukan lakukan request untuk *SSL certificate* Anda menggunakan perintah `certbot --nginx -d wgui.example.com`.

## Menggunakan WireGuard-UI
Sekarang, setelah semua yang dibutuhkan selesai dikonfigurasi, saatnya untuk **mengkonfigurasi WireGuard menggunakan WireGuard-UI**. Kunjungi (sub)domain WireGuard UI Anda dan login menggunakan username dan password yang sudah Anda konfigurasi sebelumnya di `/etc/wireguard-ui/.env`.

> _**CATATAN:** **Jangan** menekan **"Apply Config"** sebelum Anda selesai mengkonfigurasi setting WireGuard dari WireGuard UI._

Masuk ke halaman **"WireGuard Server"** dan atur konfigurasi WireGuard, contoh:
- **Server Interface Addresses**: `10.10.88.1/24`
- **Listen Port**: `51822`
- **Post Up Script**: `/opt/wireguard-ui/postup.sh`
- **Post Down Script**: `/opt/wireguard-ui/postup.sh`

![WireGuard- UI Server Settings](wg-ui-server-config.png#center)

Kemudian, masuk ke halaman **"Global Settings"** dan pastikan semua konfigurasi sudah benar (terutama **"Endpoint Address"** dan **"Wireguard Config File Path"**).

Setelah itu, cobalah untuk menekan **Apply Config**. Periksa dan pastikan semuanya berjalan dengan baik (pengecekan dapat menggunakan perintah `wg show` atau `ss -ulnt` dari *command-line*).

### Membuat Peer (client)
Membuat *peers* menggunakan WireGuard UI sangat mudah, Anda hanya perlu menekan tombol **"+ New Client"** di sisi kanan atas dan isi informasi yang diperlukan (Minimal Anda hanya perlu mengisi *field* **"Name"**).

Setelah menambahkan *peers* (*clients*), tekan tombol **"Apply Config"** dan coba untuk melakukan koneksi ke WireGuard VPN server dari perangkat Anda. File konfigurasi untuk perangkat Anda dapat didownload dari **WireGuard UI**. Anda juga bisa dengan mudah mengimport konfigurasi untuk perangkat Anda  menggunakan fitur *scan* **QR Code**. 

![WireGuard UI clients page](wg-ui-clients.png#center)

Apa langkah selanjutnya? Bagaimana dengan [Mengkonfigurasi WireGuard VPN Client]({{< ref "/tutorials/configure-wireguard-vpn-clients/index.id.md" >}})?

## Catatan
- Jika Anda memiliki kesulitan teknis untuk melakukan *setup* VPN server WireGuard sendiri, saya dapat membantu Anda untuk melakukannya dengan imbalan sedikit uang. (_Saya juga menerima **Monero XMR** sebagai **imbalan** jika Anda tidak memiliki mata uang Rupiah_).
- Untuk dapat menghubungi saya, silahkan kunjungi [https://www.ditatompel.com/pages/contact](https://www.ditatompel.com/pages/contact).