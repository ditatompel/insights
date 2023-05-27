---
title: "Berkenalan Dengan Unix/Unix-Like File Permission"
description: "Pada sistem operasi Unix atau Unix-Like (termasuk Linux), setiap file & direktori diberikan hak akses untuk kepemilikan file, user group, dan user lainnya. Artikel mengenai hak akses pada sistem operasi Unix / Unix-like (termasuk Linux)."
# linkTitle:
date: 2012-01-28T04:08:10+07:00
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
  - Ilmu Komputer
  - Linux 101
categories:
  - TIL
  - SysAdmin
tags:
  - Linux
  - BSD
  - MacOS
  - Unix
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

Sistem operasi *Unix-like*, seperti **Linux** berbeda dari sistem komputasi lain karena mereka tidak hanya *multitasking* tetapi juga *multi-users*. Pada sistem Linux, setiap file dan direktori diberikan hak akses untuk kepemilikan file, user group terkait, dan user lainnya. Hak akses dapat ditetapkan untuk membaca file, menulis file, dan mengeksekusi file (Misalnya: menjalankan sebuah sebagai program).

<!--more-->

Berhubung masih banyak yang masih belum mengerti tentang hak akses pada *Unix/Unix-Like*, Saya mau share sedikit mengenai UNIX-like file permission (Linux, BSD, Macintosh, dll).

> _**Note** : Hanya untuk mereka yang baru memulai / harus / ingin mempelajari **Unix-like OS**, Bagi yang sudah terbiasa menggunakannya, membaca tulisan ini ini hanya buang-buang waktu._

Untuk melihat file permission suatu file / folder, kita dapat menggunakan perintah `ls`, misalnya : `ls -lh`:

```text
total 404K
drwxr-xr-x 2 ditatompel ditatompel 4.0K 2011-11-06 08:02 crayonbot
drwxr-xr-x 6 ditatompel ditatompel 4.0K 2011-11-10 23:32 devilzb0t
-rw-r--r-- 1 ditatompel ditatompel 1.2K 2011-10-06 14:09 emabot.py
-rw-r--r-- 1 ditatompel ditatompel 4.2K 2011-10-25 03:24 twc1.0.py
-rw------- 1 ditatompel ditatompel 3.7K 2011-10-26 03:28 webbot.py
```

Kita ambil contoh ouput baris berikut:
```plain
drwxr-xr-x 2 ditatompel ditatompel 4.0K 2011-11-06 08:02 crayonbot
```

Lihat pada spasinya. Di sana nampak ada 8 field:
* Field `1` : `drwxr-xr-x`
* Field `2` : `2` => sebuah angka yang menunjukan berapa *user* / *group* yang sedang mengeksekusi / mengakses file / folder tersebut.
* Field `3` : `ditatompel` => menunjukan *user* yg memiliki file tersebut. (**Owner**)
* Field `4` : `ditatompel` => menunjukan *group* yg memiliki file tersebut. (**Group**)
* Field `5` : `4.0K` => menunjukan besarnya file tersebut.
* Field `6` dan `7` : `2011-11-06 08:02` => adalah jam dan tanggal kapan terakhir kalinya file tersebut dimodifikasi.
* dan terakhir : `crayonbot` => adalah nama file / folder itu sendiri.

Mari kupas field 1 lebih dalam, tapi tidak terlalu dalam. =)

**Field `1` : `drwxr-xr-x`**

Itu adalah sistem informasi *permission* atau hak akses di sistem Unix/unix-Like. Normalnya ada 10 karakter.
Sekarang supaya lebih mudah membacanya, lihat pada penjelasan di bawah ini:

```text
d rwx r-x r-x
|  |   |   |
|  |   |   +-- user lain permission
|  |   +------ group permission
|  +---------- owner permission
+------------- tipe file -> (d) = directory / folder, (-) = file
```

Dengan penjelasan sebagai berikut :
* `r` = **R**ead -> boleh membaca
* `w` = **W**rite -> boleh memodifikasi
* `x` = e**X**ecute -> boleh mengeksekusi (biasanya untuk *binary* file atau script)

Jadi bisa disimpulkan bahwa `drwxr-xr-x` adalah :
Sebuah **folder** yang *owner* atau pemiliknya dapat membuka/mengakses, menulisi/mengubah/membuat file di dalam folder tersebut, sedangkan *group* dan *user* lain hanya dapat mengakses dan mengeksekusi saja.

Kalau `-rw-r--r--` ?

Berarti sebuah **file** yang user / pemilik file dapat membaca dan mengubah file, sedangkan yang lain hanya dapat membaca saja.

kalau `-rw-------` ?

Berarti sebuah **file** yang user / pemilik file dapat membaca dan mengubah file, sedangkan user lain membaca file tersebut pun tidak diperkenankan.

## UNIX Binary dan Octal File Permission

Pernah mengalami error / warning pada aplikasi website milik Anda yg mengandung `'permission denied'`? Lalu saat mencari solusinya di **Google** dan banyak yang menyarankan ganti saja file permissionnya jadi `777`?
Sekedar informasi, permission `777` berarti anda memberikan hak kepada semua user untuk melihat, mengubah, dan mengeksekusi file / folder tersebut.
Sebelumnya jika belum bisa / belum tau bagaimana membaca binary, silahkan kunjungi artikel saya sebelumya mengenai [Membaca Binary Secara Manual]({{< ref "/tutorials/membaca-binary-secara-manual/index.id.md" >}} "Membaca Binary Secara Manual").

```text
0: 000 => --- => 0
1: 001 => --x => 1
2: 010 => -w- => 2
3: 011 => -wx => 3
4: 100 => r-- => 4
5: 101 => r-x => 5
6: 110 => rw- => 6
7: 111 => rwx => 7
```

Sehingga :
```text
0 --- tanpa permission
1 --x execute
2 -w- write
3 -wx write and execute
4 r-- read
5 r-x read and execute
6 rw- read and write
7 rwx read, write and execute
```

Jadi jika Anda mengubah file permission menjadi `777` maka -> `drwxrwxrwx` atau `-rwxrwxrwx` -> akan membuka celah keamanan baru pada server.

Untuk *block file system* (karakter pertama) sebenarnya tidak hanya (`-`) dan (`d`) saja.. Ada yang lain juga seperti :
* `l` => **Symbolic link** (*SymLink*).
* `c` => **Character special device**.
* `b` => **Block special device**.
* `p` => **FIFO**.
* `s` => *Socket filesystem* (banyak ditemui di directory `/dev`).

Sedangkan untuk tipe file permision selain `- r w x` ada juga *access mode* (`s`) dan *stcky* (`t`). nah untuk (`s`) bisa jd *suid* dan *sgid*.

Sekian dulu dari saya, semoga berguna bagi teman2 yang baru mengenal Unix atau bercita-cita ingin menjadi sysadmin karena kebanyakan Server menggunakan Linux (Unix-Like).
