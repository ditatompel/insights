---
title: "How To Create 'Verified' (Sign) Git Commit Using SSH or GPG Signature (Linux)"
description: "How to add a 'Verified' commit message to GitHub using SSH Signing Key or GPG Signing Key, step by step."
# linkTitle:
date: 2023-10-26T10:33:43+07:00
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
  - vie
---

How to add a **"Verified"** commit message to **GitHub** using **SSH Signing Key** or **GPG Signing Key**.

<!--more-->
---

If you often visit the _commit history_ page of a **GitHub** repository, you may find that there are some _commit messages_ with **"Verified"** badge, unlabeled, or even **"Unverified"** with an orange colored badge.

This feature on GitHub indicates that the _commit_ or _tag_ comes from an authentic source and has been verified by GitHub. This is important so that other users who use the repository are sure that the changes made to the repository are indeed from verified sources.

Until this article was written, there were 3 ways to sign the _commit_ message: by using **GPG signature**, **SSH signature**, and **S/MIME signature**. From those three methods, I want to share my experience using the GPG and SSH signatures method to _signing_ commit.

To follow steps in this article, make sure that your current Git configuration is working without any problems. If you have never set up Git, follow my previous article: [How To Use Git Using SSH Protocol For GitHub]({{< ref "/tutorials/how-to-use-git-using-ssh-protocol-for-github/index.md" >}}).

## Using SSH key signature

The easiest way is using the SSH signature method. You can use the SSH key that you already use for the __Authentication key__ and upload the same _public key_ to use as the __Signing key__.

> _Note: To use the SSH Key Signature method, you need to use Git `2.34` and above._

### Adding SSH key as signing key

To add an SSH key as a __Signing key__ in your GitHub account:

1. Go to __"Settings"__ > __"SSH and GPG keys"__ > Click the __"New SSH key"__ button.
2. Fill in __"Title"__ with whatever you can easily remember to identify your _SSH key_.
3. In the __"Key type"__ section, select __"Signing Key"__.
4. Finally return to the terminal and _paste_ the contents of __SSH public key__ into _textarea_ __"Key"__. After that, click the __Add SSH key"__ button.

### Change the Git configuration on your local computer

After the SSH Signing key has been added to your GitHub Account, you need to change the Git `gpg.format` configuration value to `ssh` by running the following command:
```shell
git config --global gpg.format ssh
```

Finally, update the `user.signingkey` config and enter the location where the **SSH PUBLIC KEY** that you have uploaded is:
```shell
git config --global user.signingkey ~/.ssh/github_key.pub
```
> _Note: Change `~/.ssh/github_key.pub` with the actual location your PUBLIC KEY is stored._

## Using GPG key signature

You can use GPG Key Signature to sign _commit_ messages.

### Generating GPG key

If you don't have a _GPG key pair_ yet, you can create one by running the following command:

```shell
gpg --full-generate-key
```

After executing the command above, you will be asked to complete the information, including:
1. Type: Choose any, I recommend just using the default: `RSA and RSA`.
2. Key size: Fill in between 1024 to 4096. Default 3072. I recommend using `4096`.
3. How long the GPG key is valid: I recommend using the default (`0`, no expiration date).
4. Enter Name and email information. Pay attention when filling in email information, **make sure the email you enter is the same as the email you use on GitHub**.
5. Enter `passharse` your GPG key.

Example output from the `gpg --full-generate-key` command:

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

### Getting your GPG keys information

To see your GPG key list (having a secret key), you can run the following command:

```shell
gpg --list-secret-keys --keyid-format=long
```

Example output from the command above:

```plain
/home/jasmerah1966/.gnupg/pubring.kbx
-------------------------------------
sec   rsa4096/156C485C2EB2C1D6 2023-10-23 [SC]
      F5FEE1EF836C62F5361A643B156C485C2EB2C1D6
uid                 [ultimate] Jasmerah1966 (GPG sign key untuk GitHub) <jasmerah1966@example.com>
ssb   rsa4096/04951FB42332019F 2023-10-23 [E]
```

Then run the following command to get the GPG key in **ASCII armor** format:

```shell
gpg --armor --export 156C485C2EB2C1D6
```

> _**Note**: Change my key ID above (`156C485C2EB2C1D6`) with your key ID._

Copy your GPG key (starting from `-----BEGIN PGP PUBLIC KEY BLOCK-----` to `-----END PGP PUBLIC KEY BLOCK-----`) which after this step, you need to add to your GitHub account.

### Adding GPG to Yyur GitHub Aacount

1. Go to __"Settings"__ > __"SSH and GPG keys"__ > Click the __"New GPG key"__ button.
2. Fill in __"Title"__ with whatever you can easily remember to identify your _GPG key_.
3. Enter your GPG key into _textarea_ __"Key"__. After that, click the __Add GPG key"__ button.

## Signing your commit
If it has been set correctly, you can commit with the command `git commit -S` or `git commit -S -m 'Your commit message'`

For signing with **S/MIME** I have never had the opportunity to try. Maybe if anyone wants to add it, please add it by doing a pull request.

I hope this helps.














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
