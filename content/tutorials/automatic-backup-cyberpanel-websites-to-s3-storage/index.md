---
title: "Automatic backup CyberPanel websites to S3 Storage without CyberPanel Cloud"
description: "Bash script to automatic backup CyberPanel websites to S3-compatible Storage without connectiong your CyberPanel instance to CyberPanel Cloud"
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

In the previous article, I wrote about how to [automate CyberPanel git push without it's default Git Manager feature]({{< ref "/tutorials/automate-cyberpanel-git-push-without-git-manager/index.md" >}}), today I like to share a way to automatic backup **CyberPanel** websites to S3-compatible Storage without **CyberPanel Cloud**.

<!--more-->

## Pre-requisites
Before starting, there are several prerequisites that must be met to be able to use this method: We need an **S3 client**. There are many options you can use, such as official **AWS S3 Client** or **Minio CLI**. On this article, I'll use the **Minio CLI** as my S3 client.

## Install and configure S3 Client (Minio CLI)
On Linux distributions such as **Arch Linux**, the **Minio client** can be installed using it's *package manager* by running `pacman -S minio-client` and the **minio-client binary** will be saved as `mcli`.

In other distributions such as **Ubuntu**, **minio-client** can be installed by downloading its **binary** program. Follow the official documentation on [Minio CLI page](https://min.io/docs/minio/linux/reference/minio-mc.html).

### Install and configutration example on Ubuntu
```shell
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc
chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/
```
Then add `export PATH=$PATH:$HOME/minio-binaries/` to your *system* `$PATH` *variable* on your shell you use (Ie: `~/bashrc` if you use **bash** or `~/.zshrc` if you use **zsh**).

### Create alias for S3-Compatible service on Minio CLI
Execute this command to create an *alias* on Minio CLI:
```shell
mc alias set ALIAS HOSTNAME ACCESS_KEY SECRET_KEY
```
- Replace `ALIAS` with the name related to your S3 service.
- Replace `HOSTNAME` with your S3 **endpoint** URL .
- Replace `ACCESS_KEY` and SECRET_KEY with your S3 **access** and **secret key**.

Example:
```shell
mc alias set backup https://s3.amazonaws.com SomERanDomAcceSsKey SomERanDomSeCreTKey
```

## bash script for CyberPanel backup
After S3 *alias* is configured, create `bash` script to do a backup job for CyberPanel website to S3.
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

Change script *file permission* so it can be executed with  chmod `+x path/to/backup_cyberpanel_to_s3.sh` command.

Adjust variable values to suit with your environment :
- `MINIO_REMOTE_ALIAS` :  **alias** name that we have previously configured.
- `MINIO_BUCKET` : **bucket** name you use
- `MINIO_FOLDER` : The folder location on S3 storage where we save the folder. Don't forget to put / at the end of the folder.
- `BACKUP_RETENTION_DAY` : How long (in days) the backup on remote storage (S3) is kept.

Then, create a **cron job**, adjust as needed:
```plain
0 * * * * /bin/bash /path/to/backup_cyberpanel_to_s3.sh >/dev/null 2>&1
```
