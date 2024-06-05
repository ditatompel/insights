---
title: "Using GnuPG/PGP for Email Encryption in Thunderbird (2012)"
url: "tutorials/using-gnupg-pgp-for-email-encryption-in-thunderbird-2012"
description: "To safeguard sensitive email content, we can utilize GnuPG/PGP. GnuPG/PGP is employed to encrypt the body or message of an email."
summary: "To safeguard sensitive email content, we can utilize GnuPG/PGP. GnuPG/PGP is employed to encrypt the body or message of an email."
# linkTitle:
date: 2012-07-29T19:47:55+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
series:
#  - Tutorial
categories:
  - Privacy
  - Security
tags:
  - PGP
  - Thunderbird
images:
authors:
  - ditatompel
---

In a previous article [About Email and Privacy]({{< ref "/blog/note-about-email-and-privacy/index.md" >}} "About Email and Privacy"), we discussed how email systems work, how emails are intercepted, analyzed header data, and briefly outlined ways to protect our email privacy. On this occasion, we wish to share with you how to use GnuPG for encrypting the content of an email.

When sharing information via email with friends or colleagues, it is not uncommon to include sensitive data such as email addresses, usernames, passwords,
or other confidential information. To safeguard this sensitive content, we can utilize **GnuPG**. **GnuPG** is employed to encrypt the body or message of
an email.

By employing this method, the exchange of information requires prior consent between the sender and recipient through the exchange of a **"public key"**,
thereby ensuring that the message is much more secure in terms of confidentiality.

In this tutorial, we will utilize software **GnuPG** integrated with **Thunderbird**. The author prefers **Thunderbird** as a mail client because it is
available on various operating systems. Additionally, **Thunderbird** provides several features/extensions, such as **Enigmail**, which enables us to
perform encryption, decryption, and provide PGP signatures.

The following tools are required or used by the author for this guide:

- Linux Operating System
- [GnuPG](https://www.gnupg.org/)
- [Mozilla Thunderbird](https://www.thunderbird.net/)
- [Enigmail](http://enigmail.mozdev.org/download/index.php.html)

Before proceeding, I assume that you have successfully installed **GnuPG**, **Thunderbird**, and the **Enigmail** plugin on your operating system.

## Creating a PGP Key with GnuPG

After downloading **GnuPG** and installing it, we can _generate_ a **PGP key** by running the command: `gpg --gen-key`. You will then have several _options_ for your generated _key_, including _key type_, _key size_, how long the key is _valid_, and _passphrase key_ for your PGP key.

```plain
Please select what kind of key you want:
 (1) RSA and RSA (default)
 (2) DSA and Elgamal
 (3) DSA (sign only)
 (4) RSA (sign only)
Your selection? 1
```

First, we select option number 1 (`RSA and RSA`) which enables us to perform both _encryption_ and _signature_ of messages.

```plain
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 2048
Requested keysize is 2048 bits
```

Next, we choose the desired **keysize**. By default, the program GPG uses a value of `2048`. Enter `2048` and press enter.

```plain
Please specify how long the key should be valid.
 0 = key does not expire
 <n> = key expires in n days
 <n>w = key expires in n weeks
 <n>m = key expires in n months
 <n>y = key expires in n years
Key is valid for? (0) 1y
Key expires at Sun 27 Jul 2013 05:55:36 PM WIT
Is this correct? (y/N) y
```

Then, we determine how long the key is valid. In this example, I made the key valid for **1 year**. Enter `1y` and press enter.

```plain
GnuPG needs to construct a user ID to identify your key.

Real name: Tutorial PGP
Email address: test@crayoncreative.web.id
Comment: Untuk contoh tutor PGP
You selected this USER-ID:
 "Tutorial PGP (Untuk contoh tutor PGP) <test@crayoncreative.web.id>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
You need a Passpharse to protect your secret key.
```

The next step is to provide a **user ID** to identify the key we are creating. The user ID includes your original name, email address, and comment. Fill in all the forms and then type `O` and press enter.

After that, a _popup_ will appear with a form to fill in the **passphrase key**, as shown in the picture below:

![gpg gen-key](pgp-thunderbird-01.png#center)

Fill in the **passphrase key** which will serve as a password for using your PGP Key and decrypting messages. Press the `Ok` button, then wait for a few seconds, and you will see a _summary key_ with information such as expiration date, owner's name, and others. As shown on the picture, my **PGP public key** is `D47A605E`.

![gpg gen-key2](pgp-thunderbird-02.png#center)

## Using PGP in Thunderbird with Enigmail

Open your **Thunderbird** program, select option **OpenPGP** > **Key Management**. Then, a list of keys available on our system will appear, as shown in the picture below:

![OpenPGP management Thunderbird](pgp-thunderbird-03.png#center)

Make sure your **public key ID** on **OpenPGP** is the same as what you just created. Then, to perform testing, we can send an email to `adele-en@gnupp.de` (_PGP Email Robot_) with our _public key_ attached. The way to do it is by selecting menu **OpenPGP** > **Attach Public Key**.

![OpenPGP attach public key](pgp-thunderbird-04.png#center)

Then, a _popup list PGP key_ will appear. Select the PGP key according to the email we use (`D47A605E`) by checking the box on the left side of Account / User ID.

![List PGP keys](pgp-thunderbird-05.png#center)

Send your message, and then after a few seconds you will receive an email reply from **Adele**:

![List PGP keys](pgp-thunderbird-06.png#center)

Enter your **passphrase key PGP key** to find out the contents of the message. It should appear like the picture below:

![](pgp-thunderbird-07.png#center)

After successfully emailing with the _"Robot"_, it's time to try emailing with a real person. (_Find someone who is already familiar with using PGP and exchange Public Keys 1 same as each other_) In the **OpenPGP** menu, check the options **Sign Message** and **Encrypt Message**. (Make sure the pencil and key icons on the bottom right are yellow).

![Open PGP button Thunderbird](pgp-thunderbird-08.png#center)

Send the message, and then only someone who has a complete _PGP key_ and knows their _passphrase key_- can read the message.

![Open PGP button Thunderbird](pgp-thunderbird-09.png#center)

I hope this guide helps you who want to pay more attention to privacy when exchanging messages through email.

Sources:

- [http://enigmail.mozdev.org/documentation/quickstart.php.html](http://enigmail.mozdev.org/documentation/quickstart.php.html)
- [http://www.dewinter.com/gnupg_howto/english/GPGMiniHowto.html](http://www.dewinter.com/gnupg_howto/english/GPGMiniHowto.html)
- [http://dart-ngo.gr/tutorials/747-gnupg-email-encryption-using-thunderbird-tutorial](http://dart-ngo.gr/tutorials/747-gnupg-email-encryption-using-thunderbird-tutorial)
