---
title: "PHP E-Mail Advanced Validation (Format, MX Host, SMTP Mailbox)"
description: "Sebuah script PHP sederhana untuk melakukan validasi E-Mail melalui format penulisan, MX record, dan SMTP mailbox."
summary: "Sebuah script PHP sederhana untuk melakukan validasi E-Mail melalui format penulisan, MX record, dan SMTP mailbox."
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

Tidak bisa dipungkiri lagi jika di internet, keberadaan **E-Mail** sangatlah penting. Dengan adanya E-Mail, informasi dapat sangat cepat sampai meskipun sang pengirim dan penerima berada di dua benua yang berbeda. Selain itu, email juga masih menjadi pilihan perusahaan dan developer untuk menyampaikan informasi kepada para pelanggannya.

Kali ini ijinkan saya untuk berbagi sebuah _script_ **PHP** sederhana untuk melakukan validasi E-Mail melalui format penulisan, **MX record**, dan **SMTP mailbox**.

Untuk validasi alamat E-Mail, kita dapat melakukan beberapa hal. yaitu dari format penulisan email, melakukan pengecekan atas **MX record** pada domain yang ingin di cek, atau bahkan melakukan koneksi ke SMTP server yang dituju untuk melakukan pengecekan keberadaan user yang dituju.

Source code dapat didownload di `http://go.webdatasolusindo.co.id/scripts/php/email-advanced-validation.php` atau di `http://pastebin.com/yyjChgKF`.

## 1. Validasi Format Email

Format email yang sering digunakan adalah seperti berikut :
`username@domain.com`
`Username` : nama user yang dituju.
`domain.com` : adalah nama domain dimana user tersebut berada.

Kelemahan pada validasi format seperti ini adalah kita tidak tahu apakah domain tersebut benar-benar memiliki mail server. Misalnya alamat email `username@domaintidakvalid.com` akan dibaca valid, padahal sebenarnya domain tersebut tidak ada.

Untuk memastikan bahwa domain tersebut valid atau tidak, kita dapat melakukan pengecekan melalui **MX record**.

## 2. Validasi MX Record

Fungsi **MX Record** biasa digunakan untuk mendelegasikan email untuk suatu domain / host ke mail server yang dituju. (Baca : [Sistem penamaan domain](https://id.wikipedia.org/wiki/Sistem_Penamaan_Domain) agar lebih jelas)

Contohnya dengan menjalankan perintah `dig wds.co.id MX +short`:

```plain
30 aspmx3.googlemail.com.
0 aspmx.l.google.com.
10 alt1.aspmx.l.google.com.
20 alt2.aspmx.l.google.com.
30 aspmx2.googlemail.com.
```

![dig record](php-email-dig_mxrecord.png#center)

Maka akan terlihat **MX Record** untuk domain `wds.co.id`.

Dengan melakukan _query_ **MX record** tersebut, bisa dikatakan bahwa domain tersebut merupakan domain yang memungkinkan memiliki alamat email. Sedangkan kelemahan pada validasi melalui MX record adalah kita tidak tahu apakah user pada domain tersebut benar-benar ada.

Misalnya alamat email `alamat.palsu@wds.co.id` akan dikatakan valid meskipun sebenarnya user alamat palsu tidak benar-benar ada pada mail server yang dituju.

Untuk dapat mengetahui user benar-benar ada pada mail server yang dituju, kita dapat mengembangkannya lagi dengan melakukan koneksi ke **SMTP** server yang dituju.

## 3. Validasi SMTP mailbox

Dengan melakukan koneksi ke **SMTP** server, kita dapat mengetahui apakah user pada domain tersebut benar-benar ada atau tidak. Contohnya saya melakukan `telnet` ke port `25` (_default port SMTP_) dan menjalankan perintah-perintah **SMTP**.

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
RCPT TO: <alamat.palsu@wds.co.id>
550-5.1.1 The email account that you tried to reach does not exist. Please try
550-5.1.1 double-checking the recipient's email address for typos or
550-5.1.1 unnecessary spaces. Learn more at
550 5.1.1 http://support.google.com/mail/bin/answer.py?answer=6596 w4si11351321yhd.42
QUIT
221 2.0.0 closing connection w4si11351321yhd.42
Connection closed by foreign host.
```

![SMTP commands](php-email-telnetsmtp.png#center)

Perhatikan pada koneksi telnet pertama :

```plain
RCPT TO: <christian.dita@wds.co.id>
250 2.1.5 OK c2si11647357yhk.33
```

dan koneksi telnet kedua :

```plain
RCPT TO: <alamat.palsu@wds.co.id>
550-5.1.1 The email account that you tried to reach does not exist. [ Blah blah blah... ]
```

Pada koneksi pertama, terlihat bahwa _respond_ mail server mau menerima email untuk recipient yg dituju.
Sedangkan pada koneksi kedua, mail server tidak mau menerima email untuk recipient yg dituju.

Jadi bisa dikatakan bahwa user `alamat.palsu` pada domain `wds.co.id` tidak benar-benar ada.

Dari ke 3 validasi di atas itulah konsep dasar darp script **PHP E-Mail Advanced Validation** ini saya buat.

