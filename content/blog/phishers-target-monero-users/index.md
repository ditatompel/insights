---
title: "Beware, Phishers Target Monero Users"
description: I received a suspicious email claiming to be from the Monero Development Team, the email was a phishing scam designed to trick users into installing 'remote desktop' through an 'update' package.
summary: I received a suspicious email claiming to be from the Monero Development Team, the email was a phishing scam designed to trick users into installing 'remote desktop' through an 'update' package.
date: 2025-05-21T00:20:00+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - Security
tags:
    - Monero
    - Email
    - Scam
images:
authors:
    - ditatompel
---

> _I'm aware that most Monero users are tech-savvy and it is not easy to trick
> them with scams and phishing like this. So this article is only informational
> and precautionary._

On May 18, 2025, I received a spam email with the following subject: _"Monero
Interface Update: Desktop Enhancements, CLI Improvements, and Browser-Based
Access"_.

## The Email

This caught my attention because email is a communication medium that is rarely
used by the Monero community. I opened the email and it contained information
about a major update and several improvements for the Monero GUI wallet. They
also introduced a browser extension for the Monero Wallet. At the very bottom
of the email, it said the email came from the _"Monero Development Team"_ which
is unreasonable.

![content of email scam](xmr-scam-01.jpg#center)

Why do I call it unreasonable? Because I believe that the **Monero Core Team**
never sends updates to Monero users via email. The Core Team write an update
overview [every release][release-page] in their [GitHub repository][monero-gh],
then the Monero community such as [reuvo-xmr][revuo-xmr],
[monero.observer][monero-observer], [Monero Talk][monerotalk-yt], etc. helps
spread the news through their respective media.

From here, I decided to dig up more information. The email was sent via the
`monero [at] business-data-lighthouse [dot] com` using the **Amazon SES**
service. Although SPF, DKIM and DMARC records status is "passed", the email is
clearly not from `getmonero.org`.
![mail header](xmr-scam-02.jpg#center)

And it worth to mention that none of the sender domain name and Amazon SES
services are listed in `getmonero.org` **SPF record**.

Output of `drill getmonero.org TXT -t | grep spf`:

```plain
getmonero.org.	284	IN	TXT	"v=spf1 mx ptr a:mail.getmonero.org ip4:74.220.215.227 ip4:74.220.200.165 include:_spf.google.com ~all"
```

## The Phishing Site

I decided to visit the download link listed in the email. The link leads to the
sub-domain `app [dot] getmoneroupdate [dot] org` which looks almost exactly the
same as the [download page on getmonero.org][monero-download-page]. The only
difference is in the download link for each operating system and CPU
architecture. ![phishing page](xmr-phishing-page.jpg#center)

## Install on VM

I didn't find the _promised_ browser extension download link in the email, but
the `.exe` file, MacOS and Debian packages pointed to `amandinetv [dot] com`
domain. Curious about what the "malware" was like, I decided to running the
`.deb` package on an Ubuntu virtual machine. I couldn't install it with the
`dpkg -i` command due to dependency problem, but it seemed like the package
could be installed using the **App Center** (by double click on it).
![app center](app-center.jpg#center)

## Process, Init Script and tcpdump

After the application was installed, I tried to find information about whether
the application was opening a port, but I didn't find it either on TCP or UDP.
But from the `ps` command, it was seen that a Java program called
`connectwisecontrol` was running.
![ps command output](ps-output.jpg#center)

I tried to see the _init script_ used to run the process and found several
command parameters and properties in the form of _inflated base64_.
![init script](init-script.jpg#center)
Since I was too lazy to "decode" the inflated base64 string using many
web-based base64 deflate tool out there, I use `tcpdump` instead to find
information about where the process was communicating. The result of tcpdump
shows that the process is communicating to the control server (PTR record
`23-95-162-71-host.colocrossing.com`) on port `8041`.
![tcpdump](tcpdump.jpg#center)

I searched for information about the connectwise application and found that
**ConnectWise Control** is a remote desktop application that allows users to
control and access target PCs via the internet. I personally never used
ConnectWise Control (in fact, this is my first time I hear about it), but if it
is something like RustDesk or AnyDesk, it is likely that the victims computer
can be taken over by an attacker by utilizing the application.

[get-monero]: https://www.getmonero.org "The Monero Project Official Website"
[monero-download-page]: https://www.getmonero.org/downloads/ "getmonero.org Download Page"
[monero-gh]: https://github.com/monero-project/monero "Monero GitHub Repository"
[release-page]: https://github.com/monero-project/monero/releases "The Monero Project Release Page"
[revuo-xmr]: https://www.revuo-xmr.com/ "Revuo Monero Website"
[monero-observer]: https://monero.observer/ "Monero Observer"
[monerotalk-yt]: https://youtube.com/c/monerotalk "Monero Talk YouTube Channel"
