---
title: "PHP Email Advanced Validation (Format, MX Host, SMTP Mailbox)"
description: "A simple PHP script for validating email addresses using format, MX record, and SMTP mailbox checks."
summary: "A simple PHP script for validating email addresses using format, MX record, and SMTP mailbox checks."
date: 2012-10-14T20:02:21+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
series:
#  -
categories:
  - Programming
tags:
  - PHP
images:
authors:
  - ditatompel
---

It cannot be denied that on the internet, the existence of email is very important. With email, information can arrive very quickly even if the sender and recipient are on two different continents. Apart from that, email remains a popular choice for companies and developers to convey information to their customers.

This time, I'd like to share a simple PHP script to validate email addresses via writing format, MX record, and SMTP mailbox checks.

To validate an email address, we can do several things. Specifically, this involves checking the email's writing format, verifying the MX record on the domain you want to check, or even connecting to the destination SMTP server to determine the target user's whereabouts.

The source code is available for download at `http://go.webdatasolusindo.co.id/scripts/php/email-advanced-validation.php` or at `http://pastebin.com/yyjChgKF`.

## 1. Validate Email Format

The email format commonly used is as follows:

- `username@domain.com`
- `Username`: the intended recipient's name.
- `domain.com`: the domain name where the user is located.

However, this format validation has a weakness: we don't know whether the domain actually hosts a mail server. For instance, the email address `username@domaininvalid.com` will be considered valid, even though the domain does not exist. To ensure the domain's validity or nonexistence, we can check via the MX record.

## 2. Validate MX Records

The MX Record function typically delegates email for a domain/host to its destination mail server.

For example, running the command `dig wds.co.id MX +short`:

```plain
30 aspmx3.googlemail.com.
0 aspmx.l.google.com.
10 alt1.aspmx.l.google.com.
20 alt2.aspmx.l.google.com.
30 aspmx2.googlemail.com.
```

![dig record](php-email-dig_mxrecord.png#center)

This will display the MX Record for the domain `wds.co.id`.

By querying the MX record, it can be concluded that this domain allows email addresses. However, this validation has a weakness: we don't know whether the user on the domain actually exists.

For instance, the email address `fake.account@wds.co.id` will be considered valid even though the fake account does not exist on the targeted mail server.

To determine the user's actual existence, we can further develop this by connecting to the destination SMTP server.

## 3. Validate SMTP Mailbox

By connecting to the SMTP server, we can determine whether the user on the domain actually exists or not. For example, I use `telnet` to connect to port `25` (the default SMTP port) and execute SMTP commands.

```plain
dit@tompel ~ $ telnet aspmx3.googlemail.com 25
Trying 74.125.137.26...
Connected to aspmx3.googlemail.com.
Escape character is '^]'.
220 mx.google.com ESMTP c2si11647357yhk.33
HELO aspmx3.googlemail.com
250 mx.google.com at your service
MAIL FROM: <ditatompel@devilzc0de.org>
250 2.1.0 OK c2si11647357yhk.33
RCPT TO: <christian.dita@wds.co.id>
250 2.1.5 OK c2si11647357yhk.33
QUIT
221 2.0.0 closing connection c2si11647357yhk.33
Connection closed by foreign host.
dit@tompel ~ $ telnet aspmx3.googlemail.com 25
Trying 74.125.137.26...
Connected to aspmx3.googlemail.com.
Escape character is '^]'.
220 mx.google.com ESMTP w4si11351321yhd.42
HELO aspmx3.googlemail.com
250 mx.google.com at your service
MAIL FROM: <ditatompel@devilzc0de.org>
250 2.1.0 OK w4si11351321yhd.42
RCPT TO: <fake.account@wds.co.id>
550-5.1.1 The email account that you tried to reach does not exist. Please try
550-5.1.1 double-checking the recipient's email address for typos or
550-5.1.1 unnecessary spaces. Learn more at
550 5.1.1 http://support.google.com/mail/bin/answer.py?answer=6596 w4si11351321yhd.42
QUIT
221 2.0.0 closing connection w4si11351321yhd.42
Connection closed by foreign host.
```

![SMTP commands](php-email-telnetsmtp.png#center)

Pay attention to the initial telnet connection:

```plain
RCPT TO: <christian.dita@wds.co.id>
250 2.1.5 OK c2si11647357yhk.33
```

and the second telnet connection:

```plain
RCPT TO: <fake.account@wds.co.id>
550-5.1.1 The email account that you tried to reach does not exist. [ Blah blah blah... ]
```

On the first connection, it appears that the mail server wants to receive email for the intended recipient. On the second connection, the mail server does not want to receive email for the intended recipient.

Therefore, it can be concluded that the user `fake.account` in the `wds.co.id` domain does not actually exist.

Based on these three validations, I developed this basic concept of my **PHP E-Mail Advanced Validation** script.
