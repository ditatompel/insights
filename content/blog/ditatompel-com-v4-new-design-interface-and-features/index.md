---
title: "ditatompel.com v4: New Design Interface and Features"
url: "blog/2019/05/ditatompel-com-v4-new-design-interface-and-features"
description: "It's about 2 years since I create ditatompel.com (v3) using Material UI. Remake the site back to 2013's design interface using Bootstrap."
date: 2019-05-07T00:57:15+07:00
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
  - NetData
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

It's about 2 years since I create [ditatompel.com](https://www.ditatompel.com/) (`v3`) using **Material UI**, a set of *Facebook's React Components* that Implement *Google's Material Design*. A few day ago, I decide to remake the site back to **2013's** design interface using **Bootstrap**.

<!--more-->

Following [NetData](https://netdata.cloud/) design interface (yes, because it's actually use **NetData** dashboard interface to monitor more than 10 servers in parallels, REAL TIME!), new feature to show [my personal GitHub account](https://github.com/ditatompel) statistics, public repository, and recent GitHub activities was added.

![Old V3 version (React JS)](ditatompel-site-v3.png#center)

In this latest site update, I'm not blocking search engines to crawl and index my site anymore. In addition, old tools and API's are still available up there. Until this article was created, here are the features of my latest site:

- My personal GitHub account statistics (New)   
Placed at the homepage of main site. Showing account statistics, public repositories and recent GitHub activities. These stats are updated every 2 - 5 seconds (except for total push commits).
- Real Time Server Monitoring Demo (New)   
All charts is **real data statistics**, collected from my non-critical servers **in real time**.
- Online MD5 Checker   
Free online *dictionary attack* on *hashed* **MD5** string. I've more than one hundred million unique MD5 hashes.
- [Online Email Validator](https://www.ditatompel.com/tools/email-validator)   
Free online tool for verifying an email addresses format and check its **MX records** from the given lists. I can check up directly to their inbox email address if it exist, but I'm not going to implement it publicly.
- [Various Online String Converter/Generator](https://www.ditatompel.com/tools/string-tools)   
This online utility is primarily intended to help people in converting or calculating strings to different modes.
- [Online DNS Query](https://www.ditatompel.com/tools/dns-query)   
This tool fetch DNS Resource Records associated with a given hostname. Get DNS record for `SOA`, `NS`, `MX`, `A`, `AAAA`, and `TXT`.