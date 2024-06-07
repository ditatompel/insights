---
title: "Koneksi Ke Internet Modem Smart ZTE AC2726i pada Linux"
description: "Tutorial untuk melakukan koneksi ke internet dengan modem Smart Fren ZTE AC2726i (Dual Mode USB Modem) menggunakan wvdial."
summary: "Tutorial untuk melakukan koneksi ke internet dengan modem Smart Fren ZTE AC2726i (Dual Mode USB Modem) menggunakan wvdial."
date: 2012-09-08T19:40:46+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  -
categories:
#  -
tags:
  - BackTrack
  - wvdial
  - Linux
images:
authors:
  - ditatompel
---

Pada saat tutorial ini dibuat Saya menggunakan Distro **BackTrack**. Dan harusnya dapat bekerja juga di distro **Linux** lainnya.

Pertama, Anda harus [mendownload terlebih dahulu `usb_modeswitch`](https://www.draisberghof.de/usb_modeswitch/#download). Jika anda sudah memiliki koneksi internet (dengan **WiFi** misalnya), Anda cukup menjalankan perintah `wget` :

```bash
wget https://www.draisberghof.de/usb_modeswitch/usb_modeswitch-1.0.2.tar.bz2
```

Setelah proses mendownload selesai, _extract_ `usb_modeswitch-1.0.2.tar.bz2` yang baru saja Anda download.

```bash
tar -xjf usb_modeswitch-1.0.2.tar.bz2
```

Masuk ke folder `usb_modeswitch-1.0.2` dan install :

```bash
cd usb_modeswitch-1.0.2; sudo make install
```

dan Anda akan mendapatkan output kurang lebih seperti berikut :

```plain
[sudo] password for ditatompel:
mkdir -p /usr/sbin
install ./usb_modeswitch /usr/sbin
mkdir -p /etc
install ./usb_modeswitch.conf /etc
```

Terlihat bahwa ada 2 file terinstall : `usb_modeswitch` dan `usb_modeswitch.conf`. Edit `usb_modeswitch.conf` yang terletak pada folder `/etc`.

```bash
sudo nano /etc/usb_modeswitch.conf
```

tambahkan konfigurasi berikut yang mirip dengan konfigurasi modem **ZTE AC2710** (**EVDO**) oleh **Wasim Baig**

```plain
#########################################################
## ZTE AC2726i (EVDO)
DefaultVendor= 0x19d2
DefaultProduct= 0xfff5
TargetVendor= 0x19d2
TargetProduct= 0xfff1
MessageContent= "5553424312345678c00000008000069f010000000000000000000000000000"
```

Kemudian buka konfigurasi `wvdial` pada `/etc/wvdial.conf` dan edit file konfigurasinya :

> _\* Saya sarankan untuk selalu membackup konfigurasi anda sebelum melakukan modifikasi._

```bash
sudo nano /etc/wvdial.conf
```

Tambahkan konfigurasi berikut ini :

```plain
[Dialer smart]
Init1 = ATZ
Init2 = ATQ0 V1 E1 S0=0 &C1 &D2 +FCLASS=0
Modem Type = USB Modem
ISDN = 0
New PPPD = yes
Phone = #777
Modem = /dev/ttyUSB0
Username = smart
Password = smart
FlowControl = CRTSCTS
Carrier Check = No
Baud = 9600
```

Konfigurasi usb_modeswitch dan wvdial telah selesai.

Jalankan `usb_modeswitch` dari terminal untuk merubah product usb modem dari `fff5` ke `fff1`.

```bash
usb_modeswitch
```

Kemudian langkah selanjutnya yang perlu kita lakukan adalah mendeteksi **product id** dari modem yang kita gunakan:

```bash
sudo modprobe usbserial vendor=0x19d2 product=0xfff1
```

Terakhir jalankan perintah `wvdial`:

```bash
sudo wvdial smart
```

![wvdial Smart Fren](connect-internet-wvdial.png)
