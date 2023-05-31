---
title: "Misskey NodeJS (NVM with PM2) update steps"
description: "Misskey is under heavy development and event minor update need higher version of NodeJS. In this article, I want to share my experience how to perform an update to Misskey instances which run using PM2 and NVM"
# linkTitle:
date: 2023-05-20T08:52:58+07:00
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
  - Misskey
  - NodeJS
  - NVM
  - PM2
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

If you following my article about [How to install Misskey in Ubuntu 22.04 (Manual NodeJS and PM2 without Docker)]({{< ref "/tutorials/how-to-install-misskey-in-ubuntu-22-04-manual-without-docker/index.md" >}}), you may encounter some problem when trying to [update your Misskey instances](https://misskey-hub.net/en/docs/install/manual.htmlhow-to-update-your-misskey-server-to-the-latest-version).

<!--more-->

This because **Misskey** is under heavy development and event *minor* update need higher version of **NodeJS**. For example, **Misskey** `13.10.3` was released in March, 25th and it works well with **NodeJS** `18.15`. Last week (May, 12th), *Misskey* `13.12.2` was released and need to be run using (at least) on **NodeJS** `18.16`. In this article, I want to share my experience how to perform an update to **Misskey instances**.

## Install / update required dependencies for new version
First you need to know what is the [minimum requirement (dependencies)](https://misskey-hub.net/en/docs/install/manual.html#dependencies) for the latest *stable* version of **Misskey**, especially for **NodeJS** version and **PostgreSQL**. I'll take example of upgrading **Misskey** from `13.10.3` to `13.12.2` which have different minimum requirement of **NodeJS** version.

### NodeJS
```shell
nvm install 18.16
use 18.16
```
Install `corepack` and enable it from your new **nodeJS** version environment:
```shell
npm install -g corepack
corepack enable
```

### PM2
If you see _"In-memory **PM2** is out-of-date"_ message from *pm2* You may want to update your `pm2` package (optional):

1. Stop and delete all your current **pm2** process (see the processes with `pm2 ps` command):
```shell
pm2 delete nameOfProcess
```
2. If you using `systemd` to start the **pm2** process, **unstartup** it with `pm2 unstartup systemd` and execute the output from your shell.
```shell
pm2 unstartup systemd
```
3. Update and **re-enable pm2** process:
```shell
pm2 update
pm2 startup
```

Don't forget to execute the output of `pm2 startup` command.

## Update Misskey
After all required dependencies is installed, update the **Misskey** app itself. Navigate to your Misskey installation directory and execute these commands:
```shell
git checkout master
git pull
git submodule update --init
NODE_ENV=production pnpm install --frozen-lockfile
NODE_ENV=production pnpm run build
pnpm run migrate
```

Then re-run Misskey using PM2:
```shell
pm2 start "NODE_ENV=production pnpm run start" --name <your_process_name>
```

If you encounter any problems with updating, try to run `pnpm run clean-all` command and **retry the Misskey update process**.



