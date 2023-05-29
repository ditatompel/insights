---
title: "Story Behind The All New devilzc0de: Migration Process"
description: "The struggle migrating from 1 platform to another platform with different database backend and program languages."
date: 2019-05-22T02:24:04+07:00
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
  - MyBB
  - Discourse
  - Devilzc0de
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

In May 2019, I decided to migrate **devilzc0de** forum from **MyBB** to **Discourse**. Migrating this community forum with more than 300.000 users and more than 600.000 posts and topics to another platform with different database backend and program languages ​​is pain in the a**.

<!--more-->

Everyone know that **MyBB** is an incredibly powerful forum software written in **PHP** and **MySQL** as its database. It **serve devilzc0de community more than 9 years**. But, there are a number of considerations why I moved from **MyBB** to **Discourse**.

First reason is: MyBB doesn't provide **API**'s to access forum data. We need this feature to develop mobile apps and maybe, other **devilzc0de** member need forum API to access their data for their personal website or apps.

Talking about mobile accessibility; compared to Discourse, MyBB less mobile friendly. Some MyBB *themes* may have responsive layout, but it doesn't mean that you can just install them without some tweaks to other installed plugins. In the other hand, Discourse is mobile friendly since fresh install.

## Installation and Migration Process
The initial installation process is quite easy even though I have to make some configuration changes because I need to put **Nginx** in front of Discourse instance.

But the migration process is not as smooth as imagined. 2 GB of RAM in virtual server is unable to import 300.000 users continuously. **Redis** server starting to *crash* when user import process enters about 150 thousand users.

I tried to increase VPS resource from 2GB of RAM to 8GB RAM with 4 CPU cores. With this resource, import process seems to be running well and the Redis server doesn't crash. The VPS server is able to handle more than **1,700,000 queue jobs** when import process is running.

![Discourse Sidekiq Queue](dc-queue-import.png#center)

1 dumbest thing I did is not using `screen`/`tmux` feature when doing import process. While the forum posts import process reached 44%, my home internet connection was interrupted and the scary **broken pipe** appears.

![Broken Pipe](broken-pipe-dc-1.png#center)

With the SSH connection disconnected from the server, I decided to import them all over again **from scratch**. After more than 27 hours, all user data, forum categories and posts was successfully imported. Peace has come to my mind!

![Devilzc0de Migration](27-hours-import-process-1.png#center)

Is it done? Not yet, the emoji from old forum is not yet implemented, the `[spoiler]` tags is broken; so, all posts content need to be remapped. Categories need to be simplified by implementing tags feature for each posts and this can't be done automatically.

It's not an easy task but it's worth for something precious: the family, the community, the spirits for sharing and learning.