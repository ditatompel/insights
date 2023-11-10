---
title: "Cara Install dan Mengkonfigurasi Dante SOCKS Private Proxy di Ubuntu"
description: "Artikel ini membantu Anda dalam melakukan setting dan mengkonfigurasi private SOCKS proxy menggunakan Dante di server Linux yang berbasis pada distribusi Debian."
# linkTitle:
date: 2023-11-08T11:50:13+07:00
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
  - Privasi
  - Self-Hosted
  - SysAdmin
  - Networking
tags:
  - SOCKS
  - Proxy
  - Dante
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
  - jasmerah1966
---

Artikel ini membantu Anda dalam melakukan setting dan mengkonfigurasi _private **SOCKS proxy**_ menggunakan **Dante** di server Linux yang berbasis pada distribusi **Debian**.

<!--more-->
---

[Dante](https://www.inet.no/dante/) adalah **SOCKS proxy** yang sudah sangat _"mature"_ stabil yang didevelop oleh **Inferno Nettverk A/S proxy**. Di artikel ini adalah proses saya menginstall _**private SOCKS proxy**_ menggunakan **Dante** dengan sistem authentikasi _username_ dan _password_ (`pam`).

## Mempersiapkan Sistem

Sebelum memulai, ada beberapa prasyarat yang harus dipenuhi untuk mengikuti artikel ini:
- Nyaman menggunakan Linux terminal.
- Sebuah Linux server dengan **Distro** berbasis **Debian**.

Karena yang akan kita buat adalah *private proxy* yang memerlukan authentikasi _username_ dan _password_ dari akun user di sistem Linux, kita perlu membuat Linux user terlebih dahulu di server yang nantinya akan digunakan untuk proses authentikasi.

```shell
# membuat user baru
sudo useradd -r -s /bin/false myproxyuser
# mengubah password user baru tersebut
sudo passwd myproxyuser
```
> _Catatan: Ubah `myproxyuser` diatas dengan user yang ingin Anda gunakan untuk autentikasi._

## Instalasi Dante Server

Karena **Dante** adalah **SOCKS proxy** yang sudah sangat _"mature"_ dan populer, Anda bisa dengan mudah menginstall Dante server dengan _package manager_ bawaan Debian atau Ubuntu:

```shell
sudo apt install dante-server
systemctl status danted.service
```

Setelah proses installasi selesai, system akan secara otomatis mencoba menjalankan _danted.service_, namun _service_ tersebut tidak akan berjalan alias _failed_ karena belum ada metode authentikasi yang wajib dikonfigurasi.

## Konfigurasi Dante Server

File konfigurasi Dante berada di `/etc/danted.conf`. Didalamnya sudah ada contoh konfigurasi beserta keterangan yang sangat lengkap untuk apa parameter atau variabel konfigurasi tersebut digunakan.

Lakukan backup file konfigurasi bawaan tersebut dengan perintah `sudo cp /etc/danted.conf /etc/danted.conf.bak` kemudian ubah konfigurasi pada `/etc/danted.conf` dengan konfigurasi berikut (contoh):

```plain
# konfigurasi log
logoutput: stderr

# danted service berjalan pada port 1080 di semua interface
internal: 0.0.0.0 port=1080

# interface mana yang akan digunakan untuk semua komunikasi keluar
external: eth0

clientmethod: none
socksmethod: username
user.privileged: root
user.unprivileged: nobody
user.libwrap: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}
```

Dari contoh konfigurasi diatas, **Dante** akan _listen_ di port `1080` dan semua traffic keluar akan dilewatkan melalui _interface_ `eth0`.

Anda bisa mengubah _port_ dan wajib menyesuaikan _interface_ sesuai dengan _interface_ yang ada di server Anda.

Setelah konfigurasi **Dante** selesai disesuaikan dengan kebutuhan, restart servicenya menggunakan perintah `sudo systemctl restart danted.service`.

Kemudian, lakukan pengecekan apakah `danted.service` sudah berjalan dengan baik dengan perintah `sudo systemctl status danted.service`:

```plain
● danted.service - SOCKS (v4 and v5) proxy daemon (danted)
     Loaded: loaded (/lib/systemd/system/danted.service; enabled; preset: enabled)
     Active: active (running) since Thu 2023-11-09 16:51:01 WIB; 1 day 1h ago
       Docs: man:danted(8)
             man:danted.conf(5)
    Process: 885 ExecStartPre=/bin/sh -c        uid=`sed -n -e "s/[[:space:]]//g" -e "s/#.*//" -e "/^user\.privileged/{s/[^:]*://p;q;}" /etc/danted.conf`;     >
   Main PID: 935 (danted)
      Tasks: 21 (limit: 9304)
     Memory: 18.5M
        CPU: 2.701s
     CGroup: /system.slice/danted.service
             ├─    935 /usr/sbin/danted
             ├─    955 "danted: monitor"
             ├─1494108 "danted: io-chil"
             ├─1494116 "danted: io-chil"
             ├─1494127 "danted: request"
             ├─1495807 "danted: request"
             ├─1496272 "danted: negotia"
             ├─1496273 "danted: request"
             .... snip

Nov 09 16:51:01 aws-ec2 systemd[1]: Starting danted.service - SOCKS (v4 and v5) proxy daemon (danted)...
Nov 09 16:51:01 aws-ec2 systemd[1]: Started danted.service - SOCKS (v4 and v5) proxy daemon (danted).
Nov 09 16:51:02 aws-ec2 danted[935]: Nov  9 16:51:02 (1699523462.105152) danted[935]: info: Dante/server[1/1] v1.4.2 running
```

## Melakukan Testing

Setelah semua proses diatas selesai, saatnya mencoba menggunakan **proxy server** Anda. Salah satu contoh paling mudah untuk melakukan pengecekan adalah menggunakan `curl` melalui komputer Anda:

```shell
curl -x socks5://myproxyuser:myproxy_password@server_ip:proxy_port http://ifconfig.me
```
> _Sesuaikan `myproxyuser`, `myproxy_password`, `server_ip`, dan `proxy_port` dengan authentikasi dan konfigurasi yang sudah Anda lakukan sebelumnya._

Dari perintah diatas, Anda seharusnya **mendapatkan alamat IP server proxy Anda**, bukan alamat IP komputer Anda.

## Troubleshooting

Jika Anda tidak bisa melakukan koneksi `SOCKS5` ke _proxy server_ Anda, pastikan _port_ yang digunakan oleh Dante terbuka. jalankan perintah `ufw` berikut (untuk sistem yang berbasis pada Debian) untuk membuka port dari firewall:


```shell
ufw allow proto tcp to any port 1080
```

> Catatan: _Ubah port `1080` dan sesuaikan dengan konfigurasi proxy server Anda._

