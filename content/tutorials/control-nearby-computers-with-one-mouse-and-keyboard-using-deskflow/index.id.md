---
title: Mengontrol Komputer Lain di Jaringan Dengan Satu Mouse dan Keyboard Menggunakan Deskflow
description: Cara menginstall, mengonfigurasi, dan menggunakan Deskflow di Linux. Sebuah aplikasi open-source ntuk sharing keyboard dan mouse dengan komputer lain.
summary: Cara menginstall, mengonfigurasi, dan menggunakan Deskflow di Linux. Sebuah aplikasi open-source ntuk sharing keyboard dan mouse dengan komputer lain.
date: 2024-09-23T23:23:00+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - TIL
tags:
    - Deskflow
images:
authors:
    - ditatompel
---

Ada banyak cara untuk mengontrol dekstop (GUI) komputer lain melalui jaringan,
misalnya menggunakan RDP atau VNC. Kadang kala saya menggunakan
_X11 Forwarding_ juga untuk menjalankan sebuah aplikasi GUI dari remote
komputer ke laptop saya. Sedangkan untuk kontrol GUI yang lebih kompleks,
saya menggunakan [xrdp][xrdp_gh].

Tapi mungkin kedepannya cara saya untuk melakukan control desktop komputer lain
di jaringan lokal akan berbeda setelah saya menemukan [Deskflow][deskflow_gh].
Deskflow adalah sebuah aplikasi _open source_ (_upstream_ dari
[Synergy][synergy_web], komersial) untuk sharing keyboard dan mouse dengan
komputer lain. Dengan Deskflow, satu keyboard dan trackpad dari laptop saya
bisa saya gunakan untuk mengontrol desktop komputer lain.

Berbeda dengan RDP atau VNC yang menampilkan tampilan remote desktop ke
PC / laptop kita; Deskflow sama sekali tidak menampilkan apapun dari remote
desktop. Jika disederhanakan, Deskflow hanya merekam dan meneruskan mouse,
keyboard dan clipboard ke komputer lain (client). Jadi Deskflow efektif jika
remote desktop (client) memiliki monitor dan monitor tersebut berada di dekat
Anda (ibaratkan Anda memiliki multiple monitor, tapi dari PC yang berbeda).

## Instalasi

{{< youtube JiTIDnD1clM >}}

Saat tulisan ini dibuat, Deskflow **belum tersedia** di _package manager_
seluruh distro Linux. Deskflow juga tidak menyediakan _pre-compiled binary_
baik untuk Linux, MAC, maupun Windows. Jadi satu-satunya cara untuk menginstall
dan menjalankan Deskflow adalah meng-compile dari source code-nya.

> **UPDATE**: Proses build telah berubah sejak tulisan ini dibuat. Bagi
> pengguna Linux, rilis terbaru sudah penyertakan paket untuk Debian, Fedora,
> dan OpenSUSE. Silahkan kunjungi [halaman rilis
> terbaru][deskflow-release-page] mereka. Untuk Distro Arch, Deskflow sudah
> berada di repositori `extra`, jadi Anda dapat menginstallnya dengan mudah
> menggunakan `pacman -S deskflow`.

Meskipun begitu, Anda tidak perlu khawatir karena sudah tersedia
_"install / helper"_ script untuk sebagian besar distro (Debian, Fedora,
OpenSUSE, dan Arch Linux).

Di artikel ini, saya akan menggunakan 2 buah komputer (semuanya menggunakan
sistem operasi Linux):

-   P50: Komputer utama saya yang akan saya gunakan untuk mengontrol komputer
    lain (server).
-   T420: Komputer lain yang akan saya kontrol dari P50 (client).

Pertama, download source code Deskflow dan
[compile aplikasi Deskflow][deskflow_cmp] di server dan client:

```shell
git clone https://github.com/deskflow/deskflow.git
cd deskflow
./scripts/install_deps.sh
cmake -B build
cmake --build build -j$(nproc)
```

Setelah proses kompilasi berhasil, pastikan _unit test_ dan _integrity test_
berjalan dengan baik:

```shell
./build/bin/unittests
./build/bin/integtests
```

## Konfigurasi

### Server

Di komputer server, jalankan `./build/bin/deskflow`, kemudian pilih
_"Use this computer's keyboard and mouse"_.

![deskflow server](deskflow-server1.png#center)

Untuk mempermudah penggunaan aplikasi Deskflow, kita bisa membuat
[XDG Desktop Entry][xdg_desktop_spec] dengan meng-copy file
`.res/dist/linux/deskflow.desktop` ke `~/.local/share/applications`
(untuk single user) atau `/usr/share/applications` untuk multi user.
Jangan lupa sesuaikan nilai dari `Path=/usr/bin` dan `Exec=/usr/bin/deskflow`
yang ada pada file tersebut ke direktori dimana file binary deskflow disimpan.

### Client

Di komputer client, jalankan `./build/bin/deskflow` kemudian pilih
_"Use another computer's mouse and keyboard"_ dan masukkan alamat IP server ke
input text dibawahnya.

> Catatan: Entah kenapa untuk pertama kali mencoba melakukan koneksi ke server,
> saya tidak bisa melakukannya dari X11 Forwarding. Jadi saya harus melakukan
> koneksi awal langsung dari GUI laptop client (bukan dari GUI X11 Forwarding).

![deskflow client](deskflow-client1.png#center)

Setelah mencoba melakukan koneksi dari sisi client, akan muncul _pop-up window_
di komputer server yang menginformasikan bahwa ada "client" baru ingin
melakukan koneksi. Pilih _"Add client"_.

![deskflow add client popup](deskflow-add-client-popup.png#center)

Setelah itu Anda dapat memilih layout dimana posisi komputer client dapat kita
kontrol (seperti ketika menggunakan dual monitor).

![deskflow layout](deskflow-layout.png#center)

Klik "Ok" dan cobalah untuk menggeser posisi mouse pointer ke arah dimana Anda
mengkonfigurasi posisi komputer client. Seharusnya Anda sudah dapat menggunakan
mouse dan keyboard komputer server untuk komputer client.

> Tips: Setelah client ter-registrasi ke server, Anda dapat secara manual
> melakukan koneksi dari client menggunakan CLI dengan
> `deskflowc --enable-crypto [alamat ip server]`.

## Referensi

-   Deskflow Project: [github.com/deskflow/deskflow][deskflow_gh]

[xrdp_gh]: https://github.com/neutrinolabs/xrdp "xrdp GitHub repository"
[deskflow_gh]: https://github.com/deskflow/deskflow "Deskflow GitHub repository"
[deskflow-release-page]: https://github.com/deskflow/deskflow/releases/latest "Deskflow GitHub release page"
[synergy_web]: https://symless.com/synergy "Synergy Website"
[deskflow_cmp]: https://github.com/deskflow/deskflow/blob/master/BUILD.md "Deskflow Build Quick Start"
[xdg_desktop_spec]: https://specifications.freedesktop.org/desktop-entry-spec/latest/ "XDG Desktop Entry spec"
