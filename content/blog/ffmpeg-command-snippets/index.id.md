---
title: "FFmpeg Command Snippets"
description: Dengan FFmpeg kita bisa melakukan screen recording, merubah format lagu dari satu format ke format lain, kompres / convert video dan audio, dan masih banyak lagi.
date: 2011-12-21T02:14:36+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Snippets
tags:
  - FFmpeg
  - CLI
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

**FFmpeg** salah satu tools multimedia favorit saya. Boleh dibilang sangat lengkap dan berguna sekali. Dengan menggunakan **FFmpeg** kita bisa melakukan *screen recording*, merubah format lagu dari berbagai satu format ke format lain, meng-kompres / mengkonversi video dan audio, dan masih banyak lagi.

<!--more-->

Ceritanya saya punya Video hasil download dari **YouTube**. Taruh kata file video itu namanya `konser-a7x-live.mp4`. Saya ingin ambil audionya saja buat di dengerin lewat `mp3` player favorit saya.

Maka command FFmpeg untuk extract audionya:
```bash
ffmpeg -i konser-a7x-live.mp4 -vn -ar 44100 -ac 2 -ab 128k -f mp3 konser-a7x-live.mp3
```

* `-i` : adalah file inputnya (konser-a7x-live.mp4)
* `-vn` : untuk medisable video
* `-ar` : `44100Hz` audio *sampling rate*
* `-ac` : `2` *audio channel* (stereo)
* `-ab` : `128k` *bitrate*, Default adalah `bits/s`. Jadi klo ente hajar `-ab 128` doang tanpa embel2 "`k`" ente dapet outputnya jelek karena bitratenya `128b/s` (terlalu rendah)
* `-f`  : *force* format ke `mp3`   
dan yang terakhir `konser-a7x-live.mp3` adalah *output* hasil *extract* audionya.

Kemudian saya ingin potong hasil *output* audio tadi karena intro iklan nya terlalu lama. Taruh kata **a7x** mulai nyanyi dari menit `3:20`. Saya potong audio tersebut dari menit `3:20` sampai `5 menit 23 detik` selanjutnya.

Maka perintah **FFmpeg** untuk memotong potong `mp3` nya:
```bash
ffmpeg -ss 00:03:20 -t 00:05:23 -i konser-a7x-live.mp3 -acodec copy potongan-konser-a7x-live.mp3
```

Dimana:
* `-ss` waktu *start* potongan `mp3` tersebut. (mulai dari menit `3:20`)
* `-t` Lama waktu yang kita potong dari waktu *start* yang kita ingin potong tadi.
* `-acodec` *force* audio `codec` outputnya mengunakan `copy` codec dari audio (*copy stream*)

Sudah siap nih audionya dan saya bisa dengarkan lewat `mp3` player favorit saya. Tp saya blom puas, saya ingin *convert* `mp3` tersebut supaya bisa dipasang di website saya yang menggunakan salah satu **jQuery** plugin (kebanyakan jQuery plugin memanfaatkan format `ogg`).

Maka command FFmpeg berikut untuk convert `mp3` ke format `ogg`:
```bash
ffmpeg -i potongan-konser-a7x-live.mp3 -acodec libvorbis potongan-konser-a7x-live.ogg
```

Contoh video :

{{< youtube 2-cYLQBGZzk >}}

Video diatas saya ambil menggunakan **FFmpeg** juga yang dimensi capture (*crop*) screen ukuran `800x600`.

Untuk temen2 yang suka bikin dokumentasi, banyak kan yang pake software tambahan misal `recordmydesktop` dll. *FFmpeg* juga bisa melakukan *screen recording* dengan kualitas HD. command FFmpeg untuk *screen recording*:
```bash
ffmpeg -an -f x11grab -r 25 -s 1366x768 -i :0.0+0,0 -vcodec libx264 capture.mkv
```
dimana:
* `-an` : untuk record screen tanpa audio backend (misal ALSA)
* `-s` : Ukuran layar yang ingin direkam `1366x768`
* `-r` : *Frame per second* / *FPS*
* `-i` : `:0.0+0,0` koordinat video screen. Penghitungannya dimulai dari pojok kiri atas layar.
* `-vcodec` : *force* output video `codec` nya menggunakan `libx264`

Contoh hasil screen recording menggunakan `ffmpeg` bisa diliat waktu saya membuat dokumentasi **GIMP** di [https://www.youtube.com/watch?v=1xkLDHey84k](https://www.youtube.com/watch?v=1xkLDHey84k).

Untuk *snippet2* lain :

`ogg` ke `mp3`
```bash
ffmpeg -i audio.ogg -acodec libmp3lame audio.mp3
```

`wav` ke `mp3`
```bash
ffmpeg -i audio.wav -acodec libmp3lame audio.mp3
```

`wav` ke `aac`
```bash
ffmpeg -i audio.wav -acodec libfaac audio.aac
```

`wav` ke `ac3`
```bash
ffmpeg -i audio.wav -acodec ac3 audio.mp3
```

Info lebih lanjut bisa diliat dari terminal
```bash
man fmpeg
# atau
ffmpeg --help
```
Atau dari situs [http://ffmpeg.org/ffmpeg.html](http://ffmpeg.org/ffmpeg.html) (disini udah sangat lengkap dan jelas).