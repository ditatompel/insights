---
title: "Accessing Reddit Without VPN Using Libreddit"
description: "For individuals who face difficulties accessing Reddit in Indonesia due to ISP restrictions, using libreddit provides an alternative and easy means of accessing the platform without relying on a VPN."
summary: "For individuals who face difficulties accessing Reddit in Indonesia due to ISP restrictions, using libreddit provides an alternative and easy means of accessing the platform without relying on a VPN."
date: 2023-06-04T23:13:33+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  -
categories:
  - TIL
  - Privacy
tags:
  - Reddit
  - libreddit
images:
authors:
  - vie
  - jasmerah1966
---

Recently, many users in Indonesia have been experiencing difficulties in accessing Reddit due to Internet Service Provider (ISP) restrictions (read: "[New Stage of Internet Censorship in Indonesia: DPI & TCP Reset Attack]({{< ref "/blog/new-stage-of-internet-censorship-in-indonesia-dpi-tcp-reset-attack/index.md" >}})"). This issue has led to the development of various solutions that allow users to bypass these restrictions and access Reddit seamlessly.

One such solution is libreddit, a web-based application that enables users to access Reddit without the need for a Virtual Private Network (VPN). In this article, we will explore the features and benefits of using [libreddit](https://github.com/libreddit/libreddit) to access Reddit.

**Libreddit** is, in itself, an unofficial proxy interface for the website `reddit.com`, functioning as a connector between you and the `reddit.com` site.

## Libreddit _instances_

**Libreddit instances** is an engine that runs the `libreddit` program itself. This instance is usually operated by an individual, but there are also groups or organizations that operate a **Libreddit instance**.

Hereafter is a list of some instances you can use:

| URL                              | Location        | Behind Cloudflare? | Comment  |
| -------------------------------- | --------------- | ------------------ | -------- |
| https://reddit.moe.ngo           | 🇮🇩 Indonesia    | ✅                 |          |
| https://safereddit.com           | 🇺🇸United States |                    | SFW only |
| https://lr.riverside.rocks       | 🇺🇸United States |                    |          |
| https://libreddit.privacy.com.de | 🇩🇪Germany       |                    |          |

For a more comprehensive and up-to-date list, please visit [https://github.com/libreddit/libreddit-instances/blob/master/instances.md](https://github.com/libreddit/libreddit-instances/blob/master/instances.md).

## How to use libreddit

Using `libreddit` is extremely easy; all you need is a browser, visit one of the instances above. Once you're on the front page of the instance you've chosen, the first thing you should do is select the subreddit you want to subscribe to.

This way, when you access the `libreddit` instance again in the future, the content that appears on the front page will be from the subreddits you have already subscribed to.

Here's how: search for the subreddit you want to subscribe to using the search bar. For example, [r/indonesia](https://safereddit.com/r/indonesia).

![Search on libreddit](libreddit-1.png#center)

After entering the subreddit page, click the **"Subscribe"** button. Then, posts from the subscribed subreddit will automatically appear on the front page.

## Advantages and Disadvantages

There are always pros and cons. I'd like to start with the disadvantages before moving on to the advantages.

### Disadvantages

The main disadvantage is that we can only browse or view content; we don't have the option to log in (and therefore can't interact with other users by leaving comments, upvoting, downvoting, etc.).

### Advantages

- No need for **VPN**
  To access `libreddit`, you don't need to install or connect to a **VPN** if your ISP blocks Reddit. Simply use a browser and access the Libreddit instance I mentioned above.
- Ad-free
  With libeddit, you can browse postings on Reddit without ads.
- Faster
  From my experience, accessing Reddit using libreddit feels faster and more responsive.
- Privacy
  **Libreddit** only uses "Cookies" to store your "Settings" and subscribed subreddits. These Cookies do not save any personal information about you.
- SFW (Safe For Work) or +NSFW (Not Safe For Work)
  Some `libreddit` instances choose NOT to display NSFW content (**SFW** only), such as [safereddit.com](https://safereddit.com). So, you can feel more "safe" when browsing Reddit there.

## Tips for Using the **Privacy Redirect** Plugin

When searching online using search engines like Google.com, content from Reddit frequently appears in the results. Nevertheless, due to our internet service provider (ISP) blocking access to reddit.com, we are unable to directly access those links.

That's where the [_plugin browser "**Privacy Redirect**"_](https://github.com/SimonBrazell/privacy-redirect) comes in handy. Its job is to redirect (change) the original link to one that we've previously chosen.

For example, when a Google search result shows a link to _https://reddit.com/r/indonesia_, if we click on the link, the **Privacy Redirect** plugin will change it to our preferred Libreddit instance, such as _https://safereddit.com/r/indonesia_.

Currently, this plugin is available at [Firefox Add-Ons](https://addons.mozilla.org/en-US/firefox/addon/privacy-redirect/), [Chrome Web Store](https://chrome.google.com/webstore/detail/privacy-redirect/pmcmeagblkinmogikoikkdjiligflglb), and [Microsoft Edge Add-ons](https://microsoftedge.microsoft.com/addons/detail/privacy-redirect/elnabkhcgpajchapppkhiaifkgikgihj).

To use it, simply install the plugin on your browser, enter "More Options" and input your preferred URL instance into "Reddit Instance".

![Privacy Redirect Plugin](privacy-redirect-plugin.png#center).

You can also easily toggle the redirect feature for each site using the `on` - `off` switch button as shown below:

![Privacy Redirect Plugin Switch](privact-redirect-plugin-swich-on-off.png#center).

## Alternative to Libreddit

In addition to **libreddit**, there is another alternative that works in a similar way (as a _proxy_) called [**teddit**](https://codeberg.org/teddit/teddit). From a visual standpoint, **libreddit** is more similar to the new Reddit design, while **teddit** appears to follow the older Reddit design (`old.reddit.com`).

From a programming language perspective, libreddit uses **Rust**, whereas teddit uses **NodeJS**.
