---
title: "Instalasi PHP, Apache, MySQL dan PhpMyAdmin di Arch Linux"
description: "Step-by-step instalasi PHP Apache, MySQL dan PhpMyAdmin di Arch Linux."
summary: "Step-by-step instalasi PHP Apache, MySQL dan PhpMyAdmin di Arch Linux."
# linkTitle:
date: 2012-02-18T05:01:30+07:00
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
tags:
  - Linux
  - MySQL
  - Apache
  - PHP
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

Kenapa Arch Linux? Karena saya nyaman menggunakan Arch, dan hanya dengan package managernya kita udah dapet kernel dan software-software terbaru dan _up-to-date_.

{{< youtube zr7TVU7SZUs >}}

1. Pertama kita pastikan bahwa sistem kita sudah up to date.

```bash
pacman -Syu
```

2. Jika sudah, kita mulai _install_ apa yang kita butuhkan.

```bash
pacman -S php apache php-mcrypt phpmyadmin mysql
```

3. masuk pada folder `/etc/webapps/phpmyadmin`, kemudian copy konfigurasi **phpmyadmin** ke `/etc/httpd/conf/extra`

```bash
cp /etc/webapps/phpmyadmin/apache.example.conf /etc/httpd/conf/extra/httpd-phpmyadmin.conf
```

4. Kita _include-kan_ konfigurasi tersebut pada `httpd.conf` utama di folder `/etc/httpd/conf`

```apache
# Konfigurasi phpmyadmin
Include conf/extra/httpd-phpmyadmin.conf
```

![Apache Config PHPMyAdmin](phpmyadmin-include.png#center)

Kemudian cek `localhost` dan `phpmyadmin` pada browser.

6. Jika ada pesan _forbidden_ pada **phpmyadmin**, kita tambahkan konfigurasi `DirectoryIndex index.html index.php` pada `/etc/httpd/conf/extra/httpd-phpmyadmin.conf` lalu **restart** http server.

![DirectoryIndex Apache](directoryIndex.png#center)

7. Jika **PhpMyAdmin** sudah dapat diakses, tetapi masih ada pesan error _"The mysqli extension is missing."_ atau _"The mcrypt extension is missing"_; Kita perlu _me-enable_ ekstensi tersebut pada `php.ini` dengan menghilangkan tanda titik koma (`;`) di depan ekstensi yang dibutuhkan.

![PHP Extension](extension.png#center)

```ini
extension=mcrypt.so
extension=mysqli.so
extension=mysql.so
```

kemudian kita coba **restart** http server lagi.

Untuk informasi, pada Arch Linux, secara default `httpd` berjalan dengan _user_ `http` dan _group_ `http`. Agar lebih nyaman dan tidak terdapat pesan error pada CMS2 tertentu, kita perlu merubah permission dan owner pada folder `/srv/http` (tempat folder `public_html`)

```bash
chown -R http:http /srv/http
```

maka selesai sudah proses installasi Apache, PHP, MySQL, dan PhpMyAdmin.

Nah sementara basicnya sampe disini dulu.
