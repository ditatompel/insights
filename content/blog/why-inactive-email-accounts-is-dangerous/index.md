---
title: "Why Inactive Email Accounts is Dangerous"
description: "Malicious users can retrieve deleted email and try to make password reset to every popular sites and original owner will lost their website / app account."
date: 2020-06-29T13:33:45+07:00
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
  - Security
tags:
  - Email
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

Malicious users can retrieve deleted email and try to make password reset to every popular sites and original owner will lost their website / app account.

<!--more-->

> _**DISCLAIMERS**: This entire document is for educational purpose only. Author cannot be held responsible for any damage and (or) (ab)use of these informations._

## Intro
Up until now, email is still one of the most popular communication media between service providers on the internet (can be social media like Facebook, Twitter or forums like devilzc0de, etc.) and their users. Including crucial things like password reset, confirmation codes, etc.

## Deletion of Email Accounts by Service Providers
As internet users, we have to be smart and willing to read every terms and conditions for services we use and follow the updates. Including information about account deletion of inactive email accounts that can be used by other users after several months of grace period.

I'd like to use Yahoo for this example. In the mid 90's, who didn't use Yahoo services? From Search Engines, Yahoo Messenger, to Yahoo Mail dominating the Internet. But how many Yahoo Mail users are AWARE that [their email account can be lost](https://smallbusiness.yahoo.com/advisor/resource-center/yahoo-closing-down-inactive-accounts-223647318/) if it is not accessed within a certain amount of time?

## The danger of Inactive Email
When an email account is deleted and passed over certain amount of time, anyone can use that deleted email account. Here can be a problem when the deleted email account still listed as primary mail for every website/application of the previous user.

Malicious users can retrieve these emails and try to make requests for password reset to every popular sites. If this malicious user lucky enough and find the email address is registered on specific website / app, he will receive password reset information and the original owner will lost their website / app account.

## Proof of Concept
Every email sent from devilzc0de (website I manage) uses SMTP, if there is mail bounce where the message does not reach the destination inbox there must be a return receipt. As a sysadmin, I need to know why the email can't be sent and this return receipt show me the information and take necessary action.

In this scenario, I am a bad (and nasty) admin and I'm sure that the *bounced*-email sent to my forum member was once active. So I've this speculation: This email has been deleted by Yahoo and I can create a Yahoo account using that email address. Later, if the email has been registered on Facebook / Twitter, I can use their forget password feature to takeover Twitter / Facebook account from the original owner.

> _(actually, I never doing this dirty trick. I'm **doing this only once just for this article** and **I don't have any interest of your personal information**)_

And it turned out right, when I tried to log into Yahoo using that email, Yahoo said this:

> _Sorry, we don’t recognize the email._

No need to waste more time, I took the email by creating a new account. After mail registration complete, I just try to "forget the password" on every popular social media account.

{{< youtube 3n4-9MmWjsE >}}

## Special Case for Yahoo Mail outside @yahoo.com Domain
If your yahoo mail account using `@yahoo.co.id` (country base), `@ymail.com`, `@rocketmail.com`, etc. Congratulations, your account is safe because Yahoo only accepts new e-mail account registrations using `@yahoo.com`. Downsides: Recovery will be very difficult, good luck!

## Conclusion
- Internet awesome things, don't complain about privacy issues if you can't keep what belongs to you still belongs to you (in this case is email address).
- Always take time to check e-mails (even if they are all junk) so your e-mails remain active.
- Always update your email / mobile number information if there are changes and take advantage of the 2FA feature if available.
