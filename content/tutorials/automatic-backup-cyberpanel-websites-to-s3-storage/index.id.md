---
title: "Cara Backup Otomatis CyberPanel Website ke S3 tanpa menggunakan CyberPanel Cloud"
description: "Bash script untuk melakukan backup semua website yang ada di CyberPanel ke S3 storage tanpa menggunakan CyberPanel Cloud"
# linkTitle:
date: 2023-02-05T07:35:17+07:00
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
tags:
  - CyberPanel
  - S3
  - Minio
  - Automation
  - Bash
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

Jika di artikel sebelumnya saya pernah membuat artikel tentang bagaimana [cara commit otomatis ke GitHub di CyberPanel tanpa Git Manager]({{< ref "/tutorials/automate-cyberpanel-git-push-without-git-manager/index.id.md" >}}), kali ini saya ingin berbagi cara untuk melakukan backup otomatis semua website di CyberPanel ke *S3 Storage*.

Sebenarnya CyberPanel memiliki fitur bawaan untuk melakukan backup otomatis ke *S3 storage*. Namun untuk menggunakan fitur tersebut, kita harus mengkoneksikan server CyberPanel kita ke **CyberPanel Cloud**.

Sedangkan metode saya ini menggunakan `bash` *script* sehingga dapat digunakan dan diekseskusi secara otomatis melalui *cron* **tanpa harus mengkoneksikan server CyberPanel ke CyberPanel Cloud**.

<!--more-->

## Pre-requisites
Sebelum memulai, ada beberapa pra-syarat yang harus dipenuhi untuk dapat meggunakan metode ini, yaitu: kita memerlukan `S3 client`. Ada banyak opsi yang bisa Anda gunakan, seperti **AWS S3 Client** atau **Minio CLI**. Di kesempatan kali ini, saya menggunakan **Minio CLI** sebagai *S3 client* saya.

## Install dan Mengkonfigurasi S3 Client (Minio CLI)
Di distribusi Linux seperti **Arch Linux**, Minio client bisa diintall dari *package managernya* dengan menjalankan `pacman -S minio-client` dan *binary* minio-client akan disimpan dengan nama `mcli`.

Sedangkan di distribusi lain seperti **Ubuntu**, minio-client dapat diinstall dengan cara mendownload program binary-nya. Ikuti dokumentasi officialnya di [Minio CLI](https://min.io/docs/minio/linux/reference/minio-mc.html).

### Contoh installasi dan konfigurasi Minio CLI di Ubuntu
```bash
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc
chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/
```
Kemudian tambakan `export PATH=$PATH:$HOME/minio-binaries/` ke *system* `$PATH` *variable* ke konfigurasi *shell* yang Anda gunakan (misalnya `~/.bashrc` untuk `bash` atau `~/.zshrc` untuk `zsh`). 

```bash
 echo 'export PATH=$PATH:$HOME/minio-binaries/' >> ~/.bashrc
 ```

### Membuat Alias Untuk S3-Compatible Service di Minio CLI
Jalankan perintah berikut untuk mebuat *alias* pada Minio CLI:
```bash
mc alias set ALIAS HOSTNAME ACCESS_KEY SECRET_KEY
```
* Ubah `ALIAS` dengan nama yang berhubungan dengan *service* S3.
* Ubah `HOSTNAME` dengan *endpoint* URL S3 yang akan digukanan.
* Ubah `ACCESS_KEY` dan `SECRET_KEY` dengan *access* dan *secret key* untuk user pada *service* S3.

Misalnya: 
```bash
mc alias set backup https://s3.amazonaws.com SomERanDomAcceSsKey SomERanDomSeCreTKey
```

## Script Bash Untuk Backup CyberPanel
Setelah S3 *alias* selesai dikonfigurasi, buat `bash` *script* untuk melakukan backup website-website CyberPanel ke S3.

```bash
#!/bin/bash
#title           : backup_cyberpanel_to_s3.sh
#description     : Simple script to backup CyberPanel websites to S3 Storage.
#author          : Christian Ditaputratama <svcadm@ditatompel.com>
#date            : 2023-02-05
#last update     : 2023-02-05
#version         : 0.0.1
#usage           : bash backup_cyberpanel_to_s3.sh
#notes           : This script need S3 client (minio-cli) installed and
#                  configured.
#                  Please read https://rtd.ditatompel.com/automatic-backup-cyberpanel-websites-to-s3-storage
#                  for more information.
#==============================================================================

set -e

MINIO_REMOTE_ALIAS="backup" # your mc `alias` name
MINIO_BUCKET="your-bucket"
MINIO_FOLDER="path/to/remote/folder/"  # Mandatory, don't forget the trailing slash at the end
BACKUP_RETENTION_DAY=7

##### End basic config #####
# stop editing here
div============================================================================

PID_FILE=/tmp/cyberpanel_backup_running.pid

# prevent multiple backup running at the same time
if [ -f "$PID_FILE" ]; then
    echo "Process is running! Exiting..."
    exit 0
fi
touch $PID_FILE

LIST_WEBSITES=$(cyberpanel listWebsitesJson | jq -r '. | fromjson')

for WEBSITE in $(echo "${LIST_WEBSITES}" | jq -r '.[].domain'); do
    echo "Backing up ${WEBSITE}"
    cyberpanel createBackup --domainName ${WEBSITE}

    echo "Uploading to S3..."
    mc mirror /home/${WEBSITE}/backup/ $MINIO_REMOTE_ALIAS/$MINIO_BUCKET/$MINIO_FOLDER${WEBSITE}/ --overwrite
    
    echo "Remove old backup..."
    find /home/${WEBSITE}/backup -type f -name "backup-${WEBSITE}-*.tar.gz" -delete

    mc rm $MINIO_REMOTE_ALIAS/$MINIO_BUCKET/$MINIO_FOLDER${WEBSITE}/ --recursive --dangerous --force --older-than ${BACKUP_RETENTION_DAY}d
done
rm $PID_FILE
```
Ubah *file permission* supaya script tersebut dapat dieksekusi dengan perintah `chmod +x path/to/backup_cyberpanel_to_s3.sh`.

Sesuaikan nilai *variable* dari script berikut agar sesuai dengan nama *alias* Minio CLI, *S3 bucket* dan lokasi folder :
* `MINIO_REMOTE_ALIAS` :  Nama **alias** pada Minio CLI yang sudah kita set sebelumnya
* `MINIO_BUCKET` : Nama **bucket** yang digunakan
* `MINIO_FOLDER` : Lokasi folder pada *S3 storage* tempat kita menyimpan folder. Jangan lupa untuk memberikan `/` pada akhir folder.  
* `BACKUP_RETENTION_DAY` : Seberapa lama (dalam hari) backup pada remote storage (S3) disimpan.

Buat cron job agar script backup tersebut dieksekusi, sesuaikan sesuai kebutuhan:
```
0 * * * * /bin/bash /path/to/backup_cyberpanel_to_s3.sh >/dev/null 2>&1
```