---
title: "Self-Hosted Ghost: How to Upgrade Ghost v4.x"
description: "Step-by-step upgrading Self-Hosted Ghost version 4.x, the latest major version of the product."
# linkTitle:
date: 2021-03-30T21:51:29+07:00
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
  - Ghost
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

Ghost releasing [Ghost 4.0](https://ghost.org/changelog/4/) on March 16, 2021, the latest major version of the product, as well as small refresh of Ghost brand.

<!--more-->

As a prerequisite to using this guide, make sure that you have running Ghost service by following the original [installation guide](https://ghost.org/docs/install/). And before continuing upgrade process to a new [major version](https://ghost.org/docs/faq/major-versions-lts) you need to take care of any [breaking changes](https://ghost.org/docs/changes/).

## Upgrade Step
Whenever doing a manual update **always to take a full backup** of your site first. If anything goes wrong, you'll still have all your data.

### Export Your Theme
It’s a good idea to check whenever your current theme is compatible with Ghost `4.x`. Depending on your current version of Ghost, **you might need to make some changes** to your theme.

To see what changes are need to be made, download a copy of your theme zip file, and upload it to [GScan](https://gscan.ghost.org/) automatic theme compatibility testing tool.

GScan will provide a report on any new features in the Ghost theme API which are not being used, or any old ones you might be using which have been deprecated – so you can get everything fixed up.

### Export Content and Members
Start by exporting a JSON file of all your posts from the **labs area** of Ghost Admin.

Then, make a copy of entire `/content` directory as a backup for themes and images:
```bash
mkdir /backup
cp -rv content /backup/content
```
Members can be exported to a CSV file from the **Members page** of Ghost Admin.

### Upgrade Ghost-CLI
When you're ready, **as your Ghost admin user**, upgrade `Ghost-CLI` using `npm -g` command :
```bash
sudo npm install -g ghost-cli@latest
```

### Update to the latest minor version
Now, after you upgrade `Ghost-CLI` to the latest version, you need to update every site to the latest minor version before upgrading to major version.

**Make sure you’re in your site’s root directory** and then run the Ghost update command using Ghost-CLI **as your ghost admin user**.

For example, if you're on version `3.x` :

```bash
ghost update v3
```
> _**TIPS**: You do not need to upgrade through every major version. For example if you’re on `2.33.0`, you only need to upgrade to `2.38.3` (the latest `2.x` version) first, and then to `4.x`._

>> _**INFO**: the `ghost update` command will inform you of the commands to run to perform the necessary intermediate updates._

### Upgrade to the latest major version
After updating your site(s) to latest minor version, you're ready to upgrade to latest major version. Simply run `ghost upgrade` from your site’s root directory **as Ghost admin user**.

{{< youtube udbaAvl3s3E >}}

## v4.0 Highlight Changelog
- **Dashboard**: Get detailed insights into how content and members are performing, so you can understand what's working.
- **Memberships and subscriptions** are now natively part of the core platform – no longer in beta.
- **Email newsletters** are now natively built into Ghost.
- Brand **new post-preview** UI, showing you what your post will look like on web, mobile, email, social, and search – all in one place.
- Premium subscriptions with **Stripe** now work in **135 currencies**, with support for **Apple Pay**, **Google Pay**, and 0% payment fees.
- Embedded memberships and subscriptions UI, called **Portal**, which works with every Ghost theme. Past, present and future.
- Re-built the Ghost [Theme directory](https://ghost.org/themes/), including live previews and automatic installations.
- **Performance improvement**: Front-end performance jumped by more than 50%, **overall performance** in terms of requests-per-second by 40%, reduced latency by 30%, and made serving requests after start/restart faster by 300%.

## Links and Resources
- [https://ghost.org/changelog/4/](https://ghost.org/changelog/4/)
- [https://ghost.org/docs/update/](https://ghost.org/docs/update/)






