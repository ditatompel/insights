---
title: "WP Direct Install Pada Host Yang Mendisable getmyuid"
description: "Trik sederhana agar dapat melakukan upgrade / install WordPress plugin secara langsung tanpa memasukan FTP user pada hosting yang mendisable fungsi getmyuid."
# linkTitle:
date: 2012-07-23T18:26:32+07:00
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
  - SysAdmin
tags:
  - WordPress
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

Pernah mengalami problem ketika ingin melakukan upgrade **CMS WordPress** atau mungkin menginstall *plugin*nya, tetapi Anda diharuskan untuk memasukan akun **FTP** Anda?

<!--more-->

**WordPress** akan meminta akun **FTP**/**SSH** kita untuk menginstall jika fungsi `getmyuid` pada PHP di-*disable*. (beberapa Administrator men*disable* fungsi tersebut untuk alasan keamanan) Selain itu, hal yang sama akan terjadi jika kita (user yg digunakan pada HTTP server tidak memiliki wewenang untuk menambah / merubah file atau folder tertentu.)

Berikut ini trik sederhana agar kita dapat melakukan upgrade / install *plugin* **WordPress** secara langsung tanpa memasukan *FTP user* pada hosting yang men-*disable* fungsi `getmyuid` nya.

{{< youtube ULp5Mhh_5Oc >}}

Pertama, mari kita lihat pada `file.php` yang terletak pada folder `wp-admin/includes`.

Kemudian gunakan fitur pencarian untuk menemukan kata '`getmyuid`'. (pada versi WordPress yang saya gunakan saat menulis tutotial ini ada di *line* `846`)

Disana terlihat bahwa jika fungsi tersebut tidak ada / didisable, maka WordPress akan menggunakan metode upload via FTP. Yang kita butuhkan hanyalah menambahkan sedikit konfigurasi pada `wp-config.php` yaitu sebagai berikut :

```php
if ( !defined('FS_METHOD') ) define('FS_METHOD', 'direct');
```
Kemudian save konfigurasi dan selesai.

Catatan:
1. Pada nilai konstan `FS_METHOD` harus bernilai `direct`/`ssh`/`ftpext`/`ftpsockets`.
2. Cara ini tidak berlaku jika user HTTP server tidak memiliki wewenang untuk menambah / merubah file atau folder tertentu.


