---
title: "Cara Sinkronisasi 2 AdGuard Server Atau Lebih"
description: "Kita bisa dengan mudah membuat replika beberapa AdGuard Home server dengan menggunakan program bernama adguardhome-sync."
summary: "Kita bisa dengan mudah membuat replika beberapa AdGuard Home server dengan menggunakan program bernama adguardhome-sync"
date: 2025-10-08T04:14:30+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
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

Di artikel sebelumnya, saya sempat membagikan pengalaman saya mengenai
[cara install AdGuard Home di STB ZTE B860H]({{< ref "/tutorials/install-adguard-di-stb-android-zte-b860h-armbian/index.id.md" >}}).
Nah, di kesempatan kali ini, saya ingin berbagi pengalaman mengenai cara
melakukan sinkronisasi dua AdGuard Home server atau lebih menggunakan program
[bakito/adguardhome-sync][adguardhome-sync-gh].

bagian proses installasi dan konfigurasi `adguardhome-sync` ini juga sudah ada
di video berikut mulai menit ke 4:20.

{{< youtube twr8ImCmE4c >}}

## Topologi

Saya masih mengikuti topologi di artikel sebelumnya, yaitu saya menggunakan
jaringan `192.168.2.0/24`. _Primary DNS resolver_ berada di alamat IP
`192.168.2.73`, sedangkan alamat IP STB Armbian dimana AdGuard _secondary DNS
resolver_ menggunakan alamat IP `192.168.2.253`. TLDR-nya:

- _Network_: `192.168.2.0/24`
- _Primary DNS resolver_: `192.168.2.73`
- _Secondary DNS resolver_: `192.168.2.253`
- Program `adguardhome-sync` akan diinstall di _secondary DNS resolver_
  (Armbian, `192.168.2.253`)

## Instalasi

Pertama, download file `.tar.gz` sesuai dengan CPU arsitektur dimana program
`adguardhome-sync` tersebut akan diinstall dari [halaman _release_-nya di
GitHub][adguardhome-sync-release].

Setelah file berhasil didownload, _extract_ file `.tar.gz` tersebut menggunakan
perintah:

```shell
tar -xvzf adguardhome-sync_*.tar.gz
```

Buat direktori `/opt/adguardhome-sync` dan pindahkan file `adguardhome-sync`
ke direktori tersebut:

```shell
sudo mkdir -p /opt/adguardhome-sync
mv adguardhome-sync /opt/adguardhome-sync
```

## Konfigurasi

Setelah itu, buat konfigurasi file untuk `adguardhome-sync` dan letakan di
`/opt/adguardhome-sync/adguardhome-sync.yaml`. [Contoh
konfigurasi][adguardhome-sync-config] dapat dilihat di Git Repositorinya.

Sesuaikan konfigurasi tersebut, terutama pada bagian `origin` dan `replicas`.
Arahkan `origin.url` ke _primary_ AdGuard Home server admin web UI, dan
sesuaikan username dan passwordnya. Jangan lupa lakukan hal yang sama pada
bagian `replicas`.

### systemd

Buat _systemd unit file_ `/etc/systemd/system/adguardhome-sync.service`
dan isi dengan dengan konfigurasi berikut:

```plain
[Unit]
Description = AdGuardHome Sync
After = network.target

[Service]
ExecStart = /opt/adguardhome-sync/adguardhome-sync --config /opt/adguardhome-sync/adguardhome-sync.yaml run

[Install]
WantedBy = multi-user.target
```

Setelah itu, reload systemd daemon dan enable `adguardhome-sync` service dengan
menjalankan perintah berikut:

```shell
sudo systemctl daemon-reload
sudo systemctl enable adguardhome-sync.service --now
```

Sampai disini, seharusnya _secondary_ AdGuard Home sudah memiliki konfigurasi
yang identik dengan _primary_ AdGuard Home. Jika masih belum tersinkronisasi,
teman-teman bisa melakukan `troubleshooting` dengan menjalankan perintah
`sudo journalctl -u adguardhome-sync.service`.

[adguardhome-sync-gh]: https://github.com/bakito/adguardhome-sync "AdGuardHome Sync GitHub Repo"
[adguardhome-sync-release]: https://github.com/bakito/adguardhome-sync/releases "AdGuardHome Sync Release Page"
[adguardhome-sync-config]: https://github.com/bakito/adguardhome-sync?tab=readme-ov-file#config-file-1 "Contoh Konfig AdGuardHome Sync"
