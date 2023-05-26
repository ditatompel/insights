---
title: "Devilzc0de Streaming Radio Amarok Script"
description: Berhubung saya adalah tipe orang yang sulit bekerja jika ada banyak browser tab terbuka di browser, saya buat script sederhana supaya radio devilzc0de bisa didengarkan melalui Amarok.
date: 2011-12-29T03:14:32+07:00
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
  - Amarok
  - Linux
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

Berhubung saya adalah tipe orang yang sulit bekerja jika ada banyak browser tab terbuka di browser, saya  buat script sederhana supaya radio **devilzc0de** bisa didengarkan melalui **Amarok**.

<!--more-->

*tested on* :
* OS: **Arch Linux** Kernel `3.x` `x86_64`
* DE: **KDE** SC `4.7.4`
* Qt: `4.8.0`
* Source Code : `http://ls-la.ditatompel.crayoncreative.net/linux/devilzc0de_stream.tar.bz2`

![](dc-amarok2.png#center)

![](dc-amarok3.png#center)

![](dc-amarok4.png#center)

## List Radio Station
* ainstream
    * Devilzc0de Radio
* Radio Bandung
    * Prambors FM
    * Delta FM
* Radio Surabaya
    * Mercury 96FM
    * Prambors FM
    * Delta FM
* Radio Yogyakarta
    * Redjo Buntung
    * Jogjafamily
    * Swaragama
    * Female FM
    * Prambors FM
* Radio Semarang
    * Gajahmada FM
    * TOP FM Bumiayu
    * Female FM
    * Prambos FM
* Radio Jakarta
    * Delta FM
    * Female FM
    * Prambors FM
* Radio Lainnya
    * Kaskus Radio
* Static Stream Crayon Networks
    * Lagu Galauers
    * Instrumental
    * Latest Song Mix

## Cara Install
Cara installasi bisa menggunakan 2 metode, yaitu menggunakan **Amarok script manager** (*single user*) atau manual (*all users*).

### Menggunakan Amarok script manager (*single user*)
1. Buka Amarok
2. Masuk **Settings** -> **Configure Amarok** -> **Script** -> **Manage Scripts**
3. Search dengan *keyword* **Devilzc0de** -> **Install**

![](dc-amarok1.png#center)

### Manual (*all users*)
```bash
wget http://ls-la.ditatompel.crayoncreative.net/linux/devilzc0de_stream.tar.bz2
```
Sebagai *user* `root`, *extract* kemudian *copy* folder hasil *extract* ke `/usr/share/apps/amarok/scripts/`.

## Cara Penggunaan
1. Masuk ke menu **internet**.
2. Pilih **devilzc0de Radio**.
3. Pilih stasiun radio yang ingin didengarkan.

Maaf belum sempat buat untuk *player* dan *desktop environment* laen.


Pertanyaan & bugs report ke `https://devilzc0de.org/forum/thread-11791.html`.