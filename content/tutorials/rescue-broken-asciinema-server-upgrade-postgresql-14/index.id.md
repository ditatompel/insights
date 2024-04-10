---
title: "Menyelamatkan ASCIINEMA SERVER Yang Gagal Upgrade Karena PostgreSQL"
description: "Cara menangani ASCIINEMA server yang gagal upgrade karena PostgreSQL dengan melakukan backup dan recovery data yang lama."
# linkTitle:
date: 2023-03-11T08:52:39+07:00
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
  - Self-Hosted
tags:
  - asciinema
  - PostgreSQL
  - Docker
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

Hari ini, saya menemui kendala saat melakukan upgrade _self-hosted_ **asciinema server** milik saya. Setelah [mengikuti proses upgrade sesuai dokumentasi asciinema-server di GitHub](https://github.com/asciinema/asciinema-server/wiki/Installation-guide#upgrading), *container* `phoenix` dan `postgres` gagal berjalan dan selalu restart.

<!--more-->

saya mencoba mencari informasi apa yang menyebabkan hal tersebut terjadi. Dari log *container* `phoenix`, saya mendapati *error* berikut :

> **(DBConnection.ConnectionError)** _connection not available and request was dropped from queue after xxxxms. This means requests are coming in and your connection pool cannot serve them fast enough. You can address this by:_
> 
> *By tracking down slow queries and making sure they are running fast enough*   
> *Increasing the pool_size (albeit it increases resource consumption)*   
> *Allow requests to wait longer by increasing :queue_target and :queue_interval*   
> *See DBConnection.start_link/2 for more information*

kemudian dari log **postgreSQL** *container* itu sendiri, saya mendapatkan *error log* yang kurang lebih menginformasikan bahwa file yang berada di volume `postgresql` *container* tidak kompatible dengan yang sedang berjalan.:
> **FATAL**:  database files are incompatible with server   
> **DETAIL**:  The data directory was initialized by PostgreSQL version 12, which is not compatible with this version 14

Dari informasi error yang saya dapatkan tersebut, saya memutuskan untuk:
1. Melakukan *downgrade* sementara supaya saya bisa melakukan **backup database** yang sebelumnya.
2. Menghapus dan **menginstall kembali PostgreSQL yang sesuai dengan versi repositori masternya**.
3. Melakukan **restore database** yang telah saya backup dan berharap proses restore dapat berjalan dengan lancar.

Dan **ternyata berhasil**! 

## Proses penyelamatan
Masuk ke direktori `asciinema-server`, dan hentikan semua container yang berkaitan dengan **asciinema-server** dengan menjalankan perintah `docker-compose down`.

Download `asciinema-server` *docker image* yang terbaru:
```bash
docker pull asciinema/asciinema-server
```


Download *config* asciinema dari *upstream* dan lakukan *merge* ke *branch* milik Anda (jika belum dilakukan):
```bash
git fetch origin
git merge origin/master

# Perintah dibawah optional, tergantung dengan cara installasi awal asciinema-server Anda
git stash
git stash pop
git add .
git commit -m "Local upgrade"
git merge origin/master
```

### Downgrade PostgreSQL dan lakukan backup
Setelah itu, edit `docker-compose.yml`. Kembalikan `postgresql` image dari versi `14` ke versi sebelumnya (di kasus saya, versi sebelumnya di versi `12`).
```yml
version: '2'

services:
  postgres:
    image: postgres:12-alpine
    container_name: asciinema_postgres
    ### bla bla bla
``` 

Hal ini perlu dilakukan supaya kita dapat melakukan *dump database* PostgreSQL.

**Nyalakan PostgreSQL**, tapi **biarkan service asciinema-server lainnya tetap mati**.

```bash
docker-compose up -d postgres
```

Lakukan backup dengan menjalankan perintah berikut:
```bash
docker exec -it <DOCKER_CONTAINER_ID> pg_dump postgres -U postgres > asciinemadump.sql
```

> **Catatan**: informasi `DOCKER_CONTAINER_ID` bisa didapatkan dari perintah `docker ps`.

Setelah proses *dump database* selesai, matikan container postgresql tersebut dengan menjalankan perintah:
```bash
docker-compose down
```

**Hapus semua volume data yang digunakan oleh container postgresql yang lama** (defaultnya `./volumes/postgres`). Sebaiknya anda melakukan **backup** direktori tersebut dengan cara memindahkan ke folder lain sebelum menghapusya secara permanen.

### Jalankan PostgreSQL versi upstream
Setelah itu, hapus *docker volume* untuk `PostgreSQL 12` dan **gunakan PostgreSQL sesuai dengan versi dari upstream** (`v14`).

Edit kembali `docker-compose.yml` dan kembalikan sesuai dengan versi upstream.
```yml
version: '2'

services:
  postgres:
    image: postgres:14-alpine
    container_name: asciinema_postgres 
    ### bla bla bla
```

Nyalakan `PostgreSQL 14`, tapi **tetap biarkan service asciinema-server lainnya tetap mati** dulu.

```bash
docker-compose up -d postgres
```

### Restore PostgreSQL backup
Setelah PostgreSQL yang sesuai dengan versi upstream berjalan, lakukan proses *restore database* yang sudah kita backup sebelumnya.

Copy file `asciinemadump.sql` ke *volume postgres* (`./volumes/postgres`) dan ubah *file permission* supaya user `root` **didalam container** dapat membaca file tersebut.

Kemudian jalankan perintah berikut untuk melakukan **restore database** :
```bash
docker exec -it <DOCKER_CONTAINER_ID> psql -d postgres -U postgres -f /var/lib/postgresql/data/asciinemadump.sql
```

> **Catatan**: `DOCKER_CONTAINER_ID` Anda akan berbeda dengan `DOCKER_CONTAINER_ID` yang sebelumnya. Pastikan gunakan *docker container ID* yang benar.

### Jalankan asciinema-server seperti biasa
Setelah itu, jalankan semua service asciinema-server seperti biasa dengan menjalankan perintah `docker-compose up -d`. Seharusnya Anda sudah dapat menggakses **self-hosted asciinema-server** Anda kembali.
