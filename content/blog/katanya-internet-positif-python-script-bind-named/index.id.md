---
title: "Katanya Internet Positif Python Script Bind Named"
description: "Script untuk mengambil data blacklist dari kominfo.go.id, melakukan filterisasi kembali terhadap duplikasi domain atau alamat wildcard IP yang tidak valid."
date: 2017-04-22T23:55:03+07:00
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
  - SysAdmin
tags:
  - Python
  - Kominfo
  - Bind
  - DNS
  - Internet Positif
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

Kebetulan beberapa bulan lalu saya sedang ada projek membangun infrastruktur di salah 1 kantor di Indonesia. Nah salah satunya adalah membuat DNS server internal mereka, dan mereka minta untuk pemblokiran situs sesuai arahan dari pemerintah.

<!--more-->

Sebagai pendukung internet bebas, saya merasa sangat-sangat berdosa telah membangun sistem yang penuh sensor, apa lagi [sumber rujukannya amburadul](https://github.com/ditatompel/Katanya-Internet-Positif/wiki) mirip rambutnya **@74jTeZ** (`https://devilzc0de.id/forum/user-20584.html`). Tapi apalah daya, peraturan adalah peraturan dan wajib diikuti. Maka dari itu, untuk menebus dosa, saya buat script sederhana yang mudah-mudahanan berguna bagi netadmin/sysadmin, namanya **"Katanya Internet Positif"**.

**Katanya Internet Positif** adalah script sederhana untuk mengambil data *blacklist* dari `trustpositif.kominfo.go.id`, melakukan filterisasi kembali terhadap duplikasi domain atau alamat wildcard IP yang tidak valid, dan melakukan convert untuk konfigurasi BIND DNS zone blacklist.

GitHub: [https://github.com/ditatompel/Katanya-Internet-Positif](https://github.com/ditatompel/Katanya-Internet-Positif)

## Petunjuk Penggunaan
Script ini dapat dijalankan menggunakan **Python** `2.6` atau lebih.

### 1st run / update RAW_DATA
Untuk yang pertama kali menjalankan script ini (atau ingin melakukan update `RAW_DATA`), gunakan opsi `-f` *alias* `--fetch` untuk mengambil `RAW_DATA` dari `trustpositif.kominfo.go.id`.
```bash
python ./internetpositif.py --fetch
```

### Membersihkan duplikasi Data / list alamat IP yang tidak valid
Untuk membersihkan duplikasi data, menghapus alamat IP yang tidak valid, gunakan opsi `-c` *alias* `--clean`.
```bash
python ./internetpositif.py -c
```

### BIND zone file generator
Untuk membuat konfigurasi **BIND** *blacklist zone*, gunakan opsi `-g` *alias* `--generate` dengan opsi tambahan `-n`/`--nameserver`, `-e`/`--email`, `-d`/`--domain`.

Misalnya :
```bash
python ./internetpositif.py --generate -n ns.domain.com -e admin.domain.com -d blokir.domain.com
```

akan menghasilkan file :
```bind
$TTL 86400      ; 1 day
@   IN      SOA ns.domain.com. admin.domain.com. (
                               2017040503 ; serial
                               3600       ; refresh (1 hour)
                               120        ; retry (2 minute)
                               604800     ; expire (1 week)
                               86400      ; minimum (1 day)
                               )
       IN      NS      ns.domain.com.
domain.yang.diblokir.com IN CNAME blokir.domain.com.
domain.lainnya.yang.diblokir.net IN CNAME blokir.domain.com.
; [dan seterusnya]
```

Jalankan semua dalam 1 baris:
```bash
python ./internetpositif.py -cfg -n=ns.domain.com --email=admin.domain.com -d blokir.domain.com
```

## Default Values
Opsi tertentu memiliki *default value*, seperti :

- `-n` / `--nameserver` = `localhost.local`
- `-e` / `--email` = `administrator.localhost.local`
- `-d` / `--domain` = `internetbaik.wds.co.id`

Informasi lebih lanjut:
```plain
python ./internetpositif.py

-h, --help            show this help message and exit
-f, --fetch           Ambil data blacklist dari trustpositif.kominfo.go.id
-c, --clean           Bersihkan duplikasi data dari
                   trustpositif.kominfo.go.id
-g, --generate        Buat file zone file untuk BIND (BIND zone file
                   generator)

Opsi tambahan untuk BIND zone file generator:
-n NAMESERVER, --nameserver NAMESERVER
                   Nameserver option, default : localhost.local
-e EMAIL, --email EMAIL
                   Email option, default : administrator.localhost.local
-d DOMAIN, --domain DOMAIN
                   CNAME domain tujuan. Default internetbaik.wds.co.id
```

## Struktur File
Script akan membuat folder tertentu sesuai dengan opsi perintah yang diberikan.

- `-f` / `--fetch` membuat folder `./RAW_DATA/` berisi data asli yang didapat dari `trustpositif.kominfo.go.id`.
- `-c` / `--clean` membuat folder `./DATA/` berisi hasil list domain yang telah dibersihkan dari folder `./RAW_DATA/`.
- `-g` / `--generate` membuat folder `./conf/` hasil *convert* **named zone** yang didapat dari folder `./DATA/`.

## Berkontribusi
Lihat [CONTRIBUTING.md](https://github.com/ditatompel/Katanya-Internet-Positif/blob/public/CONTRIBUTING.md) untuk informasi lebih detail mengenai cara berkontribusi pada repositori ini.