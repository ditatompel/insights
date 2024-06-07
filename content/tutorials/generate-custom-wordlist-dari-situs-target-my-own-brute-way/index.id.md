---
title: "Generate Custom Wordlist Dari Situs Target, My Own Brute Way"
description: Tutorial cara untuk men-download website dan mengubahnya menjadi sebuah wordlist.
summary: Tutorial cara untuk men-download website dan mengubahnya menjadi sebuah wordlist.
# linkTitle:
date: 2011-10-01T22:36:55+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
series:
#  - Tutorial
categories:
  - Security
tags:
  - Hydra
  - Cupp
  - Wyd
  - BackTrack
images:
  - https://edge.ditatompel.com/assets/img/site-contents/generate-custom-wordlist/feature-my-own-brute-way.jpeg
authors:
  - ditatompel
---

Kadang seorang Sistem Administrator menggunakan password dengan kata dari website mereka. entah itu dari nama perusahaan, organisasi atau nama produk unggulan mereka. Berikut ini tutorial cara untuk _men-download_ website dan mengubahnya menjadi sebuah _wordlist_.

_Tools_ yang diperlukan:

1. [Wyd](http://packetstormsecurity.org/files/51130/wyd.tar.gz.html)
2. [Hydra](http://thc.org/thc-hydra/)
3. [Cupp](http://ls-la.ditatompel.crayoncreative.net/linux/cupp-3.0.tar.gz)

Untuk para pengguna **BackTrack**, tidak perlu repot menginstall semua tools tersebut. Untuk Distro lain, bisa mengikuti langkah-langkah berikut.

## Download semua konten situs

Pertama kita buat dulu direktori kerja

```bash
mkdir ~/custom-wl; cd ~/custom-wl
```

Download semua isi konten website target dengan wget sampai selesai, misal situs target kita adalah `http://ditatompel.crayoncreative.net`:

```bash
wget -r http://ditatompel.crayoncreative.net
```

```
<blah blah blah . . . . .>
FINISHED --2011-10-01 12:55:41--
Downloaded: 602 files, 19M in 6m 21s (51.2 KB/s)
```

File2 tersebut akan disimpan di direktori `~/custom-wl/[domain-situs]` atau dalam tutorial kali ini `~/custom-wl/ditatompel.crayoncreative.net`.

## Menggunakan wyd.pl

Kemudian ambil dan siapkan senjata perang utama kita : `wyd.pl` ( Pengguna **BackTrack** tidak perlu download karena sudah ada di `/pentest/password`).

```bash
wget http://dl.packetstormsecurity.net/Crackers/wyd.tar.gz
tar -xvzf wyd.tar.gz
cd wyd
perl wyd.pl -n -o ~/custom-wl/wordlist-mentah.txt ~/custom-wl/ditatompel.crayoncreative.net
```

![Custom Wordlist 1](https://edge.ditatompel.com/assets/img/site-contents/generate-custom-wordlist/custom-wordlist1.jpg#center)

Nah, kita punya file berisi kata-kata dari situs target, dan senjata utama juga sudah beraksi. Tapi masih ada yang kurang nih bro..

```bash
less ~/custom-wl/wordlist-mentah.txt
```

kata-kata yang digenerate sama `wyd.pl` tadi masih banyak yang kembar. Kita rapikan dulu dengan menggunakan perintah `uniq` supaya nantinya kita tidak mengorbankan _memory usage_.

```bash
cat ~/custom-wl/wordlist-mentah.txt | uniq > ~/custom-wl/wordlist-setengah-matang.txt
```

## Install Hydra, `pw-inspector`

Oke, sekarang _wordlist_ kita sudah agak rapi. Kita pilihin lagi nih bro supaya _script2_ tanpa spasi seperti `jquery.min.js` ga ikut masuk ke dalam _wordlist_. Caranya kita buang _wordlist_ yang hurufnya kurang dari 5 dan lebih dari 30 (karena jarang orang punya password lebih dari 30 karakter) menggunakan alat `pw-inspector` (didapat dari fiturnya **Hydra**, jadi klo yang belum punya **Hydra** download dan install dulu).

Install Hydra :

```bash
wget http://www.thc.org/releases/hydra-7.0-src.tar.gz -O /usr/local/src/hydra-7.0-src.tar.gz
cd  /usr/local/src/; tar -xvzf hydra-7.0-src.tar.gz
cd hydra-7.0-src
./configure
make && make install
```

Buang _wordlist_ yang hurufnya kurang dari 5 dan lebih dari 30 :

```bash
cat ~/custom-wl/wordlist-setengah-matang.txt | pw-inspector -m 5 -M 30 > ~/custom-wl/wordlist-oke.txt
```

Nah sekarang udah lumayan rapi _wordlist_ kita. Bro2 sekalian bisa pilih-pilih lagi tuh _wordlist_. Klo wordlistnya cukup besar, buka pake vi / editor spt kate bisa makan banyak _memory_, atau kita bisa gunakan `head -n 25 wordlist.txt` Untuk melihat 25 baris pertama atau `tail -n 25 wordlist.txt` untuk melihat 25 baris terakhir (optional).

## Menggunakan CUPP

Lalu sebagai pemanis kita jalanin uler kadut yang di **BackTrack** juga udah eksis, **CUPP**. Yang belum punya **CUPP** bisa download dulu :

```bash
wget http://ls-la.ditatompel.crayoncreative.net/linux/cupp-3.0.tar.gz -O ~/custom-wl/cupp-3.0.tar.gz
cd ~/custom-wl/; tar -xvzf cupp-3.0.tar.gz
cd cupp; python cupp.py -w ~/custom-wl/wordlist-oke.txt
```

Jawab pertanyaan dari sang juru kunci ini. Outputnya kurang lebih seperti ini :

```
> Do you want to concatenate all words from wordlist? Y/[N]: N
> Do you want to add special chars at the end of words? Y/[N]: N
> Do you want to add some random numbers at the end of words? Y/[N]Y
> Leet mode? (i.e. leet = 1337) Y/[N]: Y

[+] Now making a dictionary...
[+] Sorting list and removing duplicates...
[+] Saving dictionary to /root/custom-wl/wordlist-oke.txt.cupp.txt, counting 580896 words.
[+] Now load your pistolero with /root/custom-wl/wordlist-oke.txt.cupp.txt and shoot! Good luck!
```

![Custom Wordlist 2](https://edge.ditatompel.com/assets/img/site-contents/generate-custom-wordlist/custom-wordlist2.jpg#center)

Nah sampai di sini dulu.. Untuk bruteforcenya pasti udah pada punya tools favorit masing2.

## Referensi

- Ebook **Cracking Passwords** by: **J. Dravet**
- [http://thc.org/thc-hydra/README](http://thc.org/thc-hydra/README)
