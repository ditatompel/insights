---
title: "Devilzc0de Streaming Radio Amarok Script"
description: Since I'm the type of person who finds it difficult to work if there are lots of browser tabs open in the browser, I made a simple script so that devilzc0de radio can be listened to via Amarok.
summary: Since I'm the type of person who finds it difficult to work if there are lots of browser tabs open in the browser, I made a simple script so that devilzc0de radio can be listened to via Amarok.
date: 2011-12-29T03:14:32+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
series:
#  -
categories:
#  -
tags:
  - Amarok
  - Linux
images:
authors:
  - ditatompel
---

_tested on_ :

- OS: **Arch Linux** Kernel `3.x` `x86_64`
- DE: **KDE** SC `4.7.4`
- Qt: `4.8.0`
- Source Code : `http://ls-la.ditatompel.crayoncreative.net/linux/devilzc0de_stream.tar.bz2`

![](dc-amarok2.png#center)

![](dc-amarok3.png#center)

![](dc-amarok4.png#center)

## List Radio Station

- ainstream
  - Devilzc0de Radio
- Radio Bandung
  - Prambors FM
  - Delta FM
- Radio Surabaya
  - Mercury 96FM
  - Prambors FM
  - Delta FM
- Radio Yogyakarta
  - Redjo Buntung
  - Jogjafamily
  - Swaragama
  - Female FM
  - Prambors FM
- Radio Semarang
  - Gajahmada FM
  - TOP FM Bumiayu
  - Female FM
  - Prambos FM
- Radio Jakarta
  - Delta FM
  - Female FM
  - Prambors FM
- Radio Lainnya
  - Kaskus Radio
- Static Stream Crayon Networks
  - Lagu Galauers
  - Instrumental
  - Latest Song Mix

## How to Install

You can install 2 methods, using **Amarok script manager** (_single user_) or manually (_all users_).

### Using Amarok Script Manager (_single user_)

1. Open Amarok
2. Enter **Settings** -> **Configure Amarok** -> **Script** -> **Manage Scripts**
3. Search with _keyword_ **Devilzc0de** -> **Install**

![](dc-amarok1.png#center)

### Manual (_all users_)

```bash
wget http://ls-la.ditatompel.crayoncreative.net/linux/devilzc0de_stream.tar.bz2
```

As `root` user, extract then copy the extracted directory to `/usr/share/apps/amarok/scripts/`.

## How to use

1. Go to the **internet** menu.
2. Select **devilzc0de Radio**.
3. Select the radio station you want to listen to.

Sorry, I haven't had time to create other audio player and desktop environments.

Questions & bugs report to `https://devilzc0de.org/forum/thread-11791.html`.
