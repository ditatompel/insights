---
title: "SSH Client - Server (Security & Simplicity)"
description: Berbagi trik untuk sedikit lebih memperketat akses SSH dengan men-disable root akses SSH, mengubah port default dan menggunakan public dan private key.
# linkTitle:
date: 2012-05-17T17:09:21+07:00
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
  - Linux
  - SSH
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

Bagi para **System Administrator**, sebagai pengganti **Telnet** penggunaan **SSH** pasti sudah merupakan makanan sehari-hari yang banyak digunakan untuk mengakses sistem berbasis **Linux/Unix**. Meskipun password yang dikirim ke server sudah dienkripsi dan tidak berbentuk *plaintext* lagi, installasi [OpenSSH](https://www.openssh.com/) secara default dirasa kurang aman.

<!--more-->

Kali ini saya ingin berbagi trik yang sebenarnya sudah umum, untuk sedikit lebih memperketat akses SSH. Yaitu men-*disable* akses SSH untuk *user* `root`, menggunakan **public dan private key**, sampai mengubah *port default*. Selain itu saya juga ingin sedikit berbagi trik agar proses memanage server(s) menjadi lebih mudah dan simple.

Pada diskusi kali ini dibutuhkan (atau saya menggunakan) :
* Client PC : **Linux** dengan *desktop environment* **KDE** `4.8`.
* Server SSH (Remote PC) : Linux dengan IP `202.150.169.245`.
* Mengerti sedikit dasar Linux CLI seperti `chmod`, `ssh`, `groupadd`, `useradd`.
* Mampu menggunakan text editor seperti `vi`/`vim`/`nano`/`pico`, dll.
* dan setumpuk kesabaran yang ditumis dengan rasa keingintahuan (yang ini lupakan).

## Disable Akses root Melalui SSH
`Root` *user* adalah user yang pasti ada pada sistem Unix/Unix-Like, jika kita tidak mendisable user tersebut, maka akan mempermudah pentester melakukan serangan bruteforce.

Sebelum mendisable akses `root`, tentu saja kita perlu membuat 1 user baru yang mempunyai hak untuk menggunakan *service* SSH dan masuk ke dalam list `sudoers`.

1. Akses ssh server menggunakan *user* `root` terlebih dahulu.
```bash
ssh root@202.150.169.245
```
2. setelah masuk server SSH, buat user dan *group* baru. (Silahkan lihat `man useradd` untuk lebih jelas)
```bash
groupadd ditatompel
useradd -s /bin/bash -d /home/ditatompel -g ditatompel -G root -m ditatompel
```
3. Set password user tersebut dengan perintah `passwd ditatompel`.

![Create User](create-user.png#center)

4. Lalu tambahkan user `ditatompel` ke list `sudoers`. Edit file `/etc/sudoers` dan tambahkan permission untuk user baru tersebut:
```plain
ditatompel     ALL=(ALL)    ALL
```

5. Kemudian edit file `/etc/ssh/sshd_config` dan tambah / edit konfigurasi berikut :
```plain
PermitRootLogin no
AllowUsers ditatompel
```
6. Restart SSH *daemon*
```bash
service sshd restart #(Untuk CentOS dkk)
/etc/init.d/ssh restart #(untuk Debian)
/etc/rc.d/sshd restart #(FreeBSD, Arch, Gentoo, dkk)
```

> _**Note** : Setelah restart, pastikan akses SSH yang sedang berjalan / terkoneksi tidak putus / di close supaya kita masih memiliki akses dan dapat mengedit konfigurasi jika terjadi kesalahan._

7. Coba akses SSH server menggunakan user yang tadi baru saja kita buat, yaitu `ditatompel`.
```bash
ssh ditatompel@202.150.169.245
```

## Ubah Port Default SSH (Optional)
Mengubah port default SSH (`22`) dapat menghindari *bruteforcer ababail* yg cuma ambil script dari internet karena kebanyakan script *bruteforce* SSH defaultnya melakukan brute ke port `22`.

**NOTE** : Jika firewall server aktif, kita perlu membuka akses ke port yang baru, misalnya jika kita menggunakan `iptables`:
```bash
iptables -A INPUT -p tcp --dport 1337 -j ACCEPT
iptables save
service iptables restart
```

* Ingat, jangan menutup koneksi SSH awal yang sudah terhubung untuk menghindari hal2 yang tidak diinginkan.


Kemudian, untuk mengubah port, edit file `/etc/ssh/sshd_config` dan tambah / edit konfigurasi berikut :

```plain
Port 1337
```
kemudian restart SSH daemon.

Seperti yang kita lihat, SSH daemon melakukan listen di port `1337`. Untuk memastikannya bisa menggunakan perintah `netstat`.
```bash
netstat -plnt
```

Terakhir, selalu test lagi apakah server kita bisa diakses.

## Gunakan Public dan Private Key
1. Buat dulu *keypair* untuk SSH client dan SSH server dengan menggunakan `ssh-keygen`.
```bash
ssh-keygen -b 4048 -f serverLama-169-245 -t rsa -C "ditatompel@serverLama-169-245"
```
Maka ia akan membuat file bernama `serverLama-169-245` dan `serverLama-169-245.pub` dimana :

`serverLama-169-245` adalah **private key** kita, dan `serverLama-169-245.pub` adalah **public key** yang nantinya diletakan letakkan di server kita.

2. Pindahkan ke 2 file tersebut ke folder `~/.ssh` dan ubah file permissionnya menjadi `600`.
```bash
mv serverLama-169-245 serverLama-169-245.pub ~/.ssh/
find ~/.ssh/ -type f -exec chmod 600 {} +
```

![SSH-keygen](sshkeygen.jpg#center)

3. Pada komputer server dengan user yang baru kita buat tadi (`ditatompel`) buat *hidden folder* `.ssh` pada *home dir*nya dan ubah folder permissionnya menjadi `700`.
```bash
mkdir ~/.ssh; chmod 700 ~/.ssh
```

4. Copy **public key** yang tadi kita buat ke folder `~/.ssh` pada remote PC (*SSH Server*) dengan nama `authorized_keys` dan file permission `600`

(untuk meng*copy file* tersebut bisa menggunakan `sftp` / `scp`) : Contoh :

```bash
cd ~/.ssh
sftp -P 1337 ditatompel@202.150.169.245
```

```plain
sftp> put serverLama-169-245.pub /home/ditatompel/.ssh/authorized_keys
sftp> chmod 600 /home/ditatompel/.ssh/authorized_keys
```

![SFTP](sftp.png#center)

5. Setelah itu, edit lagi file `/etc/ssh/sshd_config` dan tambah / edit konfigurasi berikut supaya user tidak dapat mengakses shell meskipun ia mengetahui passwordnya dan wajib menggunakan private key:

```plain
PasswordAuthentication no
```
6. Restart SSH *daemon* dan coba lagi akses SSH server dengan menggunakan command :
```bash
ssh -i ~/.ssh/serverLama-169-245 -p 1337 ditatompel@202.150.169.245
```

![SSH pass](ssh-pass.png#center)

## Memanage Server Menggunakan FISH Protocol
Ni bagian yang saya suka dan yang sebenernya pingin saya share, mungkin aja ada beberapa yang belum tau.

**FISH** (*Files transferred over Shell protocol*) adalah sebuah protokol jaringan yang menggunakan **Secure Shell (SSH)** atau **Remote Shell (RSH)** untuk mentransfer file antara komputer kita dan komputer server semudah membuka2 folder / mengedit file di komputer kita. Saya menggunakan **Dolphin** yang sudah menjadi bawaan **KDE**. Selain Dolphin, KDE user juga bisa menggunakan `Konqueror` untuk menggunakan protokol FISH. (Untuk **Gnome** - **Nautilus** saya kurang tahu, mungkin yang lain bisa menambahkan dimari)

Caranya tinggal klik pada *breadcrumb* navigasi folder dan ketikan `{protokol}{user}@{server}:{port}/{folder}` kemudian tekan enter.

misalnya :
```plain
fish://ditatompel@202.150.169.245:1337/var/www/path/to/folder/you/want/to/access/
```

![Fish protocol](fish.png#center)
setelah itu kita akan dipromot untuk memasukan password SSH kita. Tapi ada permasalahan yang dihadapi, protokol FISH pada Dolphin / Konqueror tidak secara langsung tahu jika kita menggunakan public dan private key untuk mengakses server.

Maka dari itu kita dapat memanfaatkan fitur **ssh config** (lokasinya ada di `~/.ssh/config` untuk konfigurasi per user, atau `/etc/ssh/sshd_config` untuk *system wide*). Untuk konfigurasi tiap user, biasanya belum terdapat file `~/.ssh/config`, maka dari itu kita perlu buat dulu file tersebut dengan menambahkan konfigurasi `IdentityFile` supaya program yang kita gunakan tau bahwa kita harus menggunakan **private key** SSH kita :
```plain
IdentityFile /home/dit/.ssh/serverlama-169-245
```

Lalu bagaimana jika kita memiliki banyak server dan banyak **private key** untuk masing2 server? Yuk mari kita baca lanjutannya.

## Trik Konfigurasi ~/.ssh/config
Untuk para system administrator yang ngurusin banyak server yang mengharuskan tiap server memiliki akses login yang berbeda,pasti bakal susah mengingat port, password, user, dll. Belum lagi untuk inget akses aplikasi yang ada pada server2 tersebut. Maka dari itu kita bisa manfaatin fitur ssh config yang memungkinkan kita mengakses shell hanya dengan mengingat IP server dan passpharsenya saja.

Berikut ini contoh konfigurasi SSH untuk identitas multi server :
```plain
Host 202.150.169.245
Hostname 202.150.169.245
        User ditatompel
        Port 1337
        IdentityFile /home/dit/.ssh/serverlama-169-245

Host xxx.xx.xx.xxx
HostName xxx.xx.xx.xxx
        User ditakeren
        Port 12345
        IdentityFile /home/dit/.ssh/blahblah1

Host xxx.xxx.xxx.xx
Hostname xxx.xxx.xxx.xx
        User ditacakep
        Port 23213
        IdentityFile /home/dit/.ssh/blahblah2

# dan seterusnya
```

![~/.ssh/config](ssh-config.png#center)

Dengan begitu kita dapat menggunakan command SSH hanya dengan :

```bash
ssh 202.150.169.245
```
atau dengan menambahkannya ke folder *network* dengan mengakses **Network** > **Add Network Folder** kemudian isi informasi remote PC (SSH server) yang dibutuhkan.

![Fish Protocol](fish-protocol1.png#center)

Mungkin sekian dulu dari saya, silahkan bagi teman2 yang ingin menambahkan / mengkoreksi, saya akan sangat menghargai.

Referensi:
* [http://linux.die.net/man/5/ssh_config](http://linux.die.net/man/5/ssh_config).
* [http://kb.mediatemple.net/questions/1625/Using+an+SSH+Config+File](http://kb.mediatemple.net/questions/1625/Using+an+SSH+Config+File).