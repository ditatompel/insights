---
title: "How to install Misskey in Ubuntu 22.04 (Manual without Docker)"
description: "Step-by-step installing Misskey, an open-source social media platform that has been making waves in the world of fediverse enthusiasts"
# linkTitle:
date: 2023-02-24T08:51:58+07:00
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
  - Misskey
  - NodeJS
  - NVM
  - PM2
  - PostgreSQL
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

**Misskey** is an *open-source* social media platform that has been making waves in the world of *fediverse* enthusiasts. As someone who has *recently* discovered Misskey, I can confidently say that it has quickly become my favorite social media platform. From its customizable interface to its community-driven approach, Misskey offers a unique and refreshing experience for users.

<!--more-->

In this article, I want to share my experience **installing Misskey**. There are several ways to create / deploy Misskey instance, from using Docker to manually install all required dependencies. In tis article I choose to use manual installation method.

## Why use the manual installation method, when there is an easier way using docker?
1. **Overhead**. Because **running a containerized app inside a containerized operating system can create additional layers of abstraction, which can lead to increased overhead and reduced performance**. This is because each layer adds a small amount of overhead, and the more layers you have, the more overhead you will incur.
2. I **want to run multiple Misskey instance under one linux container**. Imagine if I run 5 instances and in the same time I should install and run containerized NodeJS and PostgreSQL for each instance.

While running containerized apps inside a containerized operating system can be a convenient way to manage applications, it may not always be the most optimal approach from a performance perspective.

## Requirements
- **NodeJS** `18.13.x` (we will use **NVM** for this)
- **PostgreSQL** `15.x`
- **Redis**
- **FFmpeg**
- **PM2** (optional)

### Install PostgreSQL 15
**PostgreSQL 15 is not available in official Ubuntu 22.04**, you need to enable it's official repository from PostgreSQL itself.
```shell
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null
sudo apt update
sudo apt install postgresql postgresql-client -y
```
Don't forget to start PostgreSQL and make it run on **system startup**.
```shell
sudo systemctl status postgresql
sudo systemctl enable postgresql
```

### Install Redis and FFmpeg
Simply run :
```shell
sudo apt install redis ffmpeg
```
make sure to start Redis and make it run on system startup.
```shell
sudo systemctl start redis-server.service
sudo systemctl enable redis-server.service
```

### Install NodeJS 18 using NVM
> _Install NVM and nodeJS as regular user. **Running commands below as root is not recommended!**_

Download and run NVM install script:
```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
```
When the script is executed, it clones the nvm repository to `~/.nvm`, and attempts to add the `source` lines your profile file (`~/.bash_profile`, `~/.zshrc`, `~/.profile`, or `~/.bashrc`).

Relogin to your server so you can use `nvm` command.

Install required NodeJS version, in this article we need to use NodeJS 18.

```shell
nvm install 18
```
You also need to enable `corepack` :
```shell
npm install -g corepack
corepack enable
```

### Install and build Misskey
Clone the Misskey repository
```shell
git clone --recursive https://github.com/misskey-dev/misskey.git
```

Navigate to the repository, and check out the latest version of Misskey:
```shell
cd misskey
git checkout master
```

Download submodules and install Misskey's dependencies.
```shell
git submodule update --init
pnpm install --frozen-lockfile
```

Run this following command to build misskey. (`python` is required).
```shell
NODE_ENV=production pnpm run build
```

### Configure Misskey
You need to create the appropriate PostgreSQL users with respective passwords, and an empty database for Misskey. The encoding of the database should be `UTF-8`.

```shell
sudo -u postgres psql
```

```sql
CREATE DATABASE <your_db_name> WITH ENCODING = 'UTF8';
CREATE USER <your_misskey_db_user> WITH ENCRYPTED PASSWORD '<YOUR_PASSWORD>';
GRANT ALL PRIVILEGES ON DATABASE <your_db_name> TO <your_misskey_db_user>;
\c <your_db_name>
GRANT ALL ON SCHEMA public TO <your_misskey_db_user>;
\q
```

> _**IMPORTANT**: In PostgreSQL 15, a fundamental change took place which is relevant to every user who happens to work with permissions: The default permissions of the public schema have been modified._

> _The `GRANT ALL ON SCHEMA public TO ...` is needed, otherwise you'll find : `ERROR: permission denied for schema public` message when running database initialisation._

After that, copy `.config/example.yml` to `.config/default.yml` under your Misskey repository.

Edit `.config/default.yml` to fit with your need and environment.

Finally, run the database initialisation:
```shell
pnpm run init
```

## Auto start Misskey
Last, but not least, we need to start Misskey when the system start. You can [auto start Misskey with systemd as described on it's official documentation](https://misskey-hub.net/en/docs/install/manual.html#launch-with-systemd).

### Using PM2 to manage Misskey
Because I love to use PM2 as my NodeJS application manager, I'll use that instead of `systemd`. To install PM2:
```shell
npm install pm2 -g
```
To auto run PM2 at startup as your current user, run **pm2 startup** and follow the output insruction.

Then to run Misskey using PM2:
```shell
pm2 start "NODE_ENV=production pnpm run start" --name <your_process_name>
```
Dont forget to save managed process by PM2 using `pm2 save` command.


## Updating Misskey
To update Misskey that run using NodeJS (via NPM and PM2), you can follow my another article: [Misskey NodeJS (NVM with PM2) update steps]({{< ref "/tutorials/misskey-nodejs-nvm-with-pm2-update-steps/index.md" >}}).

That's it, and welcome to another awesome Fediverse project!

## Resources
- [Misskey-hub.net :official installation page](https://misskey-hub.net/en/docs/install/manual.html)
- [linuxtechi.com: How to Install PostgreSQL 15 on Ubuntu 22.04 Step-by-Step](https://www.linuxtechi.com/how-to-install-postgresql-on-ubuntu/)
- [cybertec-postgresql.com: PostgreSQL ERROR: PERMISSION DENIED FOR SCHEMA PUBLIC](https://www.cybertec-postgresql.com/en/error-permission-denied-schema-public/)

