---
title: "Cara Setup VPN Server WireGuard Sendiri"
description: "Tutorial cara bagaimana men-setup server VPN WireGuard sendiri menggunakan VPS server seharga 6 dolar"
summary: "Cukup menggunakan VPS seharga _6 dolar_ per bulan, Anda bisa memiliki VPN server sendiri menggunakan WireGuard VPN."
# linkTitle:
date: 2023-06-05T19:04:57+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: true
# comments: false
nav_weight: 1000
series:
    - WireGuard VPN
categories:
    - Privasi
    - SysAdmin
    - Networking
    - Self-Hosted
tags:
    - VPN
    - WireGuard
images:
authors:
    - ditatompel
    - vie
---

Cukup menggunakan VPS seharga _6 dolar_ per bulan, Anda bisa memiliki **VPN** server sendiri menggunakan **WireGuard VPN**. Ikuti caranya di artikel berikut ini untuk menginstall, dan mensetting VPS **Ubuntu 22.04** menjadi **VPN server** Anda.

Setelah [beberapa seri artikel tentang **VPN IPsec**](https://insights.ditatompel.com/en/series/ipsec-vpn/) (dalam bahasa Inggris), hari ini saya ingin berbagi bagaimana cara mensetting [**WireGuard VPN**](https://www.wireguard.com/) sebagai server VPN. Jika dibandingkan dengan [L2TP/xAuth](https://insights.ditatompel.com/en/tutorials/ipsec-l2tp-xauth-ikev2-vpn-server-auto-setup/) dan [IKEv2 VPN](https://insights.ditatompel.com/en/tutorials/set-up-ikev2-vpn-server-and-clients/) (artikel saya sebelumnya tentang **IPsec VPN** dalam bahasa Inggris), dari sisi performa, **WireGuard VPN jauh lebih unggul** karena menggunakan **UDP** dan bukan **TCP**.

## Prasyarat

-   Sebuah **VPS** dengan alamat IP publik.
-   Nyaman dan terbiasa dengan Linux _command-line_.
-   Pengetahuan dasar _subnetting_ di **IPv4** (_jujur saja, sayya tidak begitu familiar dengan subnetting di IPv6, jadi artikel ini hanya untuk IPv4_).

Untuk pemilihan _cloud provider_ mana yang akan Anda gunakan, itu terserah Anda. Di artikel ini, saya akan mengguakan **Droplet** di [**DigitalOcean**](https://m.do.co/c/42d4ba96cc94) (_referral link_) untuk VPN server saya. (Anda bisa mendapatkan kredit sebesar 200 dolar yang valid untuk 60 hari secara cuma-cuma dengan menggunakan _link_ referensi saya).

> _**CATATAN**: Anda harus tahu bahwa **cloud provider biasanya membebankan biaya *extra* jika Anda melebihi batasan quota** yang telah mereka berikan._

> _VPS server yang saya gunakan untuk artikel ini akan saya hapus ketika artikel ini dipublikasikan._

## Memesan dan Menjalankan VPS Baru (DigitalOcean Droplet, opsional)

> _Jika Anda sudah memiliki VPS, Anda bisa lompati langkah pada sesi ini dah langsung menuju langkah berikutnya: "[Setup WireGuard Server](#setup-wireguard-server)._

1. Masuk ke _project_ Anda dan buat **Droplet** baru dengan memilih **Create new Droplet**.
2. Untuk menghindari _latency_ yang tinggi, **pilihlah region yang paling dekat dengan lokasi Anda**. Jika Anda di Indonesia, maka saat ini region terdekat di DigitalOcean adalah Singapore. Namun untuk tutorial kali ini saya ingin mencoba menggunakan Droplet yang lokasinya berada di Frankfurt.
3. Pilih sistem operasi untuk Droplet Anda, saya akan menggunakan **Ubuntu** `22.04 LTS`.
4. Pilih paket (**Droplet size**). Saya akan mulai dari yang rendah saja, **1 CPU** dengan **1GB of RAM** dan **bandwidth 1TB per bulan** ($6/bulan).  
   Sesuaikan paket / _Droplet Size_ yang sesuai dengan kebutuhan Anda untuk menghindari kemungkinan terkena biaya ekstra atas pemakaian bandwidth yang melebihi kapasitas paket (1TB per bulan cukup untuk saya).
5. Pilih metode autentikasi Anda untuk mengakses VPS, Saya lebih memilih menggunakan **SSH _public_ dan _private key_** daripada menggunakan authentikasi menggunakan _password_.
6. Untuk opsi sisanya, biarkan _default_ apa adanya. _Saya yakin **Anda tidak memerlukan opsi backup dan managed database** untuk VPN server ini._

> _**WireGuard** tidak membutuhkan **disk I/O** yang tinggi, jadi **VPS NVMe** tidak begitu penting (**SSD** sudah sangat cukup)._

## Setup WireGuard Server

> _**CATATAN PENTING**: Karena saya tidak begitu familiar dengan subnetting di **IPv6**, saya hanya akan menggunakan **IPv4** saja._

Setelah VPS kamu sudah siap dan sudah berjalan, saya sarankan untuk melakukan update OS terlebih dahulu menggunakan perintah `apt update && apt upgrade`, kemudian _restart_ (`reboot`) VPS anda.

> _Jika Anda ingin bisa mengatur **WireGuard** peers (client) di server Anda dengan mudah, Anda mungkin tertarik untuk membaca "[Cara install WireGuard-UI untuk mengatur server VPN WireGuard dengan mudah]({{< ref "/tutorials/installing-wireguard-ui-to-manage-your-wireguard-vpn-server/index.id.md" >}})"._

### Install WireGuard

Install WireGuard dengan menggunakan perintah `sudo apt install wireguard`. Setelah WireGuard berhasil diinstall, kita perlu membuat _private_ dan _public key_ untuk WireGuard server kita.

> _Tips: Anda bisa membuat public key yang cantik (**vanity address**) untuk **WireGuard** menggunakan alat seperti [warner/wireguard-vanity-address](https://github.com/warner/wireguard-vanity-address)._

#### Membuat _Private Key_

Anda bisa menggunakan perintah `wg genkey` untuk membuat _private key_ Anda. Simpan _private key_ Anda di tempat yang aman. Misalnya: di `/etc/wireguard/do_private.key` dengan _file permission_ `600`.

```shell
# membuat private key
wg genkey | sudo tee /etc/wireguard/do_private.key
# mengubah file permission
sudo chmod 600 /etc/wireguard/do_private.key
```

_Private key_ tersebut nantinya kita butuhkan untuk membuat _public key_ untuk server WireGuard kita. Contoh WireGuard _private key_ yang digunakan untuk artikel ini:

```
uO0GDXBc+ZH5QsLmf+qRyCtFmUV1coadJvQp8iM0mEg=
```

#### Membuat _Public Key_

Sekarang, buat _public key_ dari _private key_ yang telah kita buat sebelumnya.

```shell
sudo cat /etc/wireguard/do_private.key | wg pubkey | sudo tee /etc/wireguard/do_public.key
```

_Public key_ tersebut akan kita butuhkan untuk mengkonfigurasi koneksi WireGuard _client_ (_peers_) kita. Contoh WireGuard _public key_ yang digunakan untuk artikel ini:

```
7c023YtKepRPNNKfGsP5f2H2VtfPvVptn8Hn6jjmaz8=
```

### Mengkonfigurasi WireGuard Server

Sebelum mengkonfigurasi server WireGuard Anda, Anda perlu memilih / menentukan _private network IP range_ untuk koneksi WireGuard yang akan Anda gunakan. Anda harus menggunakan [private network IP ranges](https://en.wikipedia.org/wiki/Private_network#Private_IPv4_addresses) yang **valid**. Contoh:

-   Antara `10.0.0.0` - `10.255.255.255` (`10.0.0.0/8`)
-   Antara `172.16.0.0` - `172.31.255.255` (`172.16.0.0/12`)
-   Antara `192.168.0.0` - `192.168.255.255` (`192.168.0.0/16`)

> _Tips: Hindari menggunakan IP range yang sudah Anda gunakan dan IP range yang sering digunakan oleh sebuah aplikasi. Misalnya: Bawaan installasi Docker menggunakan network `172.17.0.0/16`. Jika Anda menggunakan Docker, Anda harus menggunakan IP range lain untuk jaringan WireGuard Anda supaya tidak terjadi bentrok._

Di artikel ini, saya akan menggunakan `10.10.88.0/24` untuk jaringan WireGuard saya.

Anda juga perlu menentukan _port_ berapa (**UDP**) yang akan digunakan oleh WireGuard. Banyak perangkat jaringan di luar sana (seperti **Netgate**, **QNAP**, dan lain-lain) menggunakan **UDP** _port_ **51280** untuk konfigurai WireGuard _default_ mereka. Untuk artikel ini, saya akan menggunakan `UDP` port `51822`.

Sekarang, kita sudah memiliki semua informasi dasar yang kita butuhkan supaya server WireGuard dapat dijalankan:

-   Server Public IP: `xxx.xx.xx0.246`
-   Server Private key: `uO0GDXBc+ZH5QsLmf+qRyCtFmUV1coadJvQp8iM0mEg=`
-   Server Public Key: `7c023YtKepRPNNKfGsP5f2H2VtfPvVptn8Hn6jjmaz8=`
-   Server Listen Port: `UDP` port `51822`
-   WireGuard Network: `10.10.88.0/24`

Buat file dengan nama `wg0.conf` untuk konfigurasi WireGuard anda di folder `/etc/wireguard` dan isi dengan contoh konfigurasi berikut ini:

```plain
# /etc/wireguard/wg0.conf

[Interface]
PrivateKey = <YOUR_SERVER_PRIVATE_KEY> # Pada contoh artikel ini: uO0GDXBc+ZH5QsLmf+qRyCtFmUV1coadJvQp8iM0mEg=
Address = <YOUR_SERVER_WG_IP_ADDRESS>  # Pada contoh artikel ini: 10.10.88.1/24
ListenPort = <SERVER_UDP_LISTEN_PORT>  # Pada contoh artikel ini: 51822
SaveConfig = true
```

> _**Catatan**: Dari konfigurasi diatas, perhatikan bahwa saya mengambil IP `10.10.88.1` untuk alamat IP server saya (di jaringan WireGuard)._

Ubah `<YOUR_SERVER_PRIVATE_KEY>`, `<YOUR_SERVER_IP_ADDRESS>`, `<SERVER_UDP_LISTEN_PORT>` dengan konfigurasi sesuai keinginan Anda.

#### Mengijinkan _IP forwarding_

Di artikel ini, kita ingin memperbolehkan _peers_ (_client_ / perangkat yang terkoneksi ke jaringan WireGuard kita) untuk menggunakan WireGuard server sebagai _default gateway_ mereka. Jadi semua lalu-lintas jaringan keluar (kecuali ke jaringan lokal **LAN/WLAN** Anda) dapat menggunakan server WireGuard ini. Jika Anda menggunakan WireGuard untuk _peer-to-peer_ saja, Anda tidak memerlukan langkah ini.

Edit `/etc/sysctl.conf` dan di akhir file tersebut, tambahkan `net.ipv4.ip_forward=1`. Setelah itu jalankan perintah `sudo sysctl -p` untuk memuat ulang konfigurasi baru di `/etc/sysctl.conf` yang baru saja kita ubah.

```shell
sudo sysctl -p
```

Setelah itu, Anda perlu mengatur ulang konfigurasi _firewall_ supaya _peers_ (client) dapat melakukan koneksi ke server WireGuard dan lalu-lintas jaringan client ter-_routing_ dengan benar.

#### Mengkonfigurasi Firewall

Secara _default_, aplikasi **UFW** (program untuk memudahkan konfigurasi _firewall_) sudah terinstall di Ubuntu. Anda perlu menambahkan _port_ yang digunakan oleh WireGuard supaya port tersebut terbuka dapat diakses dari mana saja.

```shell
sudo ufw allow OpenSSH
sudo ufw allow proto udp to any port 51822
```

Jika WireGuard port yang Anda konfigurasi bukan `51822`, ubah dan sesuaikan perintah diatas.

> _Perhatikan bahwa saya juga menambahkan **OpenSSH** ke *allow list* untuk menghindari terputusnya koneksi SSH ke server jika sebelumnya Anda belum mengkonfigurasi / mengaktifkan *firewall*._

Aktifkan / restart `ufw` dengan perintah:

```shell
ufw enable # untuk mengaktifkan firewall, atau
ufw reload # untuk merestart firewall
```

Selanjutnya, Anda perlu mengetahui _interface_ mana yang digunakan oleh server Anda sebagai _default route_-nya. untuk mengetahuinya, Anda bisa menggunakan perintah `ip route list default`. Contoh hasil dari perintah `ip route list default` saya:

```plain
default via 164.90.160.1 dev eth0 proto static
```

Perhatikan kata setelah `dev`, itu adalah _default network interface_-nya. Dari contoh diatas, _default network interface_ server saya adalah `eth0`.

Sekarang, tambahkan konfigurasi berikut ke `/etc/wireguard/wg0.conf` pada bagian `[Interface]`:

```plain
PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

Ubah `eth0` dari konfigurasi di atas dan sesuaikan dengan _default network interface_ server Anda.

Konfigurasi `/etc/wireguard/wg0.conf` Anda seharusnya mirip seperti berikut:

```plain
# /etc/wireguard/wg0.conf

[Interface]
PrivateKey = <YOUR_SERVER_PRIVATE_KEY> # Pada contoh artikel ini: uO0GDXBc+ZH5QsLmf+qRyCtFmUV1coadJvQp8iM0mEg=
Address = <YOUR_SERVER_WG_IP_ADDRESS>  # Pada contoh artikel ini: 10.10.88.1/24
ListenPort = <SERVER_UDP_LISTEN_PORT>  # Pada contoh artikel ini: 51822
SaveConfig = true

PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

Sekarang, server WireGuard kita sudah siap, cobalah untuk menjalankan _service_ WireGuard menggunakan `wg-quick` (via `systemd`):

```shell
sudo systemctl start wg-quick@wg0.service
```

Perhatikan bahwa `wg0` diatas diambil dari nama konfigurasi file pada folder `/etc/wireguard` (tapi tanpa _file extension_ `.conf`). Jika nama konfigurasi WireGuard-nya adalah `internal.conf`, Anda dapat menjalankan konfigurasi WireGuard tersebut menggunakan perintah `systemctl start wg-quick@internal.service`.

Setelah perinta diatas, pastikan _service_ WireGuard berjalan dengan perintah `systemctl status wg-quick@wg0.service`:

```plain
● wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0
     Loaded: loaded (/lib/systemd/system/wg-quick@.service; enabled; vendor preset: enabled)
     Active: active (exited) since Mon 2023-06-05 14:52:31 UTC; 2h 2min ago
       Docs: man:wg-quick(8)
             man:wg(8)
             https://www.wireguard.com/
             https://www.wireguard.com/quickstart/
             https://git.zx2c4.com/wireguard-tools/about/src/man/wg-quick.8
             https://git.zx2c4.com/wireguard-tools/about/src/man/wg.8
    Process: 714 ExecStart=/usr/bin/wg-quick up wg0 (code=exited, status=0/SUCCESS)
   Main PID: 714 (code=exited, status=0/SUCCESS)
        CPU: 131ms

Jun 05 14:52:30 fra1-do1 systemd[1]: Starting WireGuard via wg-quick(8) for wg0...
Jun 05 14:52:30 fra1-do1 wg-quick[714]: [#] ip link add wg0 type wireguard
Jun 05 14:52:30 fra1-do1 wg-quick[714]: [#] wg setconf wg0 /dev/fd/63
Jun 05 14:52:30 fra1-do1 wg-quick[714]: [#] ip -4 address add 10.10.88.1/24 dev wg0
Jun 05 14:52:30 fra1-do1 wg-quick[714]: [#] ip link set mtu 1420 up dev wg0
Jun 05 14:52:31 fra1-do1 wg-quick[714]: [#] ufw route allow in on wg0 out on eth0
Jun 05 14:52:31 fra1-do1 wg-quick[790]: Skipping adding existing rule
Jun 05 14:52:31 fra1-do1 wg-quick[790]: Skipping adding existing rule (v6)
Jun 05 14:52:31 fra1-do1 wg-quick[714]: [#] iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
Jun 05 14:52:31 fra1-do1 systemd[1]: Finished WireGuard via wg-quick(8) for wg0.
```

![WireGuard systemd](wireguard-systemd.png#center)

> *Anda bisa menjalankan perintah `sudo systemctl enable wg-quick@wg0.service` agar service WireGuard berjalan otomatis setelah server dinyalakan atau *reboot*.*

## Konfigurasi WireGuard Peer (_client_)

Pada sesi ini, saya akan menggunakan Linux (`wg-quick` via ``systemd`) sebagai contoh melakukan koneksi ke server WireGuard yang sudah kita konfigurasi sebelumnya. Untuk metode lain (seperti menggunakan **NetworkManager**), sistem operasi lain, atau koneksi dari ponsel, saya akan menambahkannya di lain artikel.

Mengkonfigurasi WireGuard _peer (client)_ di Linux menggunakan `wg-quick` via `systemd` hampir sama seperti mengkonfigurasi server WireGuard. Perbedaannya adalah: Anda tidak memerlukan konfigurasi _IP forwarding_ maupun _firewall_ (kecuali Anda memiliki kebutuhan tertentu di mesin Linux Anda). Yang perlu Anda lakukan hanyalah menginstall WireGuard, membuat _private_ dan _public key_, dan menentukan **DNS** server mana yang ingin Anda gunakan.

### Membuat _Private_ and _Public Key_ (_Client Side_)

Jika Anda sudah mempunyai pasangan _public & private key_ untuk WireGuard sebelumnya, Anda bisa menggunakan _public & private key_ tersebut dan langsung ke sesi berikutnya: "[Mengkonfigurasi WireGuard Peer (client)](#mengkonfigurasi-wireguard-peer-client)".

> _Tips: Anda bisa membuat public key yang cantik (**vanity address**) untuk **WireGuard** menggunakan alat seperti [warner/wireguard-vanity-address](https://github.com/warner/wireguard-vanity-address)._

#### Membuat Peer Private key

Anda bisa menggunakan perintah `wg genkey` untuk membuat _private key_ Anda. Simpan _private key_ Anda di tempat yang aman. Misalnya: di `/etc/wireguard/do_private.key` dengan _file permission_ `600`.

```shell
# membuat private key
wg genkey | sudo tee /etc/wireguard/do_private.key
# mengubah file permission
sudo chmod 600 /etc/wireguard/do_private.key
```

_Private key_ tersebut nantinya kita butuhkan untuk membuat _public key_ untuk server WireGuard kita. Contoh WireGuard _private key_ yang digunakan untuk artikel ini:

```
WApLrVqFvXMbvsn+62DxfQCY8rsFqmHCEFAabAeA5WY=
```

Change `/etc/wireguard/do_private.key` file permission with `sudo chmod 600 /etc/wireguard/do_private.key`.

#### Generate Peer Public Key

Sekarang, buat _public key_ dari _private key_ yang telah kita buat sebelumnya.

```shell
sudo cat /etc/wireguard/do_private.key | wg pubkey | sudo tee /etc/wireguard/do_public.key
```

_Public key_ tersebut akan kita butuhkan untuk ditambahkan ke konfigurasi server WireGuard kita. Contoh WireGuard _public key_ yang digunakan untuk artikel ini:

```
6gnV+QU7jG7BzwWrBbqiYpKQDGePYQunebkmvmFrxSk=
```

### Mengkonfigurasi WireGuard Peer (client)

Sebelum mengkonfigurasi WireGuard _peer_ (_client_), Anda perlu memilih / menentukan _alamat IP private_ untuk koneksi WireGuard peer yang akan Anda gunakan. Anda harus menggunakan alamat IP yang tidak terpakai dari _private network IP range_ WireGuard server Anda. Di artikel ini, `10.10.88.1/24` sudah digunakan oleh server WireGuard, dan kita tidak bisa menggunakan alamat IP tersebut untuk _peer_ / _client_ kita. Maka dari itu, saya akan menggunakan `10.10.88.2/24` (atau `10.10.88.2/32`).

Sekarang, kita sudah memiliki semua informasi dasar yang kita butuhkan supaya untuk konfigurasi WireGuard _peer_:

-   Server Public IP: `xxx.xx.xx0.246`
-   Server Public Key: `7c023YtKepRPNNKfGsP5f2H2VtfPvVptn8Hn6jjmaz8=`
-   Server Listen Port: `UDP` port `51822`
-   WireGuard Network: `10.10.88.0/24`
-   Client IP address: `10.10.88.2/24`

Buat file dengan nama `wg-do1.conf` untuk konfigurasi WireGuard Anda di folder `/etc/wireguard` dan isi dengan contoh konfigurasi berikut ini:

```plain
# /etc/wireguard/wg-do1.conf

[Interface]
PrivateKey = <YOUR_PEER_PRIVATE_KEY> # Pada contoh artikel ini: WApLrVqFvXMbvsn+62DxfQCY8rsFqmHCEFAabAeA5WY=
Address = <YOUR_PEER_IP_ADDRESS>     # Pada contoh artikel ini: 10.10.88.2/24
DNS = 1.1.1.1 8.8.8.8                # You can use any public / your own DNS resolver if you want

[Peer]
PublicKey = <YOUR_SERVER_PUBLIC_KEY> # Pada contoh artikel ini: 7c023YtKepRPNNKfGsP5f2H2VtfPvVptn8Hn6jjmaz8=
AllowedIPs = 0.0.0.0/0               # Route all external traffic to here
Endpoint = <YOUR_SERVER_PUBLIC_IP_ADDRESS>:<SERVER_UDP_LISTEN_PORT> # Pada contoh artikel ini: xxx.xx.xx0.246:51822
PersistentKeepalive = 15
```

Ubah `<YOUR_PEER_PRIVATE_KEY>`, `<YOUR_PEER_IP_ADDRESS>`, `<YOUR_SERVER_PUBLIC_KEY>`, `<YOUR_SERVER_PUBLIC_IP_ADDRESS>`, dan `<SERVER_UDP_LISTEN_PORT>` dan sesuaikan dengan milik Anda.

Catatan:

-   `AllowedIPs` = `0.0.0.0/0` artinya semua lalu-lintas jaringan akan melalui _peer_ tersebut (dalam hal ini, server WireGuard kita).  
    Anda bisa menentukan / memilih _routing_ menuju IP/_network_ tertentu supaya melewati _peer_ tertentu (Jika Anda terkoneksi ke banyak _peer_ / server).  
    Sebagai contoh, jika Anda hanya ingin mengarahkan lalu-lintas jaringan menuju IP 1.0.0.1 dan 8.8.4.4 melalui _peer_ tertentu dan menggunakan konesi internet dari ISP Anda sebagai _default route_-nya, Anda bisa menghapus `0.0.0.0/0` dan menambahkan `1.0.0.1/32,8.8.4.4/32` (dipisahkan dengan tanda koma) untuk nilai dari `AllowedIPs`.
-   `PersistentKeepalive` = `15` : Berapa detik sekali _peer_ mengirimkan _ping_ ke server, supaya server dapat mencapai / berkomunikasi dengan peer yang berada dibalik **NAT**/firewall.
-   `DNS` Anda juga dapat menentukan DNS server yang ingin Anda gunakan dengan menentukan alamat IP DNS server pada konfigurasi `DNS`.

#### Menambahkan _Peers Public Key_ ke WireGuard Server

Setelah itu, Anda perlu menambahkan setiap peer public key ke konfigurasi WireGuard server. Hal ini perlu dilakukan agar peers (client) dapat melakukan koneksi ke WireGuard server. Ada 2 cara yang bisa dilakukan, tergantung dari konfigurasi server Anda.

Jika Anda mengikuti tutorial ini dengan setting `SaveConfig = true` pada server, maka Anda bisa menambahkan _peer public key_ dengan perintah berikut di WireGuard Server:

```shell
wg set wg0 peer 6gnV+QU7jG7BzwWrBbqiYpKQDGePYQunebkmvmFrxSk= allowed-ips 10.10.88.2
```

Ubah `wg0` sesuai dengan _interface_ WireGuard Anda di server, `6gnV+QU7jG7BzwWrBbqiYpKQDGePYQunebkmvmFrxSk=` dengan _public key peer_ Anda, dan `10.10.88.2` dengan alamat IP pada _IP range_ WireGuard yang akan digunakan oleh peer.

Jika Anda tidak menggunakan setting `SaveConfig = true` pada server, maka Anda tinggal menambahkan informasi _peer_ ke konfigurasi server (`/etc/wireguard/wg0.conf`). Contohnya:

```plain
[Peer]
PublicKey = 6gnV+QU7jG7BzwWrBbqiYpKQDGePYQunebkmvmFrxSk=
AllowedIPs = 10.10.88.2/32
```

Ubah `6gnV+QU7jG7BzwWrBbqiYpKQDGePYQunebkmvmFrxSk=` dengan _public key peer_ Anda, dan `10.10.88.2` dengan alamat IP pada _IP range_ WireGuard yang akan digunakan oleh peer.

jangan lupa untuk melakukan _restart_ WireGuard _service_ setiap Anda melakukan perubahan pada file `/etc/wireguard/wg0.conf`.

```shell
sudo systemctl restart wg-quick@wg0.service
```

### Melakukan koneksi ke Server

Sekarang, konfigurasi _peer_ (_client_) sudah selesai, Anda dapat mencoba melakukan koneksi ke WireGuard server dengan `wg-quick` via `systemd`:

```shell
sudo systemctl start wg-quick@wg-do1.service
```

> _**Note 1**: Perhatikan bahwa `wg-do1` diatas diambil dari nama konfigurasi file pada folder `/etc/wireguard` (tapi tanpa *file extension* `.conf`). Jika nama konfigurasi WireGuard-nya adalah `vpn-wireguard.conf`, Anda dapat menjalankan konfigurasi WireGuard tersebut menggunakan perintah `systemctl start wg-quick@vpn-wireguard.service`._

> _**Note 2**: Scara default `wg-quick` menggunakan `resolvconf` untuk menambahkan entri DNS baru. Hal ini akan menyebabkan masalah dengan "network managers" dan "DHCP clients" yang tidak menggunakan `resolvconf`, karena mereka akan menulis ulang (overwrite) file `/etc/resolv.conf` (yang akan menghapus record DNS yang sudah ditambahkan oleh `wg-quick`._  
> _Solusinya adalah menggunakan "software networking" yang kompatible dengan `resolvconf`._

> _**Note 3**: Pengguna Linux yang menggunakan `systemd-resolved` harus memastikan bahwa `systemd-resolvconf` terinstall di sistem operasi yang digunakan._

Untuk memverifikasi bahwa konfigurasi sudah benar dan bekerja, coba melakukan pengecekan IP publik Anda dari _browser_ atau terminal menggunakan `wg show` atau `curl ifconfig.me`.

![wg show](wg-show.png#center)

![What is my IP](wg-vpn-do-ip.png#center)

## Kesimpulan

WireGuard adalah protokol VPN favorit saya. Performanya cepat dan lebih hemat _resource_ jika dibandingkan dengan protokol VPN lainnya. Ia juga bisa digunakan untuk koneksi _peer-to-peer_, koneksi _client-server_ atau membuat _mesh network_ yang aman.

Ketika dikombinasikan dengan **Nginx** sebagai _reverse proxy_, Anda bahkan bisa mengekspose / server HTTP di jaringan lokal Anda yang berada dibalik **NAT**/_firewall_ ke internet.

Akan tetapi, melakukan _maintenance_ pada jaringan WireGuard yang besar bisa sangat kompleks dan susah dilakukan. Namun, ada _software_ yang dapat membantu Anda untuk membantu mengatur hal itu, salah satu contohnya adalah [Netmaker](https://www.netmaker.io/).
