---
title: "Cara Akses Reddit Tanpa VPN Dengan Libreddit"
description: "Buat kamu yang kesulitan mengakses Reddit karena diblokir oleh ISP, menggunakan libreddit adalah cara alternatif dan mudah untuk mengakses Reddit tanpa VPN"
date: 2023-06-04T23:13:33+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - TIL
  - Privasi
tags:
  - Reddit
  - libreddit
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
  - vie
  - jasmerah1966
---

Buat kamu yang kesulitan mengakses **Reddit** karena diblokir oleh **ISP**, menggunakan **libreddit** adalah cara alternatif dan mudah untuk **mengakses Reddit tanpa VPN**.

<!--more-->
---

Belakangan ini, banyak yang melaporkan bahwa kawan-kawan di Indonesia mulai kesulitan mengakses **Reddit**. Mungkin karena pemerintah mulai memperketat *"jalur keluar"* dari *internet checkpoint* (baca: "[Babak Baru Sensor Internet di Indonesia: DPI & TCP Reset Attack]({{< ref "/blog/new-stage-of-internet-censorship-in-indonesia-dpi-tcp-reset-attack/index.id.md" >}})"). Berikut ini salah satu cara mengakses `reddit.com` tanpa harus menggunakan **VPN**. Contohnya adalah menggunakan [libreddit](https://github.com/libreddit/libreddit).

**Libreddit** itu sendiri adalah antar muka (*proxy*) untuk situs `reddit.com` (bukan *official*), jadi dia bertindak sebagai penghubung antara kamu dan situs `reddit.com`.

## Libreddit *instance*
**Libreddit _instance_** adalah mesin yang menjalankan program `libreddit` itu sendiri. *Instance* ini biasanya dioperasikan oleh individu, tapi ada juga kelompok atau organisasi yang mengoperasikan **Libreddit _instance_**.

Berikut ini daftar beberapa instance yang dapat kamu pakai:
|URL|Location|Behind Cloudflare?|Comment|
|-|-|-|-|
|https://reddit.moe.ngo|🇮🇩 Indonesia|✅||
|https://libreddit.ditatompel.com|🇸🇬 Singapura|✅|SFW only|
|https://safereddit.com|🇺🇸 Amerika Serikat||SFW only|
|https://lr.riverside.rocks|🇺🇸 Amerika Serikat|||
|https://libreddit.privacy.com.de|🇩🇪 Jerman|||

Untuk list yang lebih lengkap dan *up-to-date* bisa dilihat di [https://github.com/libreddit/libreddit-instances/blob/master/instances.md](https://github.com/libreddit/libreddit-instances/blob/master/instances.md).

## Cara menggunakan libreddit
Cara menggunakan `libreddit` sangat mudah, kamu cuma butuh *browser*, kunjungi salah satu [*instance* diatas](#libreddit-instance). Setelah kamu berada di halaman depan *instance* yang kamu pilih, hal pertama yang kamu harus lakukan adalah memilih *subreddit* yang ingin kamu *subscribe*.

Itu supaya ketika kamu kedepannya mengakses `libreddit` *instance* itu lagi, yang tampil di halaman depan adalah konten-konten dari *subreddit* yang sudah kamu *subscribe*.

Caranya, cari *subreddit* yang ingin kamu *subscribe* dari kolom pencarian. Misalnya [r/indonesia](https://libreddit.ditatompel.com/r/indonesia).

![Pencarian di libreddit](libreddit-1.png#center)

Setelah masuk ke halaman *subreddit* yang kamu pilih, tekan tombol _**"Subscribe"**_. Maka posting dari *subreddit* yang sudah kamu *subscribe* tersebut akan otomatis muncul di halaman depan.

## Kelebihan dan kekurangan
Selalu ada kelebihan dan kekurangan, saya ingin mulai dari kekurangannya dulu baru kelebihannya.

### Kekurangan
Kekurangan paling utama adalah kita hanya bisa *browsing* atau melihat-lihat saja. Karena di `libreddit`, kita tidak perlu *login* (memang tidak bisa). Maka dari itu, kita juga pasti tidak bisa melakukan interaksi dengan pengguna lainnya seperti memberikan komentar, *upvote*, *downvote*, dan lain-lain.

### Kelebihan
- Tidak perlu **VPN**   
Untuk mengakses `libreddit`, kita tidak perlu menginstal atau melakukan koneksi **VPN** jika ISP yang kamu pakai memblokir Reddit. Cukup bermodal *browser* dan mengakses Libreddit *instance* yang sudah saya sebutkan diatas.
- Tanpa iklan   
Dengan menggunakan libeddit, kita bisa browsing posting-posting yang ada di Reddit tanpa iklan.
- Lebih cepat   
Dari hasil pengalaman saya, mengakses reddit menggunakan libreddit terasa lebih cepat dan responsif.
- Privasi   
**Libreddit** hanya menggunakan *"Cookie"* untuk menyimpan *menu "Setting"* dan *subreddit* yang kamu *subscribe*. *"Cookie"* tersebut sama sekali tidak menyimpan informasi personal kita.
- Pilihan **SFW** *only* / **+NSFW**   
**Beberapa _libreddit instance_ memilih TIDAK menampilkan** konten **NSFW** (_**SFW** only_), seperti [libreddit.ditatompel.com](https://libreddit.ditatompel.com) dan [safereddit.com](https://safereddit.com). Jadi kamu bisa lebih merasa "aman" ketika melakukan browsing reddit disana.

## Tips Memanfaatkan _Plugin **Privacy Redirect**_
Sering kali saat kita melakukan pencarian di mesin penelusuran seperti Google.com, muncul konten dari halaman situs Reddit. Namun karena kita tidak dapat mengakses *link* Reddit tersebit karena ISP yang kita gunakan memblokir akses ke situs reddit.com.

Disini adanya [_plugin browser "**Privacy Redirect**"_](https://github.com/SimonBrazell/privacy-redirect) akan sangat membantu. Dia tugasnya akan melakukan *redirect* (mengubah) *link* asal ke *link* yang sudah kita tentukan sebelumnya.

Misalnya, ketika hasil pencarian dari google.com menampilkan *link* ke _https://**reddit.com**/r/indonesia_, ketika kita mengeklik *link* tersebut, _plugin "**Privacy Redirect**"_ akan mengubah *link* tersebut ke _libreddit instance_ pilihan kita yang sudah kita tentukan sebelumnya, misal: _https://**libreddit.ditatompel.com**/r/indonesia_.

Saat ini, _plugin Privacy Redirect_ tersebut tersedia di [Firefox Add-Ons](https://addons.mozilla.org/en-US/firefox/addon/privacy-redirect/), [Chrome Web Store](https://chrome.google.com/webstore/detail/privacy-redirect/pmcmeagblkinmogikoikkdjiligflglb), dan [Microsoft Edge Add-ons](https://microsoftedge.microsoft.com/addons/detail/privacy-redirect/elnabkhcgpajchapppkhiaifkgikgihj).

Cara menggunakannya cukup *install plugin* tersebut ke *browser* yang kamu pakai, masuk ke pilihan **"More Options"** dan masukkan *URL instance* pilihan kamu ke **"Reddit Instance"**.

![Privacy Redirect Plugin](privacy-redirect-plugin.png#center).

Kamu juga bisa dengan mudah mengaktifkan / menonaktifkan fitur *redirect* per situs dari tombol switch `on` - `off` seperti pada gambar di bawah:

![Privacy Redirect Plugin Switch](privact-redirect-plugin-swich-on-off.png#center).

## Alternatif libreddit
Selain **libreddit**, ada alternatif lain yang cara kerjanya sama (sebagai *proxy*), yaitu [**teddit**](https://codeberg.org/teddit/teddit). Dari sisi tampilan, **libreddit** lebih mirip dengan desain reddit yang baru, sedangkan **teddit** terlihat mengikuti desain reddit yang lama (`old.reddit.com`).

Dari sisi bahasa program yang digunakan, libreddit menggunakan **Rust** sedangkan teddit menggunakan **NodeJS**.