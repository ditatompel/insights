---
title: "Pacoloco: Caching Proxy Server Untuk Arch Linux Mirror"
description: Pacoloco adalah server proxy caching yang dirancang khusus untuk Pacman. Dia berjalan sebagai web server yang meniru atau bertingkah seperti Arch Linux Mirror, dan memungkinkannya Anda untuk menyimpan dan menyajikan paket kepada pengguna lainnya.
summary: Percepat full sistem upgrade Arch Linux Anda menggunakan Pacoloco, server proxy caching yang dirancang khusus untuk Pacman.
date: 2025-04-05T17:45:00+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - SysAdmin
    - TIL
tags:
    - Arch Linux
    - Open Source
images:
authors:
    - ditatompel
---

Jika Anda menggunakan beberapa mesin Arch Linux di jaringan lokal, Anda mungkin
tertarik mempelajari tentang **Pacoloco**. [Pacoloco][pacoloco-repo] adalah
server _proxy caching_ yang dirancang khusus untuk **Pacman**, sebuah _package
manager_ untuk Arch Linux. Pacoloco berjalan sebagai web server yang bertindak
seperti Arch Linux Mirror, yang memungkinkannya untuk menyimpan dan menyajikan
paket kepada pengguna lain.

Setiap kali server Pacoloco menerima permintaan dari pengguna, ia mengunduh
berkas yang diminta dari mirror Arch Linux asli lalu memberikannya ke pengguna,
sambil menyimpan salinan paket yang diunduh di penyimpanan lokal.

{{< youtube meVHOzgke10 >}}

## Studi Kasus: Menerapkan Pacoloco di Jaringan Lokal Saya

Saya memiliki beberapa mesin Arch Linux di jaringan lokal saya, termasuk satu
mesin virtual di **Proxmox** dan satu lagi KVM di laptop saya. Saya juga
memiliki laptop tua: [ThinkPad T420](https://tokopedia.link/z7b3wfiGjSb), yang
juga menjalankan Arch Linux. Untuk mengoptimalkan penggunaan bandwidth, saya
memutuskan untuk menjalankan Pacoloco server di ThinkPad T420 ini.

### Persyaratan Sistem

Pacoloco _service_ tidak memerlukan banyak _processing power_, jadi
_single-core_ CPU dengan 1 GB RAM seharusnya cukup untuk sebagian besar
pengguna. Namun, menggunakan port Ethernet yang cepat dan SSD untuk penyimpanan
cache-nya akan memberikan manfaat yang lebih baik. Disini, ThinkPad T420
memiliki Gigabit port ethernet, yang memungkinkan kecepatan transfer rata-rata
sekitar 110 MiB/s.

Karena Pacoloco tidak mendownload seluruh repositori Arch dan hanya mengunduh
file yang dibutuhkan oleh pengguna lokal, ukuran cache lokal tidak memakan
penyimpanan yang besar. Dalam kasus saya, cache lokal saya hanya sekitar 6 GB.
Hal ini dikarenakan Pacoloco _service_ secara otomatis menghapus _package_
yang tidak diunduh atau diminta selama jangka waktu tertentu.

### Menginstal dan Mengonfigurasi Pacoloco

Untuk menginstal Pacoloco, jalankan `sudo pacman -S pacoloco` dari terminal
Anda. Kemudian, menyesuaikan konfigurasi `/etc/pacoloco.yaml` sangat penting
supaya Pacoloco _service_ dapat berjalan dengan baik.

```yaml
# /etc/pacoloco.yaml

# cache_dir: /var/cache/pacoloco
cache_dir: /mnt/msata/Public/pacololo
port: 9129
download_timeout: 3600 ## downloads will timeout if not completed after 3600 sec, 0 to disable timeout
purge_files_after: 2592000 ## purge file after 30 days
# set_timestamp_to_logs: true ## uncomment to add timestamp, useful if pacoloco is being ran through docker

repos:
    archlinux:
        urls: ## add or change official mirror urls as desired, see https://archlinux.org/mirrors/status/
            - http://mirror.ditatompel.com/archlinux
            - https://mirror.ditatompel.com/archlinux
    archlinux-reflector:
        mirrorlist: /etc/pacman.d/mirrorlist ## Be careful! Check that pacoloco URL is NOT included in that file!
## Local/3rd party repos can be added following the below example:
#  quarry:
#    http_proxy: http://bar.company.com:8989 ## Proxy could be enabled per-repo, shadowing the global `http_proxy` (see below)
#    url: http://pkgbuild.com/~anatolik/quarry/x86_64

prefetch: ## optional section, add it if you want to enable prefetching
    #cron: 0 0 3 * * * * ## standard cron expression (https://en.wikipedia.org/wiki/Cron#CRON_expression) to define how frequently prefetch, see https://github.com/gorhill/cronexpr#implementation for documentation.
    cron: 0 */4 * * *
    ttl_unaccessed_in_days: 30 ## defaults to 30, set it to a higher value than the number of consecutive days you don't update your systems. It deletes and stops prefetching packages (and db links) when not downloaded after "ttl_unaccessed_in_days" days that it has been updated.
    ttl_unupdated_in_days: 300 ## defaults to 300, it deletes and stops prefetching packages which haven't been either updated upstream or requested for "ttl_unupdated_in_days".
# http_proxy: http://proxy.company.com:8888 ## Enable this if you have pacoloco running behind a proxy
# user_agent: Pacoloco/1.2
```

Mari kita uraikan beberapa konfigurasi penting di atas:

- `cache_dir` adalah direktori tempat _package_ yang diminta oleh klien akan
  disimpan. Perlu diperhatikan bahwa direktori ini memerlukan _read and write
  access_ oleh proses server.
- Di bagian `repos`, saya menambahkan mirror milik saya sendiri. Anda bisa
  menambahkan atau menggunakan mirror favorit Anda di sini.
- Terakhir, saya mengaktifkan fitur `prefetch`, dimana Pacoloco akan secara
  otomatis mengunduh _package_ yang pernah diminta oleh pengguna setiap 4 jam
  (dari konfigurasi `cron`). Dan saya membiarkan konfigurasi lainnya
  sebagaimana adanya.

Setelah mengonfigurasi file `/etc/pacoloco.yaml` Anda, aktifkan _service_
Pacoloco dengan menjalankan `sudo systemctl enable pacoloco --now`. Pastikan
bahwa _service_ Pacoloco aktif dan berjalan dengan menjalankan perintah `sudo
systemctl status pacoloco`.

### Menggunakan Pacoloco sebagai Mirror Arch Linux Anda

Untuk menggunakan Pacoloco sebagai mirror Arch Linux Anda, tambahkan URL
Pacoloco Anda di bagian paling atas di file `/etc/pacman.d/mirrorlist` Anda:

```plain
# ubah IP dan port ke server Pacoloco Anda, port default adalah 9129
Server = http://192.168.2.22:9129/repo/archlinux/$repo/os/$arch
```

Kemudian, Anda dapat melakukan _full system upgrade_ menggunakan perintah
`sudo pacman -Syu` seperti biasa.

> Tips: Sebelum melakukan _full system upgrade_, luangkan waktu untuk
> mengunjungi [situs web resmi Arch Linux][arch-web]. Di halaman depan, selalu
> ada berita terbaru terkait distribusi Arch Linux. Terkadang, informasi ini
> mencakup apakah intervensi manual perlu dilakukan sebelum atau sesudah proses
> upgrade.
>
> Selain itu, periksa juga [forum Arch Linux][arch-forum-active-topic] karena
> Anda mungkin menemukan beberapa informasi berharga dan solusi dari pengguna
> lain ketika menalami masalah setelah proses upgrade.

[pacoloco-repo]: https://github.com/anatol/pacoloco "Pacoloco Official GitHub Repository"
[arch-mirrors]: https://archlinux.org/mirrors/ "Arch Linux Mirror Overview Page"
[arch-web]: https://archlinux.org/ "Arch Linux Official Website"
[arch-forum-active-topic]: https://bbs.archlinux.org/search.php?action=show_recent "Arch Linux Forum Active Topic"
