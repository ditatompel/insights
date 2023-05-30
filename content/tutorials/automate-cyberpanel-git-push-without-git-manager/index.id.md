---
title: "Cara Commit Otomatis ke GitHub di CyberPanel Tanpa Git Manager"
description: "Cara alternatif untuk melakukan commit otomatis ke GitHub untuk website-website yang ada di CyberPanel dengan GitHub Deploy Keys."
# linkTitle:
date: 2023-01-04T05:16:48+07:00
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
  - Self-Hosted
  - SysAdmin
tags:
  - CyberPanel
  - Git
  - Automation
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

Saat saya mencoba menggunakan fitur bawaan [CyberPanel Git Manager](https://community.cyberpanel.net/t/how-to-use-cyberpanel-git-manager-for-complete-automation/30630/1), saya menemui banyak permasalahan. Salah satu diantaranya adalah error yang mengatakan: *"You are not authorized to access this resource"*. Hal tersebut selalu terjadi meskipun saya sudah mengikuti panduan komunitas.

Selain itu, dengan mengikuti panduan komunitas dengan [memberikan SSH key yang digenerate oleh CyberPanel ke akun GitHub utama](https://community.cyberpanel.net/t/how-to-use-cyberpanel-git-manager-for-complete-automation/30630/1#add-ssh-key-on-github-to-connect-cyberpanel-git-manager-8) juga akan memberikan **akses ke semua repositori** milik akun tersebut. Hal ini tentu saja tidak baik jika suatu saat seseorang mampu menanamkan *backdoor / webshell* di aplikasi website Anda. Dan sebagai informasi tambahan, konfigurasi CyberPanel secara default memberikan akses read kepada publik ke folder `.git` yang ada di folder `public_html`.

Di artikel ini, saya ingin berbagi cara alternatif untuk melakukan commit otomatis ke GitHub untuk website-website yang ada di CyberPanel (ditambah dengan metode yang lebih baik dengan memanfaatkan fitur GitHub **Deploy keys** daripada global SSH *access key* ke akun utama).

<!--more-->

## Informasi Penting
1. Cara ini **tidak mensupport** fitur *pull / webhook* seperti yang tersedia di fitur bawaan CyberPanel Git Manager. Metode ini **hanya melakukan commit dan push** file-file website yang berubah ke *remote* git repositori.
2. Direktori kerja berbeda dengan CyberPanel Git manager. Repositori *root* official CyberPanel Git Manager berada di `/home/USERNAME/public_html`, sedangkan metode ini menggunakan `$HOME` *user* direktori (`/home/USERNAME`).
3. Sehubungan dengan point ke-2 diatas, **JANGAN menggunakan kedua metode secara bersamaan di satu website**! Pilih salah satu yang sesuai dengan *style* Anda.
4. Selalu lalukan test di *testing / staging environment* sebelum mengimplementasikannya ke *production environment*!
5. Fitur backup *official* dari CyberPanel hanya melakukan backup folder `public_html`, `vhost` config dan `database` saja. Jadi jika suatu hari anda melakukan restore website Anda, Anda perlu melakukan semua langkah ini lagi dari awal.

## Konfigurasi
Saya beransumsi bahwa Anda sudah memiliki akun GitHub dan memiliki server CyberPanel yang berjalan normal tanpa kendala apapun.

### Buat GitHub Deploy Key
Login ke server CyberPanel anda menggunakan SSH milik akun website yang Anda (atau buat website baru jika Anda belum memiliki website di server CyberPanel Anda).

Buat public & private key untuk kita berikan ke repositori GitHub yang nantinya akan kita buat debgab menjalankan perintah:

```bash
ssh-keygen -t rsa -f ~/.ssh/example_com_github_rsa -C "example.com github auto push"
```

Ubah `example_com_github_rsa` dengan nama yang Anda inginkan. Saat muncul command yang meminta untuk memasukan *passpharse key*, **kosongkan** saja karena kita ingin *key-pair* tersebut digunakan tanpa password.

Kemudian, buat repositori baru di GitHub untuk website Anda, pergi ke **Repositori** -> **Settings** -> **Deploy keys** -> **Add deploy keys**.

![Tampilan repositori baru Github](github-deploy-key-01.png#center)

![GitHub Deploy keys](github-deploy-key-02.png#center)

![menambahkan GitHub deploy key baru](github-deploy-key-03.png#center)

Paste isi konten *public key* (di contoh artikel adalah `~/.ssh/example_com_github_rsa.pub`) ke *textarea* **Key field** dan pastikan **Allow write access tercentang**.

### Manfaatkan Fitur SSH Config File
Sekarang, tambahkan (atau buat jika filenya belum ada) baris berikut ini ke SSH config file milik user bersangkutan di `~/.ssh/config`.

```
Host example_com
    HostName github.com
    User git
    IdentityFile ~/.ssh/example_com_github_rsa
```

Keterangan dari konfigurasi diatas: `Host example_com` adalah sebuah *alias*. Konfigurasi tersebut memerintahkan SSH untuk melakukan koneksi ke `github.com` menggunakan user `git` dengan **private key** `~/.ssh/example_com_github_rsa` saat **perintah SSH option** ke `example_com` dijalankan.

Cek konfigurasi dan koneksi SSH diatas dengan perintah `ssh -T example_com`. Seharusnya Anda menerima pesan bahwa koneksi Anda ke GitHub berhasil: "**Hi your_github_username/example-repo! You’ve successfully authenticated, but GitHub does not provide shell access.**".

### Membuat File .gitignore

Karena metode ini tidak menggunakan `public_html` sebagai *repositori root*, melainkan menggunakan direktori `$HOME` milik user, Anda perlu melakukan *exclude* file-file yang *digenerate* oleh CyberPanel, seperti: `~/bash_history`, `~/logs` folder, dll.

Buat file `~/.gitignore` dan isi dengan konfigurasi berikut:

```
# Ignore hidden files and directory
.*
!/.gitignore
!/public_html/.*

# Ignore backup and logs directory
/backup/
/logs/

# Optional, but recommended:
# Ignore WordPress upload folder
/public_html/wp-content/uploads
# if you want to ignore wp-config.php file
/public_html/wp-config.php
```

### Koneksi Ke Remote Git Repositori
Sekarang, saatnya membuat koneksi ke remote Git repositori, jalankan perintah:
```bash
git init
git remote add origin example_com:your_git_username/example-repo.git
```

**INFORMASI PENTING** pada perintah `git remote add` diatas:
`example_com` harus cocok atau sesuai dengan *variable Host* yang ada di file `~/.ssh/config` yang kita buat sebelumnya. Jangan lupa ubah juga `your_git_username/example-repo` dengan repositori milik Anda.

Cek apakah konfigurasi `.gitignore` yang kita buat sebelumnya sudah sesuai dengan apa yang kita inginkan dengan perintah `git status`. Kurang lebih hasil *output* `git status` menyatakan bahwa `.gitignore` dan `public_html` masuk ke *untracked files*.

![perintah git status](git-status-cyber-panel-1.png#center)

## First Commit
Sebelum mengimplementasikan ke proses otomatisasi, kita perlu melakukan *first commit*, membuat **remote branch** (defaultnya: `main`) dan melakukan *push* ke *remote* repositori. Langkah ini juga akan membantu kita melakukan verifikasi apakah semua berjalan sesuai dengan apa yang kita inginkan.

```bash
# buat git config user dan email jika kita belum pernah mengkonfigurasi sebelumnya
git config user.email "your_github_registered_email@example.com"
git config user.name "Your Name"

git add .
git commit -m "first commit"
git branch -M main
git push -u origin main
```

Setelah melakukan perintah diatas, cek repositori GitHub anda, file-file website Anda seharusnya sudah ada disana.

## Otomatisasi
Buat **bash** *script* sederhana untuk mengeksekusi perintah *git commit* dan *push*. Letakan *script* tersebut dibawah `$HOME` direktori milik user (kecuali folder `public_html`):

```bash
#!/bin/bash

cd ~/
git add .
git commit -m "Updated: `date +'%Y-%m-%d %H:%M:%S'`"
git push origin main
```

Terakhir, pergi ke **CyberPanel Web UI**, masuk ke halaman **Crob Job** milik website yang sudah kita konfigurasi, tambahkan *cron job* untuk mengesekusi *script bash* yang sudah kita buat diatas:

```
/bin/bash /home/example.com/backup.sh >/dev/null 2>&1
```

Ubah `example.com` ke nama domain milik Anda, saya menyarankan untuk tidak men-setting *cron job* ini terlalu sering. Menurut saya, 2x sehari sudah lebih dari cukup.