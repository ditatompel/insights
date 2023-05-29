---
title: "Pengunaan GnuPG/PGP Untuk Enkripsi Email Pada Thunderbird (2012)"
url: "tutorials/pengunaan-gnupg-pgp-untuk-enkripsi-email-pada-thunderbird-2012"
description: "Untuk melingdungi isi email yang sifatnya rahasia tersebut, maka kita dapat mengunakan fitur PGP. PGP digunakan untuk mengenkripsi body / isi pesan email."
# linkTitle:
date: 2012-07-29T19:47:55+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
# nav_icon:
#   vendor: bootstrap
#   name: toggles
#   color: '#e24d0e'
series:
#  - Tutorial
categories:
  - Privacy
  - Security
tags:
  - PGP
  - Thunderbird
images:
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

Pada artikel sebelumnya [Tentang Email dan Privasi]({{< ref "/blog/note-about-email-and-privacy/index.id.md" >}} "Tentang Email dan Privasi") kita telah membahas mengenai bagaimana sistem email bekerja, bagaimana pesan email dibajak, menganalisa header email, dan sedikit gambaran bagaimana melindungi privasi email kita. Pada kesempatan kali ini kita ingin sedikit berbagi bagaimana menggunakan GnuPG untuk mengenkripsi isi pesan email kita.

<!--more-->

Ketika kita berbagi informasi melalui email dengan teman maupun rekan kerja, tidak jarang kita menyertakan data-data seperti email, username, password atau informasi sensitif lainnya. Untuk melingdungi isi email yang sifatnya rahasia tersebut, maka kita dapat mengunakan fitur **PGP**. **PGP** digunakan untuk mengenkripsi body / isi pesan email.

Dengan menggunakan metode ini maka proses pertukaran informasi membutuhkan persetujuan sebelumnya antara pihak pengirim dan pihak penerima dengan melakukan pertukaran **"public key"** sehingga isi pesan jauh lebih terjamin kerahasiaannya.

Dalam Tutorial ini kita akan menggunakan perangkat lunak **GnuPG** yang diintegrasikan dengan **mail client Thunderbird**. Author memlih **Thunderbird** sebagai mail client karena ia tersedia di berbagai macam OS. Selain itu **Thunderbird** menyediakan beberapa fitur / ekstensi, seperti **Enigmail** yang memungkinkan kita untuk melakukan *enkripsi*, *dekripsi*, dan memberikan *PGP signature*.

Berikut adalah tools yang diperlukan / digunakan author untuk guide ini :
- OS Linux
- [GnuPG](https://www.gnupg.org/)
- [Mozilla Thunderbird](https://www.thunderbird.net/)
- [Enigmail](http://enigmail.mozdev.org/download/index.php.html)

Sebelumnya, saya asumsikan bahwa Anda telah berhasil menginstall **GnuPG**, **Thunderbird**, dan *plugin* **Enigmail** pada sistem operasi Anda.

## Membuat PGP Key dengan GnuPG
Setelah mendownload **GnuPG** dan menginstallnya, kita *generate* **PGP key** dengan menjalankan perintah : `gpg --gen-key`. Maka Anda memiliki beberapa *option* untuk *key* yang anda *generate*, dari *tipe key*, *keysize*, berapa lama key tersebut *valid* dan *passpharse key* untuk *PGP key* Anda.

```plain
Please select what kind of key you want:
 (1) RSA and RSA (default)
 (2) DSA and Elgamal
 (3) DSA (sign only)
 (4) RSA (sign only)
Your selection? 1
```
Pada point pertama, kita pilih option nomor 1 (`RSA and RSA`) yang memungkinkan kita untuk melakukan *enkripsi* maupun *signing* pesan.
```plain
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 2048
Requested keysize is 2048 bits
```
Kemudian kita akan memilih *keysize* yang diinginkan. Secara default, program GPG menggunakan value default `2048`. Ketikan `2048` kemudian tekan enter.
```plain
Please specify how long the key should be valid.
 0 = key does not expire
 <n> = key expires in n days
 <n>w = key expires in n weeks
 <n>m = key expires in n months
 <n>y = key expires in n years
Key is valid for? (0) 1y
Key expires at Sun 27 Jul 2013 05:55:36 PM WIT
Is this correct? (y/N) y
```
Selanjutnya kita menentukan **berapa lama key tersebut valid**. Pada contoh kali ini saya membuat key tersebut valid selama **1 tahun**. Ketikan `1y` kemudian tekan enter.

```plain
GnuPG needs to construct a user ID to identify your key.

Real name: Tutorial PGP
Email address: test@crayoncreative.web.id
Comment: Untuk contoh tutor PGP
You selected this USER-ID:
 "Tutorial PGP (Untuk contoh tutor PGP) <test@crayoncreative.web.id>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
You need a Passpharse to protect your secret key.
```

Langkah selanjutnya adalah memberikan **user ID** untuk mengidentifikasi key yang sedang kita buat. User ID yang diberikan meliputi Nama Asli, Alamat Email, dan Komentar. Isi semua form tersebut kemudian ketik `O` dan tekan enter.

Setelah itu akan muncul *popup* berisi form untuk mengisi **passpharse key** seperti pada gambar di bawah ini :

![gpg gen-key](pgp-thunderbird-01.png#center)

Isi **passpharse key** yang nantinya berfungsi sebagai password untuk menggunakan PGP Key dan mendekripsi pesan. Tekan tombol `Ok` kemudian tunggu beberapa saat dan kita akan melihat *summary key* dengan informasi yang ada, misalnya tanggal *expires*, nama pemilik, dan lain sebagainya. Seperti pada contoh di pada gambar, **PGP public key** saya adalah `D47A605E`.

![gpg gen-key2](pgp-thunderbird-02.png#center)

## Penggunaan PGP pada Thunderbird dengan Enigmail
Buka program **Thunderbird** Anda, pilih option **OpenPGP** > **Key Management**. Maka akan tampil *list key* yang ada pada sistem kita seperti pada gambar berikut :
![OpenPGP management Thunderbird](pgp-thunderbird-03.png#center)

Pastikan **public key ID** Anda pada **OpenPGP** sama dengan apa yang baru saja Anda buat. Kemudian untuk melakukan testing, kita dapat mengirimkan email ke `adele-en@gnupp.de` (*PGP Email Robot*) dengan menyertakan *public key* kita. Caranya, pilih menu **OpenPGP** > **Attach Public Key**.

![OpenPGP attach public key](pgp-thunderbird-04.png#center)

Setelah itu akan muncul *popup list PGP key* yang ada. Pilih PGP key sesuai dengan email yang kita gunakan (`D47A605E`) dengan memberikan tanda centang di sebelah kiri Account / User ID.

![List PGP keys](pgp-thunderbird-05.png#center)

Kirimkan pesan Anda, kemudian setelah beberapa saat anda akan mendapatkan email balasan dari **Adele** :

![List PGP keys](pgp-thunderbird-06.png#center)

Masukan **passpharse key PGP key** Anda untuk mengetahui isi pesan tersebut. Kurang lebih akan tampil seperti gambar berikut :

![](pgp-thunderbird-07.png#center)

Setelah berhasil beremail ria dengan sang *"Robot"*, maka saatnya mencoba untuk beremail ria dengan orang asli. (*Carilah orang yang sudah terbiasa menggunakan PGP dan saling bertukar Public Key 1 sama lain*) Pada menu **OpenPGP** centang option **Sign Message** dan **Encrypt Message**. (Pastikan tanda pensil dan kunci di sebelah kanan bawah berwarna kuning).

![Open PGP button Thunderbird](pgp-thunderbird-08.png#center)

Kirimkan pesan tersebut, maka **hanya orang yang memiliki *PGP key* lengkap dengan mengetahui *passpharse key*-nya yang dapat membaca pesan** tersebut.

![Open PGP button Thunderbird](pgp-thunderbird-09.png#center)

Semoga guide ini dapat membantu Anda yang ingin lebih memperhatikan privasi saat bertukar pesan melalui email.

Referensi:
- [http://enigmail.mozdev.org/documentation/quickstart.php.html](http://enigmail.mozdev.org/documentation/quickstart.php.html)
- [http://www.dewinter.com/gnupg_howto/english/GPGMiniHowto.html](http://www.dewinter.com/gnupg_howto/english/GPGMiniHowto.html)
- [http://dart-ngo.gr/tutorials/747-gnupg-email-encryption-using-thunderbird-tutorial](http://dart-ngo.gr/tutorials/747-gnupg-email-encryption-using-thunderbird-tutorial)
