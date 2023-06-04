---
title: "Pelajaran Dari MyBB FB Connect Plugin XSS Attack"
description: Artikel ini bertujuan untuk sharing pengetahuan bagaimana cara backtracking attacker, khususnya yang memanfaatkan aplikasi Facebook.
date: 2011-12-01T23:53:39+07:00
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
  - Privasi
  - TIL
tags:
  - MyBB
  - XSS
  - Facebook
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

Beberapa waktu lalu, saya kaget belakangan ini ketika saya lihat logs situs saya yang penuh dengan uji coba *security* dari **IP** Indonesia. Salah satunya **XSS** pada **MyBB Plugin** di salah *forum* saya. Artikel ini bertujuan untuk sharing pengetahuan saja bagaimana cara *'backtracking'* *attacker*, khususnya yang memanfaatkan aplikasi Facebook.

<!--more-->

> _**CATATAN**: pada artikel ini saya tidak menggunakan ID Facebook attacker yang sebenarnya karena saya menghargai sang attacker dan guide ini hanya untuk sharing pengetahuan saja._

Seperti apa yang sudah diinformasikan oleh om **badwolves1986** di `http://devilzc0de.org/forum/thread-11110.html` bahwa ada **XSS bug** pada **plugin fbconnect** untuk **MyBB** tersebut.

Begitu mengetahui bugs tersebut, saya memang belum sempat *'menutup'* celah2nya. Saya hanya sempat menambahkan *"permission tambahan"* pada plugin tersebut yang membuat saya **BERHAK** melakukan update status akun Facebook yang digunakan untuk registrasi. Perhatikan gambar di bawah ini :

![FB Connect Permission Request](fbconnect-xss1.jpg#center)

Dari situ bisa dilihat bahwa aplikasi yang digunakan meminta permission lebih, yaitu : *"Post to Facebook as Me"* dan *"Access my data anytime"* setra beberapa data lainnya.

Dan dari sini kita bisa mendapatkan data2 attacker. Mari kita lihat pada database :

```bash
SELECT uid, username, fbuid FROM [namatableuserforumanda] WHERE uid = '[uidattacker]'
```

Perlu diingat bahwa field `fbuid` akan otomatis ada jika anda menginstall **FB Connect Plugin** untuk **MyBB**.

Dari *query* tersebut kita mendapatkan **user ID Facebook Attacker**.

![Hasil QUery SQL](fbconnect-xss2.jpg#center)

kemudian apa yang bisa kita lakukan selanjutnya? Yuk mari kita ingat-ingat lagi...

1. Kita telah memiliki user ID Facebook attacker.
2. Kita telah memiliki hak untuk melakukan update status dan mengakses data2 User ID tersebut meskipun sedang offline!

Benar sekali, **Facebook API**!

Kita bisa memanfaatkan **PHP Facebook SDK** dari [https://github.com/facebook/php-sdk](https://github.com/facebook/php-sdk).

Setelah didownload dan diupload ke webserver, mari kita buat *script* sederhana agar kita dapat melakukan update status profile Facebook attacker tersebut.

![PHP Facebook SDK](fbconnect-xss3.jpg#center)

Berikut contoh kodenya :

```php
<?php
require '[lokasi-facebook-phpsdk]';
/**
 * Facebook
 */
$app_id = "[aplikasi-id-anda]";
$app_secret = "[secret-key-app-facebook-anda]";

//build content
$fbinfo = 'Jangan lupa revoke permission setelah melakukan XSS melalui FB Connect. Atau hasilnya status anda bisa di remote seperti ini. :D Regards, M1nD_Pow3r';
$facebook = new Facebook(array(
    'appId'  => $app_id,
    'secret' => $app_secret
));
$response = $facebook->api(array(
    'method' => 'stream.publish',
    'uid' => '[user-id-attacker-dari-database]',
    'message' => $fbinfo
));
echo $fbinfo;
?>
```

Setelah itu upload ke situs anda dan eksekusi *script* tersebut. Maka anda telah berhasil melakukan update status pada akun Facebook attacker anda.

![Post menggunakan Facebook API](fbconnect-xss4.jpg#center)

Dari sini kita belajar beberapa hal:
1. *Covering track* itu perlu pada saat melakukan penyerangan sebuah situs.
2. Jangan gunakan ID / Identitas keseharian anda pada saat melakukan testing.

Lalu, kalau sudah terlanjur memperbolehkan aplikasi tersebut untuk mengakses data2 ane gimana om?

Masuk ke `http://www.facebook.com/settings/?tab=privacy`, lalu pilih **"Edit Settings"** pada pilihan **Apps and Websites**.

Nah pada menu **"Apps you use"** ente bisa hapus aplikasi2 yang sekiranya tidak diperlukan.

buat yg ingin *anonymous*, hati2 dengan Facebook karena dia benar2 mengoleksi data-data kita.

> _Jangan lupa, selalu gunakan 'pengaman' saat melakukan adegan berbahaya.._