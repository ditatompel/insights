---
title: "Membaca Binary Secara Manual"
description: "Bagaimana membaca sekumpulan angka 0 dan 1 (Binary) menjadi angka desimal. Kemudian cara mengkonversi desimal ke text (ASCII) menggunakan keyboard & Notepad"
# linkTitle:
date: 2012-01-08T04:29:52+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
# nav_icon:
#   vendor: bootstrap
#   name: toggles
#   color: '#e24d0e'
series:
  - Ilmu Komputer
categories:
  - TIL
tags:
  - Binary
images:
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

Sebenarnya artikel ini udah lama. Beberapa saya pungut dari tulisannya om **Capsoel** di **X-Code Magazine edisi 6** dan sisanya *Googling*. Saya coba angkat dan share disini karena teman saya yang tahun lalu melamar kerja di suatu perusahaan ujian pertamanya *covert Binary* ke *Decimal* dengan cara penghitungan manual. Semoga berguna.

<!--more-->

```
01000100011001010111011001101001011011000111101001100011001100000110010001100101
```

Apa itu? kenapa hanya angka `0` dan `1`? Saya yakin tidak semua orang (bahkan yang setiap harinya utak atik komputer) mengerti bagimana membaca **Binary**.

Sederetan angka 0 dan 1 ini adalah kode **binary**. Pertama, saya akan menunjukan bagaimana membaca sekumpulan angka 0 dan 1 tersebut sebagai angka **desimal**. Kemudian saya baru menunjukan bagaimana cara menggunakan angka tersebut diterjemahkan ke *text* (atau **ASCII**) menggunakan *keyboard* anda dengan *software* bawaan Windows, yaitu `notepad` (Dulu saya coba di notepadnya **Windows XP**).

Sebagai contoh mudah:

```
10101
```

pertama, bayangkan 5 digit di atas adalah sebuah slot kosong:

```
_ _ _ _ _
```

Cara membaca **binary** adalah dari kanan ke kiri.
* Slot **pertama** dari kanan mewakili nilai **1**,
* slot **kedua** dari kanan mewakili nilai **2**,
* slot **ketiga** mewakili nilai **4**,
* slot **keempat** mewakili nilai **8**,
* slot **kelima** mewakili **16**,
* dan seterusnya hingga slot ke 8.

```
slot 1 = 1
slot 2 = 2
slot 3 = 4
slot 4 = 8
slot 5 = 16
slot 6 = 32
slot 7 = 64
slot 8 = 128
```

Dengan memberikan angka `1` atau `0` pada slot-slot tersebut, kita menentukan nilai pada slot tersebut. 1 bernilai "`true`", dan 0 bernilai "`false`". Sebagai contoh:
* nilai bilangan **desimal** `1` dalam **binary** adalah `1`,
* nilai bilangan **desimal** `2` dalam **binary** adalah `10`,
* nilai bilangan **desimal** `4` dalam **binary** adalah `100`.

Kenapa bisa begitu? Kembali lagi ke slot-slot di atas.

Slot pertama dari kanan bernilai `1`, jadi jika slot pertama adalah angka `1` maka nilainya juga `1` dan bilangan binernya adalah `1`.

```
_ _ _ _ 1
```

Untuk **desimal** `2`, bilangan **biner** = `10`

karena slot pertama bernilai 1 diberi angka 0 (*false*) dan slot ke 2 diberi angka 1 (*true*)

```
_ _ _ 1 0
```

Untuk **desimal** `4`, bilangan **biner** = `100`

karena slot pertama bernilai 1 diberi angka 0 (*false*) dan slot ke 2 diberi angka 0 (*false*) dan baru slot ketiga yg bernilai 4 diberi angka 1 (*true*)

```
_ _ 1 0 0
```

Lalu gimana klo **desimal** `3`? Kan ga ada nilainya pada slot? `1 + 2 = 3`. Jadi, nilai **desimal** `3` pada **binary** adalah `11`
```
_ _ _ 1 1
```

klo desimal `5`? `1 + 4 = 5` berarti bilangan *binernya* `101`.

```
_ _ 1 0 1
```

Lalu jika kode binernya panjang banget seperti ini? Gimana bacanya ke **ASCII** / *text*?

```
01000100011001010111011001101001011011000111101001100011001100000110010001100101
```

Pisahkan dulu menjadi 8 digit:
```
01000100 01100101 01110110 01101001 01101100 01111010 01100011 00110000 01100100 01100101
```

Lalu convert ke bilangan **decimal**

```
01000100 = 68
01100101 = 101
01110110 = 118
01101001 = 105
01101100 = 108
01111010 = 122
01100011 = 99
00110000 = 48
01100100 = 100
01100101 = 101
```

Lalu ASCIInya mana?

Hehehe.. Sekarang giliran notepad menerjemahkannya.. (dulu ane coba ni teknik pake Notepad di **Windows XP**, kaga tau sekarang jalan di **Windows 7** atau tidak).

Caranya tahan <kbd>ALT</kbd> + Angka desimal yang sudah ditranslate.

<kbd>ALT</kbd> + <kbd>68</kbd> = `D`   
<kbd>ALT</kbd> + <kbd>101</kbd> = `e`

dan seterusnya, silahkan dicoba dan dibuktikan..

Atau kalau mau mudah bisa menggunakan translator binary yang banyak beredar di internet.. Misalnya saja `http://home.paulschou.net/tools/xlate/`.

