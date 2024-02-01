---
title: "Menulis ulang situs ditatompel.com ke Svelte, Tailwind, dan Go"
description: "Rencana untuk menulis ulang situs pribadi saya dari bahasa pemrograman PHP ke Go. Ada beberapa 'breaking changes' yang akan terjadi selama dan setelah proses transisi."
date: 2024-01-25T18:17:34+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Pengumuman
tags:
  - Go
  - Svelte
  - Tailwind CSS
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

Saya berencana untuk "menulis ulang" situs pribadi saya dari bahasa pemrograman PHP ke Go. Ada beberapa "breaking changes" yang akan terjadi selama dan setelah proses transisi.

<!--more-->
---

Untuk memperluas pengetahuan dan pengalaman saya di bidang _web development_, saya berencana untuk menulis ulang secara keseluruhan situs pribadi saya: [ditatompel.com](https://www.ditatompel.com) yang semula menggunakan bahasa pemrograman [PHP](https://www.php.net/) (_backend_) ke bahasa pemrograman [Go](https://go.dev/). Untuk _frontend_, saya akan mencoba beralih dari [Bootstrap](https://getbootstrap.com/) `v4.6` ke [Svelte](https://svelte.dev/) dan [Tailwind CSS](https://tailwindcss.com/).

Boleh dibilang, keputusan ini saya ambil secara sembrono karena saya __baru mempelajari bahasa pemrograman Go__ selama kurang lebih 6 bulan dan saya __tidak pernah__ menggunakan _framework_ __Svelte__ sebelumnya. Jadi, ini akan menjadi website pertama saya yang menggunakan __Svelte__ sebagai _frontend_ dan __Go__ sebagai _backend_.

## Proses Transisi

Proyek ini akan saya kerjakan di waktu senggang saya, sehingga kemungkinan akan memakan waktu cukup lama. Selama proses transisi, saya akan mulai menghilangkan fitur _"offline caching"_ pada _service worker_ yang berjalan di _browser_ Anda. Hal ini penting dilakukan supaya ketika __UI__ baru yang nantinya diluncurkan tidak berbenturan dengan _"offline cache"_ dari **UI** yang lama.

> _Karena "offline cache" pada browser dihilangkan, maka Anda akan merasakan performa yang lebih lambat saat mengakses situs saya._

## _Breaking Changes_

Untuk menerima yang baru, kadang kita harus mengucapkan selamat tinggal pada beberapa fitur lama dan memperkenalkan beberapa perubahan penting. Meskipun ini mungkin berarti mengucapkan selamat tinggal pada masa lalu, itu juga berarti menyambut masa depan yang penuh dengan kemungkinan tak terbatas (_wedjian!_ 👏👏👏).

Beberapa perubahan yang nantinya akan terjadi adalah:
- Sementara dihilangkannya koneksi _websocket_ pada halaman `/monero` sehingga tidak akan muncul notifikasi _popup_ secara _realtime_.
- Informasi tanggal _"Google Trends ™"_ tidak tidak mengacu pada zona waktu browser Anda, melainkan akan mengacu pada zona waktu **UTC**.
- Perubahan _public API endpoint_: yang semula berlokasi di `https://www.ditatompel.com/api` akan berubah menjadi `https://api.ditatompel.com`.
- Perubahan struktur data _json response_ pada beberapa API _endpoint_ yang akan saya informasikan lebih detail di kesempatan lain.

## _What Could Possibly Go Wrong?_

Jika saya gagal mengimplementasikan fitur _service worker_ di versi website terbaru Saya, Anda akan tetap _"stuck"_ pada versi website yang lama. Satu-satunya cara untuk mengatasi masalah ini adalah dengan melakukan _unregister service worker_ yang lama dan melakukan _"Clear Website Data"_ secara manual pada browser Anda. Hal ini terjadi karena situs saya saat ini sangat bergantung pada _cache_, baik itu di sisi server maupun client (browser).

---

Saya akan menginformasikan update terbaru mengenai proses transisi di halaman ini. Dengan semua perubahan ini saya berharap adanya peningkatan performa yang signifikan baik dari sisi _frontend_ maupun _backend_.

## Update

### 2024-01-31
- __BREAKING__: __Monero Public API endpoint__ dipindahkan dari `https://www.ditatompel.com/api/monero/remote-node` ke `https://api.ditatompel.com/monero/remote-node`. Lihat [commit diff 013aa7d](https://github.com/ditatompel/insights/commit/013aa7db35edd28e72907d5786fcf8877a5a3e70#diff-a8f1b286fbca7e5d241e20d067c8b17a67b86cc142d10dc7cc23cbc9fcc0e332L139-L167) untuk informasi lebih detail.

### 2024-01-29
Meskipun masih masih tahap _beta_, _frontend_ dan _backend_ versi terbaru sudah saya _deploy_ ke _production server_ pada tanggal 29 Januari 2024. Dan dari hasil [PageSpeed Insights](https://pagespeed.web.dev/) saat ini, saya cukup puas untuk performa yang saya didapatkan.

![PageSpeed Insights ditatompel.com mobile](pagespeed-insights-ditatompel-dot-com.png#center)
