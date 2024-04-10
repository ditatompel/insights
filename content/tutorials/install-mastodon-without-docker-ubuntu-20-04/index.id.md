---
title: "Install Mastodon Tanpa Docker (Ubuntu 20.04)"
description: "Cara menginstal Mastodon beserta dependensi yang diperlukan seperti PostgreSQL, Ruby, dan NodeJS, meng-konfigurasi Mastodon dan SystemD service di Ubuntu 20.04."
# linkTitle:
date: 2022-12-10T04:35:14+07:00
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
  - Mastodon
  - PostgreSQL
  - Ruby
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


**Mastodon** adalah *software* media sosial (seperti **Twitter**) yang sifatnya *free* dan *open-source*. Keunikan dari Mastodon adalah terdesentralisasi, banyak orang menginstall Mastodon dan masing-masing installasi Mastodon (yang bisa kita sebut *node* atau *instance*) dapat saling berkomunikasi dan dapat memiliki syarat dan ketentuan, kebijakan privasinya masing-masing.

Artikel ini membahas mengenai cara menginstal Mastodon di Ubuntu 20.04 beserta dependensi yang diperlukan seperti **PostgreSQL**, **Ruby**, dan **NodeJS**, meng-konfigurasi Mastodon dan **SystemD** *service* supaya dapat *auto-start* setelah server booting. 

<!--more-->

Catatan: saya menggunakan *self-signed* SSL *certificate* karena *instance* yang akan saya jalankan akan berada dibalik **Cloudflare** *reverse proxy*.

Video saat proses installasi dan konfigurasi Mastodon dapat dilihat dibawah ini:

{{< youtube eBUr7JFiGMo >}}

## Pre-requisites
Sebelum memulai, ada beberapa syarat yang harus dipenuhi untuk dapat menjalankan Mastodon, yaitu:

* Ubuntu Server 20.04 (*fresh*) dengan akses `root`.
* Sebuah domain (atau sub-domain) untuk Mastodon *instance* (dalam hal ini saya menggunakan domain `vr4.me` dan *instance* Mastodon nantinya akan dapat diakses melalui `https://social.vr4.me`).
* SMTP server untuk pengiriman email.


## Menyiapkan Sistem
Pertama, pastikan server Ubuntu yang digunakan sudah *up-to-date*:

```bash
apt update && apt upgrade
```

Install `curl`, `wget`, `gnupg`, `apt-transport-https`, `lsb-release` dan `ca-certificates`:

```bash
apt install -y curl wget gnupg apt-transport-https lsb-release ca-certificates
```

Install `NodeJS 16`:

```bash
curl -sL https://deb.nodesource.com/setup_16.x | bash -
```

Gunakan repositori *official* **PostgreSQL**:

```bash
wget -O /usr/share/keyrings/postgresql.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgresql.list
```
Update dan install *system package* yang dibutuhkan:

```bash
apt update
apt install -y \
  imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
  g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf \
  bison build-essential libssl-dev libyaml-dev libreadline6-dev \
  zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
  nginx redis-server redis-tools postgresql postgresql-contrib \
  certbot python3-certbot-nginx libidn11-dev libicu-dev libjemalloc-dev
```

Aktifkan fitur **NodeJS** `corepack` dan set versi **Yarn** ke `classic`:

```bash
corepack enable
yarn set version classic
```

Install **Ruby** dengan `rbenv`.

> **Catatan**: `rbenv` harus diinstall melalui *single Linux user*, maka kita perlu membuat linux user yang nantinya *service* Mastodon akan berjalan atas user tersebut. (di artikel ini kita akan buat user `mastodon`) :

```bash
adduser --disabled-login mastodon
```

Kemudian, login sebagai `mastodon` user:

```bash
su - mastodon
```

Dan sebagai `mastodon` user, install `rbenv` dan `rbenv-build`:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec bash
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

Setelah proses setup **Ruby** *environment* selesai, baru kita dapat menginstall versi Ruby dan `bundler` yang diperlukan:

```bash
RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 3.0.4
rbenv global 3.0.4
gem install bundler --no-document
```

kemudian kembali sebagai `root` user untuk melakukan setting PostgreSQL.

```bash
exit
```

### Setting PostgreSQL
Untuk performa yang optimal, kita bisa menggunakan [**pgTune**](https://pgtune.leopard.in.ua/) untuk *menggenerate* konfigurasi sesuai *resource* server kita. Edit `/etc/postgresql/15/main/postgresql.conf` dan masukkan setting rekomendasi dari situs **pgTune** diatas sebelum merestart *service* PostgreSQL dengan perintah `systemctl restart postgresql`.

Sekarang, buat PostgreSQL user yang nantinya akan digukakan. Hal paling mudah adalah menggunakan **ident authentication** menggunakan user yang sama dengan linux username `mastodon`.

Bukan *promt* PostgreSQL:

```bash
sudo -u postgres psql
```

pada command *promt* `psql`, jalankan perintah berikut:

```sql
CREATE USER mastodon CREATEDB;
\q
```

Sampai disini, kebutuhan sistem utama sudah siap, saatnya untuk melanjuktan ke tahap berikutnya yaitu mensetup Mastodon dan *dependency-nya*.

## Setting Mastodon

Login sebagai `mastodon` user dan download *source code* Mastodon menggunakan `git` (pilih `stable` *release*):

```bash
su - mastodon
git clone https://github.com/mastodon/mastodon.git live && cd live
git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)
```

Install Ruby and JavaScript *dependencies* untuk aplikasi Mastodon:

```bash
bundle config deployment 'true'
bundle config without 'development test'
bundle install -j$(getconf _NPROCESSORS_ONLN)
yarn install --pure-lockfile
```

jalankan Mastodon *interactive setup wizard*:

```bash
RAILS_ENV=production bundle exec rake mastodon:setup
```

Perintah diatas akan :
* Membuat konfigurasi file (`.env.production`)
* Menjalankan *pre-compilation asset* website
* Membuat skema database

Di kasus saya, saya ingin Mastodon dapat diakses melalui `https://social.vr4.me`, tetapi tetap menggunakan *main* domain `vr4.me` sebagai identitas usernya (`@ditatompel@vr4.me`, dan **bukan** `@ditatompel@social.vr4.me`). 

Agar hal tersebut dapat dicapai, saya perlu menambahkan konfigurasi `WEB_DOMAIN=social.vr4.me` dan mengubah *value* dari `LOCAL_DOMAIN` menjadi `vr4.me` di file konfigurasi mastodon (`.env.production`). Silahkan kunjungi halaman [dokumentasi konfigurasi](https://docs.joinmastodon.org/admin/config/) untuk informasi lebih detail.

Setelah konfigurasi Mastodon dirasa sudah benar, kita bisa kembali sebagai user `root`:

```bash
exit
```

## Setting Nginx
Copy sample konfigurasi Nginx yang ada di repositori Mastodon:

```bash
cp /home/mastodon/live/dist/nginx.conf /etc/nginx/sites-available/mastodon
ln -s /etc/nginx/sites-available/mastodon /etc/nginx/sites-enabled/mastodon
```

kemudian edit `/etc/nginx/sites-available/mastodon` dan ubah `example.com` ke domain yang digunakan (dalam kasus ini `social.vr4.me`).

Seperti yang sudah saya informasikan sebelumnya, *instance* Mastodon yang saya jalankan akan berada dibalik Cloudflare *reverse proxy* sehingga saya hanya akan menggunakan *self-signed certificate*.

Jika Anda ingin menggunakan **Certbot** untuk mendapatkan SSL certificate:

```bash
systemctl reload nginx
certbot --nginx -d social.vr4.me
```

Ubah `social.vr4.me` dengan nama domain Anda.

## Setting Mastodon SystemD Service

Copy template `systemd service` dari repositori Mastodon ke `/etc/system/systemd`:

```bash
cp /home/mastodon/live/dist/mastodon-*.service /etc/systemd/system/
```

kemudian *start* dan *enable* Mastodon *services*:

```bash
systemctl daemon-reload
systemctl enable --now mastodon-web mastodon-sidekiq mastodon-streaming
```

Tunggu beberapa menit dan coba akses Mastodon dari web broser dan selamat menikmati!

## Resources
* [https://docs.joinmastodon.org/admin/install/](https://docs.joinmastodon.org/admin/install/)
