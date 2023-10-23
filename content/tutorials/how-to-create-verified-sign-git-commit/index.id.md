---
title: "Cara Setting 'Verified' (Sign) Git Commit Dengan SSH atau GPG Signature (Linux)"
description: "Langkah-langkah dan cara menambahkan 'Verified' commit message pada GitHub menggunakan SSH Signing Key atau GPG Signing Key."
# linkTitle:
date: 2023-10-23T23:32:49+07:00
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
  - PGP
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

Cara menambahkan **"Verified"** _commit message_ pada **GitHub** menggunakan **SSH Signing Key** atau **GPG Signing Key**.

<!--more-->
---

Jika Anda sering berkunjung ke halaman _commit history_ dari sebuah **GitHub** repositori, Anda mungkin menemukan ada beberapa _commit message_ yang memiliki label **"Verified"** berwarna hijau, tidak berlabel, atau bahkan berlabel **"Unverified"** dengan label berwarna orange.

Fitur pada GitHub tersebut menandakan bahwa _commit_ atau _tag_ tersebut berasal dari sumber yang otentik dan telah terverifikasi oleh GitHub. Hal ini penting supaya pengguna lain yang menggunakan repositori tersebut yakin bahwa perubahan yang dilakukan pada repositori tersebut memang benar dari sumber yang sudah terverifikasi.

Sampai artikel ini dibuat, ada 3 cara untuk menandatangani atau __signing__ pesan _commit_ tersebut, yaitu dengan menggunakan **GPG signature**, **SSH signature**, dan **S/MIME signature**. Dari ketiga metode yang ada, saya ingin berbagi pengalaman saya menggunakan GPG dan SSH signature untuk melakukan _signing_.

Untuk mengikuti langkah-langkah di artikel ini, pastikan Anda sudah dapat menggunakan aktifitas seperti _commit_ dari komputer Anda tanpa ada masalah. Jika Anda belum pernah mensetting Git, ikuti artikel saya sebelumnya yang berjudul [Cara Menggunakan Git Melalui Protokol SSH Untuk Akun GitHub]({{< ref "/tutorials/how-to-use-git-using-ssh-protocol-for-github/index.id.md" >}}).

## Menggunakan SSH Key Signature
Cara paling mudah adalah menggunakan metode SSH signature. Anda dapat menggunakan SSH key yang sudah Anda gunakan untuk __Authentication key__ dan mengupload _public key_ yang sama untuk digunakan sebagai __Signing key__.

### Menambahkan SSH Key Sebagai Signing Key

Untuk menambahkan SSH key sebagai __Signing key__ di akun GitHub Anda: 

1. Masuk ke __"Settings"__ > __"SSH and GPG keys"__ > Klik tombol __"New SSH key"__.
2. Isi __"Title"__ dengan apapun yang mudah Anda ingat untuk mengidentifikasi _SSH key_ Anda.
3. Pada bagian __"Key type"__, pilih __"Signing Key"__.
4. Terakhir kembali ke terminal dan _paste_ isi dari __SSH public key__ ke _textarea_ __"Key"__. Setelah itu klik tombol __Add SSH key"__.

### Mengubah Konfigurasi Git di Komputer Anda

Setelah SSH Signing key ditambahkan ke Akun GitHub, Anda perlu merubah konfigurasi git `gpg.format` ke `ssh` dengan cara menjalankan perintah berikut:
```shell
git config --global gpg.format ssh
```

Terakhir update config `user.signingkey` dan masukkan lokasi dimana **SSH PUBLIC KEY** yang sudah Anda upload.
```shell
git config --global user.signingkey ~/.ssh/github_key.pub
```
Catatan: Ubah `~/.ssh/github_key.pub` dengan lokasi sebenarnya PUBLIC KEY Anda disimpan.

## Menggunakan GPG Key Signature

Selain menggunakan SSH Key Signature, Anda bisa menggunakan GPG Key Signature untuk melakukan _signing commit_.

### Membuat GPG Key
Jika Anda belum memiliki _GPG key pair_, Anda dapat membuatnya dengan menjalankan perintah berikut:
```shell
gpg --full-generate-key
```

Setelah menjalankan perintah diatas, Anda akan diminta untuk melengkapi informasi, diantaranya:
1. Jenis: Pilih apa saja, Saya rekomendasikan untuk menggunakan default saja, yaitu `RSA and RSA`.
2. Key size: Isi antara 1024 hingga 4096. Default 3072. Saya rekomendasikan untuk menggunakan `4096`.
3. Seberapa lama GPG key tersebut valid: Saya rekomendasikan untuk menggunakan default (`0`, tidak ada tanggal expire).
4. Masukkan informasi Nama, email, dan komentar. Perhatikan pada saat mengisi informasi email, **pastikan email yang Anda masukan sama dengan email yang Anda gunakan di GitHub** (dan sudah melakukan verifikasi).
5. Masukkan `passpharse` GPG key Anda.

Contoh output dari perintah `gpg --full-generate-key`:

```plain
gpg (GnuPG) 2.2.41; Copyright (C) 2022 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
  (14) Existing key from card
Your selection? 1
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0
Key does not expire at all
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: Jasmerah1966
Email address: jasmerah1966@example.com
Comment: GPG sign key untuk GitHub
You selected this USER-ID:
    "Jasmerah1966 (GPG sign key untuk GitHub) <jasmerah1966@example.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: revocation certificate stored as '/home/jasmerah1966/.gnupg/openpgp-revocs.d/F5FEE1EF836C62F5361A643B156C485C2EB2C1D6.rev'
public and secret key created and signed.

pub   rsa4096 2023-10-23 [SC]
      F5FEE1EF836C62F5361A643B156C485C2EB2C1D6
uid                      Jasmerah1966 (GPG sign key untuk GitHub) <jasmerah1966@example.com>
sub   rsa4096 2023-10-23 [E]
```

### Mendapatkan Informasi GPG Key Anda
Untuk melihat list GPG key Anda (memiliki _secret key_), Anda dapat menjalankan perintah berikut:

```shell
gpg --list-secret-keys --keyid-format=long
```

Contoh output dari perintah diatas:
```plain
/home/jasmerah1966/.gnupg/pubring.kbx
-------------------------------------
sec   rsa4096/156C485C2EB2C1D6 2023-10-23 [SC]
      F5FEE1EF836C62F5361A643B156C485C2EB2C1D6
uid                 [ultimate] Jasmerah1966 (GPG sign key untuk GitHub) <jasmerah1966@example.com>
ssb   rsa4096/04951FB42332019F 2023-10-23 [E]
```

Kemudian jalankan perintah berikut untuk mendapatkan GPG key dalam format **ASCII armor**:

```shell
gpg --armor --export 156C485C2EB2C1D6
```

> _**Catatan**: Ubah key ID milik saya diatas (`156C485C2EB2C1D6`) dengan key ID milik Anda._

Copy GPG key Anda (diawali dari `-----BEGIN PGP PUBLIC KEY BLOCK-----` sampai `-----END PGP PUBLIC KEY BLOCK-----`) yang setelah ini perlu Anda tambahkan ke akun GitHub Anda.

### Menambahkan GPG Ke Akun GitHub Anda

1. Masuk ke __"Settings"__ > __"SSH and GPG keys"__ > Klik tombol __"New GPG key"__.
2. Isi __"Title"__ dengan apapun yang mudah Anda ingat untuk mengidentifikasi _GPG key_ Anda.
3. Masukkan GPG key Anda ke _textarea_ __"Key"__. Setelah itu klik tombol __Add GPG key"__.

## Melakukan Signing Commit
Jika sudah disetting dengan benar, Anda bisa melakukan commit dengan perintah `git commit -S` atau `git commit -S -m 'Pesan commit kamu'`

Untuk signing dengan **S/MIME** saya belum pernah memiliki kesempatan untuk mencoba. Mungkin jika ada yang ingin menambahkan silahkan ditambahkan dengan melakukan pull request.

Semoga membantu.
