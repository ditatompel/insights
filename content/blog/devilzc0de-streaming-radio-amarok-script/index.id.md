---
title: "Devilzc0de Streaming Radio Amarok Script"
description: Berhubung saya adalah tipe orang yang sulit bekerja jika ada banyak browser tab terbuka di browser, saya buat script sederhana supaya radio devilzc0de bisa didengarkan melalui Amarok.
summary: Berhubung saya adalah tipe orang yang sulit bekerja jika ada banyak browser tab terbuka di browser, saya buat script sederhana supaya radio devilzc0de bisa didengarkan melalui Amarok.
date: 2011-12-29T03:14:32+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
series:
#  -
categories:
#  -
tags:
  - Amarok
  - Linux
images:
authors:
  - ditatompel
---

Berhubung saya adalah tipe orang yang sulit bekerja jika ada banyak browser tab terbuka di browser, saya buat script sederhana supaya radio **devilzc0de** bisa didengarkan melalui **Amarok**.

_tested on_ :

- OS: **Arch Linux** Kernel `3.x` `x86_64`
- DE: **KDE** SC `4.7.4`
- Qt: `4.8.0`
- Source Code : `http://ls-la.ditatompel.crayoncreative.net/linux/devilzc0de_stream.tar.bz2`

![](dc-amarok2.png#center)

![](dc-amarok3.png#center)

![](dc-amarok4.png#center)

## List Radio Station

- ainstream
  - Devilzc0de Radio
- Radio Bandung
  - Prambors FM
  - Delta FM
- Radio Surabaya
  - Mercury 96FM
  - Prambors FM
  - Delta FM
- Radio Yogyakarta
  - Redjo Buntung
  - Jogjafamily
  - Swaragama
  - Female FM
  - Prambors FM
- Radio Semarang
  - Gajahmada FM
  - TOP FM Bumiayu
  - Female FM
  - Prambos FM
- Radio Jakarta
  - Delta FM
  - Female FM
  - Prambors FM
- Radio Lainnya
  - Kaskus Radio
- Static Stream Crayon Networks
  - Lagu Galauers
  - Instrumental
  - Latest Song Mix

## Cara Install

Cara installasi bisa menggunakan 2 metode, yaitu menggunakan **Amarok script manager** (_single user_) atau manual (_all users_).

### Menggunakan Amarok script manager (_single user_)

1. Buka Amarok
2. Masuk **Settings** -> **Configure Amarok** -> **Script** -> **Manage Scripts**
3. Search dengan _keyword_ **Devilzc0de** -> **Install**

![](dc-amarok1.png#center)

### Manual (_all users_)

```bash
wget http://ls-la.ditatompel.crayoncreative.net/linux/devilzc0de_stream.tar.bz2
```

Sebagai _user_ `root`, _extract_ kemudian _copy_ folder hasil _extract_ ke `/usr/share/apps/amarok/scripts/`.

## Cara Penggunaan

1. Masuk ke menu **internet**.
2. Pilih **devilzc0de Radio**.
3. Pilih stasiun radio yang ingin didengarkan.

Maaf belum sempat buat untuk _player_ dan _desktop environment_ laen.

Pertanyaan & bugs report ke `https://devilzc0de.org/forum/thread-11791.html`.

