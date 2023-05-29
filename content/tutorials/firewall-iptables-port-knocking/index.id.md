---
title: "Firewall iptables Port Knocking"
description: "Berbagi tips untuk meningkatkan keamanan server dengan menggunakan teknik port knocking iptables firewall."
# linkTitle:
date: 2013-07-01T22:16:19+07:00
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
  - Security
tags:
  - iptables
  - Port Knocking
  - Linux
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

Kali ini saya ingin berbagi tips untuk meningkatkan keamanan server dengan menggunakan teknik **port knocking**. **Port knocking** adalah sebuah cara untuk membuka *port* tertentu dengan cara mengirimkan paket ke sedetetan port-port tertentu yang telah ditentukan sebelumnya.

<!--more-->

> _**Q** : Tujuannya untuk apa?_

**A** : Tujuannya untuk menghindari serangan dari *pentester* yang melakukan *scanning port* untuk mendapatkan *service-service* yang mungkin bisa diexploitasi oleh mereka. Karena jika *pentester* yang melakukan *scanning* tersebut tidak mengetuk *port* yang telah ditentukan sebelumnya secara berurutan, maka *port* yang ingin kita lindungi tersebut tidak akan terbuka.

> _**Q** : Bisa lebih detail?_

**A** : Misalnya kita punya *service* **SSH** yang listen di *port* `22`, sedangkan *pentester* punya *0day remote root exploit* untuk aplikasi **OpenSSH** tersebut misalnya. Maka server akan terancam keamanannya karena port `22` tersebut terbuka. Dengan menggunakan teknik *port knocking*, hanya mereka yang mengetahui port mana yang harus di *"hit"* terlebih dahulu yang dapat membuka dan mengakses port `22` tersebut.

Supaya lebih jelas, saya ambil contoh dari *thread* saya sebelumnya tentang **celeng Lawang Sewu CTF** (`http://devilzc0de.org/forum/thread-20071.html`). Challange yang ke-2 adalah mengenai *port knocking*.

*Port knocking* ini bisa kita konfigurasi dengan `iptables` *firewall* (yang biasanya sudah dimiliki *kernel Linux* pada kebanyakan distro linux).

Pada kesempatan kali ini saya share bagaimana **cara konfigurasi port knocking menggunakan `iptables`**.

> _**Disclaimer**: Dengan mengikuti tutorial ini, author tidak bertanggung jawab jika ada kesalahan dan kehilangan remote akses ke server._

VIDEO TUTORIAL : [http://youtu.be/0zFQocf7C_0](http://youtu.be/0zFQocf7C_0).

Yang dibutuhkan pada tutorial kali ini :
- Server & Client dengan **OS Linux** (pada tutorial kali ini ane menggunakan **CentOS**)
- `iptables` (server firewall)
- `nmap` (untuk *scan* dan *knocking port* dari *client*)
- Pengetahuan dasar mengenai *iptables*.

**Studi Kasus:**

Saya punya sebuah server (IP : `192.168.0.100`), saya menggunakan SSH untuk melakukan manajemen server tersebut. SSH port untuk *remote* aksesnya adalah default (Port `22`). Saya ingin menutup port `22` dan hanya terbuka pada saat dibutuhkan.

Disinilah kita gunakan teknik *port knocking*, dimana saya sudah menge-set konfigurasi supaya user harus mengirimkan paket **TCP** ke port (misalnya) `1111` lalu `2222`, lalu `3333`, dan terakhir `4444` baru kembudian port `22` (SSH) tersebut terbuka.

- IP Server : `192.168.0.100`.
- OS : **CentOS**.
- SSH Port : `22`.
- Skema **Port Knocking** : Paket `TCP` Port `1111` => `2222` => `3333` => `4444` => Port `22` terbuka.

Untuk bawaan server **CentOS**, konfigurasi *firewall* sudah membuka port `22` untuk SSH.

![Port 22 open](pk-01.png#center)

Maka kita perlu mengkonfigurasi ulang `iptables` *firewall*nya. Kita dapat menggunakan perintah `iptables-save > iptables.rules` untuk melakukan *dump* / *backup rules firewall*.

Coba lihat pada hasil konfigurasi *firewall* yang baru saja kita *dump*, kurang lebih seperti berikut (untuk **CentOS**):

```plain
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
-A INPUT -p icmp -j ACCEPT 
-A INPUT -i lo -j ACCEPT 
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited 
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
```
![iptables dump config](pk-02.png#center)

Perhatikan pada rules berikut :
```plain
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
```

terlihat bahwa iptables memperbolehkan akses melalui port 22.

Mari kita buat `iptables` *rules* sesuai keinginan kita di studi kasus ini, yaitu kita ingin menutup port `22` tersebut, dan hanya terbuka pada saat port `1111`,`2222`,`3333`,`4444` mendapatkan paket `TCP` secara berurutan.

Copy `iptables.rules` yang sebelumnya sudah kita dapatkan ke `iptables-new.rules`, kemudian edit.
```bash
cp iptables.rules iptables-new.rules
vi iptables-new.rules
```
dan edit seperti pada gambar dibawah :

![iptables port knocking rules](pk-03.png#center)

Dengan kata lain, saya membuka port `80`, kemudian menambahkan *firewall rules* baru yang secara dinamis dapat membuka port `22` selama 15 detik jika port `1111`, `2222`, `3333`, `4444` mendapatkan kiriman paket `TCP` secara berurutan dalam jangka waktu 5 detik.

Setelah dirasa udah oke, kita restore konfigurasi firewall yang baru dengan menggunakan `iptables-restore`, lalu *restart iptables service*nya.
```bash
iptables-restore < iptables-new.rules
service iptables save
service iptables restart
```
kemudian untuk memastikan rules yang baru sudah berjalan gunakan perintah :
```bash
iptables -L -n
```
![iptables rules list](pk-04.png#center)

Nah kalau udah, mari kita coba cek scan port `22` pada server dari komputer kita menggunakan `nmap`, maka akan terlihat port tersebut tertutup oleh *firewall*.
```bash
nmap -Pn 192.168.0.100 -p22
```

![nmap port 22](pk-05.png#center)

Setelah itu kita buat **script bash** sederhana untuk melakukan *knocking port*.

```bash
#!/bin/bash
HOST=$1
shift
for ARG in "$@"
do
    nmap -PN --host_timeout 201 --max-retries 0 -p $ARG $HOST
done
```

Simpan dengan nama `knock.sh` lalu `chmod +x` agar *script* tersebut dapat dieksekusi.

cara penggunaan:
```bash
# ./knock.sh [ip server] [list port]
# misalnya:
./knock.sh 192.168.0.100 1111 2222 3333 4444
```

Dengan mengetuk port `1111`, `2222`, `3333`, `4444` secara berurutan maka port `22` yang telah kita tentukan dari *rules firewall* akan terbuka. Dengan begitu kita dapat melakukan koneksi SSH ke server.

![nmap port knocking](pk-06.png#center)

Sekian tutorial mengenai port knocking.

Silahkan dikembangkan sendiri dengan kreatifitas masing2, *protocol* dan paket yang dikirimkan tidak hanya terbatas pada **TCP** saja, kita juga bisa memanfaatkan kombinasi protokol **TCP**, **UDP** atau bahkan **ICMP**.

Referensi:
- [http://en.wikipedia.org/wiki/Port_knocking](http://en.wikipedia.org/wiki/Port_knocking)
- [http://www.faqs.org/docs/iptables/index.html](http://www.faqs.org/docs/iptables/index.html)
- [https://wiki.archlinux.org/index.php/Port_Knocking](https://wiki.archlinux.org/index.php/Port_Knocking)
- Tambahan dari om @[od3yz]: [http://www.overflow.web.id/source/Metode-Port-Knocking-dengan-Iptables.pdf](http://www.overflow.web.id/source/Metode-Port-Knocking-dengan-Iptables.pdf)




