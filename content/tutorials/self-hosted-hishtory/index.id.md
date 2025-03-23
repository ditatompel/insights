---
title: Langkah-langkah Menginstall Self-hosted HiSHtory
description: Cara menginstall self-hosted HiSHtory, sebuah program yang menyimpan konteks riwayat terminal. Ikuti panduan yang mudah diikuti ini untuk proses penyiapan yang lancar
summary: HiSHtory adalah alat yang menyimpan konteks riwayat terminal, termasuk tanggal dieksekusinya perintah, direktori, dan durasi perintah tersebut berjalan. Artikel ini menunjukkan cara menginstal self-hosted HiSHtory, yang memungkinkan Anda mengelola riwayat terminal dengan mudah.
date: 2025-03-20T19:08:00+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - Self-Hosted
tags:
    - Bash
    - Zsh
    - HiSHtory
    - Linux
images:
authors:
    - ditatompel
---

Jika Anda sering bekerja menggunakan Linux Terminal, fitur _history_ pada
_shell_ yang kita gunakan bisa sangat membantu meningkatkan produktifitas kita.
Namun, **secara _default_**, fitur _shell history_ seperti `bash` atau `zsh`
memikili keterbatasan. Beberapa diantaranya adalah:

- Tidak menyimpan informasi dari direktori mana perintah yang kita jalankan.
- Tidak adanya informasi apakah perintah tersebut sukses dieksekusi atau tidak.
- Tidak adanya informasi seberapa lama komputer kita membutuhkan waktu untuk
  menyelesaikan perintah tersebut.

Bagi sebagian besar pengguna Linux, fitur-fitur diatas memang sedikit
_overkill_ dan bukan sebuah fitur yang krusial. Dan menyimpan informasi ekstra
tersebut sedikit banyak dapat meningkatkan disk I/O dan mempengaruhi performa
mesin. Tetapi, bagi sebagian penguna Linux lainnya, fitur tersebut dapat sangat
membantu melakukan investigasi ataupun troubleshooting pada sebuah sistem.

Jika informasi-informasi tersebut dapat disimpan secara terpusat dan dapat
dilakukan pencarian berdasarkan kata kunci tertentu, tentu akan sangat membantu
meringankan tugas para Linux System Administrstrator yang seringkali banyak
menggunakan perintah dengan _pipeline_ yang kompleks. Untungnya ada sebuah
program yang bernama **HiSHtory**.

{{< youtube z1ZUzmzv70c >}}

## Pengenalan HiSHtory

[HiSHtory][hishtory-gh] merupakan program yang menyimpan konteks history
terminal dari jam dan tanggal kapan perintah tersebut dieksekusi, lokasi
direktori yang aktif saat perintah dijalankan, dan seberapa lama perintah
tersebut dieksekusi. Informasi tersebut dapat disimpan secara lokal (per mesin)
ataupun terpusat (_clint-server architecture_).

Dengan kata lain, Anda dapat melakukan pencarian _shell pipeline_ yang
kompleks dari server atau mesin lain dengan mudah dari laptop atau salah satu
komputer Anda.

## Menggunakan HiSHtory secara Terpusat (self-hosted)

Di artikel ini, saya akan menggunakan 2 buah laptop dengan sistem opersai
Linux dengan detail sebagai berikut:

- hostname T420 dengan IP `192.168.2.22` akan bertugas sebagai server sekaligus
  client
- hostname P50 sebagai client

Perlu diperhatikan bahwa saya akan mengunakan HiSHtory server versi Docker,
sehingga pastikan komputer server sudah terinstall Docker dan dapat berjalan
dengan baik.

### Mengkonfigurasi HiSHtory Server

1. Login ke komputer server dan `clone` repositori
   [ddworken/hishtory][hishtory-gh] dan masuk ke direktori tersebut:

```shell
git clone https://github.com/ddworken/hishtory.git
cd hishtory
```

2.  Edit `backend/server/docker-compose.yml` dan sesuaikan konfigurasi sesuai
    kebutuhan. Karena saya menggunakan PostgreSQL sebagai database backend-nya,
    saya mengubah `POSTGRES_PASSWORD` dari `TODO_YOUR_POSTGRES_PASSWORD_HERE`
    ke `MyStrongPassword`. Karena saya mengubah konfigurasi default password
    Posgres, saya perlu menyesuaikan juga nilai dari environment variable
    `HISHTORY_POSTGRES_DB` sesuai dengan password yang sudah saya tentukan.
    Selain itu, karena port 80 pada server sudah saya gunakan untuk proses
    lain, saya mengubah listen port HiSHtory server di host machine dari
    port `80` ke port `45680`.
    ![HiSHtory backend docker-compose](hishtory-server-docker-compose.jpg#center)
    Kurang lebih konfigurasi `backend/server/docker-compose.yml` saya
    sebagai berikut:

```yml
version: "3.8"
networks:
    hishtory:
        driver: bridge
services:
    postgres:
        image: postgres
        restart: unless-stopped
        networks:
            - hishtory
        environment:
            POSTGRES_PASSWORD: MyStrongPass
            POSTGRES_DB: hishtory
            PGDATA: /var/lib/postgresql/data/pgdata
        volumes:
            - postgres-data:/var/lib/postgresql/data
        healthcheck:
            test: pg_isready -U postgres
            interval: 10s
            timeout: 3s
    hishtory:
        depends_on:
            postgres:
                condition: service_healthy
        networks:
            - hishtory
        build:
            context: ../../
            dockerfile: ./backend/server/Dockerfile
        restart: unless-stopped
        deploy:
            restart_policy:
                condition: on-failure
                delay: 3s
        environment:
            HISHTORY_POSTGRES_DB: postgresql://postgres:MyStrongPass@postgres:5432/hishtory?sslmode=disable
            HISHTORY_COMPOSE_TEST: $HISHTORY_COMPOSE_TEST
        ports:
            - 45680:8080
volumes:
    postgres-data:
```

3. Kemudian _build_ docker image dengan menjalankan perintah:

```shell
docker compose -f backend/server/docker-compose.yml build
```

4. Setelah proses build selesai, coba jalankan HiSHtory server menggunakan
   perintah:

```shell
docker compose -f backend/server/docker-compose.yml up
```

Tunggu beberapa saat dan pastikan HiSHtory server berjalan dengan baik. Hal
ini bisa di cek dengan menggunakan perintah `docker ps` atau melakukan
pengecekan langsung ke HiSHtory HTTP server: `curl -sIL http://127.0.0.1:45680`
(ubah dan sesuaikan IP:port dengan konfigurasi milik Anda).

### Mengkonfigurasi HiSHtory Client

Satu hal yang penting, karena kita akan menggunakan _self-hosted_, Anda
**perlu** menambahkan juga environment variable
`HISHTORY_SERVER=http://<ip>:<port>` ke `.bashrc` atau `.zshrc` Anda
(sesuaikan alamat IP dan port yang digunakan).

Selain itu, secara _default_, HiSHtory client akan terinstall di `~/.hishtory`.
Namun, supaya `$HOME` direktori saya lebih rapi, di artikel kali ini saya akan
menggunakan direktori `~/.config/hishtory`. Hal ini bisa dilakukan dengan
menambahkan `HISHTORY_PATH=.config/hishtory` ke `.bashrc` atau `.zshrc` Anda.

Sehingga kurang lebih `.bashrc` atau `.zshrc` saya ada tambahan konfigureasi
sebagai berikut:

```shell
export HISHTORY_PATH=.config/hishtory
# sesuaikan IP dan port di bawah ini dengan environment Anda
export HISHTORY_SERVER="http://192.168.2.22:45680"
```

Setelah envoronment variable diatas ditambahkan, reload sesi shell Anda,
kemudian download dan jalankan install script yang sudah tersedia:

```shell
curl https://hishtory.dev/install.py | python3 -
```

Script tersebut akan secara otomatis mengenerate device ID dan secret key Anda
serta berbagai konfigurasi dasar lainnya. Simpan secret key yang tampil
sehingga dapat Anda gunakan untuk sinkronisasi di komputer lain.

Untuk mengkonfigurasi pada komputer atau server kedua dan seterusnya, ulangi
proses diatas di masing-masing komputer atau server. Setelah proses installasi
hishtory menggunakan install script terakhir diatas selesai, jalankan perintah
berikut:

```shell
hishtory init $YOUR_HISHTORY_SECRET_FROM_FIRST_DEVICE
```

Ubah `$YOUR_HISHTORY_SECRET_FROM_FIRST_DEVICE` dengan secret key dari device
pertama.

> **Catatan**: Secret key juga bisa ditampilan dengan menjalankan perintah
> `hishtory status` dari device pertama.

Semoga membantu.

[hishtory-gh]: ttps://github.com/ddworken/hishtory "Repositori Official HiSHtory"
