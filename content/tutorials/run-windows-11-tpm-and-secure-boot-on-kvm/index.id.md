---
title: "Menjalankan Windows 11 (TPM Dan Secure-Boot) Di KVM"
description: "Cara mengaktifkan TPM dan secure-boot untuk menjalankan Windows 11 di QEMU/KVM."
# linkTitle:
date: 2022-09-19T03:57:12+07:00
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
#  - 
tags:
  - Windows
  - KVM
  - QEMU
  - libvirt
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

**Microsoft** memperketat keamanan dari **Windows 11** dengan menambahkan [**TPM**](https://support.microsoft.com/en-us/topic/what-is-tpm-705f241d-025d-4470-80c5-4feeb24fa1ee) dan [**Secure-Boot**](https://support.microsoft.com/en-us/windows/windows-11-and-secure-boot-a8ff1202-c0d9-42f5-940f-843abef64fad) sebagai kebutuhan minimal yang harus dipenuhi agar kita dapat menginstall Windows 11 baik itu *bare-metal* ataupun melalui virtualisasi.

Artikel ini membahas bagaimana mengaktifkan **TPM** dan **Secure-Boot** untuk Windows 11 di **QEMU** *virtual machine* (VM).

<!--more-->

## Prerequisites / Prasyarat
Sebelum memulai dan melangkah lebih jauh, Anda perlu memenuhi persyaratan berikut untuk dapat mengikuti langkah-langkah dari artikel ini:

* Memiliki ISO Windows 10. Anda dapat mengunduh [ISO Windows 11 *official*](https://www.microsoft.com/en-gb/software-download/windows11) dari situs resmi milik Microsoft.
* Memiliki dan mengunduh [*virtio driver* untuk Windows 11](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso) yang nantinya digunakan untuk menginstall driver pada *guest machine* (seperti **Ethernet controller**).
* *Host* yang sudah dikonfigurasi dan dapat menjalankan KVM dengan baik sebelumnya, termasuk program GUI `virt-manager` (**Virtual Machine Manager**).

Di artikel ini, *KVM host* saya menggunakan Arch Linux (BTW :joy:), namun langkah-langkah yang diperlukan agar dapat menjalankan Windows 11 menggunakan KVM sebenarnya tidak jauh beda dengan *distro* Linux lainnya.

## Install TPM pada Host KVM
Kita perlu menginstall software [swtpm](https://github.com/stefanberger/swtpm) di KVM host supaya KVM host dapat melakukan simulasi TPM.

Karena `swtpm` sudah tersedia di **Arch Linux Community package**, proses installasi cukup dengan menjalankan perintah `pacman -S swtpm`. Jika Anda mengunakan distro lain, carilah informasi cara menginstall `swtpm` di halaman dokumentasi dari distro favorit Anda.

Sebagai contoh, jika KVM host Anda menggunakan **Ubuntu**, Anda perlu menambahkan PPA milik [Stefan Berger's PPA repository](https://launchpad.net/~stefanberger/+archive/ubuntu/swtpm) sebelum melakukan installasi mengunakan `apt install swtpm-tools`.

Untuk mengecek apakah *swtpm* sudah berhasil diinstall dan melihat versi yang digunakan, cukup jalankan perintah `swtpm --version`: 
```
TPM emulator version 0.7.3, Copyright (c) 2014-2021 IBM Corp
```

## Buat Windows 11 di KVM menggunakan *virt-manager*
Buatlah VM baru untuk Windows 11 dari aplikasi / program GUI `virt-manager`, pada bagian **CDROM**, gunakan **Windows 11 ISO** yang sudah didownload dari situs resminya, tentukan alokasi CPU, RAM dan kapasitas penyimpanan sesuai kebutuhan dan kemampuan KVM host Anda. Dan pada bagian akhir *wizard configuration*, centang, tick ***"Costumize configuration before install"***.

## Konfigurasi virtualiasi hardware Windows 11
Supaya Windows 11 dapat berjalan dengan mulus di KVM, kita perlu membuat beberapa perubahan konfigurasi hardware dari *virt-manager*.

* Klik pada bagian **Overview**, ubah opsi **Firmware** ke `UEFI x86_64: /usr/share/edk2-ovmf/x64/OVMF_CODE.secboot.fd` (atau setidaknya pilih *firmware* yang mengandung kata **UEFI OVMF_CODE** atau **secboot**).

* Klik pada menu **Add Hardware** dan tambahkan `TPM`. Pastikan opsi `Type` adalah `Emulated`, kemudian ubah opsi `Model` dari `CRB` menjadi `TIS`, dan opsi `Version` menjadi `2.0`.  

![Menu konfigurasi virt-manager](kvm-win11-01-tpm.jpg#center "Menu konfigurasi virt-manager")

* Klik pada bagian **Network interface** dan ubah **Device model** dari `e1000e` menjadi `virtio`.

## Install Windows 11
Jalankan VM dan ikuti proses installasi Windows 11 hingga proses *initial Windows setup*. Pada tahap *initial Windows setup*, Anda akan mendapati bahwa VM Windows Anda tidak dapat terhubung ke internet.

Hal ini diebabkan karena Windows 11 belum dapat mendeteksi *Network Interface*nya. Sementara, abaikan dulu masalah tersebut karena kita bisa memperbaikinya nanti.

![Windows 11 install no internet connection](kvm-win11-02-no-network-iface.png#center "Windows 11 install no internet connection")

Klik ***"I don't have internet"*** kemudian ***"Continue with limited setup"*** dan selesaikan *initial setup* hingga kita berhasil login masuk ke Desktop.


## Install *virtio driver* pada VM Windows 11
Setelah proses installasi selesai, matikan dulu VM Windows 11 supaya kita bisa memperbaiki permasalahan pada ***Ethernet Driver***nya. Kemudian kembali ke konfigurasi VM di `virt-manager`, pilih **SATA CDROM 1**, dan ubah `Source path` dari yang semula adalah **ISO Windows 11** menjadi lokasi tempat **Windows 11 virtio drivers** dengan mengeklik tombol **Browse** dan pilih [Windows 11 virtio drivers](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso) yang sudah Anda download dan simpan di KVM host Anda.

Sekarang, nyalakan kembali VM Windows 11. Setelah berhasil login ke Desktop, klik pada **icon Search dari task bar**, dan masukkan kata kunci **"Device Manager"**. Anda akan menemukan program dengan nama **"Device Manager"**, jalankan program tersebut.
![Menu pilihan virtio drivers ISO](kvm-win11-03-virtio-driver.jpg#center "Menu pilihan virtio drivers ISO")

Di program **"Device Manager"**, klik kanan pada **Ethernet adapter** dan pilih **update driver**. Pilih menu **"Browse my computer for drivers"** kemudian pilih **Windows 11 virtio drivers ISO** dari **CDROM**, centang **"Include subfolders"**, klik tombol **"Next"** dan setelah itu seharunya *driver ethernet adapter* sudah berhasil diinstall. Cek koneksi internet di VM Windows 11 Anda, seharusnya Anda sudah terhubung ke internet dari VM Windows Anda.

