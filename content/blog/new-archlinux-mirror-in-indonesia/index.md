---
title: "New Archlinux Mirror in Indonesia"
description: "New archlinux mirror repository in Indonesia and it's Grafana monitoring metrics."
date: 2023-02-17T08:36:36+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  -
categories:
#  -
tags:
    - Arch Linux
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

Yesterday, on February 16th, 2023, I made a [feature request][feature-request]
so that my **Arch Linux** repository mirror can be added to the **official Arch
Linux repository**. And now it's already listed on the [official Arch Linux
mirror page][official-archlinux-mirror-page]! Yay! Thank you, [Anton
Hvornum][anton-hvornum] and Arch Linux Mirror Team!

{{< youtube tO44l_oVO2A >}}

## Mirror Information

Location: **Indonesia Data Center Duren Tiga** (IDC3D) Jakarta, Indonesia (ID)

URL:

- `http://mirror.ditatompel.com/archlinux`
- `https://mirror.ditatompel.com/archlinux`

Bandwidth: **1Gbps**

At the time this article was written, `mirror.ditatompel.com` **synchronizes to
the Tier 1 mirror every 2 hours**.

To use this mirror, simply add the following configuration to your
`/etc/pacman.d/mirrorlist`:

```plain
Server = http://mirror.ditatompel.com/archlinux/$repo/os/$arch
Server = https://mirror.ditatompel.com/archlinux/$repo/os/$arch
```

Alternatively, you can use the `reflector` package (`pacman -S reflector`) to
search and generate the fastest mirror for you. For example:

```shell
reflector --verbose -l 10 -f 10 --sort rate
```

## Public Monitoring

For official mirrors, the **Arch Linux** website itself provides monitoring
that can be accessed at
[https://archlinux.org/mirrors/mirror.ditatompel.com/][official-archlinux-mirror-page].

However, I provide [monitoring for the mirror.ditatompel.com server through
Grafana][mirror-grafana], which can be accessed without having to log in / have
an account on my Grafana server.

[feature-request]: https://bugs.archlinux.org/task/77542 "My feature request for official mirror"
[official-archlinux-mirror-page]: https://archlinux.org/mirrors/mirror.ditatompel.com/ "mirror.ditatompel.com details page on archlinux.org"
[anton-hvornum]: https://bugs.archlinux.org/user/15638 "Anton Hvornum, ArchLinux mirror admin"
[mirror-grafana]: https://monitor.ditatompel.com/d/mirror-ditatompel-com/mirror-ditatompel-com?orgId=2&refresh=1m "Mirror monitoring through Grafana"
