---
title: "PassToBin, Simple Pastebin API Python Script"
description: PassToBin.py, Simple Pastebin API Python Script.
date: 2012-08-05T17:27:47+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Programming
tags:
  - Python
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

Script Python untuk mengupload *source file* ke `pastebin.com` menggunakan **pastebin API**. Anda dapat menyesuaikan nama file, mem-posting sebagai pengunjung atau akun **Pastebin** Anda dengan pilihan *public*/*private paste* dan _auto configure **syntax highlight**_ untuk beberapa tipe file.

<!--more-->

Anda dapat mendownload atau ikut memodifikasi/commit `passtobin.py` tersebut melalui [repositori PassToBin di GitHub](https://github.com/ditatompel/PassToBin).

```plain
Program Langage : Python
Python Version : 2.x
Tested on : Linux 
```

**Contoh Penggunaan :**
```bash
python passtobin.py -f /path/to/file/upload.txt
```

**Pilihan yang tersedia :**
```plain
Options:
 -h, --help            show this help message and exit
  -f FILE               file you want to upload (Required!)
  -u USER, --user=USER  your pastebin username, will be submit as guest if
                        not specified
  -n NAME, --name=NAME  your pastebin file title (optional)
  -p, --private         set this param for private paste
  -t TYPE, --type=TYPE  force format syntax highlight (Default: text)
  -e    Paste expires. Default: Never
```

**Dimana:**
- `-h` atau `--help` :  Untuk menampilkan opsi dan cara penggunaan.
- `-f` `FILE` (wajib ditentukan!): Lokasi file yang ingin diupload ke pastebin.com
- `-u` `USER` atau `--user=USER` (*Optional*): Username pastebin Anda. Klo tidak di set, maka otomatis akan melakukan paste sebagai guest.
- `-n` `NAME` atau `--name="Judul file"` (*Optional*): Nama judul file yang akan munjul pada "title" pastebin. Jika tidak diisi, maka akan menggunakan judul default *"untitled"*
- `-t` `TYPE` atau `--type=TYPE` (Optional): Untuk *force syntax highlight* yg digunakan. Jika tidak di set, maka script akan coba otomatis medeteksi dari ekstensi file tersebut. Untuk sementara support auto detect ekstensi yang ada pada `line 121 - 127`.   
Secara *default*, jika file ekstensi tidak ada pada list diatas, maka akan menggunakan format text (tanpa *syntax highlight*). Untuk force type lebih lengkapnya bisa dilihat pada `http://pastebin.com/api`.
- `-e` (*Optional*) : Brapa lama file tersebut akan ada di pastebin.com. untuk expires option :
    - `N` = Never (*Default*)
    - `10m` = 10 *Minutes*
    - `1H` = 1 *Hour*
    - `1D` = 1 *Day*
    - `1M` = 1 *Month*
- `-p` atau `--private`: *Private paste*. Max untuk 1 akun free pastebin = 25 private paste.

Misalnya saya ingin upload *private file* dengan format `apache log` ke pastebin menggunakan user `ditatompel` **expires** selama 1 hari dengan judul paste **"Apache Log Jan 2012"** Maka :
```bash
python passtobin.py         \
-f /var/log/httpd/error_log \
-u ditatompel               \
-t apache                   \
-e 1D                       \
-n "Apache Log Jan 2012"    \
--private
```

