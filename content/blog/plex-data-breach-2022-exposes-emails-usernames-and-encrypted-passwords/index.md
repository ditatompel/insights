---
title: "Plex Data Breach 2022 Exposes Emails, Usernames and Encrypted Passwords"
date: 2022-08-29T04:53:11+07:00
lastmod:
draft: false
description: Plex discovered that a third-party was able to access a limited subset of their user data that includes emails, usernames, and encrypted passwords
noindex: false
featured: false
pinned: false
# comments: false
series:
  - Data Breach
categories:
  - Security
tags:
  - Plex
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
  - mr-morningstar
---

A few days ago, I received an email from Plex (an American streaming media service and a client–server media player platform) informing me that they had a data leak. They ask their users to be aware of an incident involving their Plex account information.

<!--more-->

## What happened?

They discovered suspicious activity on one of their databases and immediately began an investigation and it does appear that a third-party was able to access a limited subset of data that includes emails, usernames, and encrypted passwords. According to Plex, even though all account passwords that could have been accessed were hashed and salted and secured in accordance with best practices, out of an abundance of caution they suggest all Plex accounts to have their Plex account password reset. Rest assured that credit card and other payment data are not stored on their servers at all and were not affected in this incident.

## What they're already doing?
They already addressed the method that this third-party employed to gain access to the system, and they're doing additional reviews to ensure that the security of all of their systems is further hardened to prevent future incursions. While the account passwords were secured in accordance with best practices, they suggest all Plex users to reset their password.

## What we can do?
Long story short, they kindly request that we should reset our Plex account password immediately. When doing so, there's a checkbox to *"Sign out connected devices after password change."* This will additionally sign out all of your devices (including any Plex Media Server we own) and require you to sign back in with your new password. This may be a headache, but recommend to increased security. For further account protection, they also recommend enabling [two-factor authentication](https://support.plex.tv/articles/two-factor-authentication/) on your Plex account if you haven't already done so. They have created a support article with step-by-step instructions on [how to reset your Plex password](https://support.plex.tv/articles/account-requires-password-reset/).
