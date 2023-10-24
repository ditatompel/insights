---
title: "Cara Menggunakan Git Melalui Protokol SSH Untuk Akun GitHub"
description: "Cara menggunakan Git melalui protokol SSH untuk mengakses repositori GitHub. Dimulai dari membuat SSH key pair hingga menambahkan SSH public key ke akun GitHub Anda."
# linkTitle:
date: 2023-10-23T08:18:33+07:00
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
  - TIL
tags:
  - Git
  - GitHub
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
  - jasmerah1966
---

Artikel ini mungkin berguna bagi Anda yang ingin memulai menggunakan **Git** dan menghubungkannya ke **GitHub** menggunakan protokol **SSH**. Proses dimulai dari membuat __SSH key pair__ hingga menambahkan __SSH public key__ ke akun GitHub Anda.

<!--more-->
---

Git merupakan salah satu _version control_ yang paling disukai dan paling banyak digunakan oleh para _software developer_ di seluruh dunia. Beberapa _"Cloud" version control berbasis Git_ seperti [GitLab](https://about.gitlab.com/), [GitHub](https://github.com/), hingga [Codeberg](https://codeberg.org/) menawarkan beberapa fitur unik satu dengan yang lainnya. Namun ada fitur yang pasti ada di tiap _provider_, yaitu mengakses git repositori menggunakan protokol SSH.

Proses authentikasi menggunakan protokol SSH memanfaatkan __SSH public dan private key__ sehingga Anda tidak perlu memberikan __username__ dan _personal access token_ setiap ingin mengakses atau melakukan _commit_ ke repositori Anda.

Kali ini saya ingin berbagi cara menggunakan protokol SSH sebagai metode autentikasi ke spesifik provider, yaitu GitHub. Namun sebelum memulai, pastikan `git` dan `ssh` sudah terinstall di komputer Anda dan Anda sudah memiki akun di GitHub.com.

## Membuat SSH key

Ketika Anda ingin mengakses _private_ repositori Anda atau melakukan perubahan ke repositori GitHub Anda menggunakan SSH, Anda perlu menggunakan SSH _private key_ untuk proses autentikasi. Maka dari itu, buat SSH key pair menggunakan perintah berikut:

```shell
mkdir ~/.ssh && chmod 700 ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/github_key -C "SSH key untuk github"
```

Perintah diatas akan membuat folder `.ssh` di `$HOME` direktori, merubah folder _permission_nya, dan meletakkan _private key_ di `$HOME/.ssh/github_key` dan _public key_ di `$HOME/.ssh/github_key.pub`. Contoh _output_ dari perintah `ssh-keygen` diatas:


```plain
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/jasmerah1966/.ssh/github_key
Your public key has been saved in /home/jasmerah1966/.ssh/github_key.pub
The key fingerprint is:
SHA256:dPniZJhVTjmj2gOi5Q4we8gucBs6b+4fpPJ6J2xnj7Q SSH key untuk github
The key's randomart image is:
+--[ED25519 256]--+
|            o.   |
|           =+    |
|        . +..o   |
|  o   o..=..     |
| . =.+ .S++ .    |
|. *o+ . .+o.     |
|o=.+oo    ..     |
|+oO.++.          |
|.@=*E..          |
+----[SHA256]-----+
```

> _**Catatan**: Anda akan diminta untuk memasukkan `passphrase` pada saat proses pembuatan SSH key pair diatas. Terserah Anda ingin mengisi atau mengosongi passphrase SSH key Anda. Jika Anda mengisi passphrase, maka Anda akan diminta memberikan passphrase saat Anda menggunakan SSH key tersebut._

## Menggunakan SSH Config File
Pada umumnya, banyak tutorial di luar sana yang menggunakan `ssh-agent` sebagai _SSH key manager_nya. Namun saya lebih menyukai trik yang digunakan oleh @ditatompel dengan [Manfaatkan Fitur SSH Config File]({{< ref "/tutorials/automate-cyberpanel-git-push-without-git-manager/index.id.md#manfaatkan-fitur-ssh-config-file" >}}).

Tambahkan (atau buat jika filenya belum ada) baris berikut ini ke SSH config file di `~/.ssh/config`:

```plain
# ~/.ssh/config file
# ...

Host github.com
    User git
    PubkeyAuthentication yes
    IdentityFile ~/.ssh/github_key

# ...
```

Pastikan `IdentityFile` mengacu ke SSH _private key_ yang sudah Anda buat sebelumnya (pada contoh di artikel ini adalah `~/.ssh/github_key`).

## Menambahkan SSH Public Key Ke Akun GitHub Anda
Setelah memiliki _SSH key pair_ dan _SSH config file_ dikonfigurasi, saatnya menambahkan _SSH public Key_ ke akun GitHub Anda.

1. Masuk ke __"Settings"__ > __"SSH and GPG keys"__ > Klik tombol __"New SSH key"__.
2. Isi __"Title"__ dengan apapun yang mudah Anda ingat untuk mengidentifikasi _SSH key_ Anda.
3. Pada bagian __"Key type"__, pilih __"Authentication Key"__.
4. Terakhir kembali ke terminal dan _paste_ isi dari __SSH public key__ (pada contoh tutorial ini adaalah `~/.ssh/github_key.pub`) key _textarea_ __"Key"__. Setelah itu klik tombol __Add SSH key"__.

![menambahkan SSH key baru ke akun GitHub](github-add-new-ssh-key.jpg#center)

Dengan begitu proses konfigurasi sudah selesai dan Anda dapat mencoba melakukan lakukan koneksi ke GitHub dengan perintah `ssh -T github.com`. Seharusnya Anda menerima pesan bahwa koneksi Anda ke GitHub berhasil: "**Hi jasmerah1966! You've successfully authenticated, but GitHub does not provide shell access.**".

Selanjutnya: Baca [Cara Setting 'Verified' (Sign) Git Commit Dengan SSH atau GPG Signature]({{< ref "/tutorials/how-to-create-verified-sign-git-commit/index.id.md" >}}).
