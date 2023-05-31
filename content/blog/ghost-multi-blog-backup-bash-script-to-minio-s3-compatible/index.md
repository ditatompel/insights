---
title: "Ghost multi-blog backup bash script to Minio (S3 Compatible)"
description: "Simple bash script to automatic backup multiple Ghost blog on the same server to remote AWS S3 compatible server."
date: 2023-01-18T07:20:27+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - SysAdmin
tags:
  - Ghost
  - S3
  - Minio
  - Bash
images:
#  - 
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

So, inspired from J[erry Ng's Ghost backup script](https://jerrynsh.com/backing-up-ghost-blog-in-5-steps/) which can be used to backup single blog site to remote storage using `rclone`, I write this script that can be used to automatic backup multi Ghost blog on the same server to remote **AWS S3 compatible server** (in this case Minio) using Minio-CLI.

<!--more-->

## What's backed up?
- `config.production.json` and `package-lock.json` file.
- Everything under `content/` directory.
- MySQL dump database.

Structure of generated backup on remote backup location (S3): `[BUCKET_NAME]/ghost/[WEBSITE_NAME]/[YEAR]/[MONTH]/`.

## Requirements
- Access to Linux Ghost admin user.
- Configured [Minio CLI](https://min.io/docs/minio/linux/reference/minio-mc.html).
- S3 Compatible storage server (in this case Minio)

## Script

```bash
#!/bin/bash
# Backup ghost website(s) to Minio
# Inspired from https://jerrynsh.com/backing-up-ghost-blog-in-5-steps/
# 
# This script also need Minio CLI configured, see:
# https://min.io/docs/minio/linux/reference/minio-mc.html
# Or edit and adapt with your favorite s3 client on
# S3_SECTION below.

set -e

MINIO_REMOTE_ALIAS="myminio" # your mc `alias` name
MINIO_BUCKET="backups"
MINIO_FOLDER="ghost/"        # Mandatory, don't forget the trailing slash at the end

# Array of website, `IFS` property separate by `|`
# `IFS[0]` = website shortname, used to organize backuo folder location on S3
# `IFS[1]` = Ghost website directory
GHOST_WEBSITES=(
    "example_blog1|/path/to/blog1"  # 1st website
    "example_blog2|/path/to/blog2"  # 2nd website
)

##### End basic config #####

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

for WEBSITE in "${GHOST_WEBSITES[@]}"
do
    IFS='|' read -ra WEBPARAMS <<< "$WEBSITE"
    if [ ! -d "${WEBPARAMS[1]}" ]; then
        echo "Folder not exists.. Skipping ${WEBPARAMS[0]}"
    else
        BACKUPDATE=`date +%Y-%m-%d-%H-%M`
        echo "Performing backup ${WEBPARAMS[0]}"
        cd ${WEBPARAMS[1]}
        
        ### ARCHIVE ###
        tar -czf $SCRIPT_DIR/$BACKUPDATE-${WEBPARAMS[0]}.tar.gz content/ config.production.json package-lock.json
        
        ### DATABASE SECTION ###
        db_user=$(ghost config get database.connection.user | tail -n1)
        db_pass=$(ghost config get database.connection.password | tail -n1)
        db_name=$(ghost config get database.connection.database | tail -n1)
        mysqldump -u"$db_user" -p"$db_pass" "$db_name" --no-tablespaces | gzip > "$SCRIPT_DIR/$BACKUPDATE-$db_name.sql.gz"
        
        ### S3_SECTION ###
        # adapt to your env
        mc cp $SCRIPT_DIR/$BACKUPDATE-${WEBPARAMS[0]}.tar.gz $MINIO_REMOTE_ALIAS/$MINIO_BUCKET/$MINIO_FOLDER${WEBPARAMS[0]}/$(date +%Y)/$(date +%m)/$BACKUPDATE-${WEBPARAMS[0]}.tar.gz
        mc cp $SCRIPT_DIR/$BACKUPDATE-$db_name.sql.gz $MINIO_REMOTE_ALIAS/$MINIO_BUCKET/$MINIO_FOLDER${WEBPARAMS[0]}/$(date +%Y)/$(date +%m)/$BACKUPDATE-$db_name.sql.gz
        
        
        # REMOVE LOCAL BACKUP
        rm -f $SCRIPT_DIR/$BACKUPDATE-${WEBPARAMS[0]}.tar.gz
        rm -f $SCRIPT_DIR/$BACKUPDATE-$db_name.sql.gz
	cd $SCRIPT_DIR
    fi

done

exit 0
```
Or you can find it on [https://gist.github.com/ditatompel/dc1d13259df3b945a633f8c0b789bd80](https://gist.github.com/ditatompel/dc1d13259df3b945a633f8c0b789bd80).

## How to use
Edit `MINIO_REMOTE_ALIAS`, `MINIO_BUCKET`, `MINIO_FOLDER` and array of website(s) to `GHOST_WEBSITES` variable. Then you can execute the script using cron.