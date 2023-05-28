---
title: "Coretan Tentang Email & Privasi"
description: "Bagaimana sistem email bekerja, informasi apa yang bisa didapat dari pesan email, &amp; cara menjaga privasi saat melakukan pertukaran informasi melalui email."
date: 2012-07-28T19:02:22+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Privacy
  - TIL
tags:
  - Email
  - SMTP
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

Kali ini kita akan mencoba untuk membahas bagaimana sistem email bekerja email, informasi apa yang bisa kita dapat dari pesan email, dan paling tidak bagaimana menjaga privasi pada saat melakukan pertukaran informasi melalui email.

<!--more-->

Sebelum kita lanjutkan mengenai privasi email, akan lebih baik jika kita memahami terlebih dahulu bagaimana sistem email bekerja dan hal-hal apa saja yang yang berkaitan dengan privasi email.

## Bagaimana sistem email bekerja?
Cara yang paling umum mengirim email adalah menggunakan mail server ISP atau perusahaan. Ketika kita mengklik tombol "**Send**", perangkat lunak email kita akan melakukan koneksi **SMTP** ke mail server kita. Mail server kita akan mencoba untuk menyampaikan pesan ke mail server ISP yang dituju, kemudian pesan akan dikirimkan ke kotak surat (**Inbox**) penerima pada mail server ISP yang dituju. Pesan yang disimpan di sana dapat dibaca oleh penerima email menggunakan **POP3** atau **IMAP**.

## Bagaimana pesan email dibajak?
Paling tidak dalam perjalanan-nya pesan email disimpan di dua server : 1 di mail server ISP pengirim dan 1 lagi di server mail ISP penerima. Saat email kita ditujukan kepada bank, perusahaan, rekan bisnis, dll, isi pesan pada email dapat menarik perhatian staff TI yang melakukan pemantauan mail server.

Dan kita tahu bahwa tidak ada yang dapat mencegah oknum staf TI yang memiliki akses ke server email, membuka dan membaca pesan itu. Dan tentu saja orang lain yang sebenarnya tidak berwenang seperti *attacker* yang telah memiliki akses ke mail server tersebut juga dapat melihat dan membaca isi pesan yang kita kirimkan. Cara lain untuk mendapatkan isi dari sebuah email adalah melalui *sniffing* lalu lintas jaringan.

## Privasi Pada Header Email
Ketika menganalisis pesan email kita bisa mendapatkan banyak informasi tentang pengirimnya. Alamat IP komputer, lokasi geografis, zona waktu, bahasa yang digunakan, *software* email yang digunakan dan lain sebagainya. Informasi-informasi tersebut kadang tercantum tanpa sepengetahuan pengguna / pengirim email.

Sebagai contoh, kita mungkin tidak ingin penerima mengetahui bahwa sistem operasi kita menggunakan Bahasa Indonesia sebagai bahasa *default* atau bahwa kita sedang berada di sebuah negara dan menggunakan salah satu layanan ISP lokal. Semua informasi ini dapat dengan mudah didapat dari **header** pesan email.

Setiap pesan email terdiri dari dua bagian: **header** dan **body**. Bagian *header* berisi **subjek** pesan, alamat **email pengirim** dan **penerima**. Selain itu header email juga berisi informasi **tanggal dan waktu** pesan dikirim dan kapan pesan itu tiba, lalu perangkat lunak email yang digunakan pengirim, dan lain sebagainya. Informasi ini biasa digunakan untuk menyampaikan pesan, dan memungkinkan staf IT untuk melakukan *debug* jika ada masalah dengan mail server-nya.

## Analisa Header Email
Berikut adalah contoh *header* pesan yang dikirim oleh `pengirim@gmail.com` ke `penerima@yahoo.co.id` yg saya **Bcc**-kan ke `penerima_tersembunyi@list.ru`.

![RAW Email](email-dan-privasi.jpg#center)

Nah dari header email inilah yang dapat kita cari informasi lebih dalam mengenai email tersebut. Perhatikan pada informasi berikut:

```plain
Received: from [209.85.210.45] (port=39452 helo=mail-pz0-f45.google.com)
by mx25.mail.ru with esmtp
```
dan
```plain
Received: from [10.69.40.36] ([202.152.202.174])
by mx.google.com with ESMTPS id n10sm65348710pbe.4.2011.09.25.13.16.06
```

Disana terdapat 2 informasi. Mari kita bedah lagi lebih dalam..

- Tag `Received from` pertama dari alamat IP `209.85.210.45` dan diterima oleh `mx25.mail.ru`.
- Tag `Received from` kedua dari alamat IP lokal `10.69.40.36` dan IP publik sumber pengirim email adalah `202.152.202.174` dan diterima oleh `mx.google.com`.

Mari kita cari informasi dari ke 2 IP publik diatas menggunakan fitur WHOIS yang sudah banyak tersedia di internet :

- `209.85.210.45` [http://www.ip-adress.com/ip_tracer/209.85.210.45](http://www.ip-adress.com/ip_tracer/209.85.210.45) (Google)
- `202.152.202.174` [http://www.ip-adress.com/ip_tracer/202.152.202.174](http://www.ip-adress.com/ip_tracer/202.152.202.174) (PT. Bakrie Telecom Tbk)

Dari sini kita dapat menyimpulkan bahwa pengirim mengirimkan email dari ISP Bakrie Telecom Tbk dan diterima oleh Mail Excange milik Google.
Dari hasil trace tersebut, kita bisa mendapatkan informasi telpon, alamat, email, dan lain sebagainya dari ISP yang digunakan tersebut (yang mungkin berguna jika kita menjadi korban penipuan atau kasus merugikan lain-nya. Perlu diketahui bahwa setiap ISP / perusahaan memiliki kebijakan sendiri atas informasi pengguna-nya).

Ada banyak informasi lagi yang dapat kita ambil dari *header* diatas, misalnya :
Pengirim menggunakan perangkat lunak **Thunderbird** versi `3.1.13` dengan sistem operasi **Linux** `32 bit`, dengan zona waktu lokal `+7` (lokasi geografis Indochina).

```plain
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.21)
Gecko/20110831 Thunderbird/3.1.13
Date: Mon, 26 Sep 2011 03:16:04 +0700
```

Perlu diketahui juga bahwa tidak semua header email membawa informasi lengkap seperti di atas, informasi yang pasti dibawa adalah `from`, `to`, dan `subject`. Semua data lainnya biasa dibawa oleh perangkat lunak / server email yang digunakan. Biasanya pengguna tidak memiliki kontrol atas header ini, informasi header-header tersebut yang paling berbahaya bagi privasi email dan mengandung banyak informasi tentang pengirim.

## Gunakan perangkat lunak email yang aman
Menggunakan perangkat lunak email yang benar adalah awal yang baik bagi keamanan email. Jika kita menggunakan perangkat lunak email yang penuh *bugs* maka semakin memungkinkan untuk diserang karena pesan email membawa informasi vendor perangkat lunak email beserta versinya.

Dari informasi vendor dan versi yang didapat sudah cukup untuk menulis sebuah pesan khusus yang memanfaatkan celah software untuk menyerang komputer kita (dengan *trojan* misalnya). Nah dari celah-celah yang ada memungkinkan penyerang untuk mengambil / mendapatkan informasi username, password, akun rekening bank, informasi pribadi, dan lain sebagainya.

Semua skenario diatas bukan rekayasa, dan hal ini benar-benar terjadi. Ada banyak instansi yang menawarkan untuk memata-matai pihak tertentu melalui internet. Jika pesaing bisnis kita rela mengeluarkan sejumlah uangnya untuk mengetahui informasi kita, maka kita hendaknya lebih berhati-hati. =)

## HTML Tracker (image)
Sebagian besar aplikasi email mampu untuk menampilkan pesan email dengan format HTML. Hal ini tidak berbeda saat kita melakukan browsing biasa, bedanya hanya halaman web ditampilkan dalam jendela perangkat lunak email yang kita gunakan, bukan pada browser.

Saat melihat email berformat HTML, email tersebut dapat menyisipkan tag tertentu seperti *image*/gambar yang sudah di simpan di server pengirim. Hal ini juga bisa dimanfaatkan sebagai alat *tracking*.

Untuk menggambarkan bagaimana mereka bekerja, mari kita bayangkan bahwa kita sedang menjalankan beberapa bisnis online pakaian wanita misalnya . Kita menerima pesan email dari orang tak dikenal misal sebagai berikut :

```plain
From : someuser@yahoo.com
For: customer@foobar.com
Subject: About Victoria Secret
Hello, good day!
How are you?
I'm good here, I want to ask about [bla bla bla]

Regards,
Attacker
```

Untuk menarik perhatian kita, attacker mungkin menggunakan tag yang berhubungan dengan bisnis yg kita jalankan, nama lengkap, atau nama perusahaan pada baris *"Subject"*. Kita buka pesan tersebut, kemudian menyadari bahwa itu hanyalah email spam.

Tapi apakah kita menyadari bahwa pesan yang dikirim adalah pesan dengan format HTML dan berisi gambar kecil / transparan yang telah disiapkan sebelumnya di server milik penyerang?
Jika gambar yang dilampirkan secara otomatis di-download (*render*) saat kita membaca pesan. Penyerang dapat menganalisa log web server dimana gambar yang telah disiapkan tadi disimpan. Dari situ memungkinkan penyerang untuk mendapatkan beberapa informasi kita. Misalnya tanggal dan waktu kita membaca email ini, alamat IP, sistem operasi, dll.

![Log image tracker pada webserver](email-dan-privasi_image-mail-log.jpg#center)

Hal ini berarti bahwa privasi kita dapat terancam cukup dengan membuka pesan email, bahkan tanpa membalas email tersebut.

## Bagaimana melindungi privasi email kita?
Gunakan enkripsi untuk melindungi pesan email kita. Satu-satunya cara untuk melindungi pesan email adalah dengan mengenkripsi email tersebut. Ada beberapa teknik untuk melakukannya.

### PGP dan S/MIME
**PGP** dan **S/MIME** digunakan untuk mengenkripsi body email, header email tetap tidak terlindungi. Dengan menggunakan metode ini maka membutuhkan persetujuan sebelumnya antara pihak pengirim dan pihak penerima, dengan melakukan pertukaran **"public key"**.

Perlu dicatat bahwa hanya menggunakan **PGP** dan **SMIME** tidak menjamin privasi kita. meskipun kita menggunakan **PGP** atau **S/MIME**, *header* pesan masih tetap tidak terenkripsi, dan akan ditransfer dalam bentuk plain teks melalui Internet jika tidak menggunakan protokol **SSL**/**TLS**.

### Koneksi SSL/TLS
**SSL**/**TLS** dapat digunakan untuk mengenkripsi lalu lintas email secara keseluruhan dari pengirim ke penerima. Dengan koneksi yang terenkripsi **SSL**/**TLS** dapat mencegah seseorang melakukan *sniffing* lalulintas jaringan saat pesan dikirim dan ditermima oleh penerima (Paling tidak hingga email diterima pada Inbox alamat email tujuan).

Referensi :
- darkc0de.com archive - Understanding Email Security And Anonimity.
- [http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol](http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol).