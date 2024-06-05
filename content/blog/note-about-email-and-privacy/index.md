---
title: "Note About Email and Privacy"
description: "Understanding how email systems work: what information are available from an email message, with strategies for maintaining privacy during information exchange through email."
summary: "Understanding how email systems work: what information are available from an email message, with strategies for maintaining privacy during information exchange through email."
date: 2012-07-28T19:02:22+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
series:
#  -
categories:
  - Privacy
  - TIL
tags:
  - Email
  - SMTP
images:
authors:
  - ditatompel
---

Today, we will attempt to discuss how email systems work; specifically, what information can be obtained from an email message, and strategies for maintaining privacy during information exchange via email.

Before we proceed with discussing email privacy, it would be more advisable to first understand how email systems work and the various aspects related to email privacy.

## How Email Systems Work?

The most common way to send an email is by utilizing your Internet Service Provider's (ISP) or company's mail server. When you click the "**Send**" button, your email software establishes a connection via **Simple Mail Transfer Protocol (SMTP)** with your mail server.

Your mail server then attempts to deliver the message to the target ISP's mail server, and subsequently, the message is delivered to the recipient's **Inbox** on the target ISP's mail server. The stored message can be accessed by the recipient using **Post Office Protocol (POP)** or **Internet Message Access Protocol (IMAP)**.

## How Email Messages are Compromised?

During its transmission, an email message is stored on at least two servers: one at the sender's Internet Service Provider (ISP) mail server and another at the recipient's ISP mail server. When we send emails to banks, companies, business associates, etc., the contents of our email can potentially attract the attention of IT staff monitoring the mail server.

It's worth noting that no system is completely secure, but it is possible to prevent an IT staff member with access to the email server from opening and reading the message. Additionally, unauthorized individuals who have gained access to the email server can also read the contents of our sent emails. Another way for someone to obtain the content of an email is through network traffic sniffing.

## Email Header Privacy

When analyzing an email message, we can obtain a significant amount of information about its sender from its header. This includes IP address, geographical location, time zone, language used, email software employed, and so forth. Such information is often displayed without the sender's knowledge or consent.

For instance, we may not want recipients to know that our system uses Indonesian as the default language or that we are currently located in a country and utilizing one of its local ISPs. All this information can be easily obtained from an email message's header.

Every email message consists of two main parts: the **header** and the **body**. The header contains essential information such as the **subject**, sender's and recipient's email addresses, date and time of sending and receipt, email client used by the sender, and more. This information is typically used to deliver the message, enabling IT staff to perform troubleshooting if there are issues with their mail server.

## Analyzing an Email Header

Here is an example of a message header sent from `sender@gmail.com` to `reciever@yahoo.co.id`, which I have **Bcc**-ed to `hiddenrecipient@list.ru`.

![RAW Email](email-dan-privasi.jpg#center)

```plain
Received: from [209.85.210.45] (port=39452 helo=mail-pz0-f45.google.com)
by mx25.mail.ru with esmtp
```

and

```plain
Received: from [10.69.40.36] ([202.152.202.174])
by mx.google.com with ESMTPS id n10sm65348710pbe.4.2011.09.25.13.16.06
```

There are two pieces of information to be examined.

- The first "Received from" tag originates from IP address 209.85.210.45 and was received by mx25.mail.ru.
- The second "Received from" tag originates from local IP address 10.69.40.36 and the public sender's email IP is 202.152.202.174, received by mx.google.com.

Let us search for information about these two public IPs using the WHOIS feature widely available on the internet:

- 209.85.210.45 [http://api.ditatompel.com/ip/209.85.210.45]([http://api.ditatompel.com/ip/209.85.210.45) (Google)
- 202.152.202.174 [http://api.ditatompel.com/ip/202.152.202.174](http://api.ditatompel.com/ip/202.152.202.174) (PT.
  Bakrie Telecom Tbk)

From here, we can conclude that the sender dispatched an email from ISP Bakrie Telecom Tbk and was received by Mail Exchange of Google.
The trace results provide information on telephone numbers, addresses, emails, and other details from the used ISP (which may be useful if one becomes a victim of fraud or another case).

There are many pieces of information to be gleaned from the above headers, for instance:

The sender employed software **Thunderbird** version `3.1.13` with operating system **Linux** `32 bit`, utilizing local time zone `+7` (Indochina geographical location).

```plain
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.21)
Gecko/20110831 Thunderbird/3.1.13
Date: Mon, 26 Sep 2011 03:16:04 +0700
```

It is also essential to recognize that not all email headers carry comprehensive information like the above; certain details are undoubtedly present, including `from`, `to`, and `subject`. All other data typically accompanies emails from software or servers used for transmission. Usually, users have no control over these headers; the contained information poses a significant threat to email privacy and conveys numerous details about the sender.

## Utilize Secure Email Software

Using genuine and up-to-date email software is a good starting point for email security. If we use email software replete with bugs, the likelihood of being attacked increases significantly, as emails carry information about the vendor and version used.

From the obtained vendor and version details, it would be sufficient to craft a targeted message that exploits software vulnerabilities to attack our computer (using trojans, for instance). The existing loopholes enable attackers to obtain or steal sensitive information such as usernames, passwords, bank account details, personal data, and so on.

All the above scenarios are not merely hypothetical; indeed, this is reality. There are numerous entities offering to infiltrate specific parties via the internet. If our business competitor is willing to spend a considerable amount of money to gather our information, we should be more vigilant.

## HTML Tracker (Image)

Most email applications are capable of rendering emails in HTML format. This is similar to regular browsing, except that the webpage is displayed within the email client's window, rather than a browser.

When viewing an HTML-formatted email, it can embed specific tags, such as image/pre-saved images on the sender's server. This can also be exploited as a tracking tool.

To illustrate how they work, let us imagine that we are running several online women's clothing businesses. We receive an unknown email message as follows:

```plain
From: someuser@yahoo.com
To: customer@foobar.com
Subject: About Victoria Secret
Hello, good day!
How are you?
I'm good here, I want to ask about [bla bla bla]

Regards,
Attacker
```

To grab our attention, the attacker might use tags related to our business, full name, or company name on the "Subject" line. We open the message, and upon noticing it's just spam, we dismiss it.

However, do we realize that the sent email is in HTML format and contains a small, transparent image pre-stored on the attacker's server?

When the attached image is automatically downloaded (rendered) as we read the message, the attacker can analyze the web server logs where the image was stored. From there, it becomes possible for the attacker to obtain some information about us. For instance, the date and time we opened this email, our IP address, operating system, and so on.

![Log Image Tracker](email-dan-privasi_image-mail-log.jpg#center)

This implies that our privacy can be compromised simply by opening an email message, even without responding to it.

## How can we safeguard the privacy of our email communications?

To safeguard the privacy of our email communications, we should employ encryption. The only means of protecting email transmissions is by encrypting them. There are several techniques for accomplishing this.

### PGP and S/MIME: Preeminent Encryption Tools for Secure Email Communications

PGP and S/MIME are used to encrypt the body of an email, leaving the email header unencrypted. This method requires prior agreement between the sender and recipient, involving the exchange of "public keys".

It is essential to note that relying solely on PGP and S/MIME does not guarantee our privacy. Although we use PGP or S/MIME, the email header remains unencrypted and will be transferred in plain text over the Internet unless we also utilize the SSL/TLS protocol.

### The SSL/TLS Connection: A Crucial Layer of Protection

SSL/TLS can be used to encrypt the entire email transmission flow from sender to receiver. With an encrypted connection, SSL/TLS prevents anyone from conducting network sniffing when the message is sent and received by the intended recipient (at least until the email arrives in the inbox of the target email address).

References:

- darkc0de.com archive - Understanding Email Security And Anonimity.
- [http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol](http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol).
