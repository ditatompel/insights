---
title: "Cloudflare Reverse Proxies are Dumping Uninitialized Memory"
description: "Between 22 Sep 2016 – 18 Feb 2017 passwords, private messages, API keys, and other sensitive data were leaked by Cloudflare to random requesters."
date: 2017-02-25T23:25:58+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Security
  - Privacy
tags:
  - Cloudflare
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

Between 22 Sep 2016 – 18 Feb 2017 **passwords**, **private messages**, **API keys**, and other **sensitive data were leaked by Cloudflare** to random requesters. Data was *cached* by search engines, and may have been collected by random adversaries over the past few months. Many people call this issue **Cloudbleed**.

<!--more-->

This bug reported by [Tavis Ormandy](https://twitter.com/taviso) from [Google's Project Zero](https://bugs.chromium.org/p/project-zero/issues/list). He was seeing corrupted web pages being returned by some HTTP requests run through Cloudflare. Once they understood what they see and the implications, they stopped and contacted cloudflare security.

## Cloudbleed Impact
Requests to sites with the HTML *rewrite* features enabled triggered a pointer math bug. Once the bug was triggered the response would include data from ANY other Cloudflare proxy customer that happened to be in memory at the time.

Meaning a request for a page with one of those features could include data from [Uber](https://www.uber.com/) or one of the many other customers that didn't use those features. So the potential impact is every single one of the sites using Cloudflare's proxy services (including HTTP & HTTPS proxy).

Here's a random example of the data Google's Project Zero Member are finding and purging.

![Cloudbleed Dump](cloudbleed-1.png#center)

![Fitbit](cloudbleed-2.png#center)

![a private message from a popular dating site, **okcupid**](cloudbleed-3.png#center)

> _The greatest period of impact was from February 13 and February 18 with around 1 in every 3,300,000 HTTP requests through Cloudflare potentially resulting in memory leakage (that's about 0.00003% of requests), potential of 100k-200k paged with private data leaked every day — [source](https://news.ycombinator.com/item?id=13719518)_

Confirmed affected domains found in the wild: [http://doma.io/2017/02/24/list-of-affected-cloudbleed-domains.html](http://doma.io/2017/02/24/list-of-affected-cloudbleed-domains.html).

## Detailed Timeline
_\* Time in **UTC**_

- 2017-02-18 0011 [Tweet](https://twitter.com/taviso/status/832744397800214528) from [Tavis Ormandy](https://twitter.com/taviso) asking for Cloudflare contact information.
{{< tweet user="taviso" id="832744397800214528" >}}
- 2017-02-18 0032 Cloudflare receives details of bug from Google
- 2017-02-18 0040 Cross functional team assembles in San Francisco
- 2017-02-18 0119 Email Obfuscation disabled worldwide
- 2017-02-18 0122 London team joins
- 2017-02-18 0424 Automatic HTTPS Rewrites disabled worldwide
- 2017-02-18 0722 Patch implementing kill switch for cf-html parser deployed worldwide
- 2017-02-20 2159 SAFE_CHAR fix deployed globally
- 2017-02-21 1803 Automatic HTTPS Rewrites, Server-Side Excludes and Email Obfuscation re-enabled worldwide

Source : [Cloudflare](https://blog.cloudflare.com/incident-report-on-memory-leak-caused-by-cloudflare-parser-bug/)

## What should I do?
Check your password managers and change all your passwords, especially those on these affected sites (below). Rotate API keys & secrets, and confirm you have 2FA set up for important accounts. This might sound like fear-mongering, but the scope of this leak is truly massive, and due to the fact that all Cloudflare proxy customers were vulnerable to having data leaked, it's better to be safe than sorry.

Theoretically sites not in this list can also be affected (because an affected site could have made an API request to a non-affected one), you should probably change all your important passwords.

## Full List Sites
[Download the full list.zip (22mb)](https://github.com/pirate/sites-using-cloudflare/archive/master.zip?ref=rtd.ditatompel.com).
4.287.625 possibly affected domains. Download this file, unzip it, then run :
```bash
grep -x domaintocheck.com sorted_unique_cf.txt
```
to see if a domain is present.

Also, a list of some [iOS apps](https://www.nowsecure.com/blog/2017/02/23/cloudflare-cloudbleed-bugs-impact-mobile-apps/) that may have been affected.

## Methodology
According to [Nick Sweeting](https://github.com/pirate), this list was compiled from 3 large dumps of all Cloudflare customers provided by crimeflare.com/cfs.html, and several manually copy-pasted lists from stackshare.io and wappalyzer.com. Crimeflare collected their lists by doing NS DNS lookups on a large number of domains, and checking SSL certificate ownership.

He scraped the Alexa top 10,000 by using a simple loop over the list:
```bash
for domain in (cat ~/Desktop/alexa_10000.csv)
    if dig $domain NS | grep cloudflare
        echo $domain >> affected.txt
    end
end
```

The Alexa scrape, and the Crimeflare dumps were then combined in a single text file, and passed through `uniq | sort`.

## Data sources
- [https://stackshare.io/cloudflare](https://stackshare.io/cloudflare)
- [https://wappalyzer.com/applications/cloudflare](https://wappalyzer.com/applications/cloudflare)
- DNS scraper running on Alexa top 10,000 sites (grepping for cloudflare in results)
- [https://www.cloudflare.com/ips/](https://www.cloudflare.com/ips/) (going to find sites that resolve to these IPs next)
- [http://www.crimeflare.com/cfs.html](http://www.crimeflare.com/cfs.html) (scrape of all Cloudflare customers)
- [http://www.doesitusecloudflare.com/](http://www.doesitusecloudflare.com/)

You can also contact [Nick Sweeting](https://github.com/pirate) on twitter [@theSquashSH](https://twitter.com/theSquashSH) if you believe your site is not affected, submit a PR on github.

## Sources
- [https://www.reddit.com/r/sysadmin/](https://www.reddit.com/r/sysadmin/)
- [https://github.com/pirate/sites-using-cloudflare/blob/master/README.md](https://github.com/pirate/sites-using-cloudflare/blob/master/README.md)
- [https://blog.cloudflare.com/incident-report-on-memory-leak-caused-by-cloudflare-parser-bug/](https://blog.cloudflare.com/incident-report-on-memory-leak-caused-by-cloudflare-parser-bug/)