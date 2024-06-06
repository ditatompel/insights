---
title: "Membuat Lab Virtualisasi Pada Jaringan Lokal Dengan VirtualBox (2012)"
description: "Memanfaatkan VirtualBox untuk membangun lab virtualisasi pada jaringan lokal."
summary: "Memanfaatkan VirtualBox untuk membangun lab virtualisasi  pada jaringan lokal."
# linkTitle:
date: 2012-12-21T20:40:14+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
series:
#  - Tutorial
categories:
  - SysAdmin
tags:
  - VirtualBox
  - Linux
  - MySQL
images:
authors:
  - ditatompel
---

Belakangan ada beberapa teman yang bertanya dan tertarik untuk belajar _build_ server. Kebanyakan dari mereka berfikir bahwa untuk belajar build server / maintenance server itu butuh **VPS** atau bahkan _dedicated server_. Apa bener begitu? Padahal harga untuk **VPS** untuk ukuran sebagian mahasiswa dirasa cukup tinggi, apa lagi _dedicated server_.

Sebenarnya kalau kita hanya ingin belajar, tidak harus sewa **VPS**, awal2 kita bisa manfaatkan yang namanya _virtualisasi_. (namanya belajar jadi ga perlu kan _IP public_ yang bisa diakses siapa saja, makanya kita gunakan jaringan dan IP lokal).

Ada banyak jalan untuk melakukan virtualisasi ini, ada **OpenVZ**, **VirtualBox**, **Xen**, **VMware**, dll. dari **para-virtualisasi** sampai **full-virtualisasi**, dari versi _community_ (gratis) sampai _enterprise_ (berbayar). Masing-masing ada kelebihan dan kekurangan (dan saya ga mau berdebat masalah ini).

kali ini saya menggunakan **VirtualBox**, Karena sudah banyak user yang menggunakan **VirtualBox** pada komputer pribadinya. Sebelum melanjutkan, saya informasikan dulu situasi dan kondisi pada saat _guide_ ini dibuat.

- **Subnet**: `/24`
- **Gateway** : `192.168.0.2`
- **Host OS** : IP=`192.168.0.242` OS=`Linux`

Taruh kata saya ingin membuat **2 virtual server**, 1 untuk _database server_ (**MySQL server**) dan 1 sever lainnya untuk apa juga belum terpikirkan. ;p

Jadi yang dibutuhkan :

- **VirtualBox** dengan _module_ `vboxnetfit`
- **ISO CentOS 6.x netinstall**
- Koneksi Internet

Video:
{{< youtube r5s8lBDNBXI >}}

## Part 1: Setting Guest Hosts (virtual server)

Pertama kita pastinya butuh **VirtualBox**. Silahkan yang belom punya download dulu. Kemudian module `vboxnetfit` untuk _bridged adapter_ ke _virtual server_. Kemungkinan Anda juga butuh module `vboxdrv` (optional buat jalanin custom _kernel_) Aktifinnya tinggal `modprobe` [nama_module].

Jika sudah mari kita jalankan VirtualBox dan buat virtual hostnya. Caranya klik Icon New di kiri atas, lalu masukan informasi nama dan OS yang digunakan. Misalnya:

- **Name** : CentOS Contoh Server III
- **Type** : Linux
- **Version** : RedHat (32/64 sesuai CPU Host)

Kemudian tekan tombol Next.

![Add New VirtualBox Host](feature-virtual-lab-jar-lokal-01.png#center)

berikutnya menentukan kapasitas **RAM** yang nantinya dipake sama _virtual server_, kasi aja **512MB**, klo udah tekan tombol next lagi.

![VirtualBox Set Guest RAM](virtual-lab-jar-lokal-02.png#center)

Selanjutnya buat virtual HDD, pilih opsi ke 2 **"Create a virtual hard drive now"** kemudian tekan next.

![VirtualBox Set Guest Virtual HDD](virtual-lab-jar-lokal-03.png#center)

Setelah itu keluar lagi pilihan buat tipe hard drivenya. Klo nantinya tidak ingin memindah ke virtualisasi lain pilih saja _default_ **VDI**. Tp kali ini saya pilih **QEMU** biar **dikira** _dewa_. Klo udah tekan tombol **Create**.

![VirtualBox Set Guest Virtual HDD Type](virtual-lab-jar-lokal-04.png#center)

nanti di sebelah kiri ada _list Virtual Guest_ yang pernah dibuat. Klik kanan pada menu yang baru aja kita buat dan pilih **"Setting"**.

Pada menu **Storage** => **Controller IDE** pilih image file yang digunakan. Ane pake **ISO CentOS 6.2 Netinstall 64 Bit**.

![VirtualBox Set Guest OS](virtual-lab-jar-lokal-05.png#center)

kemudian pada menu **Network** -> **Adapter 1** Ubah **Attached to** dari **NAT** ke **Bridged Adapter**. Name nya sesuaikan dengan interface yang sedang digunakan (dalam kasus saya : `eth0`).

![VirtualBox Set Bridged Adapter](virtual-lab-jar-lokal-06.png#center)

klo udah klik **Ok**, lalu Start **Virtual Guest**nya.

Nah proses installasi sama aja ky install OS biasa.

Media Installation OS ane pilih URL _biar dikira admin_.

![Linux install method](virtual-lab-jar-lokal-07.png#center)

Yang perlu diperhatikan adalah : Gunakan Alamat _IP statik_/_DHCP Statik_ dari _router_, jangan dinamis. Karena jika IP dinamis kita bakal susah ngeremote terutama masalah _fingerprint_ SSH.

![Linux install IP setting](virtual-lab-jar-lokal-08.png#center)

Kali ini ane kasi IP `192.168.0.152`, Gateway `192.168.0.2` dan DNS server google (`8.8.8.8`).

lalu isikan URL image **CentOS**, ane pake `mirror.nus.edu.sg`, silahkan nte bisa ganti lewat `kambing.ui.ac.id` / apa lah itu. Yang jelas sesuain ama arsitektur yang nte gunain. misal (`http://kambing.ui.ac.id/centos/6.3/os/x86_64` buat yang pake **64 bit**).

![Linux URL setup](virtual-lab-jar-lokal-09.png#center)

kemudian klik ok dan tunggu proses installasi selesai; maka nte akan disuruh buat nge*reboot* OS.

**Reboot**/**Poweroff** virtual guest tadi. Kita edit **primary boot**nya dari **CD-ROM** ke **Hard Disk**. Caranya :

**Setting** -> **System** -> **Motherboard** -> **Boot Order** -> Naikin menu **Hard Disk** ke posisi pertama / hilangkan centang pada **Floppy** dan **CD/DVD-ROM**.

![VirtualBox Boot Order](virtual-lab-jar-lokal-10.png#center)

klo udah coba jalanin lagi Virtual Guestnya. Nte bisa pake **CLI** supaya virtual host yang bisa jalan di background. Caranya :

Pertama tampilin dulu list Virtual Guestnya dengan perintah : `VBoxManage list vms`.
![VBoxManage list vms](virtual-lab-jar-lokal-11.png#center)

Lalu jalankan perintah berikut untuk menjalankan virtual guest di background : `VBoxManage startvm "nama virtual machine" --type=headless`. Misalnya:

```bash
VBoxManage startvm "CentOS Contoh Server III" --type=headless
```

Kalau udah jalan coba `ping` ke IP virtual guest yang tadi kita buat (`192.168.0.152`), tunggu sampai up dan masuk melalui **SSH**.

```bash
ssh root@192.168.0.152
```

Dari sana nte bisa setting nama hostname, update software, dll.

## Part 2: Install Guest Host lain

Ulangi **Part 1** untuk membuat _Virtual Guest_ lain sehingga kita punya 2 _virtual host_ dan di-_run_ bersamaan dengan _option headless_ tadi. Beri virtual guest ke 2 ini dengan IP `192.168.0.151`. Sebagai contoh virtual guest ke 2 kali ini kita gunakan untuk database server.

Di Virtual Guest yang ke-2 ini, install MySQL Server :

```bash
yum install mysql mysql-devel mysql-server
```

Start mysql server

```bash
service mysqld start
```

settting ulang mysql servernya dengan menjalankan perintah `/usr/bin/mysql_secure_installation`. Maka bakal ada pertanyaan interaktif untuk menyetting ulang MySQL server.

kemudian masuk ke MySQL server dengan user `root` untuk membuat user dan database baru.

```bash
mysql -h localhost -u root -p
```

maka nte bakal disuruh isi password mysqlnya untuk user root. Setelah masuk buat user baru:

```bash
CREATE USER 'ditatompel'@'192.168.0.%' IDENTIFIED BY 'password';
```

dimana:

- `ditatompel` adalah **nama user**nya
- `192.168.0.%` adalah nama hostname/IP dari mana dia melakukan remote koneksi ke MySQL server. (`192.168.0.%` sama saja dengan `192.168.0.0/24`)
- `password` adalah password yang digunakan.

```sql
CREATE DATABASE IF NOT EXISTS db_testing;
```

dimana `db_testing` adalah nama database yang nanti kita gunakan.

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON db_testing.* TO 'ditatompel'@'192.168.0.%';
```

dimana `SELECT`, `INSERT`, `UPDATE`, `DELETE` adalah permission milik user `ditatompel` dari host `192.168.0.%` pada semua `table` dalam database `db_testing` ( `db_testing`.`*` ) kemudian jangan lupa untuk melakukan **flush privileges**.

```sql
FLUSH PRIVILEGES;
```

Kalau sudah pastikan juga port **MySQL** (_default_ `3306`) tidak di block oleh _firewall_.

![iptables](virtual-lab-jar-lokal-12.png#center)

Setelah itu coba melakukan koneksi ke server MySQL dari virtual guest yang 1 nya atau dari PC kita.

```bash
mysql -h 192.168.0.151 -u ditatompel -p
```

dimana `192.168.0.151` adalah alamat IP server MySQL dan `ditatompel` adalah user yang kita buat pada server MySQL sebelumnya.

![iptables](virtual-lab-jar-lokal-13.png#center)

> _**Q** : Om, klo mau bikin 5 virtual guest dan RAM laptop / PC ane cuma 1GB kan ga mungkin, trus gimana ?_

**A** : Nte pake / bawa pulang laptop temen, colokin ke 1 network dan jalanin virtualbox, lakuin langkah2 di atas. Klo nte ada 4 laptop dan per laptop nte jalanin 3 Virtual guest berarti nte punya 12 virtual guest.

Jadi intinya begitu semua sudah terhubung dan dapat berkomunikasi, beres udah. Nte bisa juga testing buat belajar _port knocking_, config _firewall_, **IDS/IPS**, _load balancing_ sampai _clustering_. meskipun hasilnya masih sangat jauh dari maksimal.
