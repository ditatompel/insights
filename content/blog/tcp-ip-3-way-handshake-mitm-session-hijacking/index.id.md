---
title: "TCP/IP - 3-Way-Handshake - MiTM - Session Hijacking"
url: "tcp-ip-3-way-handshake-mitm-session-hijacking"
description: "Konsep dasar TCP/IP 3 way handshake , network sniffing, MITM, session hijacking yang dikemas dalam cerita kehidupan sehari-hari agar lebih mudah dimengerti."
date: 2012-05-12T06:16:34+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Networking
  - Security
  - TIL
tags:
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

Konsep dasar **TCP/IP** *3-way-handshake*, *network sniffing*, *Man-in-The-Middle* (**MiTM**), *session hijacking* yang dikemas dalam cerita kehidupan sehari-hari agar lebih mudah dimengerti : *"Antara Aku, Kau, dan Dia. Sebuah kisah Cerita cinta antara Sofi, Andi dan Jovi"*.

<!--more-->

Konon, dahulu kala ada seorang pria bernama Andi yang terkenal karena ketampanan dan keramahannya. Berkat ketampanan dan sikapnya yang ramah terhadap setiap orang, maka banyak wanita yang ingin berkenalan dan menjadikan Andi sebagai pacarnya; tidak terkecuali Sofi, seorang gadis muda cantik yang sudah lama ingin menyatakan cinta dan memberikan perhatiannya sepenuhnya kepada Andi.

## TCP/IP
Nah agar Sofi dapat mewujudkan impian cintanya, maka tentu saja pertama kali Sofi harus berkenalan dan melakukan komunikasi (baca: **PDKT**) sama Andi. Toh ga mungkin kan kalau kita tiba-tiba bilang cinta tanpa kenalan dulu sama orang begitu aja tanpa ada tindakan yang konsisten dari waktu ke waktu seperti perhatian, pengertian, kasih sayang, dll.

Nah dari perhatian, pengertian tersebut kita harus tau dan pinter membagi. Ga mungkin klo kita berikan perhatian terlalu besar misalnya : *"Sayang, sudah makan belum? Makan dulu gih!"*, *"Sayang sudah mandi belum? Mandi dulu gih!"* karena ntar dikira tukang ngatur, ga mungkin kita kasi pengertian ini itu brondongan secara langsung karena ntar dikira tukang ngomel, ga mungkin juga kita beri kasih sayang yang langsung seabrek karena ntar dikira kita murahan.

Konsepnya sama seperti konsep **TCP/IP** dimana kita tidak bisa mengirimkan paket besar sekaligus ke tempat tujuan, kita harus membagi paket besar tersebut menjadi paket-paket kecil dimana paket-paket tersebut akan ditandai dengan _**SEQ**uence number_. Dengan identitas *sequence number* yang diberikan, penerima akan membangun pake-paket kecil tersebut berdasarkan nomor urutan *sequence number* sehingga menjadi paket besar yang utuh.

## 3-Way-Handshake
Maka dari itu, dengan segenap hati dan dengan segenap kegalauanya, Sofi memberanikan diri untuk mengajak kenalan si Andi melalui **YM!**.

```plain
+------------------------------------------------------------------------------+
              Halo Andi, gue Sofi mau ngomong sama kamu.
  ____        ----------------------------------------->           _
-/ __"| u                     SYNchronize                      U  /"\  u
<\___ \//                                                       \/ _ \/
  ___) |       Hai Sofi, gue Andi boleh mari kita ngobrol       / ___ \
.|____/>>     <=========================================       /_/   \_\
_)(  (__)             SYNchronize-ACKnowledgement              \\    <<
(__)                                                          (__)  (__)
                           Oke, makasih Andi
              ----------------------------------------->
                              ACKnowledge

      <+-+-+-+-+-+-+-+ SYN, SYN-ACK, ACK = ESTABILISHED +-+-+-+-+-+-+-+>
```

Nah dari gambar yang ga jelas di atas bisa kita liat awal percakapan mereka ada 3 poin penting, yaitu:
1. Sofi mengirim paket _TCP **SYN**chronize_ kepada Andi.
2. Andi menerima paket **SYN** dari Sofi dan Andi mengirim balasan _**SYN**chronize-**ACK**nowledgement_ kepada Sofi.
3. Sofi menerima **SYN-ACK** dari Andi dan Kemudian Sofi mengirimkan _**ACK**nowledge_.

**TCP** *connection* **ESTABLISHED**.

Atau secara teknis bisa digambarkan mirip seperti:
```plain
           _                     SYN ISN=5000                       _
    _     /||      ------------------(1)-------------------->      ||\     _
  ~% }    \||D                                                    C||/    { )
| /\__,=_[_]               ACK=5001; SYN ISN=7000                 [_]_=,__/\ |
|_\_  |----|      <=================(2)=====================      |----|  _/_|
|  |/ |    |                                                      |    | \|  |
|  /_ |    |                      ACK=7001                        |    | _\  |
    Host A         ------------------(3)-------------------->          Host B
```

1. Host A mengirim _**SYN**chronize_ dengan **ISN** (**Initial Sequence Number**) `5000`.   
\* **ISN** / *Initial Sequence Number* adalah *sequence number* pertama yang dikirimkan dan bernilai *random*.
2. Host B menerima dan mengembalikan segmen **TCP** dengan _**SYN**chronize-**ACK**nowledgement_, dengan **ISN** `7000` dan **ACK** `5001`.   
\* **ACK** `5001` adalah *sequence number* berikutnya dari host A yang diharapkan oleh Host B.
3. Host A yang menerima **ISN** `7000` dari host B mengakui penerimaan **ISN** dari host B (_**ACK**nowledgement_ `7001`).

Kemudian komunikasi terus terjadi berdasarkan *sequence number* yang terus bertambah berdasarkan data yang dikirim dan diterima hingga akhir percakapan.

Nah, dari sini masing-masing sudah saling berkenalan dan tau identitas 1 sama lain. Dengan perkenalan yang sopan (*3-way-handshake*) proses komunikasi (baca: PDKT) dapat terus berlanjut. Dari ngobrol-ngobrol kecil, bicara tentang hobi, dll hingga Sofi dan Andi makin deket. Yah, yang namanya cinta boss, bikin 2 ekor insan itu senyam-senyum sendiri macem gajah melahirkan di depan komputer. Tapi ingat! Tidak jarang (baca:**SERING**) di sebuah hubungan ada yang namanya pihak ke-3 yang biasanya datang mengacau.

## Sniffing & Man in The Middle (MiTM)
Di cerita ini muncul karakter baru sebagai pihak ke-3. Sebut saja namanya Jovi. Dia teman dekat Sofi dan Sofi sering cerita tentang Andi kepada Jovi (Tau ndiri kan gejala orang jatuh cinta, apa aja diomongin). Dari cerita-cerita Sofi, tumbuhlah rasa penasaran Jovi terhadap Andi.

Nah mulailah Jovi melakukan perannya sebagai pihak ke-3. Ia mencari tau dan menyimak bagaimana hubungan Sofi dengan Andi (baca:*sniffing*). Jovi mengamati jam berapa Sofi biasa chatting dengan Andi, bagaimana tata cara bahasanya, seperti apa penulisan bahasa alaynya, dll.

```plain
             _                                      _
        ~0  (_|  . - ' - . _ . - ' - . _ . - ' - . |_)  O
       |(_~|^~~|                 |                |~~^|~_)|
       TT/_ T"T                  +                 T"T _\HH
         Sofi                    |                   Andi
                              ___+___
                             |.-----.|
                             ||x . x||
                             ||_.-._||
                             `--)-(--`
                            __[=== o]___
                           |:::::::::::|\
                           `-=========-`()
                                Jovi
```

Seperti yang sudah saya tulis sebelumnya pada bagian **TCP/IP** bahwa data yang dikirim akan dipecah menjadi paket-paket kecil dengan *sequence number* untuk tiap paketnya. Dan untuk melakukan koneksi TCP antara host A dan host B harus melalui yang namanya *3-way-handshake* terlebih dulu. Dari hasil *shake hand* 3 kali tadi akan mendapatkan *sequence number* sebagai indentitas yang terus bertambah berdasarkan data yang dikirim dan diterima.
Dengan melakukan *sniffing* dan memperhatikan *sequence number* antara Sofi dan Andi, maka Jovi dapat melakukan sesuatu yang bernama *Session Hijacking*. Mari kita ambil contoh dari lanjutan gambar yang ga jelas sebelumnya yaitu :

```plain
           _                     SYN ISN=5000                       _
    _     /||      ------------------(1)-------------------->      ||\     _
  ~% }    \||D                                                    C||/    { )
| /\__,=_[_]               ACK=5001; SYN ISN=7000                 [_]_=,__/\ |
|_\_  |----|      <=================(2)=====================      |----|  _/_|
|  |/ |    |                                                      |    | \|  |
|  /_ |    |                      ACK=7001                        |    | _\  |
    Host A         ------------------(3)-------------------->          Host B
                   
        <+-+-+-+-+-+-+-+-+-+-+-+ ESTABILISHED +-+-+-+-+-+-+-+-+-+-+-+>
        
           _                  SEQ=5001; DATA=128                    _
    _     /||      ------------------(4)-------------------->      ||\     _
  ~% }    \||D                                                    C||/    { )
| /\__,=_[_]                      ACK=5129                        [_]_=,__/\ |
|_\_  |----|      <=================(5)=====================      |----|  _/_|
|  |/ |    |                                                      |    | \|  |
|  /_ |    |                  SEQ=5129; DATA=81                   |    | _\  |
    Host A         ------------------(6)-------------------->          Host B
                   
                                   ACK=5210
                   <=================(7)=====================
                   
      <+-+-+-+-+-+-+-+-+-+-+-+ SESSION HIJACKING +-+-+-+-+-+-+-+-+-+-+-+>
                                                                    _
                                    SEQ=5210; DATA=50              ||\     _
                       _   ---------------(8)--------------->     C||/    { )
                  ~0  (_|                                          [_]_=,__/\ |
                 |(_~|^~~|              ACK=5250                   |----|  _/_|
                 TT/_ T"T  <==============(9)================      |    | \|  |
                  Host C                                           |    | _\  |
                                    SEQ=5250; DATA=200                 Host B
                           --------------(10)--------------->

  <+-+-+-+-+-+-+-+-+-+-+-+ SESSION HIJACKING EFFECT +-+-+-+-+-+-+-+-+-+-+-+>
       
           _                  SEQ=5210; DATA=60                    _
    _     /||      ------------------(11)-------------------->     ||\     _
  ~% }    \||D                                                    C||/    { )
| /\__,=_[_]                 SEQ=5210; DATA=60                    [_]_=,__/\ |
|_\_  |----|      ------------------(12)-------------------->     |----|  _/_|
|  |/ |    |                                                      |    | \|  |
|  /_ |    |                      ACK=5450                        |    | _\  |
    Host A         <=================(13)=====================         Host B

                              SEQ=5210; DATA=60               
                   ------------------(14)-------------------->
                   
                                   ACK=5450                   
                   <=================(15)=====================
```

1. Host A (Sofi) mengirim _**SYN**chronize_ dengan **ISN** (*Initial Sequence Number*) `5000`.
2. Host B (Andi) menerima dan mengembalikan segmen **TCP** dengan _**SYN**chronize-**ACK**nowledgement_, dengan **ISN** `7000` dan **ACK** `5001`.
3. Host A yang menerima **ISN** `7000` dari host B mengakui penerimaan **ISN** dari host B (_**ACK**nowledgement_ `7001`).
4. Host A Mengirimkan _**SEQ**uence number_ `5001` dengan banyaknya data yang dikirim `128` kepada host B.
5. Host B memberitahukan bahwa ia telah menerima paket dari dengan _**ACK**nowledgement_ `5129` (_**SEQ**uence number_ Host A=5001 + Data yang dikirim Host A 128).
6. Host A mengirimkan _**SEQ**uence number_ `5129` dengan banyaknya data yang dikirim `81` kepada host B.
7. Host B memberitahukan bahwa ia telah menerima paket dari dengan _**ACK**nowledgement_ `5210` (_**SEQ**uence number_ Host A=5129 + Data yang dikirim Host A 81).

```plain
<!– #break; –>
```

Ternyata eh ternyata, Jovi (host C) telah melakukan *sniffing* dengan memperhatikan _**SEQ**uence number_ dari komunikasi yang dilakukan oleh Sofi (Host A) dan Andi (Host B).

8. Dari hasil *sniffing* Jovi (Host C), ia mengirimkan _**SEQ**uence number_ `5210` dan informasi data yang dikirimkan sebanyak `50` kepada Andi (Host C). _**SEQ**uence number_ yang dikirimkan Jovi (Host C) ini berdasarkan _**ACK**nowledgement_ dari Andi (Host B) untuk Sofi (Host A)
9. Seperti biasa, Host B mengirimkan _**ACK**nowledgement_ paket yang ia terima kepada sang pengirim, yaitu Host C.
10. Komunikasi berlanjut antara Jovi (Host C) dan Andi (Host B). Dari contoh ini, host C mengirimkan _**SEQ**uence number_ `5250` dengan informasi data yang dikirim sebanyak `200` kepada host B.

```plain
<!– #break; –>
```

Lalu apa yang terjadi dengan Sofi (Host A)? Tentu saja hubungan mereka terputus. Hal ini dimulai pada saat Jovi (Host C) mengirimkan _**SEQ**uence number_ `5210` kepada Andi (Host C) **(tahap ke 8)** dan Andi tidak mengirimkan _**ACK**nowledgement_-nya kepada Sofi (Host A) melainkan kepada Jovi (Host C) **(tahap ke 9)** Karena Jovi telah mengirimkan _**SEQ**uence number_ `5210` kepada Andi terlebih dahulu.

11. Host A mengirimkan _**SEQ**uence number_ `5210` dengan banyaknya data yang dikirim `60` kepada host B atas dasar _**ACK**nowledgement_ dari host B sebelumnya (tahap ke 7).
12. karena host A tidak menerima _**ACK**nowledgement_ dari Host B dari _**SEQ**uence number_ `5210` yang ia kirim, maka Host A mengira paket yang ia kirimkan kepada host B tidak sampai / rusak di tengah jalan; sehingga Host A mengirimkan lagi paket _**SEQ**uence number_ `5210`-nya.
13. Karena terakhir kali host B menerima paket _**SEQ**uence number_ `5210` dan data yang dikirim `50` dari Host C **(tahap ke 10)**; Host B mengirimkan _**ACK**nowledgement_ `5450` kepada host A.   
Hal ini terjadi terus menerus karena host A menerima _**ACK**nowledgement_ yang tidak seharunya ia terima, dan Host B menerima _**SEQ**uence number_ yang seharusnya tidak ia terima. Kalau kata Parto di OVJ *"Wayangnya Bingung, Dalangnya Juga Bingung"*. Terjadilah apa yang dinamakan **"ACK Storm"**. (mengenai *ACK Storm*, **MiTM**, hijack menghijack mungkin bisa kita bahas di lain kesempatan yang juga berhungan dengan **TCP RST** *flag* dan **ARP Cache Poisoning**).

Hancur sudah hubungan Sofi dengan Andi, dan terciptalah hubungan Jovi dan Andi. Sadis? Sadis memang.. Ngenes? ngenes memang.. Tapi itulah hidup. _You never know what you have until you lose it, and once you lose it, you can never get it back. Of course, Sofi going to get broken heart. That's just part of growing up, and it makes Sofi stronger. Maybe, just maybe... Sofi and Andi can handle it better next time._ x_x

Akhir kata, maksud hati menulis cerita cinta, apa daya jadinya seperti ini. Dari mana pula datangnya **TCP**, darimana pula datangnya *Session Hijacking*. Pembaca bingung, penulisnya juga bingung. Apapun itu, moga aja bisa berguna meskipun sederhana dan seadanya.

