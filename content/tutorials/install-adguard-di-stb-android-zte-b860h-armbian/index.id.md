---
title: "Menginstall AdGuard di STB Android ZTE B860H (Armbian)"
description: "Cara install AdGuard Home untuk DNS Resolver Lokal di STB Android ZTE B860H (Armbian 25/Debian Trixie)"
summary: "Cara install AdGuard Home untuk DNS Resolver Lokal di STB Android ZTE B860H (Armbian 25/Debian Trixie)"
# linkTitle:
date: 2025-10-08T04:14:30+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
# nav_icon:
#   vendor: bootstrap
#   name: toggles
#   color: '#e24d0e'
categories:
    - SysAdmin
    - Self-Hosted
tags:
    - Armbian
    - AdGuard
    - DNS
images:
authors:
    - yiliuba168
---

Beberapa tahun lalu, saya sempat **menginstall [Armbian di STB Android
ZTE B860H][soc-s905x]**. Setelah lama tidak saya gunakan, akhirnya saya
memutuskan untuk _"menghidupkannya"_ lagi dengan menginstall ulang STB tersebut
menggunakan **[Armbian][armbian-website] 25.11** yang basisnya adalah
**Debian 13 (Trixie)**. STB tersebut akan saya gunakan sebagai _secondary DNS
resolver_ untuk jaringan lokal saya.

Nah, di artikel ini saya ingin berbagi pengalaman saya dalam menginstall
**[AdGuard Home][adguardhome-gh]** di Armbian 25.11 (versi minimal yang
_DNS resolver_-nya menggunakan `systemd-resolve`).

## Prasyarat & Topologi

Sebelum memulai dan supaya lebih jelas, saya informasikan dulu bahwa di artikel
ini saya menggunakan jaringan `192.168.2.0/24`. Sedangkan alamat IP STB Armbian
dimana AdGuard _secondary DNS resolver_ akan diinstall adalah `192.168.2.253`.

Supaya teman-teman mempunyai gambaran prosesnya, saya juga menyertakan video
saat saya melakukan installasi dan konfigurasi AdGuard berikut:

{{< youtube twr8ImCmE4c >}}

> **Catatan**: Sebenarnya, Armbian sudah menyediakan `armbian-config` yang bisa
> digunakan untuk menginstall _software-software_ atau _service_ seperti
> AdGuard, NFS, dan lain-lain. Tapi disini saya sengaja memilih melakukan
> installasi secara manual saja supaya kita tidak _"terkunci"_ di
> _environment_ tertentu.

## Install AdGuard di Armbian

AdGuard menyediakan _install script_ yang secara otomatis dapat mendownload dan
mengkonfigurasi AdGuard Home sehingga dia dapat otomatis berjalan setelah reboot.
Teman-teman bisa menjalankan perintah berikut :

```shell
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
```

> **Catatan**: Saya sarankan membaca dan memahami terlebih dulu isi dari
> _install script_-nya sebelum mengeksekusi perintah diatas.

Setelah menjalankan install script, AdGuard Home akan terinstall di direktori
`/opt/AdGuardHome`, dan secara default, _web admin interface_-nya menggunakan
port `3000`. Teman-teman dapat mengakses web admin interface-tersebut melalui
`http://[ip-armbian]:3000` (ubah `[ip-armbian]` ke alamat IP Armbian milik
teman-teman).

### Memperbaiki Error _bind: address already in use_

Secara default, port 53 (baik TCP maupun UDP) pada Armbian digunakan oleh
`systemd-resolve`; jadi teman-teman perlu me-nonaktifkan `DNSStubListener`
sehingga port 53 dapat digunakan oleh AdGuard DNS.

Untuk melakukannya, buat direktori `/etc/systemd/resolved.conf.d` dengan
perintah berikut:

```shell
sudo mkdir -p /etc/systemd/resolved.conf.d
```

Setelah itu, buat file `/etc/systemd/resolved.conf.d/adguardhome.conf` yang
berisi konfigurasi berikut:

```plain
[Resolve]
DNS=127.0.0.1
DNSStubListener=no
```

Setelah itu jalankan perintah berikut:

```shell
sudo mv /etc/resolv.conf /etc/resolv.conf.backup
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl reload-or-restart systemd-resolved
```

Perintah diatas akan membuat file backup dari `/etc/resolv.conf`, membuat
_symlink_ `/run/systemd/resolve/resolv.conf` ke `/etc/resolv.conf`, kemudian
merestart `systemd-resolved` service.

Dokumentasi lebih lengkap dapat dilihat di [halaman FAQ AdGuard][faq-address-in-use].

### Konfigurasi Awal AdGuard Home Dari Admin Web UI

Buka `http://[ip-armbian]:3000` menggunakan web browser, disana teman-teman
akan diarahkan untuk mengkonfigurasi AdGuard. Pada bagian **"Admin Web
Interface"**, pilih **"Listen interface"** ke **"All interfaces"** dan ubah
**"Port"** dari `80` ke `3000`.

Pada bagian **"DNS Server" **, ubah **"Listen Interface"** ke **"All
Interfaces"** supaya mesin lain yang berada pada satu jaringan dengan STB
Armbian dapat menggunakan DNS server tersebut.

Setelah itu, tekan tombol **"Next"** dan buat user dan password untuk admin
web UI. Ikuti langkah-langkah selanjutnya dan seharusnya teman-teman sudah bisa
melakukan login ke AdGuard Home dashboard menggunakan username dan password
yang baru saja dibuat dan melakukan konfigurasi lanjutan.

> Jika teman-teman memiliki beberapa AdGuard Home dan ingin mereplikasi
> konfigurasi secara berkala dan otomatis, teman-teman bisa mengikuti artikel
> tentang [Cara Sinkronisasi 2 AdGuard Server Atau Lebih]({{< ref "/tutorials/cara-sinkronisasi-2-adguard-server-atau-lebih/index.id.md" >}}).

[soc-s905x]: https://www.armbian.com/soc/s905x/ "Armbian Amlogic S905X Page"
[armbian-website]: https://www.armbian.com "Armbian Official Website"
[adguardhome-gh]: https://github.com/AdguardTeam/AdGuardHome "AdGuardHome GitHub Repo"
[faq-address-in-use]: https://adguard-dns.io/kb/adguard-home/faq/#bindinuse "Dokumentasi dan Solusi bind: address already in use"
