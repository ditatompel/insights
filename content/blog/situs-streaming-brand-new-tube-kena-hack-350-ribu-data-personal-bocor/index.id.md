---
title: "Situs Streaming Brand New Tube Kena Hack, 350 Ribu Data Personal Bocor"
description: 350 ribu data personal bocor dari situs streaming asal Inggris Brand New Tube, termasuk termasuk email, username, alamat IP, jenis kelamin, pesan pribadi, dan password
date: 2022-09-08T17:43:40+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Privasi
tags:
#  - 
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
---

Di bulan Agustus 2022, situs streaming bernama **Brand New Tube** dilaporkan mengalami kebocoran data. Hampir **350 ribu data personal pengguna bocor** dari situs asal Inggris tersebut, termasuk email, username, alamat IP, jenis kelamin, pesan pribadi, dan password yang disimpan dengan **SHA1** *hash* (*unsalted*).  

<!--more-->

```
Tanggal kebocoran data: 14 August 2022
Ditambahkan ke HIBP: 8 September 2022
Total akun terdampak: 349,627
Jenis data: Alamat email, jenis kelamin, alamat IP, password, pesan pribadi, username
```

Berdasarkan informasi yang dihimpun dari situs ***Have I Been Pwned***, kebocoran data terjadi pada tanggal 14 Agustus 2022, namun baru dipulbikasikan 25 hari kemudian, yaitu tanggal 8 Semptember 2022. Dari kejadian tersebut, dikatakan 349.627 data personal pengguna situs tersebut bocor. Data yang bocor ke publik berisi informasi email, username, alamat IP, jenis kelamin, *hashed* password, hingga pesan pribadi.

Diketahui, data-data tersebut sudah beredar luas di internet dan dapat didownload secara gratis berupa file yang sudah dikompress dalam format `.7z` dengan ukuran file sebesar 1,7GB. Setelah diekstract, file tersebut berisi 3 fiee ***SQL database*** yang secara keseluruhan berukuran 19GB.

```
42M Agu 15 00:16 bdbrandnewtube_chat.sql
18G Agu 15 00:13 bdbrandnewtube_com.sql
65M Agu 15 00:15 bdbrandnewtube_com_users.sql
```

## Kritik dari aktivis keamanan

Dilansir dari situs **Unity News Network**, seorang aktivis keamanan mengatakan bahwa **Mohammad Butt** selaku *Sole Director* dan **Sonia Poulton** selaku *host* dari acara ***Rise*** sudah diperingatkan sejak 2 tahun lalu, namun tidak ditanggapi dengan serius. 

Metode penimpanan password juga ikut dikritisi karena hanya menggunakan *one-way-hash* **SHA1** tanpa adanya *salt* yang tentunya cukup mudah untuk mendapatkan *plaintext* dari *hashed* password yang tersebar, terutama jika password yang digunakan oleh pengguna tidak cukup kompleks.
