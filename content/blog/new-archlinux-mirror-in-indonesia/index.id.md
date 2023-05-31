---
title: "Official Mirror Arch Linux Dari Indonesia Bertambah Satu Lagi"
description: "Mirror official Arch Linux (Tier 2) baru dari Indonesia (Lokasi: IDC Duren Tiga)"
date: 2023-02-17T08:36:36+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
#  - 
tags:
  - Arch Linux
images:
#  - 
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

Kemarin pada tanggal 16 Februari 2023, saya membuat [*feature request*](https://bugs.archlinux.org/task/77542) supaya **mirror repositori Arch Linux** saya dapat ditambahkan ke *official* repositori Arch Linux. Dan saat ini sudah terlisting ke [halaman resmi mirror Arch Linux](https://archlinux.org/mirrors/mirror.ditatompel.com/)! Terima kasih [Anton Hvornum](https://bugs.archlinux.org/user/15638) dan Arch Linux Mirror Team!

Sebenarnya, dulu saya pernah juga me-maintenance mirror Arch Linux. Pada saat itu waktu server devilzc0de.org masih sehat dan domain belum hilang 😂. Tapi... Ah, sudahlah.. Jadi keinget masa-masa indah 😍, masa masa sendu 😞.

<!--more-->

## Informasi Mirror

Lokasi: Indonesia Data Center Duren Tiga (IDC3D) **Jakarta**, **Indonesia** (ID)

URL:
- `http://mirror.ditatompel.com/archlinux`
- `https://mirror.ditatompel.com/archlinux`

Bandwidth:
1Gbps

Pada saat artikel ini dibuat, `mirror.ditatompel.com` melakukan sinkronisasi ke *Tier 1 mirror* **setiap 2 jam sekali**.

Untuk menggunakan mirror tersebut cukup tambahkan konfigurasi berikut pada `/etc/pacman.d/mirrorlist` Anda:
```
Server = http://mirror.ditatompel.com/archlinux/$repo/os/$arch
Server = https://mirror.ditatompel.com/archlinux/$repo/os/$arch
```

Atau anda bisa menggunakan *package* `reflector` (`pacman -S reflector`) untuk mencari dan menggenerate mirror yang paling cepat untuk Anda.
Misalnya:

```bash
reflector --verbose -l 10 -f 10 --sort rate -c Indonesia,Singapore
```

> ***Note**: Saya menambahkan `-c Indonesia,Singapore` karena rata-rata ISP di Indonesia saat ini memiliki bandwidth yang cukup besar dan latency yang baik untuk ke Singapore.*


## Public Monitoring
Untuk official mirror, situs Arch Linux sendiri sudah menyediakan monitoring yang dapat diakses di [https://archlinux.org/mirrors/mirror.ditatompel.com/](https://archlinux.org/mirrors/mirror.ditatompel.com/).

Namun saya sendiri menyediakan [monitoring untuk server mirror.ditatompel.com melalui Grafana](https://monitor.ditatompel.com/d/mirror-ditatompel-com/mirror-ditatompel-com?orgId=2&refresh=1m) yang dapat diakses tanpa harus login / memiliki akun di server Grafana saya.

Semoga mirror tambahan saya yang tidak seberapa ini dapat membantu mengurangi *server load* dan *bandwidth* rekan-rekan sebangsa dan setanah air. (*Wedjiannnn* 😂)

Doakan juga supaya saya tetap dapat *me-maintenance* mirror ini dan sedikit berkontribusi ke *distro* yang paling Saya sayangi sejak tahun 2011 lalu. Amin!