---
title: "Password 101: Best Practices for Secure Online Living"
description: "Discusses how you should create and treat your passwords as well as tips for using a password manager to make it easier to manage unique and random passwords on every site / application you use."
summary: "Discusses how you should create and treat your passwords as well as tips for using a password manager to make it easier to manage unique and random passwords on every site/application you use."
date: 2022-09-09T19:47:48+07:00
lastmod:
draft: false
noindex: false
featured: true
pinned: false
series:
#  -
categories:
  - Security
tags:
  - Bitwarden
  - KeepassXC
images:
authors:
  - ditatompel
---

The password is a crucial aspect of online security. This article explores how to create and manage strong, unique passwords, as well as [tips for using an open-source password manager](#tips-for-using-a-password-manager) to securely store and access your credentials on various websites and apps.

So, how should we treat and create good passwords? Here are 5 crucial points (in my opinion) regarding passwords and tips for using **a password manager**.

## Never Share Your Password with Anyone

I'd like to remind you of one of the key differences between **_private_** and **_secret_** according to the [_Cypherpunk's Manifesto_](https://www.activism.net/cypherpunk/manifesto.html).

**A secret is something that only you know**, nobody else should know. On the other hand, **private is something you don't want the whole world to know**. It's like your home address, phone number, or the shape of your personal belongings... (you get the idea). Your closest acquaintances may be aware of certain private aspects about yourself.

A password, however, is a secret matter that **only you** should know. Think of sharing your password as betraying yourself – something to be avoided at all costs. Not even a trusted partner or family member deserves access to this secret information.

## Never Use the Same Password

Many of my friends still use the same passwords across various websites. When you use the same password across multiple websites and apps, you're inviting potential disaster into your digital life.

The rule is clear: use separate passwords for each website and app. Why? Because if those credentials were to leak into the public domain, the consequences would be severe.

Even the most secure-looking websites can fall victim to data breaches. Even well-known websites have made mistakes before – like [**Facebook** was once stored its users' passwords in plain text](https://techcrunch.com/2019/03/21/facebook-plaintext-passwords/). :clap: :shit:

Imagine waking up one morning to find that your personal info has been compromised, or worse – your financial accounts have been drained. It's a nightmare scenario that can be avoided by using unique passwords for each online account.

The best-designed systems can have flaws, and those operated by well-intentioned and experienced humans are not immune to mistakes and imperfections. Therefore, never use the same password and enable two-factor authentication (2FA) to make it even safer.

## Use a Long and Complex Password

![Password Brute Force Table](feature-password-brute-time-table.png#center "Password Brute Force Table")

The table above provides information on how long it takes to obtain a plain-text password using **an Nvidia GeForce 1080**, assuming we can perform a brute-force attack 30 million times in one second.

Of course, this simulation varies depending on the hardware's capabilities and the hash algorithm used. Use a **minimum of 12 random characters containing numbers, symbols, uppercase letters, and lowercase letters**. The longer it is, the better, as technology and hardware capabilities develop rapidly.

> By **a truly random password**, I mean one that is completely unrecognizable as a word, whether noun or adjective. For example: `i7#xYkU9Txd@5Y`

> Although there are other factors that can shorten the time needed to obtain a plain-text password due to **hash collisions** (see [Wikipedia Hash Collision](https://en.wikipedia.org/wiki/Hash_collision)), using a complex password at least reduces the options available to crackers, making it harder for them to easily obtain our plain-text password.

## Avoid Using Personal Identifiers in Your Passwords

Many people tend to choose and combine personal information in their passwords. For example:

- **Date of birth**: ditatompel09111978 or 19781109dita
- **Address**: tompelBrooklyn12St
- **Phone Number**: dita7576
- **Hobby**: Fap3x24

_\*Forget the last one_ :speak_no_evil:.

Information that can be inferred from this data can be exploited for a [_Brute Force_](https://en.wikipedia.org/wiki/Brute-force_attack) attack on your password. So, **use a password that is difficult to guess and completely random**.

## Don't Store Your Passwords Within Browser's Built-in Password Management or Unencrypted Document

Avoid storing your passwords within a browser's built-in password management feature. Most mainstream browsers' built-in password management features do not implement encryption or additional authentication measures, so your password may be stored in plaintext on your device. If someone borrows our PC/laptop, it only takes a few seconds to retrieve the stored password.

Similarly, avoid storing passwords on built-in phone features as well, and instead use an **Open-Source Password Manager** that I will discuss later in this article.

## Changing Passwords Regularly is No Longer Relevant

![OTP according to Kominfo](pak-menkom-johnny-ngomong-otp-harus-selalu-diganti-lmao.jpg#center "OTP according to Indonesia Minister of Communication and Information Technology")

[Tempo.co](https://bisnis.tempo.co/read/1630039/kebocoran-data-pribadi-terjadi-lagi-johnny-plate-masyarakat-harus-sering-ganti-password), quoting **Indonesia Minister of Communication and Information Technology**, Mr. **Johnny G Plate**:

> _"One time password itu harus selalu kita ganti sehingga kita bisa menjaga agar data kita tidak diterobos,"_.

Translated to English:

> _"We must always change our one-time password so that our data is not breached,"_.

Hmm... Excuse me! **OTP** or one-time password means a password that's only used once. After being used, the password is no longer valid. By nature, it changes itself and it's not us who decide its value.

> _I'm sure the minister doesn't really mean it. His intention was probably about regular passwords, wasn't it? right? Yeah?_ :worried:

Back to the topic of why I think changing passwords regularly is no longer relevant: because remembering the site or app we signed up for is already difficult, let alone having to change them regularly with random complex passwords.

In my personal opinion, by implementing the points I mentioned earlier, it's sufficient (for most people).

## Password Managers

The points I mentioned above will be very difficult to achieve without a **Password Manager**. Use an open-source password manager that can be freely audited by the public at any time.

There are many open-source password managers like [Bitwarden](https://bitwarden.com/), [KeepassXC](https://keepassxc.org/), [Padloc](https://padloc.app/), etc. If you have the infrastructure and capabilities to build and manage a _self-hosted server_ for your password manager, it would be better if you use its self-hosted version.

### Tips for Using a Password Manager

To follow my tips, you'll need:

- 2 email accounts, one of which is an email address **that has never been used** to register anywhere.
- The ability to remember at least 3 complex passwords that are different (**minimum 12 characters including numbers, symbols, uppercase and lowercase letters**).

So, let say I already have two email addresses:

1. `ditatompel@gmail.com`
2. `administrator@ditatompel.com`

I use the first email for every website registration that requires email verification (primary email). Remember and note down the password for logging in to this email **in your brain memory** (never write it anywhere, including a password manager).

The second email is **only** used for the recovery/reset password feature from the primary email. Don't tell anyone about this recovery email address except the provider of the primary email (in this case: Gmail).

> When you set up a recovery email address with your provider (such as Gmail), they will typically send notifications to that email if they detect suspicious activity on your account. Even if your primary email account has been compromised, you can still maintain control over your account by accessing it through the recovery email.

Register to your password manager provider using your primary email. Usually, the password manager will ask you to set up a **Master Password**. Use a different password from the passwords of the primary and recovery email. And, again: remember and note down the **Master Password** in your brain (never write it anywhere, including the password manager itself).

Don't forget to enable 2FA/OTP (if the provider offers this feature) for accessing these three important accounts (the primary email, the recovery email, and the password manager).

Use the password manager to generate and store all passwords for websites or applications you use **except** the primary email, the recovery email, and the master password of the password manager.

That way, you'll have different random passwords for each website or application you use without having to bother remembering them. I hope this article is helpful and adds insight.

> **NOTES**:
>
> - This tip won't be useful if your PC or device is already infected with malicious software like a keylogger.
> - Special note about email: If you use an email service provider like Yahoo! or Google, you may lose your email account if you never log in within a certain period of time. I wrote about this topic: ["_Why Inactive Email Accounts is Dangerous_"](https://insights.ditatompel.com/en/blog/2020/06/why-inactive-email-accounts-is-dangerous/). So, always make it a habit to log in to your email service provider at least once every 2 months.

Resources:

- Random data fed or [_salt (Cryptography)_](<https://en.wikipedia.org/wiki/Salt_(cryptography)>)
- [Dictionary Attack](https://en.wikipedia.org/wiki/Dictionary_attack)
- [Rainbow Table Attack](https://www.beyondidentity.com/glossary/rainbow-table-attack)
