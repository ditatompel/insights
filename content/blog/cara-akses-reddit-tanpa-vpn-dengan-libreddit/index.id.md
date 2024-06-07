---
title: "Cara Akses Reddit Tanpa VPN Dengan Libreddit"
description: "Buat kamu yang kesulitan mengakses Reddit karena diblokir oleh ISP, menggunakan libreddit adalah cara alternatif dan mudah untuk mengakses Reddit tanpa VPN"
summary: "Buat kamu yang kesulitan mengakses Reddit karena diblokir oleh ISP, menggunakan libreddit adalah cara alternatif dan mudah untuk mengakses Reddit tanpa VPN"
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
authors:
  - vie
  - jasmerah1966
---

Belakangan ini, banyak yang melaporkan bahwa kawan-kawan di Indonesia mulai kesulitan mengakses **Reddit**. Mungkin karena pemerintah mulai memperketat _"jalur keluar"_ dari _internet checkpoint_ (baca: "[Babak Baru Sensor Internet di Indonesia: DPI & TCP Reset Attack]({{< ref "/blog/new-stage-of-internet-censorship-in-indonesia-dpi-tcp-reset-attack/index.id.md" >}})"). Berikut ini salah satu cara mengakses `reddit.com` tanpa harus menggunakan **VPN**. Contohnya adalah menggunakan [libreddit](https://github.com/libreddit/libreddit).

**Libreddit** itu sendiri adalah antar muka (_proxy_) untuk situs `reddit.com` (bukan _official_), jadi dia bertindak sebagai penghubung antara kamu dan situs `reddit.com`.

## Libreddit _instance_

**Libreddit _instance_** adalah mesin yang menjalankan program `libreddit` itu sendiri. _Instance_ ini biasanya dioperasikan oleh individu, tapi ada juga kelompok atau organisasi yang mengoperasikan **Libreddit _instance_**.

Berikut ini daftar beberapa instance yang dapat kamu pakai:
|URL|Location|Behind Cloudflare?|Comment|
|-|-|-|-|
|https://reddit.moe.ngo|🇮🇩 Indonesia|✅||
|https://safereddit.com|🇺🇸 Amerika Serikat||SFW only|
|https://lr.riverside.rocks|🇺🇸 Amerika Serikat|||
|https://libreddit.privacy.com.de|🇩🇪 Jerman|||

Untuk list yang lebih lengkap dan _up-to-date_ bisa dilihat di [https://github.com/libreddit/libreddit-instances/blob/master/instances.md](https://github.com/libreddit/libreddit-instances/blob/master/instances.md).

## Cara menggunakan libreddit

Cara menggunakan `libreddit` sangat mudah, kamu cuma butuh _browser_, kunjungi salah satu [_instance_ diatas](#libreddit-instance). Setelah kamu berada di halaman depan _instance_ yang kamu pilih, hal pertama yang kamu harus lakukan adalah memilih _subreddit_ yang ingin kamu _subscribe_.

Itu supaya ketika kamu kedepannya mengakses `libreddit` _instance_ itu lagi, yang tampil di halaman depan adalah konten-konten dari _subreddit_ yang sudah kamu _subscribe_.

Caranya, cari _subreddit_ yang ingin kamu _subscribe_ dari kolom pencarian. Misalnya [r/indonesia](https://safereddit.com/r/indonesia).

![Pencarian di libreddit](libreddit-1.png#center)

Setelah masuk ke halaman _subreddit_ yang kamu pilih, tekan tombol _**"Subscribe"**_. Maka posting dari _subreddit_ yang sudah kamu _subscribe_ tersebut akan otomatis muncul di halaman depan.

## Kelebihan dan kekurangan

Selalu ada kelebihan dan kekurangan, saya ingin mulai dari kekurangannya dulu baru kelebihannya.

### Kekurangan

Kekurangan paling utama adalah kita hanya bisa _browsing_ atau melihat-lihat saja. Karena di `libreddit`, kita tidak perlu _login_ (memang tidak bisa). Maka dari itu, kita juga pasti tidak bisa melakukan interaksi dengan pengguna lainnya seperti memberikan komentar, _upvote_, _downvote_, dan lain-lain.

### Kelebihan

- Tidak perlu **VPN**  
  Untuk mengakses `libreddit`, kita tidak perlu menginstal atau melakukan koneksi **VPN** jika ISP yang kamu pakai memblokir Reddit. Cukup bermodal _browser_ dan mengakses Libreddit _instance_ yang sudah saya sebutkan diatas.
- Tanpa iklan  
  Dengan menggunakan libeddit, kita bisa browsing posting-posting yang ada di Reddit tanpa iklan.
- Lebih cepat  
  Dari hasil pengalaman saya, mengakses reddit menggunakan libreddit terasa lebih cepat dan responsif.
- Privasi  
  **Libreddit** hanya menggunakan _"Cookie"_ untuk menyimpan _menu "Setting"_ dan _subreddit_ yang kamu _subscribe_. _"Cookie"_ tersebut sama sekali tidak menyimpan informasi personal kita.
- Pilihan **SFW** _only_ / **+NSFW**  
  **Beberapa _libreddit instance_ memilih TIDAK menampilkan** konten **NSFW** (_**SFW** only_), seperti [safereddit.com](https://safereddit.com). Jadi kamu bisa lebih merasa "aman" ketika melakukan browsing reddit disana.

## Tips Memanfaatkan _Plugin **Privacy Redirect**_

Sering kali saat kita melakukan pencarian di mesin penelusuran seperti Google.com, muncul konten dari halaman situs Reddit. Namun karena kita tidak dapat mengakses _link_ Reddit tersebit karena ISP yang kita gunakan memblokir akses ke situs reddit.com.

Disini adanya [_plugin browser "**Privacy Redirect**"_](https://github.com/SimonBrazell/privacy-redirect) akan sangat membantu. Dia tugasnya akan melakukan _redirect_ (mengubah) _link_ asal ke _link_ yang sudah kita tentukan sebelumnya.

Misalnya, ketika hasil pencarian dari google.com menampilkan _link_ ke _https://**reddit.com**/r/indonesia_, ketika kita mengeklik _link_ tersebut, _plugin "**Privacy Redirect**"_ akan mengubah _link_ tersebut ke _libreddit instance_ pilihan kita yang sudah kita tentukan sebelumnya, misal: _https://**safereddit.com**/r/indonesia_.

Saat ini, _plugin Privacy Redirect_ tersebut tersedia di [Firefox Add-Ons](https://addons.mozilla.org/en-US/firefox/addon/privacy-redirect/), [Chrome Web Store](https://chrome.google.com/webstore/detail/privacy-redirect/pmcmeagblkinmogikoikkdjiligflglb), dan [Microsoft Edge Add-ons](https://microsoftedge.microsoft.com/addons/detail/privacy-redirect/elnabkhcgpajchapppkhiaifkgikgihj).

Cara menggunakannya cukup _install plugin_ tersebut ke _browser_ yang kamu pakai, masuk ke pilihan **"More Options"** dan masukkan _URL instance_ pilihan kamu ke **"Reddit Instance"**.

![Privacy Redirect Plugin](privacy-redirect-plugin.png#center).

Kamu juga bisa dengan mudah mengaktifkan / menonaktifkan fitur _redirect_ per situs dari tombol switch `on` - `off` seperti pada gambar di bawah:

![Privacy Redirect Plugin Switch](privact-redirect-plugin-swich-on-off.png#center).

## Alternatif libreddit

Selain **libreddit**, ada alternatif lain yang cara kerjanya sama (sebagai _proxy_), yaitu [**teddit**](https://codeberg.org/teddit/teddit). Dari sisi tampilan, **libreddit** lebih mirip dengan desain reddit yang baru, sedangkan **teddit** terlihat mengikuti desain reddit yang lama (`old.reddit.com`).

Dari sisi bahasa program yang digunakan, libreddit menggunakan **Rust** sedangkan teddit menggunakan **NodeJS**.

