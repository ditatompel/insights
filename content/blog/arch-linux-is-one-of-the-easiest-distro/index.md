---
title: Arch Linux is One of the Most Easiest Distributions
description: Arch Linux could be one of the easiest distributions for those with prior Linux experience who want to read the documentation.
summary: Arch Linux could be one of the easiest distributions for those with prior Linux experience who want to read the documentation.
keywords:
    - Linux
    - Arch Linux
date: 2024-07-20T12:21:01+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
categories:
    - TIL
tags:
    - Linux
    - Arch Linux
authors:
    - ditatompel
---

In 2011, I had an interesting experience when I tried to register on the [Arch Linux forum](https://bbs.archlinux.org/). An additional security question indirectly stated that, _"If you are not a Linux operating system user, you cannot register."_ Are you curious about what the security question looks like? This is what the additional questions looked like when I tried to register on the Arch Linux forum at the end of 2011.

![Security question Arch Linux forum registration in 2011](arch-forum-sec-question-2011.png#center)

From the additional security question above, it's clear that it's impossible for someone who is not a Linux user to provide the desired output from `date -u +%W$(uname)|sha256sum|sed 's/\W//g'`.

The absence of a GUI installer, the need to configure partitions, network connectivity, and display manager independently are some of the main reasons why Arch Linux was considered one of the most challenging and "elite" distributions.

Arch Linux is definitely not a distribution for people who have never used Linux before; that's for sure. The initial challenges gave the impression that Arch Linux was an _"elite"_ distro where only Linux experts were suitable to use it.

## Feeling of Superiority to Users of Other Linux Distributions

The initial challenges presented by the installation process also led to the emergence of "elites" who felt superior to users of other Linux distributions that featured GUI installers, such as Fedora, Debian, Ubuntu, and others.

I can relate to this feeling because I too experienced a sense of superiority when I first successfully installed and configured my system from scratch, covering aspects like partitioning, locales, keyboard layout, timezone, network connectivity, and NTP, all the way up to setting up a window manager via CLI.

However, that sense of superiority eventually dissipated as I realized that, in reality, I am just an **ordinary** Linux user, much like the average user of other Linux distributions. I am not a kernel maintainer, nor have I ever had or possess the ability and experience to contribute to the Linux kernel. I'm also not a distro maintainer or tester; I was foolish to consider myself a "Linux expert" or an "elite."

If you genuinely want to be regarded as elite, try setting up [BLFS](https://www.linuxfromscratch.org/blfs/) and use it as your daily driver; then I can admit that you're very competent and patient in building Linux systems (and have impressive hardware too 👍).

## Arch Linux Isn't That Scary

Please note that Arch Linux is not the only Linux distribution that requires manual installation and configuration. [Gentoo](https://www.gentoo.org/), for instance, is similar in this regard. While I personally like Gentoo, my hardware limitations prevent me from compiling most packages using `Portage`, making it unsuitable as my daily driver. These limitations make me consider Gentoo to be more challenging than Arch Linux.

For those of you who already have prior experience with Linux and are comfortable working with CLI, Arch Linux could be the easiest distribution for you, as long as:

-   You have the time and willingness to read the documentation.
-   You adhere to the KISS principle (_Keep It Simple, Stupid_).

### Easy Installation

The Arch Linux installation process that many people describe as difficult is actually quite straightforward if you're comfortable working with the Linux CLI. The few times I installed Arch Linux, I simply followed the official [Installation Guide](https://wiki.archlinux.org/title/Installation_guide), which was largely a matter of copying and pasting commands.

{{< youtube Pb66WXYxJHY >}}

Furthermore, the presence of `arch-install-script` makes the Arch Linux installation process even more accessible.

After completing the initial "base" install, the process of setting up a GUI, such as a window manager or desktop environment, is also relatively easy and well-documented. all I need to do is visit the [Arch Wiki](https://wiki.archlinux.org/), look for information relevant to my needs, read, and follow the instructions as needed.

### Breaking Changes

In the 2010s, I encountered several issues with performing full system upgrades, some of which were quite significant and required extra time to find solutions and fixes.

However, in recent years, I've found that the `core` package maintained by the [Arch Linux Developers](https://archlinux.org/people/developers/) is very stable for daily use. Moreover, the `extra` packages maintained by the [Arch Linux Package Maintainers](https://archlinux.org/people/package-maintainers/) are also relatively stable, with major problems rarely occurring during or after upgrades. This stability can be attributed to the combined efforts of the [Arch Testing Team](https://wiki.archlinux.org/title/Arch_Testing_Team) and upstream software developers.

For personal desktop/PC usage, I find that doing long-term [maintenance](#maintenance) on Arch Linux is easier and more enjoyable compared to point-release distributions.

## The Hard Part

The following points generally apply to any Linux distribution, not specifically to Arch Linux.

### Keeping It Simple

**Pacman**, the package manager for Arch Linux, is incredibly powerful. Additionally, the existence of the [Arch Buld System](https://wiki.archlinux.org/title/Arch_build_system) and the [Arch User Repository](https://wiki.archlinux.org/title/Arch_User_Repository) makes it easy to install software outside of the `core` and `extra` packages.

However, this convenience and ease of use can make it difficult to resist installing something that's not really needed. The more software installed, the more complex the system becomes, especially when dealing with dependencies that often give rise to their own problems.

### Maintenance

From my experience as a Linux system administrator, maintaining a system for the long term is hard, regardless of whether it's a point-release or rolling-release distribution.

Point-release distributions are known for being stable, meaning they remain relatively stable as long as they're still within their support period. However, when a point-release distro's enters its "end-of-life" period, upgrading to the next major version can be a nightmare. I recall the experience of having to upgrade from CentOS 5 to CentOS 8 (Ohh.. I really miss that CentOS era).

Meanwhile, Arch Linux is a rolling-release distribution where you receive updates as soon as upstream software is released. The advantage is that you get the latest software when performing a full system upgrade (`pacman -Syu`). However, this also means that the possibility of "breaking changes" is much greater than with point-release distributions.

### Security

Computer and network security is inherently difficult. Period.

## Notes

Regarding the internet meme "_I use Arch BTW_". I love the meme and want to share what's in my mind when using it:

1. As a joke.  
   Because it's a meme.
2. To seek help by providing more specific information.  
   When I encounter a problem and create a topic/thread in an online forum, the use of the meme essentially says "_Hey, I'm having this problem ... My operating system is... My distro is... Does anyone having this similar issue? How you fix that? Plese help by sharing your experience._".

So, I used that meme with absolutely no intention of assuming I'm "superior". Not at all.

And for those who consider themselves "superior" to other Linux users; whatever distro you use, remember that you (and I) are nothing more than just an
average Linux user.
