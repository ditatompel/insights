---
title: "Sekilas Tentang DNS Hijacking"
description: "Bagaimana secara teknis DNS hijacking itu dilakukan, bukan tutorial mengenai penggunaan tools / teknik nyata seorang attacker melakukan DNS Hijacking."
date: 2012-01-18T03:20:20+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Security
  - Networking
tags:
  - DNS
  - MiTM
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

Karena belakangan ini sedang marak **DNS Hijacking**, bahkan **Twitter** pun jadi korban, saya coba membahas dan ingin berdiskusi tentang apa itu *DNS hijacking*. Disini yang ingin saya bahas adalah bagaimana secara teknis DNS hijacking itu dilakukan, bukan tutorial mengenai penggunaan *tools* / teknik nyata seorang *attacker* melakukan **DNS Hijacking**.

<!--more-->

**DNS Hijacking** adalah teknik serangan yang bertujuan untuk mengubah entri DNS menuju ke IP lain daripada menuju ke IP sebenarnya. Sebelum melanjutkan, ada baiknya untuk mengerti terlebih dahulu mengerti apa dan bagaimana [Sistem Penamaan Domain](https://id.wikipedia.org/wiki/Sistem_Penamaan_Domain) itu bekerja.

![dig](dig.png#center)

Untuk memahami lebih baik, saya coba kasi contoh di kehidupan sehari-hari. (Bukan cerita nyata)

Taruh kata saya ingin mencari *exploit* di situs `1337day.com`. Maka saya akan memasukkan alamat `1337day.com` ke *address bar browser* lalu menekan enter, sehingga saya akan dibawa ke situs `http://1337day.com/`. Tapi, apa yang terjadi di balik layar saat kita melakukan aktivitas tersebut?

Pada dasarnya, browser akan mengirimkan permintaan ke **DNS Server** untuk mendapatkan alamat IP domain `1337day.com`, DNS server tersebut kemudian menjawab dan memberitahu browser kita alamat IP untuk 1337day.com adalah `77.120.120.218` sehingga browser kita akan mengakses alamat IP 1337day.com (`77.120.120.218`) dan menampilkan isi dari halaman website tersebut.

Cerita berlanjut, 2 hari kemudian saya dapat kabar dari seorang teman kalau situs 1337day.com udah tutup dan berubah jadi toko baju.

Otomatis saya tidak percaya, masa situs keren begitu berubah jadi toko baju.. Yang bener aja!!! Saya ga akan percaya sebelum membuktikan dengan mata kepala saya sendiri! Saya ambil notebook saya, buka browser dan coba buka situs `http://1337day.com/` tadi.

Saya kaget, ternyata situs tersebut benar2 menjadi situs toko baju. Saya benar2 sudah yakin dan memastikan bahwa ini bukan sebuah lelucon. **URI** juga udah saya cek dengan teliti.

Saya pikir *"Ini berita heboh nih..."* Saya langsung chatting sama pacar simpanan stok no #21 yang ada di Russia (sekali lagi, bukan cerita nyata!!). Saya beritahukan berita tersebut (cw simpenan saya yang 1 ini seorang geeks). Saya terkejut karena dia bilang situs *1337day.com* baik-baik saja, isinya juga masih seputar *exploits* dan *vulnerable software*. Trus pacar simpenan saya menyuruh saya untuk *nge-ping* ke *1337day.com* dan mencocokan IP hasil ping saya dengan IP hasil `ping` si do'i, dan hasilnya berbeda!

Kalau mau akses 1337day.com, langsung aja ke IPnya. Kata si do'i. Langsung saya coba akses melalui alamat IP.

```
http://77.120.120.218/
```

Dan browser menunjukan tampilan situs **inj3ct0r** yang sebenarnya. Saya yg awalnya pingin keliatan keren jd keliatan aslinya, bego.

Nah inilah contoh korban dari skenario **DNS hijacking**. Kita mungkin bertanya-tanya apa yang terjadi, apakah DNS Server memberitahu Anda alamat IP yang salah? Hmm... Mungkin ...

Ada beberapa teknik untuk melakukan DNS hijacking ini.

## DNS Cache Poisoning
Seperti yang dapat kita bayangkan, DNS server tidak dapat menyimpan semua informasi tentang semua nama / IP yang ada di internet kedalam *memory space*nya. Itulah mengapa DNS server (*resolver*) melakukan *caching* yang memungkinkan untuk menyimpan DNS record untuk sementara waktu. Sebuah fakta bahwa Server DNS memiliki catatan / otoritas domain hanya untuk domain2 yang diarahkan kepadanya, Jika sebuah DNS Server (*resolver*) memerlukan *record* domain di luar otoritasnya, DNS Server akan mengirimkan permintaan ke server DNS lain yang bertanggung jawab atas record domain yang diperlukan. Karena itulah DNS menyimpan *record* ke dalam *cache* karena tidak mungkin sebuah DNS server melakukan *forward* request ada permintaan / *query*.

Informasi yang saya tuliskan diatas sudah dipersimple, karena sebenarnya di balik layar prosesnya jauh lebih kompleks. Saya akan coba membuat artikel khusus mengenai *Root DNS*, *Resolver*, *TLD*, dan *Authoritative DNS* di lain waktu.

Sekarang mari kita lihat bagaimana seseorang melakukan *cache poisoning* ke DNS Server kita.

![DNS Cache Poisoning](dns-cache-poisoning.jpg#center)

1. Penyerang melakukan *query* ke DNS server untuk alamat IP yang dikelola oleh *name server* yang dimiliki oleh penyerang "Berapa adalah alamat IP dari owned.com?"
2. DNS Cache Server tidak memiliki cache record untuk owned.com dan harus meneruskan query ke DNS Server yang bertanggungjawab untuk domain owned.com dimana DNS Server yang bertanggungjawab telah dikuasai oleh penyerang.
3. DNS server milik penyerang memberitahu DNS Cache Server bahwa alamat IP dari owned.com adalah 200.1.1.10. Bersamaan dengan itu, DNS server milik penyerang juga menyisipkan record palsu. Misalnya :

```text
1337day.com adalah 111.1.1.11
mail.1337day.com adalah 111.1.1.11
```
4. DNS Cache Server merespon untuk query asli penyerang dengan - *"Alamat IP dari owned.com adalah 200.1.1.10."* Tapi siapa yang peduli, tujuan penyerang bukan untuk mendapatkan alamat IP dari owned.com, tapi untuk melakukan transfer record palsu diatas.
5. Beberapa hari kemudian, seorang user biasa yang juga menggunakan DNS Cache Server yang sama melakukan query untuk alamat IP dari 1337day.com - *"Berapa adalah alamat IP dari 1337day.com?"*
6. DNS Cache Server merespon request user biasa tersebut dari cache dengan record palsu yang sebelumnya telah disisipkan oleh penyerang.

![DNS Spoofing](feature-dns_spoof-small-1.png#center)

## DNS ID Spoofing (with Sniffing)
Ketika komputer A melakukan request alamat IP server B melalui sebuah DNS Server, komputer A membawa informasi sebuah nomor identitas acak yang harus dibawa ketika melakukan *query* ke DNS Server, kemudian ketika jawaban dari DNS Server diterima oleh komputer A dan dibandingkan dengan identitas acak tadi. Dalam hal ini jika kedua angka tadi sama, maka jawaban akan dianggap valid, dan jika tidak sama maka jawaban akan diabaikan oleh komputer A.

Pertanyaannya, apakah konsep ini aman? Tidak sepenuhnya.

Siapa pun bisa memulai serangan untuk mendapatkan nomor identitas tersebut. Jika Anda misalnya pada **LAN** / **Wireless**, seseorang dapat melakukan *sniffing* saat komputer A melakukan request ke DNS Server, melihat ID permintaan dan mengirimkan jawaban record palsu dengan nomor ID yang benar.

Bingung? Untuk lebih jelas bisa lihat gambar di bawah.

![DNS Spoofing ID](dns-spoofing-id.jpg#center)
1. User mengirimkan melakukan UDP request ke DNS Server - *"Berapa adalah alamat IP dari 1337day.com?"* - Dengan ID dari 212.
2. Penyerang melakukan *snifing* semua lalu lintas jaringan user tersebut dan merespon DNS query.
3. Setelah mengidentifikasi DNS query untuk 1337day.com dengan ID 212, penyerang merespon dengan "Alamat IP dari 1337day.com adalah 111.1.1.11" menggunakan ID yang sama.
4. Dan baru beberapa saat kemudian, DNS Server mengirimkan respon *"Alamat IP dari 1337day.com adalah 77.120.120.218"*, tetapi diabaikan oleh komputer user karena telah menerima respon sebelumnya dari penyerang.
Ada beberapa keterbatasan untuk teknik serangan ini. Dari contoh di atas, penyerang menjalankan *sniffing*, mendapatkan nomor ID dan harus mampu membangun respon palsu lebih cepat daripada server DNS dapat menyediakan jawaban yang sah.

Sekian dulu untuk DNS Hijackingnya, sebenernya masih ada beberapa teknik untuk melakukan DNS Hijacking seperti DNS ID Spoofing (*without Sniffing*), *Birthday Attack*, *Page Rank Escalation*, dll seperti yang ada di [Pharming Attack Vectors Section 3](http://www.technicalinfo.net/papers/Pharming2.html) (cukup lengkap klo saya bilang).

Saya akan coba tambahin dan benerin kata2 yang masih belepotan di kesempatan lain.

Source :

* paper dari situs darkc0de.com
* Sistem Penamaan Domain (`http://devilzc0de.org/forum/thread-7744.html`) oleh @[linuxer46]
* SET(harvester)+Dns Spoofing (`http://devilzc0de.org/forum/thread-11128.html`) oleh @[motaroirhaby]
* DNS spoofing di Local Network Tutorial (`http://devilzc0de.org/forum/thread-2671.html`) oleh @[wenkhairu]
* DNS Cache Poisoning (`http://devilzc0de.org/forum/thread-800.html`) oleh @[oela]
* Bailiwicked DNS Attack (Cache Poisoning) (`http://ezine.echo.or.id/ezine19/e19.008.txt`) oleh @[Cyberheb]

