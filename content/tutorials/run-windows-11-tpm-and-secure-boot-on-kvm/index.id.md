---
title: "Menjalankan Windows 11 (TPM Dan Secure-Boot) Di KVM"
description: "Cara mengaktifkan TPM dan secure-boot untuk menjalankan Windows 11 di QEMU/KVM."
summary: "Cara mengaktifkan TPM dan secure-boot untuk menjalankan Windows 11 di QEMU/KVM."
# linkTitle:
date: 2022-09-19T03:57:12+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
series:
#  - Tutorial
categories:
#  -
tags:
    - Windows
    - KVM
    - QEMU
    - libvirt
images:
authors:
    - ditatompel
---

**Microsoft** memperketat keamanan dari **Windows 11** dengan menambahkan
[**TPM**][win_tpm] dan [**Secure-Boot**][win_secure_boot] sebagai kebutuhan
minimal yang harus dipenuhi agar kita dapat menginstall Windows 11 baik itu
_bare-metal_ ataupun melalui virtualisasi.

Artikel ini membahas bagaimana mengaktifkan **TPM** dan **Secure-Boot** untuk
Windows 11 di **QEMU** _virtual machine_ (VM).

## Prerequisites / Prasyarat

Sebelum memulai dan melangkah lebih jauh, Anda perlu memenuhi persyaratan
berikut untuk dapat mengikuti langkah-langkah dari artikel ini:

-   Memiliki ISO Windows 10. Anda dapat mengunduh
    [ISO Windows 11 _official_][win11_dl] dari situs resmi milik Microsoft.
-   Memiliki dan mengunduh [_virtio driver_ untuk Windows 11][virtio_win_iso]
    yang nantinya digunakan untuk menginstall driver pada _guest machine_
    (seperti **Ethernet controller**).
-   _Host_ yang sudah dikonfigurasi dan dapat
    [menjalankan KVM]({{< ref "/tutorials/how-to-install-virt-manager-on-arch-linux" >}})
    dengan baik sebelumnya, termasuk program GUI `virt-manager`
    (**Virtual Machine Manager**).

Di artikel ini, _KVM host_ saya menggunakan Arch Linux (BTW :joy:), namun
langkah-langkah yang diperlukan agar dapat menjalankan Windows 11 menggunakan
KVM sebenarnya tidak jauh beda dengan _distro_ Linux lainnya.

{{< youtube ik31RsNqMcw >}}

## Install TPM pada Host KVM

Kita perlu menginstall software [swtpm][swtpm_gh] di KVM host supaya KVM host
dapat melakukan simulasi TPM.

Karena `swtpm` sudah tersedia di **Arch Linux Community package**, proses
installasi cukup dengan menjalankan perintah `pacman -S swtpm`. Jika Anda
mengunakan distro lain, carilah informasi cara menginstall `swtpm` di halaman
dokumentasi dari distro favorit Anda.

Sebagai contoh, jika KVM host Anda menggunakan **Ubuntu**, Anda perlu
menambahkan PPA milik [Stefan Berger's PPA repository][swtpm_ppa] sebelum
melakukan installasi mengunakan `apt install swtpm-tools`.

Untuk mengecek apakah _swtpm_ sudah berhasil diinstall dan melihat versi yang
digunakan, cukup jalankan perintah `swtpm --version`:

```plain
TPM emulator version 0.7.3, Copyright (c) 2014-2021 IBM Corp
```

## Buat Windows 11 di KVM menggunakan _virt-manager_

Buatlah VM baru untuk Windows 11 dari aplikasi / program GUI `virt-manager`,
pada bagian **CDROM**, gunakan **Windows 11 ISO** yang sudah didownload dari
situs resminya, tentukan alokasi CPU, RAM dan kapasitas penyimpanan sesuai
kebutuhan dan kemampuan KVM host Anda. Dan pada bagian akhir
_wizard configuration_, centang **_"Costumize configuration before install"_**.

## Konfigurasi virtualiasi hardware Windows 11

Supaya Windows 11 dapat berjalan dengan mulus di KVM, kita perlu membuat
beberapa perubahan konfigurasi hardware dari _virt-manager_.

-   Klik pada bagian **Overview**, ubah opsi **Firmware** ke
    `UEFI x86_64: /usr/share/edk2-ovmf/x64/OVMF_CODE.secboot.fd` (atau
    pilih _firmware_ yang mengandung kata **UEFI OVMF_CODE** atau **secboot**).
-   Klik pada menu **Add Hardware** dan tambahkan `TPM`. Pastikan opsi `Type`
    adalah `Emulated`, kemudian ubah opsi `Model` dari `CRB` menjadi `TIS`,
    dan opsi `Version` menjadi `2.0`.

![Menu konfigurasi virt-manager](kvm-win11-01-tpm.jpg#center "Menu konfigurasi virt-manager")

-   Klik pada bagian **Network interface** dan ubah **Device model** dari
    `e1000e` menjadi `virtio`.

> Catatan: Jika Anda mengalokasikan _virtual_ CPU (vCPU) lebih dari satu,
> pastikan topologi CPU yang Anda konfigurasi mengunakan 1 socket. Hal ini
> dikarenakan Windows Home Edition hanya membaca maksimal 1 CPU socket,
> sedangkan Windows Pro Edition maksimal 2 CPU socket. Untuk informasi lebih
> detail bisa dilihat di
> [chart perbandingan edisi Windows][win_edition_comp_wiki].
>
> Jadi bermainlah pada CPU _cores_ dan _thread_, karena rata-rata
> _consumer hardware_ hanya memiliki 1 CPU socket
> (kecuali Anda menggunakan _mid-range_ / _high-end_ server).

## Install Windows 11

Jalankan VM dan ikuti proses installasi Windows 11 hingga proses
_initial Windows setup_. Pada tahap _initial Windows setup_, Anda akan
mendapati bahwa VM Windows Anda tidak dapat terhubung ke internet.

Hal ini diebabkan karena Windows 11 belum dapat mendeteksi
*Network Interface*nya. Sementara, abaikan dulu masalah tersebut karena kita
bisa memperbaikinya nanti.

![Windows 11 install no internet connection](kvm-win11-02-no-network-iface.png#center "Windows 11 install no internet connection")

Klik **_"I don't have internet"_** kemudian **_"Continue with limited setup"_**
dan selesaikan _initial setup_ hingga kita berhasil login masuk ke Desktop.

> **Catatan**: Di versi Windows terbaru (yang terakhir saya coba di iso
> `Win11_23H2_English_x64v2.iso`), tombol **_"I don't have internet"_** tidak tampil.
>
> ![BypassNRO.cmd](kvm-win11-oobe-bypassnro.jpg#center "BypassNRO.cmd")
>
> Untuk menampilkannya, tekan tombol <kbd>SHIFT</kbd> + <kbd>F10</kbd>. Untuk
> menampilkan _command prompt_ dan Ketikan `OOBE\BypassNRO.cmd` lalu tekan
> <kbd>ENTER</kbd>. Setelah itu komputer akan restart dan tombol
> **_"I don't have internet"_** akan muncul.

## Install _virtio driver_ pada VM Windows 11

Setelah proses installasi selesai, matikan dulu VM Windows 11 supaya kita bisa
memperbaiki permasalahan pada **_Ethernet Driver_**nya. Kemudian kembali ke
konfigurasi VM di `virt-manager`, pilih **SATA CDROM 1**, dan ubah
`Source path` dari yang semula adalah **ISO Windows 11** menjadi lokasi
tempat **Windows 11 virtio drivers** dengan mengeklik tombol **Browse** dan
pilih [Windows 11 virtio drivers][virtio_win_iso] yang sudah Anda download dan
simpan di KVM host Anda.

Sekarang, nyalakan kembali VM Windows 11. Setelah berhasil login ke Desktop,
klik pada **icon Search dari task bar**, dan masukkan kata kunci
**"Device Manager"**. Anda akan menemukan program dengan nama
**"Device Manager"**, jalankan program tersebut.

![Menu pilihan virtio drivers ISO](kvm-win11-03-virtio-driver.jpg#center "Menu pilihan virtio drivers ISO")

Di program **"Device Manager"**, klik kanan pada **Ethernet adapter** dan pilih
**update driver**. Pilih menu **"Browse my computer for drivers"** kemudian
pilih **Windows 11 virtio drivers ISO** dari **CDROM**, centang
**"Include subfolders"**, klik tombol **"Next"** dan setelah itu seharunya
_driver ethernet adapter_ sudah berhasil diinstall. Cek koneksi internet di VM
Windows 11 Anda, seharusnya Anda sudah terhubung ke internet dari VM Windows
Anda.

[win_tpm]: https://support.microsoft.com/en-us/topic/what-is-tpm-705f241d-025d-4470-80c5-4feeb24fa1ee "Apa itu TPM?"
[win_secure_boot]: https://support.microsoft.com/en-us/windows/windows-11-and-secure-boot-a8ff1202-c0d9-42f5-940f-843abef64fad "Windows 11 dan Secure Boot"
[win11_dl]: https://www.microsoft.com/en-gb/software-download/windows11 "Download Windows 11"
[virtio_win_iso]: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso "Windows 11 virtio driver"
[swtpm_gh]: https://github.com/stefanberger/swtpm "swtpm GitHub repository"
[swtpm_ppa]: https://launchpad.net/~stefanberger/+archive/ubuntu/swtpm "swtpm PPA repository"
[win_edition_comp_wiki]: https://en.wikipedia.org/wiki/Windows_10_editions#Comparison_chart "Windows Edition Comparison chart"
