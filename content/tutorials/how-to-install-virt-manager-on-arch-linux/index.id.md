---
title: Cara Install Virt-Manager (Libvirt GUI) di Arch Linux
description: Tutorial cara instalasi Virt-Manager, sebuah libvirt GUI untuk mempermudah kita dalam melakukan manajemen mesin virtualiasi atau emulator (KVM/QEMU) di komputer kita.
summary: Tutorial cara instalasi Virt-Manager, sebuah libvirt GUI untuk mempermudah kita dalam melakukan manajemen mesin virtualiasi atau emulator (KVM/QEMU) di komputer kita.
date: 2024-09-11T03:08:45+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - Self-Hosted
    - SysAdmin
tags:
    - KVM
    - libvirt
    - QEMU
images:
authors:
    - ditatompel
---

Saya sudah beberapa kali menulis artikel yang berhubungan dengan
[**KVM**][kvm_web]/[**QEMU**][qemu_web] dan [**Virt-Manager**][virtmanager_web],
tapi saya belum punya tulisan tentang bagaimana cara menginstall dan
mengkonfigurasi Virt-Manager di Arch Linux. Maka ijinkan saya untuk
mendokumentasikannya disini.

**Virt-Manager** adalah GUI untuk `libvirt` yang dapat mempermudah kita dalam
melakukan manajemen mesin virtualiasi/emulator di komputer kita.

## Pengantar: Antara KVM dan QEMU

Sebelum memulai dan agar lebih memahami opsi apa saja yang nantinya bisa
digunakan di _virt-manager_, saya ingin sedikit membahas mengenai **KVM**
dan **QEMU**. Banyak orang beranggapan bahwa KVM dan QEMU adalah suatu hal
yang sama. Hal ini tidak benar.

**KVM merupakan _full-virtualization_** dimana dia menggunakan _hardware_ untuk
teknologi virtualisasinya. Agar dapat menggunakan tekologi KVM, CPU Anda harus
mensupport virtualisasi (dalam hal ini `Intel VT-x` untuk prosesor **Intel**
dan `AMD-V` untuk prosesor **AMD**).

Sedangkan **QEMU merupakan sebuah emulator**. Dia dapat melaukan emulasi sistem
secara penuh meskipun _hardware_ yang Anda miliki tidak mensupport virtualiasi.
QEMU dapat melakukan emulasi perangkat seperti _storage_, _network device_,
dan lain-lain. Dia juga dapat melakukan emulasi ke arsitektur CPU yang berbeda,
misalnya: host `x86_64` melakukan emulasi arsitektur ARM pada
_guest virtual machine_-nya.

Jika dilihat dari sisi performa, KVM jauh lebih unggul dibandingkan QEMU karena
KVM langsung menggunakan hardware. KVM juga sangat optimal untuk virtualiasi
sistem Linux dan menyediakan manajemen sumber daya yang lebih baik daripada
QEMU.

Dari segi kompatibilitas, QEMU lebih unggul karena dia dapat melakukan emulasi
ke banyak arsitektur CPU, emulasi ke perangkat seperti _storage_, _network_,
_display adapter_, dan lain-lain. QEMU juga tidak memerlukan hardware yang
mensupport teknologi virtualiasi untuk menjalankannya.

Untuk melakukan pengecekan apakah CPU yang Anda gunakan mensupport virtualisasi
dapat menggunakan perintah:

```shell
lscpu | grep Virtualization
```

Jika perintah diatas tidak menghasilkan output apapun, maka Anda hanya dapat
menggunakan QEMU.

Jika CPU Anda mensupport virtualiasi Anda dapat menggunakan KVM+QEMU yang
mengkombinasikan akselerasi hardware serta virtualiasi CPU dan RAM secara penuh.

> **Catatan**: Kebanyakan CPU _mid-range_ hingga _high-end_ yang diproduksi 10
> tahun terakhir seharusnya mensupport virtualisasi. Jika dari pengecekan
> `lscpu` diatas tidak menghasilkan apapun, silahkan cek konfigurasi BIOS dan
> mengaktifkan fitur tersebut.

## Instalasi Software Yang Dibutuhkan

Pertama, install `libvirt`, `dnsmasq`, `qemu-desktop` dan `virt-manager`:

```shell
sudo pacman -S libvirt dnsmasq qemu-desktop virt-manager
```

Disini, `dnsmasq` diperlukan untuk konektifitas jaringan untuk guest (DHCP).
Sedangkan `qemu-desktop` diperlukan untuk desktop GUI.

Jika Anda hanya menjalankan _virtual machine_ secara _headless_, Anda bisa
mengganti `qemu-desktop` dengan `qemu-base`. Baik `qemu-base` dan
`qemu-desktop` hanya support emulasi `x86_64`. jika Anda akan menggunakan
arsitektur seperti ARM di _virtual machine_, Anda perlu menginstall
`qemu-emulators-full`.

## Konfigurasi Hak Akses

Supaya user biasa dapat menggunakan `virt-manager`, tambahkan user Anda ke
group `libvirt` dengan perintah :

```shell
sudo usermod -aG libvirt <username_anda>
```

Kemudian ubah atau tambahkan konfigurasi berikut ke `/etc/libvirt/libvirtd.conf`:

```plain
unix_sock_group = "libvirt"
unix_sock_ro_perms = "0770"
```

konfigurasi diatas mengubah kepemilikan **libvirt UNIX socket** ke group
`libvirt` dan mereka yang berada di dalam group `libvirt` dapat melakukan
_read_ maupun _write_.

## Menggunakan Virt-Manager

Sebelum menjalankan GUI (`virt-manager`), jalankan `libvirtd` dengan perintah:

```shell
sudo systemctl start libvirtd
```

Hal ini supaya kita dapat menggunakan QEMU/KVM tidak pada **user session**
sehingga _guest machine_ nantinya dapat terkoneksi ke jaringan.

{{< youtube Y01SwRqkX8I >}}

Setelah _libvirt daemon_ berjalan, Anda bisa menjalankan `virt-manager` dan
mulai menambahkan koneksi `QEMU/KVM`. Setelah itu cobalah membuat
_virtual machine_ yang ingin dicoba. Jika mengalami kesulitan, mengikuti video
yang saya sertakan diatas mungkin sedikit banyak dapat membantu.

Untuk menjalankan Windows VM, Anda memerlukan `swtpm` dan mengkonfigurasi
TPM hardware. Silahkan baca artikel saya sebelumnya:
["Menjalankan Windows 11 VM (TPM dan Secure-Boot) di Linux"]({{< ref "/tutorials/run-windows-11-tpm-and-secure-boot-on-kvm" >}}).

## Referensi

-   [KVM Arch Wiki][kvm_aw]
-   [QEMU Arch Wiki][qemu_aw]
-   [Virt-Manager Arch Wiki][virtmanager_aw]

[kvm_web]: https://linux-kvm.org/page/Main_Page "KVM Website"
[kvm_aw]: https://wiki.archlinux.org/title/KVM "KVM Arch Wiki"
[qemu_web]: https://www.qemu.org/ "QEMU Website"
[qemu_aw]: https://wiki.archlinux.org/title/QEMU "QEMU Arch Wiki"
[virtmanager_web]: https://virt-manager.org/ "Virt-Manager official website"
[virtmanager_aw]: https://wiki.archlinux.org/title/Virt-manager "Virt Manager Arch Wiki"
