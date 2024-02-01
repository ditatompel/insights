---
title: "Rewriting ditatompel.com Site to Svelte, Tailwind and Go"
description: "I plan to rewrite my personal site from the PHP programming language to Go. There are several breaking changes that will occur during and after the transition process."
date: 2024-01-25T16:28:11+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Announcement
tags:
  - Go
  - Svelte
  - Tailwind CSS
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

I plan to “rewrite” my personal site from the PHP programming language to Go. There are several “breaking changes” that will occur during and after the transition process.

<!--more-->
---

To improve my knowledge and experience in the field of web development, I decided to rewrite my entire personal site: [ditatompel.com](https://www.ditatompel.com) which originally used the [PHP programming language](https://www.php.net/) (backend) to the [Go programming language](https://go.dev/). For the frontend, I'll try switching from [Bootstrap](https://getbootstrap.com/) `v4.6` to [Svelte](https://svelte.dev/) and [Tailwind CSS](https://tailwindcss.com/).

It could be said that I took this decision carelessly because I had __only been studying the Go programming language for approximately 6 months__ and I had __never used the Svelte framework before__. So, this will be my first website that uses __Svelte__ as the frontend and __Go__ as the backend.

## Transition Process

I will be working on this project in my free time, so it will likely take a while. During the transition process, I will begin to eliminate the _"offline caching"_ feature on the _service worker_ running in your browser. This is important to do so that when the new __UI__ is launched it does not conflict with the _"offline cache"_ of the old **UI**.

> _Because the "offline cache" in the browser is removed, you will experience slower performance when accessing my site._

## Breaking Changes

To accept the new, sometimes we have to say goodbye to some old features and introduce some important changes. While this may mean saying goodbye to the past, it also means welcoming a future full of endless possibilities 👏👏👏.

Some of the changes that will occur are:
- Temporarily removed the __websocket__ connection on the `/monero` page so that popup notifications will not appear in real time.
- __"Google Trends ™"__ page information does not refer to your browser's _timezone_, but instead refers to the **UTC timezone**.
- Changes to the public API endpoint: which was originally located at `https://www.ditatompel.com/api` will change to `https://api.ditatompel.com`.
- Changes to the json response data structure on several API endpoints which I will provide more detailed information on another occasion.

## What Could Possibly Go Wrong?

If I fail to implement the _service worker_ feature in my latest website version, you will remain stuck with the old application version. The only way to solve this problem is to unregister the old service worker and manually "Clear Website Data" in your browser. This happens because my site currently relies heavily on cache, both on the server and client (browser) side.

---

I will provide the latest updates regarding the transition process on this page. With all these changes, I hope there will be a significant increase in performance both from the frontend and backend.

## Update

### 2024-01-31
- __BREAKING__: __The Monero Public API endpoint__ moved from `https://www.ditatompel.com/api/monero/remote-node` to `https://api.ditatompel.com/monero/remote-node`. See [Public API Monero Remote Node List]({{< ref "/blog/public-api-monero-remote-node-list/index.md" >}}) and [commit diff 013aa7d](https://github.com/ditatompel/insights/commit/013aa7db35edd28e72907d5786fcf8877a5a3e70#diff-a8f1b286fbca7e5d241e20d067c8b17a67b86cc142d10dc7cc23cbc9fcc0e332L139-L167) for more details.

### 2024-01-29
Even though it is still in the beta stage, I have deployed the latest version of the frontend and backend to the production server on January 29 2024. And from the current results of [PageSpeed Insights](https://pagespeed.web.dev/), I am quite satisfied with the performance that I got.

![PageSpeed Insights ditatompel.com mobile](pagespeed-insights-ditatompel-dot-com.png#center)
