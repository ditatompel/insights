---
title: "Spoofing SSL MITM Attack Juniper SSL VPN & UAC"
description: "Kemungkinan melakukan man-in-the-middle (MiTM) attack untuk melakukan spoofing SSL server pada Juniper SSL VPN & UAC."
date: 2013-06-14T21:53:43+07:00
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
  - Juniper
  - Junos
  - MiTM
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

**Juniper Junos Pulse Secure Access Service** (atau biasa disebut **SSL VPN**) dengan **IVE OS** `7.0r2` sampai `7.0r8` dan `7.1r1` sampai `7.1r5` dan **Juniper Junos Pulse Access Control Service** (atau biasa disebut **UAC**) dengan **UAC OS** `4.1r1` sampai `4.1r5` memasukan *test* **Certification Authority** (**CA**) pada daftar **Trusted Server CA** yang memudahkan *malicious user* melakukan man-in-the-middle (*MiTM*) *attack* untuk melakukan *spoofing* SSL server dengan mengatasnamakan test CA tersebut.

<!--more-->

**Junos SSL VPN** dan **Junos UAC software** menggunakan list pada **Trusted Server CA Root Certificate** untuk melakukan verifikasi valid atau tidaknya sertifikat server.

Konfigurasi internal dan *development* (*testing*) **Authority (CA) Root Certificate** secara tidak sengaja ditambahkan ke dalam *release build* yang ada pada situs *download* **Juniper**. Jika seseorang mampu menguasai **Certificate Authority** yang telah dikonfigurasi pada **SSL VPN/UAC** untuk dipercaya, maka ia dapat membuat sertifikat palsu untuk setiap domain yang mereka inginkan.

## Contoh Bagaimana Trusted Server CA Digunakan
Seorang pengguna sedang melakukan *browsing* melalui **SSL VPN rewriter** ke sebuah situs SSL (*https*), **SSL VPN** bertindak sebagai *https client*, maka dari itu ia akan menggunakan daftar list dari **Certificate Authorities** untuk mem-verifikasi bahwa *backend https server *memiliki sertifikat yang sah.

Jika sertifikat terbukti valid maka pengguna tidak akan melihat pesan *warning* apapun. Namun, jika validasi sertifikat gagal, pengguna akan melihat warning yang menyatakan bahwa *"the site's certificate is not valid, would you like to continue?"*

Permasalahan dengan memiliki **Certificate Authoritie**s pada perangkat yang tidak dipercaya adalah ketika seseorang dapat mengambil alih **CA** tersebut, maka mereka dapat membuat sertifikat yang tidak valid muncul sebagai sertifikat yang valid kepada pengguna.

Meskipun begitu, untuk melakukan eksploitasi bukanlah hal yang mudah, penyerang harus melakukan kombinasi dengan membuat sertifikat palsu serta memiliki kontrol terhadap **DNS server** yang digunakan oleh pengguna.

Jika mereka dapat membuat sertifikat palsu dan mengontrol informasi *DNS lookup* untuk situs yang dikunjungi pengguna, maka penyerang dapat melakukan *spoofing secure session* (*https*) terhadap pengguna yang kemudian dapat dimanfaatkan untuk mencuri informasi atau data sensitif karena pengguna tidak akan dapat membedakan antara situs asli dan situs palsu yang telah disiapkan pengguna.

## Solusi
Software update untuk **IVE OS** dan **UAC OS** telah dirilis untuk mengatasi masalah ini. *Update* tersebut berisi perbaikan untuk **IVE OS** `7.1r7` keatas dan **UAC OS** `4.1r6` keatas.

Untuk **IVE OS** `7.2rX` atau **UAC OS** `4.2rX` keatas yang pernah melakukan upgrade dari rilis yang terkena dampak tersebut :

> **System** --> **Configuration** --> **Certifications** --> **Trusted Server CAs** --> **"Reset Trusted Server CAs"**

Untuk **IVE OS** `7.1rX` atau **UAC OS** `4.1rX` dapat mengikuti langkah-langkah pada [kb.juniper.net/KB27552](http://kb.juniper.net/KB27552) untuk mengatasi ini secara manual karena tombol reset tidak tersedia dalam versi tersebut.

- Tidak ada produk / platform **Juniper Networks** lainnya yang terpengaruh masalah ini.
- **Juniper SIRT** tidak melihat adanya eksploitasi berbahaya kerentanan ini.
- Masalah ini dikenal juga sebagai [CVE-2013-3970](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2013-3970).
- Referensi : [http://kb.juniper.net/InfoCenter/index?page=content&id=JSA10571](http://kb.juniper.net/InfoCenter/index?page=content&id=JSA10571).



