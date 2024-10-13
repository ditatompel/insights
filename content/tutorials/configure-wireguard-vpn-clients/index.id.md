---
title: "Mengkonfigurasi WireGuard VPN Client"
description: "Informasi mengenai cara mengimport konfigurasi VPN WireGuard Anda ke Android, iOS, MacOS, Windows dan Linux."
summary: "Artikel ini berisi informasi mengenai cara untuk mengimport konfigurasi WireGuard VPN Anda ke Android, iOS/iPhone, MacOS, Windows dan Linux."
# linkTitle:
date: 2023-06-06T23:51:13+07:00
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
    - WireGuard VPN
categories:
    - Privasi
    - Networking
tags:
    - WireGuard
    - iPhone
    - Android
    - Linux
    - Windows
    - MacOS
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
    - vie
---

Artikel ini adalah bagian dari [seri **WireGuard VPN**](https://insights.ditatompel.com/id/series/wireguard-vpn/). Jika Anda belum membaca artikel sebelumnya dari seri ini, Anda mungkin akan tertarik untuk membaca [Cara Setup **VPN Server WireGuard** Sendiri]({{< ref "/tutorials/how-to-setup-your-own-wireguard-vpn-server/index.id.md" >}}) atau [Menginstall WireGuard-UI untuk Mengatur WireGuard Server Anda]({{< ref "/tutorials/installing-wireguard-ui-to-manage-your-wireguard-vpn-server/index.id.md" >}}).

Pada awalnya, [WireGuard](https://www.wireguard.com/) dirilis untuk **kernel Linux**, namun sekarang WireGuard sudah tersedia untuk **Windows**, **macOS**, **BSD**, **iOS**, dan **Android**. Saat Anda membeli **VPN WireGuard** dari penyedia layanan VPN, biasanya Anda akan menerima file konfigurasi (beberapa penyedia juga memberi gambar **QR Code**). File konfigurasi inilah yang Anda butuhkan untuk menyetting VPN WireGuard di perangkat Anda.

Untuk Windows, MacOS, Android, dan iOS, yang perlu anda lakukan adalah mengimport file konfigurasi yang diberikan oleh penyedia layanan VPN WireGuard ke [aplikasi official WireGuard](https://www.wireguard.com/install/). Untuk pengguna Linux yang menggunakan `wg-quick` bahkan jauh lebih mudah, yaitu cukup meletakkan file konfigurasi ke folder `/etc/wireguard`.

Meskipun cara mensettingnya cukup mudah, saya akan tetap menuliskan langkah-langkah untuk menginstall atau mengimport konfigurasi WireGuard disini untuk keperluan dokumentasi pribadi.

Konfigurasi WireGuard yang diberikan oleh penyedia layanan VPN atau Sistem Administrator Anda sebenarnya hanyalah sebuah _text_ file saja, biasanya akan terlihat seperti berikut:

```plain
[Interface]
Address = 10.10.88.5/32
PrivateKey = gJc2XC/D2op6Y37at6tW1Sjl8gY/O/O4Apw+MDzAZFg=
DNS = 1.1.1.1
MTU = 1450

[Peer]
PublicKey = dW7TUSnRylgpo+rbNr1a55Wmg1lCBgjYnluiJhDuURI=
PresharedKey = Ps4+a+xQfwKFBx+yWHKF7grUP3rzilOCQDftZ5A3z08=
AllowedIPs = 0.0.0.0/0
Endpoint = xx.xx.xx0.246:51822
PersistentKeepalive = 15
```

> _Bagian alamat IP dari `[Peer] Endpoint` diatas dihapus untuk alasan privasi dan keamanan._

## iPhone / iOS

Download [official WireGuard client untuk iOS dari App Store](https://apps.apple.com/us/app/wireguard/id1441195209?ls=1), pastikan bahwa aplikasi berasal dari **"[WireGuard Development Team](https://apps.apple.com/us/developer/wireguard-development-team/id1441195208)"**.

Kemudian Anda dapat mengimport konfigurasi dengan menekan tombol <kbd>+</kbd> yang terletak di sisi layar kanan atas dari aplikasi WireGuard.

### Menggunakan QR Code

1. Jika penyedia layanan VPN Anda memberikan gambar **QR Code** untuk konfigurasi WireGuardnya, pilih **"Create from QR code"** kemudian _scan_ gambar **QR Code** yang diberikan tersebut.
2. Ketika diminta untuk memasukan **name of the scanned tunnel** ([_contoh gambar_](wg-ios1.png)), isi saja dengan apapun yang bisa Anda ingat dengan mudah. _Hindari menggunakan karakter selain `-` dan `[a-z]`_. Profile koneksi VPN baru yang baru saja Anda tambahkan akan muncul di aplikasi WireGuard Anda.

### Menggunakan import file atau archive

1. Untuk mengimport konfigurasi dari file `.conf`, Anda perlu mendownload terlebih dahulu konfigurasi tersebut ke perangkat Anda.
2. Setelah konfigurasi tersebut terdownload ke perangkat Anda, pilih **"Create from file or archive"** dan import konfigurasi WireGuard Anda.
   _Ingat, hindari menggunakan karakter selain `-` dan `[a-z]` untuk **interface** **"name"**_.

Setelah konfigurasi berhasil diimport, cukup tap tombol **"_switch_ Active"** pada profile VPN ke **on** untuk mengkatifkan koneksi VPN [[_contoh gambar connected VPN WireGuard yang aktif di iOS_](wg-ios2.png)].

## Android

Download [official WireGuard client untuk Android dari Play Store](https://play.google.com/store/apps/details?id=com.wireguard.android),pastikan bahwa aplikasi berasal dari **"[WireGuard Development Team](https://play.google.com/store/apps/developer?id=WireGuard+Development+Team)"**.

Anda dapat mengimport konfigurasi dengan menekan tombol <kbd>+</kbd> yang terletak di sisi layar kanan bawah dari aplikasi WireGuard.

### Menggunakan QR Code

1. Jika penyedia layanan VPN Anda memberikan gambar **QR Code** untuk konfigurasi WireGuardnya, pilih **"Scan from QR code"** kemudian _scan_ gambar **QR Code** yang diberikan tersebut.
2. Ketika diminta untuk memasukan **Tunnel Name** ([_contoh gambar_](wg-android1.png)), isi saja dengan apapun yang bisa Anda ingat dengan mudah. _Hindari menggunakan karakter selain `-` dan `[a-z]`_. Profile koneksi VPN baru yang baru saja Anda tambahkan akan muncul di aplikasi WireGuard Anda.

### Menggunakan import file atau archive

1. Untuk mengimport konfigurasi dari file `.conf`, Anda perlu mendownload terlebih dahulu konfigurasi tersebut ke perangkat Anda.
2. Setelah konfigurasi tersebut terdownload ke perangkat Anda, pilih **"Import from file or archive"** dan import konfigurasi WireGuard Anda.
   _Ingat, hindari menggunakan karakter selain `-` dan `[a-z]` untuk **interface** **"name"**_.

Setelah konfigurasi berhasil diimport, cukup tap tombol **"_switch_ Active"** pada profile VPN ke **on** untuk mengkatifkan koneksi VPN [[_contoh gambar connected VPN WireGuard yang aktif di Android_](wg-android2.png)].

## Windows dan MacOS

Saya meletakan Windows dan MacOS di sesi yang sama karena mengimport konfigurasi WireGuard untuk sistem operasi Windows dan MacOS cukup mirip. Setelah aplikasi [official WireGuard](https://www.wireguard.com/install/) terinstall:

1. Klik tombol "**Add Tunnel**" (atau pada _icon dropdown_-nya) dan "**Import tunnel(s) from file...**", kemudian pilih file konfigurasi WireGuard Anda.
2. Setelah berhasil melakukan konesi VPN WireGuard, coba lakukan pengecekan alamat IP publik Anda. Jika semua konfigurasi benar, maka IP VPN server Anda yang seharusnya tampil saat pengecekan, bukan IP dari ISP Anda.
   ![Koneksi VPN WireGuard di Windows](wg-windows-connected.png#center)

## Linux

Untuk pengguna Linux, Anda perlu menginstall _package_ `wireguard` ke sistem Anda. Cari tahu [bagaimana cara menginstall WireGuard dari situs resmi WireGuard](https://www.wireguard.com/install/) atau dari halaman dokumentasi _distro_ yang Anda gunakan.

### Menggunakan wg-quick

Cara paling mudah dan paling _simple_ untuk menggunakan WireGuard adalah dengan menggunakan `wg-quick` yang tersedia setelah Anda menginstall _package_ `wireguard`. Letakkan file konfigurasi WireGuard dari penyedia layanan VPN Anda ke `/etc/wireguard` dan lakukan koneksi ke VPN server menggunakan perintah berikut:

```shell
sudo systemctl start wg-quick@<interface-name>.service.
```

Ubah `<interface-name>` diatas dengan nama file (tanpa ekstensi `.conf`) dari konfigurasi WireGuard yang diberikan oleh penyedia layanan VPN Anda.

Sebagai contoh, jika Anda mengubah nama file `wg0.conf` ke `wg-do1.conf` yang berada di folder `/etc/wireguard`, Anda bisa melakukan koneksi ke VPN server menggunakan perintah `sudo systemctl start wg-quick@wg-do1.service`.

Cobalah melakukan pengecekan koneksi WireGuard dengan mengecek alamat IP publik Anda dari browser atau terminal (`curl ifconfig.me`). Jika alamat IP yang terdeteksi masih alamat IP dari ISP yang Anda gunakan, perintah pertama untuk melakukan _troubleshot_ adalah `sudo wg show` atau `sudo systemctl status wg-quick@wg-do1.service`.

> _**Catatan 1**: Secara default, `wg-quick` menggunalan `resolvconf` untuk memasukan entri **DNS** baru. Hal ini akan menimbulkan masalah dengan **network manager** dan **DHCP client** yang tidak menggunakan `resolvconf`, karena mereka akan menulis ulang entri DNS di `/etc/resolv.conf` (yang akan menghapus DNS server yang telah ditambahkan oleh perintah `wg-quick`)._  
> _Solusinya adalah dengan menggunakan software network manager yang mensupport `resolvconf`._

> _**Catatan 2**: Pengguna `systemd-resolved` harus memastikan bahwa `systemd-resolvconf` terinstall dan berjalan dengan baik._

### Mengunakan NetworkManager

**NetworkManager** pada _bleeding-edge_ atau _rolling release distro_ seperti **Arch Linux** sudah mensupport WireGuard VPN secara _native_.

#### Menggunakan NetworkManager TUI & GUI

![NetworkManager tui](wg-nmtui.png#center)

Anda dapat dengan mudah mengkonfigurasi koneksi WireGuard dan _peers_-nya menggunakan **NetworkManager TUI** atau **GUI**. Pada contoh ini, saya akan menggunakan **NetworkManager GUI**.

1. Buka **NetworkManager** GUI, klik <kbd>+</kbd> untuk menambahkan koneksi.
2. Pilih "**Import a saved VPN configuration**" import konfigurasi WireGuard Anda.
3. Kemudian, Anda dapat mengubah "**Connection name**" dan "**Interface name**" ke apapun yang bisa Anda ingat dengan mudah. Tapi, **Hindari menggunakan karakter selain `-` dan `[a-z]`** untuk "**Interface name**". Koneksi tidak akan berjalan jika Anda menggunakan karakter spesial seperi _spasi_.

![NetworkManager gui](wg-nmgui.png#center)

#### Menggunakan nmcli

`nmcli` dapat mengimport konfigurasi `wg-quick`. Sebagai contoh, untuk mengimport konfigurasi WireGuard dari `/etc/wireguard/t420.conf`:

```shell
nmcli connection import type wireguard file /etc/wireguard/t420.conf
```

Meskipun `nmcli` dapat membuat profil koneksi WireGuard, tetapi ia tidak mendukung konfigurasi untuk _peer_. Berikut ini adalah contoh konfigurasi WireGuard melalui format `.nmconnection` file yang ada pada folder `/etc/NetworkManager/system-connections/` untuk _multiple peers_ dan _custom routing_:

```plain
[connection]
id=WG-<redacted>
uuid=<redacted-uuid-string>
type=wireguard
autoconnect=false
interface-name=wg-<redacted>
timestamp=1684607233

[wireguard]
private-key=<redacted_base64_encoded_private_key>

[wireguard-peer.<redacted_base64_encoded_public_key>]
endpoint=<redacted_ip_address>:<redacted_port>
persistent-keepalive=15
allowed-ips=0.0.0.0/0;

[wireguard-peer.<redacted_base64_encoded_public_key>]
endpoint=<redacted_ip_address>:<redacted_port>
persistent-keepalive=15
allowed-ips=<redacted_specific_ip_network_routes_separated_by_semicolon>

[ipv4]
address1=10.10.88.2/24
dns=192.168.1.105;192.168.1.252;
method=manual

[ipv6]
addr-gen-mode=stable-privacy
method=ignore
```

![nmcli wireguard connection example](wg-nmcli.png#center)

## Catatan

-   Anda tidak dapat melakukan koneksi ke VPN server yang sama dari 2 perangkat atau lebih dengan **key** yang sama. **Setiap perangkat HARUS memiliki _key_ yang unik**.
-   Untuk beberapa sistem operasi seperti Windoes, jika Anda tidak dapat mengimport konfigurasi WireGuard Anda ke aplikasi WireGuard, pastikan bahwa file konfigurasi Anda berekstensi `.conf`.

