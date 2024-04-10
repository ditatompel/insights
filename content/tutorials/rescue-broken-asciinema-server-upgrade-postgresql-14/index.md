---
title: "Rescue broken asciinema-server upgrade (PostgreSQL 12 => 14)"
description: "How to rescue broken asciinema-server upgrade that caused by incompatible files in the volume of the old PostgreSQL 12 container with the latest upstream version"
# linkTitle:
date: 2023-03-11T08:52:39+07:00
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
  - Self-Hosted
tags:
  - asciinema
  - PostgreSQL
  - Docker
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

Today, I'm experiencing some problem with my recent self-hosted asciinema server upgrade. After following the upgrade process according to the [asciinema-server documentation page on GitHub](https://github.com/asciinema/asciinema-server/wiki/Installation-guide), the `phoenix` and `postgresql` containers failed to run and kept restarting.

<!--more-->

I'm trying to find information on what causes this to happen. From the *container* log, I got the following error:

> _**(DBConnection. ConnectionError)** connection not available and request was dropped from queue after xxxxms. This means requests are coming in and your connection pool cannot serve them fast enough. You can address this by:_

```plain
By tracking down slow queries and making sure they are running fast enough
Increasing the pool_size (albeit it increases resource consumption)
Allow requests to wait longer by increasing :queue_target and :queue_interval
See DBConnection. start_link/2 for more information
```

Then from the log of the posgreSQL container itself, I found information that **the files in the volume of the PostgreSQL container are not compatible with the one that currently running** :

> _**FATAL**: database files are incompatible with server_   
> _**DETAIL**: The data directory was initialized by PostgreSQL version 12, which is not compatible with this version 14_

So, the root cause likely due database upgrade **from PostgreSQL 12 to PostgreSQL 14**.

From these informations, I decided to:
1. Doing a temporary downgrade so I can back up the previous database.
2. Uninstall and **reinstall** the appropriate version of PostgreSQL from the **master repository**.
3. Restore the database that I have backed up and **hope** that the restore process can run smoothly.

**And it worked!**

## Rescue process
Before begining, I assume that you follow the official installation process.

Enter the `asciinema-server` directory, and **stop all containers** associated with `asciinema-server` by running `docker-compose down`.

Download the latest `asciinema-server` docker image:
```shell
docker pull asciinema/asciinema-server
```

Download the **asciinema** config from *upstream* and **merge it into your branch** (if you haven't already):
```shell
git fetch origin
git merge origin/master

# The commands below are optional
# and depending on your initial asciinema-server installation
git stash
git stash pop
git add .
git commit -m "Local upgrade"
git merge origin/master
```

### 1. Downgrade PostgreSQL to previous running version and back up the old data
After that, edit `docker-compose.yml`, **temporarily** revert **postgres image** from version `14` to your previous version (for me, my previous version was at version `12`).

```yaml
version: '2'

services:
   postgres:
     image: postgres:12-alpine
     container_name: asciinema_postgres
     ### blah blah blah
```
This is necessary so that we can **dump** the PostgreSQL database.

Turn on PostgreSQL, but **leave the other `asciinema-server` services off**.
```shell
docker-compose up -d postgres
```

Perform a backup by running the following command:
```shell
docker exec -it <DOCKER_CONTAINER_ID> pg_dump postgres -U postgres > asciinemadump.sql
```

> _**Note**: Your `DOCKER_CONTAINER_ID` information can be obtained from docker `ps command`._

After the database dump process is complete, turn off the PostgreSQL container by running this command:
```shell
docker-compose down
```
delete all volume data used by the **PostgreSQL container** (default is `./volumes/postgres`).

> _**IMPORTANT**: I recommend that you **back up the directory before permanently deleting it**!_

### 2. Run the upstream version of PostgreSQL
After that, **delete the docker volume for PostgreSQL 12** and use the same PostgreSQL version from upstream (`v14`).

Again, edit `docker-compose.yml` and revert the config according to the upstream version:
```yaml
version: '2'

services:
   postgres:
     image: postgres:14-alpine
     container_name: asciinema_postgres
     ### blah blah blah
```

Turn on PostgreSQL 14, but **leave the other asciinema-server services disabled**.
```shell
docker-compose up -d postgres
```

### 3. Restore PostgreSQL backups
After PostgreSQL that is compatible with the upstream version is running, do the database restore process that we have backed up before.

Copy the `asciinemadump.sql` file to the **Postgres volume** ( default: `./volumes/postgres`) and **change the file permissions** so that the **root user inside the container can read the file**.

Then run the following command to restore the database:
```shell
docker exec -it <DOCKER_CONTAINER_ID> psql -d postgres -U postgres -f /var/lib/postgresql/data/asciinemadump.sql
```

> _**Note**: Your `DOCKER_CONTAINER_ID` will be different from the previous `DOCKER_CONTAINER_ID`. Make sure to use the correct docker container ID._

### 4. Run asciinema-server as usual
After that, run all the `asciinema-server` services as usual (`docker-compose up -d`), and you should be able to **access your self-hosted asciinema-server** again.
