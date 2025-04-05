---
title: "Pacoloco: A Caching Proxy Server For Arch Linux Mirrors"
description: Pacoloco is a caching proxy server designed specifically for Pacman. It runs as a web server that acts like an Arch Linux Mirrors, allowing it to cache and serve packages to users.
summary: Speed up your Arch Linux full system upgrade using Pacoloco, a caching proxy server designed specifically for Pacman.
date: 2025-04-05T15:30:00+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - SysAdmin
    - TIL
tags:
    - Arch Linux
    - Open Source
images:
authors:
    - ditatompel
---

If you're using multiple Arch Linux machines on your local network, you might
be interested in learning about **Pacoloco**. [Pacoloco][pacoloco-repo] is a
caching proxy server designed specifically for **Pacman**, the package manager
of Arch Linux. It runs as a web server that acts like an [Arch Linux
Mirrors][arch-mirrors], allowing it to cache and serve packages to users.

Every time the Pacoloco server receives a request from a user, it downloads the
requested file from a real Arch Linux mirror and bypasses it to the user, while
keeping copies of downloaded packages in local storage.
https://youtu.be/

{{< youtube meVHOzgke10 >}}

## Case Study: Implementing Pacoloco on My Local Network

I have a small number of Arch Linux machines on my local network, including one
virtual machine on **Proxmox** and another KVM on my laptop. I also have an old
[ThinkPad T420](https://tokopedia.link/z7b3wfiGjSb) laptop, which is also
running Arch Linux. To optimize my setup and reduce bandwidth usage, I decided
to run the Pacoloco service on this ThinkPad T420.

### System Requirement

Pacoloco service doesn't require much processing power, so a single-core CPU
with at least 1GB of memory should be sufficient for most users. However, using
a fast Ethernet port and an SSD for its cache storage will provide better
benefits. In my case, the ThinkPad T420 has a **GbE Ethernet port**, which
enables transfer speeds of approximately 110MiB/s on average.

Since Pacoloco does not mirror the entire Arch repository and only downloads
files needed by local users, the local cache size requires very little storage.
In my case, my local cache is only about 6GB. This is because the Pacoloco
service automatically deletes packages that have not been downloaded for a
certain period of time.

### Installing and Configuring Pacoloco

To install Pacoloco, run `sudo pacman -S pacoloco` from your terminal. The
configuration file (`/etc/pacoloco.yaml`) is essential for setting up the
server correctly.

```yaml
# /etc/pacoloco.yaml

# cache_dir: /var/cache/pacoloco
cache_dir: /mnt/msata/Public/pacololo
port: 9129
download_timeout: 3600 ## downloads will timeout if not completed after 3600 sec, 0 to disable timeout
purge_files_after: 2592000 ## purge file after 30 days
# set_timestamp_to_logs: true ## uncomment to add timestamp, useful if pacoloco is being ran through docker

repos:
    archlinux:
        urls: ## add or change official mirror urls as desired, see https://archlinux.org/mirrors/status/
            - http://mirror.ditatompel.com/archlinux
            - https://mirror.ditatompel.com/archlinux
    archlinux-reflector:
        mirrorlist: /etc/pacman.d/mirrorlist ## Be careful! Check that pacoloco URL is NOT included in that file!
## Local/3rd party repos can be added following the below example:
#  quarry:
#    http_proxy: http://bar.company.com:8989 ## Proxy could be enabled per-repo, shadowing the global `http_proxy` (see below)
#    url: http://pkgbuild.com/~anatolik/quarry/x86_64

prefetch: ## optional section, add it if you want to enable prefetching
    #cron: 0 0 3 * * * * ## standard cron expression (https://en.wikipedia.org/wiki/Cron#CRON_expression) to define how frequently prefetch, see https://github.com/gorhill/cronexpr#implementation for documentation.
    cron: 0 */4 * * *
    ttl_unaccessed_in_days: 30 ## defaults to 30, set it to a higher value than the number of consecutive days you don't update your systems. It deletes and stops prefetching packages (and db links) when not downloaded after "ttl_unaccessed_in_days" days that it has been updated.
    ttl_unupdated_in_days: 300 ## defaults to 300, it deletes and stops prefetching packages which haven't been either updated upstream or requested for "ttl_unupdated_in_days".
# http_proxy: http://proxy.company.com:8888 ## Enable this if you have pacoloco running behind a proxy
# user_agent: Pacoloco/1.2
```

Let's break down some of important configuration above:

- `cache_dir` is a directory where packages requested by clients will be
  stored. I changed the default cache directory to another physical disk so
  that it doesn't overwhelm my main disk read and write operation. Please note
  that this directory requires read and write access by the server process.
- In the `repos` section, I added my own mirror. Feel free to use your favorite
  mirrors here.
- Last, I activated the `prefetch` feature, where Pacoloco will automatically
  download package updates that have been requested by users every 4 hours
  (from `cron` config). And I leave the other configurations as they are.

After configuring your `/etc/pacoloco.yaml` file, enable Pacoloco service by
running `sudo systemctl enable pacoloco --now`. Make sure that the service is
active and running by executing `sudo systemctl status pacoloco`.

### Using Pacoloco as Your Arch Linux Mirror

To use Pacoloco as your Arch Linux mirror, add your Pacoloco URL at the top of
your `/etc/pacman.d/mirrorlist` file:

```plain
# change IP and port to your Pacoloco server, default port is 9129
Server = http://192.168.2.22:9129/repo/archlinux/$repo/os/$arch
```

And, that's it. You can do full system upgrade using `sudo pacman -Syu` as
usual. It will fetch the requested packages from your Pacoloco server first.

> **Tips**: When doing a full system upgrade, take the time to visit the
> [official Arch Linux website][arch-web]. On the front page, there is always
> the latest news related to the Arch Linux distribution. Sometimes, this
> information includes whether manual intervention may be required during the
> upgrade process or not.
>
> In addition, also check out the [Arch Linux forum][arch-forum-active-topic]
> because you may find some valuable insights and troubleshooting tips from
> other users who have experienced similar issues when upgrading.

[pacoloco-repo]: https://github.com/anatol/pacoloco "Pacoloco Official GitHub Repository"
[arch-mirrors]: https://archlinux.org/mirrors/ "Arch Linux Mirror Overview Page"
[arch-web]: https://archlinux.org/ "Arch Linux Official Website"
[arch-forum-active-topic]: https://bbs.archlinux.org/search.php?action=show_recent "Arch Linux Forum Active Topic"
