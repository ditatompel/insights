---
title: "Trying Gmail Confidential Mode for G Suite Users"
description: "Gmail Confidential mode allow G Suite users sending emails with expiration date, restrict to forward, copy, print, or download email content or attachments."
date: 2019-05-29T02:40:06+07:00
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
  - Gmail
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

On March 7, 2019, Google announced that they launch their new feature: [Gmail confidential mode](https://www.google.com/appserve/mkt/p/AFnwnKXVaLLz4xNwmc5rWL3tVvNvAeKWlMyQlIOqGxA59ESDm6x2hiqez7CPqHv4WcsTIxKrMbr16TX1OgtZum8Vy6CMwLmZErvwhqp8_CA7) in beta. This feature allow G Suite users with Gmail enabled **sending emails with expiration date**, in additional, the **recipients won't be able to forward, copy, print, or download email content or attachments and sender can be revoke email message any time**.

<!--more-->

I am super exited about the this features. how come an email couldn't be forwarded? How does Google delete / revoke e-mails that already sent to another e-mail servers? Therefore, let's find out!

## Getting Started
This feature will become generally available (GA) on June 25, 2019 and will be set to default ON for all domains with Gmail enabled. So **before the date, you need to be G Suite admin to enable this feature**.

To enable confidential mode for G Suite organisation, go to the Admin console and navigating to **Apps** > **G Suite** > **Settings for Gmail** > **User settings**. There will be select option to **Enable confidential mode**.

![Google Admin Console](gsuite-confidential-01.png#center)

## End Users - Sender
Once Gmail confidential mode is activated by admin, users can use Gmail confidential mode. When they compose an email, there is a button to enable confidential mode for the email.

![Google confidential mode button](gsuite-confidential-02.png#center)

If users click on the button, it opens the Gmail confidential mode user settings dialog box where they can modify the settings:

![Google confidential mode dialog box](gsuite-confidential-03.png#center)

Users can set an expiration date for messages and messages can revoked by sender at any time. When choosing *"No SMS passcode"* option, Google will send passcode to recipients by email.

## End Users - Recipient's
I tried sending an email with confidential mode enabled from G Suite to non Google-related e-mail service (in this case is cPanel), the results is like this:

![Google confidential mode message](gsuite-confidential-04.png#center)

When user sends a confidential message, **Gmail replaces the message body and attachments with a unique link**. Only the subject and body containing the unique link are sent via SMTP. There's no other special email headers set by Gmail confidential message. So, that's the reason why sender can revoke the mail message: the **mail body and attachment are kept at Google servers**. The recipient's are forced to read confidential email message from the generated link.

When recipient's click at message link, a new tab in recipient's browser will open and recipient's need to click on **"SEND PASSCODE"** button. The one-time passcode will be sent to the recipient's e-mail (or phone number if sender choose "SMS passcode"  option).

![Google confidential mode passcode](gsuite-confidential-05.png#center)

After verifying passcode, recipient's will be able to see the original email message.

![Google confidential mode opened](gsuite-confidential-06.png#center)

## Google Really Keeps Their Words
On the ~~"simple"~~ message page, Google really keeps his word: there are no **"forward message"** button. Recipient's won't be able to print or copy the message contents because shortcut features <kbd>CTRL</kbd> + <kbd>P</kbd> for printing pages, and mouse click on message body is disabled. Trying to print using browser menu options won't help because message body **CSS** likely set to `@media print { display: none !important; }`.

![Google confidential mode disable copy](gsuite-confidential-07.png#center)

The most interesting thing is when opening the **developer console**/**inspect element** (look at the picture below).

![Browser developer console](gsuite-confidential-08.png#center)
When I open the attached link, my browser is currently being logged in to my gmail.com personal account and google maybe ~~tracking~~, or at least they know that I've access (maybe as the owner, or an unauthorized user) of recipient's email. Yes, Google know that recipient's email (in this case `administrator@devilzc0de.id`) having relations or linked to my personal gmail account. :)

## Conclusions
- Removes the option to forward, copy, download or print messages **reduce the risk** of confidential information being accidentally shared with the wrong people.
- Protecting sensitive content in your emails by creating expiration dates and additional authentication via text message to view an email makes it **possible to protect data even if a recipient’s email account has been hijacked** while the message is active.
- Although confidential mode helps prevent the recipients from accidentally sharing your email, **it doesn't prevent recipients from taking screenshots or photos of messages or attachments**.
- Recipients who have **malicious programs** on their computer **may still be able to copy or download your messages or attachments**.
- When sending emails, **subject header should not contain any confidential content**.

## Resources
- [https://gsuiteupdates.googleblog.com/2019/03/keep-data-secure-with-gmail-confidential-mode-beta.html](https://gsuiteupdates.googleblog.com/2019/03/keep-data-secure-with-gmail-confidential-mode-beta.html)
- [https://support.google.com/a/answer/7684332](https://support.google.com/a/answer/7684332)
- [https://support.google.com/vault/answer/9000913](https://support.google.com/vault/answer/9000913)

