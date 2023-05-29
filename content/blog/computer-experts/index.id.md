---
title: "Computer Experts"
description: "Mengenai job desk Programmer, NOC Engineer dan System Administrator berdasarkan tingkatan-tingkatan-nya serta sedikit menjawab misteri dari seorang hacker."
date: 2012-08-20T18:16:39+07:00
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
tags:
#  - 
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

Mengenai job desk **Programmer**, **NOC Engineer** dan **System Administrator** berdasarkan tingkatan-tingkatan-nya. Dan mungkin juga sedikit menjawab misteri dari seorang hacker.

<!--more-->

Serta mungkin juga sedikit menjawab misteri dari kata *"hacker"* karena mindset kata *hacker* di masyarakat terkesan buruk atau seorang perusak.

Semoga dapat membantu bagi Anda yang belum mengerti/tau *jobdesk title* berikut pada umumnya.

## 1. Programmer
Atau Coder, yaitu seorang yang menulis/menciptakan perangkat lunak untuk pada komputer. Tiap bahasa pemrograman memiliki keterbatasan, kelebihan dan kekurangan-nya masing-masing. Bahasa yang berbeda biasanya digunakan untuk tugas yang berbeda pula.

Sebagai contoh: **PHP**, **ASP**, **JSP**, **JavaScript** biasanya digunakan untuk website programming. **C**, **C++**, **Java**, **Python**, **Perl** biasanya digunakan untuk membuat program yang dapat dieksekusi, atau mungkin berupa program CLI. Untuk benar-benar menguasai 1 bahasa program dibutuhkan waktu yang tidak sebentar.

## 2. NOC Engineer
**NOC engineer** melakukan berbagai tugas seperti mengkonfigurasi dan mengelola *router*, menangani masalah yang ada pada jaringan komputer dan memastikan bahwa media yang ditransmisikan melalui jaringan berfungsi dengan baik.

**NOC engineer** harus memahami konsep **TCP/IP**, terminologi jaringan seperti seperti **LAN**, **WAN** dan *subnetting*. Mereka juga mengetahui karakteristik dari *switch*, *repeater*, *bridge*, *gateway* dan *router*.

## 3. SysAdmin
Seorang **SysAdmin**/**Sistem Administrator** bertugas dan bertanggung jawab instalasi/konfigurasi, mengoperasikan, dan *memaintenance* sistem baik software dan maupun hardware serta infrastruktur terkait lainnya.

Ia melakukan pemantauan sistem secara harian, memverifikasi integritas dan ketersediaan sumber daya hardware, sumber daya server, meninjau log sistem dan aplikasi, juga melakukan backup. Melakukan patching OS dan melakukan upgrade secara teratur. Melakukan konfigurasi ulang/menambahkan atau menghapus sebuah service/daemon baru yang diperlukan.

## 4. Advanced (Network?) Programmer
> _Kemampuan point pertama ditambah dengan point ke 2._
Ia mampu mengimplementasikan bahasa pemrograman dengan konsep dasar jaringan serta tau bagaimana berkomunikasi dengan dua mesin / lebih menggunakan protokol **TCP/IP** ataupun **UDP** yang digunakan untuk mengimplementasikan server dan klien.

Contoh logic :
```plain
Main()
    Create a socket ("server socket")
    Bind server socket to "well known port"
    "Listen" on server socket (activate so can be used for client)
    forever do
        newDataSocket = accept(server socket, ...)
        handleClient(newDataSocket)
        close newDataSocket

handleClient(datastream)
    forever do
        command = read from datastream
        If(read-error or command==quit) then break
        Process command and generate response
        Write response to datastream
# *dan seterusnya
```

## 5. Advanced SysAdmin
> _Kemampuan poin pertama ditambah dengan kemampuan poin ke-3._

Ia mampu melakukan coding / scripting untuk proses otomatisasi server, misalnya otomatis backup, dll.

Ia juga mampu mengkonfigurasi dan mengimplementasikan berbagai macam protokol/service seperti FTP server, web server, DNS server, mail server, proxy server, database server, sehingga terbentuklah aplikasi untuk *end user*.

## 6. Advanced NOC Engineer
> _Kemampuan poin ke-2 ditambah dengan kemampuan point ke-3._

Menguasai **TCP/IP** dan **UDP** sehingga konfigurasi server yang ia tangani cenderung lebih baik dan optimal saat terjadi serangan pada layer network seperti **ICMP**, **Smurf**, **SYN/ACK**, **ARP**, dll.

Ia juga mampu mengkonfigurasi perangkat jaringan dan menggunakan fitur seperti **OSPF**, **BGP**, dll, serta mengimplementasikan *load-balancing* / *failover* secara optimal.

## 7. Hacker
> _Kemampuan poin pertama ditambah dengan kemampuan poin ke-2 ditambah dengan kemampuan poin ke-3._

Jadi mereka BUKAN orang yang hanya mengeksekusi program/exploit *"siap pakai"* yang didapat dari internet dan menimbulkan kerusakan besar, mereka BUKAN orang yang tanpa berfikir dan hanya ingin terlihat keren di depan teman-temannya.

Mereka adalah orang-orang yang membuat dunia IT bergerak, orang-orang yang menemukan hal-hal baru, mendapatkan protokol baru bekerja, memperbaiki bug yang mereka temukan dalam sebuah sistem.