---
title: Arch Linux Adalah Salah Satu Distro Termudah
description: Arch Linux bisa jadi salah satu distro termudah bagi Anda yang sudah berpengalaman menggunakan Linux dan mau membaca dokumentasi.
summary: Arch Linux bisa jadi salah satu distro termudah bagi Anda yang sudah berpengalaman menggunakan Linux dan mau membaca dokumentasi.
keywords:
    - Linux
    - Arch Linux
date: 2024-07-20T10:07:51+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
categories:
    - TIL
tags:
    - Linux
    - Arch Linux
authors:
    - ditatompel
---

Di tahun 2011-an, ada pengalaman menarik yang saya alami ketika mencoba melakukan registrasi di [forum Arch Linux](https://bbs.archlinux.org/). Sebuah pertanyaan tambahan atau _security question_ yang secara tidak langsung mengatakan bahwa _"jika kamu bukan pengguna sistem operasi Linux, kamu tidak bisa melakukan registrasi"_. Penasaran seperti apa _security question_ tersebut? Beginilah penampakan pertanyaan tambahan saat saya mencoba melakukan registrasi di forum Arch Linux pada akhir tahun 2011.

![Security question registrasi forum Arch Linux di tahun 2011](arch-forum-sec-question-2011.png#center)

Dari _security question_ tambahan diatas, jelas tidak mungkin seseorang yang bukan pengguna Linux dapat memberikan _output_ yang diinginkan dari `date -u +%W$(uname)|sha256sum|sed 's/\W//g'`.

Tidak adanya GUI _installer_, perlunya mengkonfigurasi partisi, konektifitas jaringan, hingga _window_ atau _display manager_ secara mandiri menjadi beberapa alasan utama kenapa Arch Linux merupakan salah satu distro yang "sulit" dan _"elite"_.

Arch Linux jelas bukan distro untuk orang yang belum pernah menggunakan Linux sebelumnya, hal itu tidak bisa dipungkiri. Tantangan awal yang diberikan tersebut kemudian menjadikan kesan Arch Linux merupakan sebuah distro yang _"elite"_ dimana hanya para Linux _expert_ yang cocok menggunakannya.

## Perasaan "Superior" Terhadap Pengguna Distribusi Linux Lain

Tantangan awal proses installasi yang diberikan tersebut turut memicu munculnya "kaum _elite_" yang merasa dirinya _"superior"_ terhadap penguna ditribusi Linux lainnya yang menyertakan GUI installer seperti Fedora, Debian, Ubuntu, dan lain-lain.

Hal ini sangat bisa saya pahami karena saya juga pernah merasa _"superior"_ ketika pertama kali berhasil menginstall dan mengkonfigurasi sistem saya dari partisi, _locale_, _keyboard layout_, _timezone_, konektifitas jaringan dan NTP, hingga _window manager_ melalui CLI.

Tapi perasaan _"superior"_ tersebut pada akhirnya hilang setelah menyadari bahwa kenyatannya saya hanya seorang **pengguna** Linux biasa, sama seperti pengguna rata-rata distribusi Linux lainnya, tidak lebih. Saya bukan kernel _maintainer_, saya tidak pernah dan tidak memiliki kemampuan serta pengalaman berkontribusi ke Linux kernel, saya bukan distro _maintainer_ ataupun _tester_; betapa bodoh dan naifnya saya saat itu mengganggap diri saya sebagai "Linux _expert_" atau kaum _"elite"_.

Jika Anda menggunakan sebuah distro yang menurut Anda sulit hanya untuk dianggap sebagai seorang _"expert"_, sepertinya Anda perlu bermain lebih jauh. Jika memang benar-benar ingin dianggap _elite_, gunakan [(B)LFS](https://www.linuxfromscratch.org/blfs/) sebagai _daily driver_; dengan begitu bisa saya akui bahwa Anda memang sangat kompeten dan sabar dalam membangun sistem Linux (serta memiliki hardware yang mengesankan 👍).

## Arch Linux Tidak Semengerikan Itu

Perlu diketahui bahwa Arch Linux bukan satu-satunya Linux distro yang perlu menginstall dan mengkonfigurasinya secara manual. [Gentoo](https://www.gentoo.org/) juga seperti itu. Jujur saja, saya suga Gentoo, tapi keterbatasan _hardware_ saya untuk _me-compile_ sebagian besar _package_ menggunakan `Portage` tidak memungkan saya untuk menggunakannya sebagai _daily driver_. Keterbatasan tersebut membuat saya menganggap banwa Gentoo jauh lebih sulit dibandingkan Arch Linux.

Bagi Anda yang sudah memiliki pengalaman menggunakan Linux sebelumnya dan nyaman menggunakan CLI, Arch Linux bisa menjadi distro termudah bagi Anda selama:

-   Memiliki waktu dan kemauan untuk membaca dokumentasi.
-   Tetap pada prinsip KISS (_Keep It Simple, Stupid_).

### Installasi Yang Mudah

Proses instalasi Arch Linux yang banyak orang bilang sulit ternyata sangat mudah jika Anda sudah terbiasa bekerja dengan Linux CLI. Beberapa kali saya menginstall Arch Linux, saya cukup mengikuti _"official"_ [_Installation Guide_](https://wiki.archlinux.org/title/Installation_guide) yang sebagian besar adalah _copy paste_.

{{< youtube Pb66WXYxJHY >}}

Ditambah lagi, dengan adanya `arch-install-script` semakin mempermudah proses installasi Arch Linux.

Setelah "`base`" install, proses installasi yang berkaitan dengan GUI seperti _window atau desktop manager_ juga cukup mudah dan terdokumentasi dengan baik. Saya hanya perlu pergi ke [Arch Wiki](https://wiki.archlinux.org/), mencari informasi terkait dengan apa yang saya butuhkan, membaca dan mengikuti instruksi yang sekiranya diperlukan.

### _Breaking Changes_

Memang dulu di tahun 2010-an, saya beberapa kali mengalami kendala dalam melakukan _full system upgrade_, beberapa diantaranya cukup _"major"_ dan perlu waktu extra untuk mencari solusi dan melakukan perbaikan.

Tetapi beberapa tahun terakhir, saya merasa `core` package yang dimaintain oleh [Arch Linux Developers](https://archlinux.org/people/developers/) sangat stabil untuk _daily driver_. Begitu `extra` package yang dimaintain oleh [Arch Linux Package Maintainers](https://archlinux.org/people/package-maintainers/) cukup stabil dan jarang ada _major problem_ ketika dan setelah melakukan upgrade. Pastinya Hal ini dapat dicapai tidak terlepas dari kontribusi [Arch Testing Team](https://wiki.archlinux.org/title/Arch_Testing_Team) dan tentu saja **upstreams software developers** itu sendiri.

Bahkan untuk _personal desktop / PC_, bagi saya melakukan [maintenance jangka panjang](#_maintenance_) di Arch Linux lebih mudah dan menyenangkan dibandingkan dengan distribusi _point release_.

## Bagian Yang Sulit

Poin-poin berikut sebenarnya secara umum berlaku untuk disto apapun, tidak spesifik di Arch Distro.

### Menjaga Tetap Simple

**Pacman**, _package manager_ untuk Arch Linux sungguh sangat _powerful_. Ditambah dengan adanya [Arch Buld System](https://wiki.archlinux.org/title/Arch_build_system) serta [Arch User Repository](https://wiki.archlinux.org/title/Arch_User_Repository) membuat _software_ diluar `core` dan `extra` _package_ sangat mudah diinstall ke sistem. Kenyamanan dan kemudahan didapatkan membuat kita sulit menahan diri untuk mencoba dan menginstall sesuatu yang sebenarnya tidak benar-benar kita butuhkan.

Semakin banyak softare yang terinstall akan membuat sistem semakin kompleks, terutama untuk masalah _"dependency"_ yang sering kali memunculkan masalah tersendiri.

### _Maintenance_

Dari pengalaman saya sebagai Linux system administrator, melakukan _maintenance_ sebuah sistem untuk **jangka panjang** memang sangat sulit, tidak perduli itu _point release_ distro maupun _rolling release_ distro.

_Point release_ cenderung dikenal stabil. Stabil disini dalam artian selama masih dalam masa support. Ketika distro _point release_ memasuki masa _"end-of-life"_, melakukan upgrade ke _major version_ berikutnya akan sangat mengerikan. Saya ingat betul masa-masa saya harus melakukan upgrade dari **CentOS 5** hingga **CentOS 8** (_oh, I really miss that CentOS era_).

Sedangkan Arch Linux merupakan _rolling release_ distro dimana Anda akan mendapatkan update begitu _upstreams_ melakukan rilis software. Kelebihannya, Anda akan mendapatkan _software_ terbaru ketika melakukan _full system upgrade_ (`pacman -Syu`). Kekurangannya, kemungkinan adanya _"breaking changes"_ jauh lebih besar dibandingkan dengan _point release_ distro.

### _Security_

Keamanan komputer dan jaringan itu susah. Titik.

## Catatan

Mengenai internet meme _"I use Arch BTW"_. Saya suka meme tersebut dan saya ingin mempresentasikan apa yang ada di pikiran saya ketika menggunakan meme tersebut:

1.  Sebagai sebuah lelucun.  
    Karena memang itu sebuah meme.
2.  Membutuhkan bantuan dengan memberikan informasi yang lebih spesifik.  
    Ketika saya menemui masalah kemudian membuat topik / thread di forum online, penggunaan meme tersebut kurang lebih mengatakan bahwa _"Hei, saya mengalami masalah ..... Sistem operasi saya adalah ..... Adakah yang bisa membantu saya atau mengalami hal yang sama seperti saya?"_.

Jadi saya menggunakan meme itu sama sekali tidak ada maksud untuk menganggap saya _"superior"_. Tidak sama sekali.

Dan bagi Anda yang menganggap diri Anda _"superior"_ terhadap pengguna Linux lain; apapun distro yang Anda gunakan, sadarlah bahwa Anda (dan saya) tidak lebih dari sekedar pengguna Linux rata-rata.
