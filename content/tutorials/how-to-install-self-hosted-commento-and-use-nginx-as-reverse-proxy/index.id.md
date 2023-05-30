---
title: "Cara Install Commento Dan Konfigurasi Nginx Sebagai Reverse Proxy-nya"
description: "Cara menginstal Commento beserta dependensi yang diperlukan seperti PostgreSQL, meng-konfigurasi Commento dan SystemD service, dan menggunakan Nginx sebagai reverse-proxy supaya Commento dapat diakses melalui HTTPS."
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

**Commento** adalah platform layanan komentar (seperti **Disqus**) yang berfokus pada privasi. Dia *open-source*, relatif cepat saat diakses dan dapat didownload dan dijalankan di server milik kita sendiri (*self-hosted*). Artikel ini membahas mengenai cara menginstal Commento beserta dependensi yang diperlukan seperti **PostgreSQL**, meng-konfigurasi Commento dan **SystemD** *service* supaya dapat *auto-start* setelah server booting. Dan, sebagai tambahan, menggunakan **Nginx** sebagai *reverse-proxy* supaya Commento dapat diakses melalui HTTPS.

<!--more-->

> **PERINGATAN**: Saya menggunakan Commento sudah cukup lama, tapi sejak 1 tahun yang lalu sampai artikel ini dibuat, saya tidak menemukan adanya rilis terbaru ataupun *commit* ke *master branch* di **git** repositori-nya. Anda bisa mencoba [Commento++](https://github.com/souramoo/commentoplusplus) sebagai penggantinya.


## Kebutuhan Hardware
Commento bisa dibilang cukup ringan dan dari pihak developer sendiri menyarankan untuk dapat menjalankan Commento, paling tidak server memiliki 64MB *free* RAM dan paling tidak 30MB *free disk space*. Tentu saja kebutuhan tersebut diluar kebutuhan untuk menjalankan PostgreSQL database server dan Nginx Web Server / *Reverse Proxy* server.

Tentu saja Anda bisa juga menggunakan PostgreSQL server terpisah atau penyedia layanan PostgreSQL berbasis *cloud* untuk database Commento.

Program commento yang distribusikan ke publik terkonfirmasi dapat berjalan dengan baik di arsitektur hardware `amd64` dan `x86`.

## Kebutuhan Software
Commento menggunakan PostgreSQL sebagai databasenya, dan supaya dapat berjalan dengan baik, dibutuhkan PostgreSQL versi `9.6` atau lebih tinggi. Tidak ada kebutuhan software lainnya, kecuali Anda benar-benar ingin meng*compile* Commento dari *source-code*nya.

Disamping itu, disarankan juga untuk menggunakan Nginx didepan Commento supaya commento dapat diakses melalui HTTPS.

## Install PostgreSQL
Di artikel ini mari kita asumsikan bahwa kita menggunakan **Ubuntu** `20.04` dimana dari repositori *official package repository*-nya sudah menyediakan PostgreSQL versi `9.6` (atau lebih tinggi).

Install `postgresql` dan `postgresql-contrib`:

```bash
sudo apt update && sudo apt install postgresql postgresql-contrib
```

Secara default, Postgres menggunakan konsep yang disebut `roles` untuk menghandle autentikasi dan otorisasi (sistemnya mirip dengan `User` dan `Group` pada sistem operasi Linux / Unix). 

Buat `role` baru pada PostgreSQL menggunakan user `postgres` menggunakan perintah berikut:
```bash
sudo -u postgres createuser --interactive
```

```
Enter name of role to add: commento
Shall the new role be a superuser? (y/n) n
Shall the new role be allowed to create databases? (y/n) n
Shall the new role be allowed to create more new roles? (y/n) n
```

Setelah itu, buat database baru menggunakan user `postgres` yang nantinya digunakan oleh Commento dengan perintah `createdb` :

```bash
sudo -u postgres createdb commento
```

Perintah diatas akan membuat database baru dengan `commento`.

Opsional: Buat password untuk user postgres:

```bash
sudo -u postgres psql
ALTER USER postgres PASSWORD '[GantiDenganPasswordPilihanAnda]';
```
Jika sukses, Posgres akan merespond dengan output `ALTER ROLE`.

## Install Commento
Cari [Commento rilis terbaru](https://vr4.me/g/OyQAY) dan download arsipnya ke server:
```bash
wget https://dl.commento.io/release/commento-v1.8.0-linux-glibc-amd64.tar.gz
```

Extract ke folder dimana program *binary* Commento ingin disimpan dan nantinya dijalankan. Misalnya `/opt/commento`.
```bash
mkdir /opt/commento
tar -xvzf commento-v1.8.0-linux-glibc-amd64.tar.gz -C /opt/commento/
```

## Mengkonfigurasi Commento
Sebelum dapat menjalankan program / *service* Commento, Anda perlu menentukan konfigurasi yang dibutuhkan, antara lain: URL yang nantinya digunakan untuk mengakses `self-hosted` Commento, koneksi ke database, dll. Ada pula konfigurasi opsional seperti SMTP dan OAuth.

Di artikel ini mari kita asumsikan kalau Commento akan dijalankan di server dengan menggunakan alamat IP lokal (`127.0.0.1`) port `8088` dan nantinya dapat diakses dari URL `https://commento.ditatompel.com` melalui **Nginx reverse proxy**.

Selain itu, diasumsikan juga server database PostgreSQL berada di 1 server yang sama dengan program Commento dijalankan dengan informasi sebagai berikut:

Host: `127.0.0.1`   
Nama database : `commento`   
User: `commento`   
password: `commentoPassword`   

Buat *environment variables* yang nantinya digunakan oleh Commento systemd service. Anda bisa meletakan file `.env` di folder `/etc/commento/commento.env` supaya nantinya kita lebih mudah saat mengubah-ubah konfigurasi.
```bash
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

Kemudian buat `systemd` *service file* yang berlokasi di `/etc/systemd/system/commento.service`:
```bash
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

Reload konfigurasi `systemd` *service files* kemudian jalankan Commento *service*:
```bash
sudo systemctl daemon-reload
sudo systemctl start commento
sudo systemctl enable commento
```

## Setting Nginx *reverse proxy* untuk Commento (sub)domain
Terakhir, saatnya untuk mengkonfigurasi **Nginx** didepan Commento. Konfigurasi `server block` **Nginx** dibawah ini adalah contoh *basic* yang memerintahkan Nginx berjalan sebagai *reverse-proxy* untuk Commento (Mengaktifkan HTTPS dan meneruskan *HTTP request* ke `127.0.0.1` port `8088`).

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

Restart Nginx *service* dan coba akses Commento menggunakan browser Anda.

## Resources
* [https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart](https://r.vr4.me/QKRFo)
* [https://docs.commento.io/](https://docs.commento.io/)
