---
title: Akses Aplikasi Self-Hosted di Rumah Dari Manapun
description: Tujuan artikel ini adalah untuk menunjukkan bagaimana saya dapat mengakses foto dan video saya di rumah dari mana saja, menggunakan VPN tunnel yang terhubung ke server Immich lokal saya.
summary: Bagaimana saya dapat mengakses aplikasi Immich saya di rumah dari mana saja.
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

Ada banyak cara untuk mengekspose _HTTP service_ yang berada dibalik NAT supaya
dapat diakses dari internet. Pada umumnya, teknik yang dilakukan adalah
melakukan _network tunnel_ menggunakan VPN dan HTTP _reverse proxy_.
[Cloudflare Tunnel][cloudflare-tunnel] adalah salah satu contoh yang
menggunakan teknik ini.

Di artikel ini saya ingin berbagi pengalaman dan cara saya mengekspose HTTP
service yang berada di jaringan lokal ke internet menggunakan WireGuard VPN
tunnel dan Nginx sebagai _HTTP reverse proxy_. HTTP service yang akan saya
expose adalah [Immich][immich-web]. Bagi yang belum tahu, Immich adalah solusi
manajemen foto dan video yang dapat dihosting sendiri; sebuah alternatif dari
[Google Photos][google-photos].

Saya tidak akan membahas detail cara menginstall Immich karena proses
[instalasi Immich menggunakan Docker][immich-docker-install] sangat mudah
dilakukan. Saya akan lebih fokus ke konfigurasi Nginx dan VPN tunnel, serta
topologi yang digunakan.

{{< youtube RIiSldGZuD0 >}}

## Prasyarat

Sebelum memulai ada beberapa kondisi yang perlu dipenuhi, yaitu:

1. Sebuah nama domain atau subdomain yang menggunakan Cloudflare sebagai
   _authoritative DNS server_.
2. Sebuah VPS dengan IP public (sudah terinstall WireGuard dan Nginx yang
   nantinya digunakan untuk _reverse proxy_ ke jaringan lokal).
3. Sebuah PC / VM / LXC di jaringan lokal untuk menjalankan Nginx, Docker dan
   Certbot.

## Topologi

Sebelum memulai, saya ingin membagikan topologi jaringan yang saya gunakan saat
artikel ini dibuat.

![gambar topologi jaringan](topology.jpg#center)

Ijinkan saya menjelaskan topologi diatas dan memberikan tambahan informasi
untuk mengikuti artikel ini:

-   Subdomain yang saya gunakan untuk Immich adalah `i.arch.or.id`.
-   IP publik VPS server yang saya gunakan adalah `154.26.xxx.xx`.
-   IP VPS server untuk WireGuard tunnel adalah `10.88.88.51`.
-   Jaringan LAN menggunakan segmen `192.168.2.0/24`.
-   Immich terinstall di LXC yang berada di jaringan lokal dengan alamat IP
    `192.168.2.105`.
-   LXC Immich terkoneksi ke VPS server dan menggunakan IP tunnel `10.88.88.105`.
-   Di LXC Immich juga terinstall Nginx dan Certbot.

Tujuan akhir dari artikel ini adalah aplikasi Immich dapat diakses dari
internet dan seluruh perangkat yang berada pada jaringan lokal dapat terkoneksi
secara langsung ke server Immich tanpa harus memutar ke internet.

Jadi ketika saya berada di luar rumah, saya masih tetap bisa mengakses foto dan
video saya yang berada di rumah melalui aplikasi Immich. Sedangkan saat saya
berada dirumah, saya dapat secara leluasa melakukan sinkronisasi atau upload
foto dan video lebih cepat karena terkoneksi langsung menggunakan jaringan LAN.

## Konfigurasi

### Cloudflare: DNS record & Edge Certificates

Anda perlu mendelegasikan _authoritative DNS server_ ke Cloudflare kemudian
tambahkan atau arahkan `A`/`AAAA` record untuk subdomain yang akan digunakan
oleh immich ke IP public VPS Anda. Di artikel ini berarti saya mengarahkan `A`
record `i.arch.or.id` ke IP `154.26.xxx.xx`.

![](cf-dns-record.jpg#center)

Ada beberapa setting default dari Cloudflare yang perlu dirubah supaya LXC
dapat melakukan request sertifikat SSL menggunakan certbot, yaitu:

1. Mengubah **mode enkripsi** ke `Full`. Caranya masuk ke manajemen domain ->
   **SSL/TLS** -> **Overview**. Pada bagian **"SSL/TLS encryption"** ubah
   **_encryption mode_** ke `Full`. Hal ini perlu dilakukan supaya Cloudflare
   mau menerima _"self-signed certificate"_ dari _origin server_.
   ![](cf-encryption-mode.jpg#center)
2. Mendisable **"Always Use HTTPS"** dan **"Automatic HTTPS Rewrites"**.
   Caranya masuk ke manajemen domain -> **Edge Certificates**. Pastikan
   **"Always Use HTTPS"** dan **"Automatic HTTPS Rewrites"** tidak aktif. Hal
   ini perlu dilakukan supaya verifikasi SSL request dari LXC ke **Let's
   Encrypt** server berjalan dengan lancar.
   ![](cf-automatic-https.jpg#center)

### VPS: WireGuard & Nginx

Anda perlu mensetting dan menjalankan WireGuard di VPS server yang nantinya
digunakan untuk berkomunikasi dengan LXC server yang berada di jaringan lokal.
Jika Anda belum pernah melakukan konfigurasi WireGuard, Anda dapat membaca
artikel saya sebelumnya tentang [cara setup WireGuard VPN server secara
manual]({{< ref "/tutorials/how-to-setup-your-own-wireguard-vpn-server/index.id.md" >}})
atau [menggunakan WireGuard-UI]({{< ref "/tutorials/installing-wireguard-ui-to-manage-your-wireguard-vpn-server/index.id.md" >}}).

Kurang lebih, konfigurasi WireGuard di VPS server saya sebagai berikut:

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

Kemudian konfigurasi Nginx di VPS server sebagai reverse proxy ke LXC server,
kurang lebih konfigurasi Nginx saya sebagai berikut:

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

Bisa dilihat bahwa Nginx di VPS server menggunakan _Self-signed certificates_.
Hal ini tidak menjadi masalah karena kita sudah mengkonfigurasi Cloudflare
SSL/TLS **encryption mode** ke `Full`.

Dengan konfigurasi diatas, _HTTP request_ dari internet akan melewati
Cloudflare dan menggunakan sertifikat SSL yang valid dari Cloudflare. Request
dilanjutkan ke VPS server dan kemudian diteruskan ke LXC server melalui
WireGuard VPN tunnel.

### Lokal LXC: WireGuard, Immich (Docker), Nginx, Certbot

Install WireGuard dan buat konfigurasi supaya bisa terhubung ke WireGuard
server di VPS. Berikut ini contoh konfigurasi WireGuard di LXC server saya:

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

Kemudian, install Immich dengan mengikuti proses [instalasi Immich menggunakan
Docker dari situs resminya][immich-docker-install]. Secara default, Immich akan
menggunakan TCP port `2283`.

Buat konfigurasi Nginx virtual host untuk Immich. Nginx di LXC ini akan
berfungsi sebagai reverse proxy dan menghandle **Acme challenge** sehingga
server LXC memiliki sertifikat yang valid. Berikut ini adalah contoh
konfigurasi Nginx virtual host untuk Immich di server LXC lokal:

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

Dari konfigurasi Nginx diatas, perlu diperhatikan bahwa untuk konfigurasi awal
saya masih menggunakan _Self-signed certificate_. Langkah selanjutnya adalah
melakukan request sertifikat SSL menggunakan Certbot.

> **Catatan**: Sebelum melakukan request serifikat SSL, pastikan koneksi antara
> VPS server dan LXC melalui WireGuard tunnel berjalan dengan baik. Begitu pula
> dengan konfigurasi Nginx baik di VPS server dan LXC server.

Install certbot Nginx plugin. Di Ubuntu, Anda bisa menginstall cerbot Nginx
plugin menggunakan `sudo apt install python3-certbot-nginx`. Setelah Certbot
Nginx plugin terinstall, lakukan request sertifikat SSL dari XLC server:

```shell
sudo certbot --nginx -d i.arch.or.id
```

Ubah `i.arch.or.id` ke (sub)domain milik Anda.

### LAN: Lokal DNS resolver

Langkah terakhir adalah mengkonfigurasi perangkat-perangkat di jaringan LAN
supaya subdomain `i.arch.or.id` mengarah ke IP lokal server LXC
(192.169.2.105). Cara paling efektif adalah menggunakan lokal _DNS resolver_
yang bisa digunakan oleh seluruh perangkat di jaringan LAN. Untuk konfigurasi
_DNS resolver_ akan sangat bervariasi tergantung seperti apa jaringan LAN
masing-masing.

Untuk jaringan LAN saya, saya mempunyai dua buah DNS resolver. DNS resolver
pertama berada di Router **MikroTik**, dan resolver kedua menggunakan
**AdGuard Home** yang berjalan di Linux Container. AdGuard home disini saya
gunakan juga sebagai DHCP server untuk jaringan lokal saya.

Berikut capture konfigurasi DNS resolver di MikroTik router dan AdGuard Home
saya:

![](lan-dns-resolver.jpg#center)

Dengan konfigurasi tersebut, seluruh perangkat yang ada di jaringan lokal
menggunakan DHCP akan langsung akan menggunakan IP `192.168.2.105` ketika
mencoba mengakses subdomain `i.arch.or.id`.

## limitasi

-   Karena maksimum upload di Cloudflare hanya 100MB per request (untuk free
    version), maka proses sinkronisasi Immich dari internet kemungkinan besar
    banyak yang gagal, terutama saat sinkronisasi video.

[cloudflare-tunnel]: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/ "Cloudflare Tunnel"
[immich-web]: https://immich.app/ "Immich website"
[immich-docker-install]: https://immich.app/docs/install/docker-compose "Install Immich using Docker"
[google-photos]: https://photos.google.com/ "Google Photos website"
