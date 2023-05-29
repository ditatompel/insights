---
title: "Scan MS08-067, Conficker, Regsvc dan SMBv2 DoS Dengan Nmap"
description: "Contoh perintah Nmap untuk melakukan scan MS08-067 Vulnerability, Conficker, Regsvc dan SMBv2 Denial of Service."
date: 2012-09-08T18:46:55+07:00
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
tags:
  - Nmap
  - Conficker
  - MS08-067
  - SMB
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

Sebagai pengguna komputer, khususnya seorang sistem administrator, melakukan pengecekan *vulnerability* sangatlah penting. Jika tidak dilakukan dapat menimbulkan kerugian yang serius karena *virus*/*worm* yang digunakan oleh *malicious hacker* yang memanfaatkan celah keamanan tersebut.

<!--more-->

Saya asumsikan bahwa Nmap telah terinstall dengan *scripting engine* `smb-check-vulns`.

Contoh berikut ini adalah perintah untuk melakukan scan alamat IP `114.56.xxx.xx` pada port `445`. Anda perlu mengganti `114.56.xxx.xx` dengan alamat IP yang ingin Anda cek.

```bash
nmap -T insane --script smb-check-vulns.nse -p 445 114.56.xxx.xx
```

Dari perintah di atas, Anda akan mendapatkan output kurang lebih seperti berikut :
```plain
Starting Nmap 5.00 ( http://nmap.org ) at 2010-03-08 06.20 WIT
Interesting ports on 114.56.xxx.xx:
PORT STATE SERVICE
445/tcp open microsoft-ds
Host script results:
| smb-check-vulns:
| MS08-067: FIXED (likely by Conficker)
|_ Conficker: Likely INFECTED (by Conficker.C or lower)
Nmap done: 1 IP address (1 host up) scanned in 7.08 seconds
```

Dapat Anda lihat bahwa pada celah keamanan [MS08-067](http://www.microsoft.com/technet/security/bulletin/ms08-067.mspx) pada host tersebut telah *fixed* (tertutup) karena terinfeksi **Conficker**. Anda dapat mendownload [Kido Killer](http://support.kaspersky.com/faq/?qid=208279973) yang dibuat oleh **Kaspersky** pada host yang terinfeksi **Conficker**.

Sedikit penjelasan lebih detail dari hasil scan Nmap diatas :

## MS08-067
Pengecekan apakah host memiliki celah keamanan `MS08-067`. Sebuah celah keamanan **RPC** pada **Windows** yang memungkinkan *malicious user* untuk melakukan **Remote Code Execution** (**RCE**).

Perlu diperhatikan bahwa melakukan pengecekan **MS08-067** sangat berbahaya karena dapat membuat sistem menjadi *hang* / *crash*. Namun celah **MS08-067** sangatlah penting (wajib) ditutup.

[Metasploit](http://www.metasploit.com/) telah lama memiliki [ms08_067_netapi exploit](http://metasploit.com/svn/framework3/trunk/modules/exploits/windows/smb/ms08_067_netapi.rb) untuk celah ini dan berjalan lancar terhadap sistem yang memiliki celah keamanan tersebut.

## Conficker
Pengecekan apakah host terinfeksi oleh **Conficker**. Pengecekan ini berdasarkan program *conficker scanner* yang dapat ditemukan di [http://iv.cs.uni-bonn.de/wg/cs/applications/containing-conficker](http://iv.cs.uni-bonn.de/wg/cs/applications/containing-conficker).

## regsvc DoS
Pengecekan apakah dapat memanfaatkan celah yang mengakibatkan *service* `regsvc` *crash* yang disebabkan karena **null pointer dereference**. Jika celah tersebut ada, menjalankan pengecekan ini akan menyebabkan service tersebut *crash* (meskipun perlu guest account atau lebih tinggi agar dapat bekerja).

## MBv2 DoS
Melakukan DoS pada celah keamanan [CVE-2009-3103](http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2009-3103) (menyebabkan *bluescreen* jika berhasil). Berkerja pada **Windows Vista** dan beberapa versi **Windows 7**.

POC source code dapat ditemui di [http://seclists.org/fulldisclosure/2009/Sep/0039.html](http://seclists.org/fulldisclosure/2009/Sep/0039.html).
