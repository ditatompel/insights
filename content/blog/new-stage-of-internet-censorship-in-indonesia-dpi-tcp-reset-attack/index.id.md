---
title: "Babak Baru Sensor Internet di Indonesia: DPI & TCP Reset Attack"
description: "Beberapa upstream provider atau checkpoint melakukan TCP Reset Attack untuk memblokir akses ke website-website yang dinilai ilegal."
date: 2023-06-04T01:19:36+07:00
lastmod:
draft: false
noindex: false
featured: true
pinned: false
# comments: false
series:
#  - 
categories:
  - TIL
  - Privasi 
tags:
  - MiTM
  - Internet Positif
  - VPN
  - Proxy
  - DNS-over-HTTPS
  - Kominfo
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

Berbeda dengan sebelumnya yang menggunakan **DNS filtering**, beberapa *upstream* telah melakukan **TCP Reset Attack** untuk memblokir akses ke website-website yang dinilai ilegal. Dan kenapa Anda harus mulai perduli untuk masalah ini.

<!--more-->
---

## Latar Belakang
Sejak beberapa bulan yang lalu, saya mulai tidak dapat mengakses **reddit.com** dari koneksi internet **ISP** saya, padahal di jaringan rumah saya sudah memakai **DNS-over-HTTPS (DoH)**. Hal yang sama terjadi juga ketika saya melakukan **VPN** ke server saya yang notabenenya tanpa **"Internet Positif"** (baca: tanpa sensor).

Browser saya selalu mengatakan _error **"The connection was reset"**_. *Service* gratis [libreddit yang saya sediakan](https://libreddit.ditatompel.com/) untuk mengakses **Reddit** tanpa konten bermuatan **NSFW** juga menjadi tidak bekerja (servernya sebelumnya ada di **Indonesia Data Center Duren Tiga** atau **IDC-3D**).

Setelah berdiskusi dengan rekan kantor dan melakukan sedikit observasi, saya dapat menyimpulkan bahwa yang saya alami adalah **_TCP reset attack_ (TCP RST)** dan terjadi di _**Upstream** provider_ yang saya gunakan. Sepertinya (menurut saya pribadi), *upstream provider* yang saya gunakan dipaksa atau terpaksa melakukan aktifitas "jahat" ini.

Kenapa saya bilang terpaksa atau dipaksa? Karena *Upstream provider* adalah pelaku bisnis, dan tujuan bisnis salah satunya adalah meraih laba sebesar-besarnya. Sedangkan untuk melakukan **Deep Packet Inspection (DPI)** untuk *traffic* yang besar bukan hal yang murah. Coba saja cari informasi harga **Palo Alto 5200** series, **Cisco Firepower 9300** series, atau **FortiGate 6000** series jika tidak percaya. Itu baru biaya *hardware*, belum untuk biaya *maintenance*, dan pengeluaran oprasional seperti *training*, gaji, dan lain-lain. Tapi jika ancamannya adalah pencabutan izin, apa boleh buat?

Memang perangkat *firewall enterprise* seperti yang saya sebutkan diatas pasti dimiliki perusahaan ISP besar, apa lagi di *network checkpoint*. Namun saya yakin, pelaku bisnis akan lebih memilih menghemat *resource* dan menghindari komplain dari *customer* bisnisnya (*downstream*) daripada harus melakukan *deployment* dan *integration* DPI di infrastruktur *network* yang sudah mereka punya.

Jika *cost* untuk melakukan **DPI** akan sangat mahal, mungkinkah **TCP-RST attack** tersebut diimplementasikan di setiap *checkpoint* pada skala nasional? Tidak mungkin bukan? *Hold my beer*, Anda mungkin tidak tahu *track-record* seberapa *"kaya"* negara kita untuk membeli dan mengimplementasikan hal-hal seperti itu di bagian [#Privasi](#privasi).

## Investigasi
Saya melakukan investigasi yang sangat sederhana untuk membuktikan apakah benar **TCP-RST attack** itu terjadi. Ada 2 cara yang saya lakukan:
1. menggunakan browser dengan *inspect element* (*simple*).
2. Langsung dari server saya yang berada di Indonesia dan melakukan *network capture* menggunakan `tcpdump` (*advanced*).

> _CATATAN: Dari yang selama ini saya amati, **TCP-RST attack** belum diimplementasikan di seluruh *checkpoint* / *upstream*. Jadi masih banyak provider yang belum tertampak._

### Menggunakan Browser (*inspect element*, *simple*)
![Browser error: connection reset](browser-connection-reset.png#center)

Cara paling mudah (tetapi tidak detail) adalah menggunakan browser Anda. Ketika Anda tidak dapat mengakses reddit.com (atau situs lain yang diblokir pemerintah) dan mendapatkan pesan _error **"The connection was reset"**_; besar kemungkinan ISP (atau *upstream* ISP) Anda sudah mengimplementasikan metode ini.

Cara lebih detail, sebelum mencoba akses ke reddit.com klik kanan pada browser dan cari kata "*inspect*" atau "*developer tools*". Masuk ke tab "**Network**" kemudian baru coba akses reddit.com. Informasi "*CONNECTION_RESET*" pada tab status muncul jika server mengirimkan *packet reset* (**RST**).

### Menggunakan `tcpdump` dan `curl` (*advanced*)
> Supaya dapat mengerti metode ini, Anda perlu mengetahui **konsep dasar TCP/IP** dan **3-Way-Handshake**. Saya pernah menulis mengenai analogi [TCP/IP - 3-Way-Handshake - MiTM - Session Hijacking]({{< ref "/blog/tcp-ip-3-way-handshake-mitm-session-hijacking/index.id" >}}) di tahun 2012 lalu. Atau silahkan mencari sendiri dari mesin penelusuran favorit Anda.

Saya mencoba melakukan investigasi **langsung** dari server saya yang berada di **Indonesia Data Center Duren Tiga**. Caranya cukup *simple*, yaitu dengan melakukan `curl` **HTTP GET** ke reddit.com dan melakukan *packet capture* menggunakan `tcpdump` secara bersamaan.

Dibawah ini `151.101.xx.xxx` adalah salah 1 IP reddit.com yang saya dapatkan dari **DNS resolver** saat melakukan testing. Sedangkan `xxx.xxx.x06.26` adalah IP public server milik saya.

Sample `curl https://reddit.com -vvv` output:
```plain
*   Trying 151.101.xx.xxx:443...
* TCP_NODELAY set
* Connected to reddit.com (151.101.xx.xxx) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* OpenSSL SSL_connect: Connection reset by peer in connection to reddit.com:443 
* Closing connection 0
curl: (35) OpenSSL SSL_connect: Connection reset by peer in connection to reddit.com:443
```

sample `tcpdump -i ens18 dst 151.101.xx.xxx or src 151.101.xx.xxx -Nnn`:
```plain
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens18, link-type EN10MB (Ethernet), capture size 262144 bytes
00:54:25.646807 IP xxx.xxx.x06.26.43020 > 151.101.xx.xxx.443: Flags [S], seq 1624542501, win 64240, options [mss 1460,sackOK,TS val 3865742701 ecr 0,nop,wscale 7], length 0
00:54:25.659369 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [S.], seq 2720903651, ack 1624542502, win 65535, options [mss 1460,sackOK,TS val 1136396143 ecr 3865742701,nop,wscale 9], length 0
00:54:25.659407 IP xxx.xxx.x06.26.43020 > 151.101.xx.xxx.443: Flags [.], ack 1, win 502, options [nop,nop,TS val 3865742714 ecr 1136396143], length 0
00:54:25.666249 IP xxx.xxx.x06.26.43020 > 151.101.xx.xxx.443: Flags [P.], seq 1:518, ack 1, win 502, options [nop,nop,TS val 3865742721 ecr 1136396143], length 517
00:54:25.666843 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [R.], seq 1, ack 518, win 16, length 0
00:54:25.666850 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [R.], seq 1, ack 518, win 16, length 0
00:54:25.666931 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [R.], seq 1, ack 518, win 16, length 0
00:54:25.678672 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [.], ack 518, win 285, options [nop,nop,TS val 1136396162 ecr 3865742721], length 0
00:54:25.678708 IP xxx.xxx.x06.26.43020 > 151.101.xx.xxx.443: Flags [R], seq 1624543019, win 0, length 0
00:54:25.683731 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [P.], seq 1:3717, ack 518, win 285, options [nop,nop,TS val 1136396167 ecr 3865742721], length 3716
00:54:25.683753 IP xxx.xxx.x06.26.43020 > 151.101.xx.xxx.443: Flags [R], seq 1624543019, win 0, length 0
```

**Keterangan dari hasil `tcpdump` _flag_ diatas**:

| TCP Flag  | tcpdump flag | keterangan        |
| --------  | ------------ | ----------------- |
| `SYN`     | `S`          | Koneksi dimulai   |
| `FIN`     | `F`          | Koneksi selesai   |
| **`RST`** | **`R`**      | **Koneksi reset** |
| `PUSH`    | `P`          | Data *push*       |
| `ACK`     | `.`          | *Acknowledgment*  |

> _* Flag diatas dapat dikombinasikan, misalnya `[s.]` adalah packet `SYN-ACK`._

![TCP-RST attack](tcp-rst-attack.png#center)

Terlihat jelas setelah server saya melakukan *handshake* dan mengirimkan pengiriman *packet data*, saya langsung menerima `RST` (*reset*) *flag*.

## Kenapa Anda Harus Perduli?
Meskipun belum sekelas [The Great Firewall of China (GFW)](https://en.wikipedia.org/wiki/Great_Firewall), terapi indikasi menuju kesana sangat terasa. yang sebelumnya hanya dari **DNS spoofing**, **filtering** dan **redirect**; sekarang sudah menggunakan *Deep Packet Inspection* dan *TCP reset attack*. 

[Dikutip dari Wikipedia](https://en.wikipedia.org/wiki/Deep_packet_inspection#Indonesia), pemerintah Indonesia melalui **Telkom Indonesia** (ISP milik pemerintah) mengunakan teknologi **Deep Packet Inspection (DPI)** dari **Cisco Meraki** melakukan pengawasan (*surveillance*) dan *maping* Nomor Induk Kependudukan (**NIK**) terhadap masyarakat yang menggunakan jasa ISP milik pemerintah.

Tujuan dari **Deep Packet Inspection (DPI)** termasuk melakukan *filter* terhadap konten pornografi, ujaran kebencian dan meredakan tensi (misalnya di Papua 2019). Pemerintah Indonesia juga berencana [meningkatkan pengawasan](wikipedia-dpi-indonesia.png#center) (*surveillance*) ke tingkat lebih lanjut hingga tahun 2023.

### Makin Terbatasnya Akses Terhadap Informasi
Kedepannya, ~~Anda~~ kita akan mengalami kesulitan untuk mendapatkan informasi yang dianggap *"terlarang"* oleh pemerintah. Ingin melihat dan mencoba sendiri contoh nyata-nya? Coba gunakan mesin pencari asal China bernama [Baidu](https://www.baidu.com/) dan lakukan pencarian dengan kata kunci **"Tiananmen Square"**. Bandingkan hasil penelusuran dari **Baidu** dengan hasil pencarian mesin pencari lain.

Saya sendiri sudah mengalaminya, meskipun tidak seperti dan separah di China sana, tetapi sangat merepotkan dan menyebalkan. Misalnya ketika saya mencoba melakukan pencarian mengenai *trouble* yang saya alami mengenai masalah **IT**, sering kali mesin pencarian mengeluarkan hasil pencarian dari **Reddit** dan solusi itu ada dan sudah didiskusikan disana. Namun untuk mengaksesnya saya harus melakukan **VPN** terlebih dahulu sebelum masuk ke *link* hasil pencarian tersebut.

### Rusaknya Hak Asasi dan Turunnya Nilai-Nilai Demokrasi
Pembatasan hak digital dapat merusak hak asasi manusia dan menurunkan nilai-nilai demokrasi. Contohnya pada awal tahun 2021, penduduk **desa Wadas** yang telah menolak proyek pertambangan batu Andesit (untuk keperluan proyek **Bendungan Bener**).

Selama beberapa tahun kemudian, penduduk desa Wadas masih meluncurkan seri protes dan menggunakan media sosial untuk menggerakkan dukungan dan meningkatkan kesadaran. Namun, konektivitas internet mereka justru (diyakini) dibatasi oleh pihak berwajib sebagai respon terhadap protes warga pada Februari 2022.

Penduduk Wadas melaporkan kesulitan dalam mengakses akun Twitter masing-masing pada minggu yang sama, walaupun belum jelas bagaimana pembatasan tersebut dilakukan. Siilahkan baca sendiri artikel dari DetiX berjudul [Derasnya Penindasan Hak Digital di Wadas](https://news.detik.com/x/detail/investigasi/20220221/Derasnya-Penindasan-Hak-Digital-di-Wadas/).

### *Chilling Effect* / Efek Jera dan Matinya Kebebasan Berekspresi
Efek jera atau biasa dikenal sebagai [*Chilling Effect*](https://en.wikipedia.org/wiki/Chilling_effect) adalah sebuah konsep ketakutan masyarakat yang muncul karena hukum atau peraturan perundang-undangan yang ambigu (*EHEMMMMM... UUITE.. Ehemmmm.. Maaf tiba-tiba batuk*). Biasanya *chilling effect* berhubungan dengan peraturan yang terkait dengan pencemaran nama baik atau fitnah (*Ehemmmm... maaf batuk lagi..*).

Selama 2018, [polisi menangkap 122 orang terkait ujaran kebencian di media sosial](https://nasional.kompas.com/read/2019/02/15/15471281/selama-2018-polisi-tangkap-122-orang-terkait-ujaran-kebencian-di-medsos). Disana, ada lima jenis kejahatan, mulai dari *hoaks*, berita bohong, berita palsu, penistaan agama, hingga pencemaran nama baik ungkap **Brigjen Pol. Rachmad Wibowo** yang saat itu menjabat sebagai **Direktur Tindak Pidana Siber Badan Reserse Kriminal Polri**.

Kemudian di 2021, dengan *"diaktifkannya"* **Polisi Siber** akan makin membungkam kebebasan sipil itu sendiri, khususnya tekait kebebasan berekspresi. Hal tersebut disampaikan oleh Koordinator Komisi untuk Orang Hilang dan Tindak Kekerasan (**Kontras**) **Fatia Maulidiyanti**.

Dan di bulan februari 2022, hasil survey dari **Indikator Politik Indonesia** menunjukan bahwa 62,9 (dengan metode *stratified random* dari 1.200 responden dengan *margin of error* sekitar 2,9 persen) responden menyatakan setuju dan sangat setuju bahwa [masyarakat saat ini semakin takut dalam mengeluarkan pendapat](https://nasional.tempo.co/read/1580168/survei-indikator-politik-indonesia-629-persen-rakyat-semakin-takut-berpendapat).

> "_Sekarang Polisi Siber itu gampang sekali, kalau misalnya Anda mendapatkan berita yang mengerikan, lalu lapor ke polisi, dalam waktu sekian menit diketahui dapat dari siapa, dari mana, lalu ditemukan pelakunya lalu ditangkap." - **Mahfud MD**_

### Privasi
Sebenarnya, privasi adalah hal pertama yang seharusnya saya sebut dari semua poin-poin ini. Tapi karena di Indonesia masyarakatnya masih tidak begitu perduli urusan privasi ya saya taruh di hampir akhir. *Lha wong* data **BSI** bocor aja yang paling banyak diributin duitnya, bukan kebocoran data pribadinya.

> _Tenang boss, duit itu pasti balik karena perbankan pasti punya rekap data dan backup, transaksi sesama bank maupun antar bank juga pasti tercatat. Yang rugi adalah waktu dan tenaga Anda saat layanan tersebut tidak bisa digunakan. Dan yang paling penting, data pribadi Anda yang nantinya diperjual belikan._

Kembali ke masalah privasi dan **Deep Packet Inspection (DPI)**, sebenarnya awal DPI dibuat oleh *engineer* adalah untuk mengukur dan mengatur keamanan jaringan dan melindungi pengguna dan mencegah penyebaran *malware*. Tapi, dengan dimanfaatkan teknologi tersebut sebagai alat *surveillance* akan sangat berdampak buruk pada privasi ~~Anda~~ kita. Selain itu, DPI juga dapat dimanfaatkan untuk mempelajari prilaku / *interest* seorang individu maupun instansi dari aktifitas mereka di internet yang pada akhirnya dapat digunakan untuk *targeted (behavioral) marketing*. 

Berbagi laporan telah mengaitkan pihak berwajib dengan pembelian dan penggunaan *spyware* dan alat-alat *surveillance* canggih lainnya. Misalnya, di tahun 2015, **Citizen Lab**; sebuah kelompok penelitian yang berbasis di **Toronto** [menduga bahwa pemerintah Indonesia pernah menggunakan *spyware* **FinFisher**](https://citizenlab.ca/2015/10/mapping-finfishers-continuing-proliferation/) yang mengumpulkan data seperti audio **Skype**, *key log*, dan tangkapan layar.

Di tahun 2016, [**Joseph Cox**](https://www.vice.com/en/contributor/joseph-cox) [mengungkap](https://www.vice.com/en/article/4xaq4m/the-uk-companies-exporting-interception-tech-around-the-world) bahwa *International Mobile Subscriber Identity-catchers* ([**IMSI-catchers**](https://en.wikipedia.org/wiki/IMSI-catcher)) pernah dijual ke Indonesia dari perusahaan Swiss dan Inggris. **IMSI-catcher** adalah perangkat yang digunakan untuk menangkap (*intercept*) *traffic* jaringan ponsel dan melakukan pelacakan lokasi kepada pengguna ponsel. Bisa dibilang, seperti sebuah *"BTS palsu"* sebagai perantara antara ponsel milik pengguna ke BTS asli milik ISP.

Pada Desember 2021, **Citizen Lab**, menyatakan bahwa ada kemungkinan besar pemerintah Indonesia telah menjadi pelanggan **Cytrox** yang menjual **Predator** *spyware*. Selain itu, **Citizen Lab** juga melaporkan pada Desember 2020 bahwa Indonesia sangat mungkin pernah membeli teknologi dari [**Circles**](https://dimse.info/circles/), sebuah perusahaan yang menjual exploit dari sistem selular global yang kemudian bergabung dengan [NSO group](https://www.nsogroup.com/). Metode yang dilakukan **Citizen Lab** untuk mengetahui hal tersebut adalah dengan melakukan *scanning & signature fingerprinting* terhadap *checkpoint firewall* pada perangkat **Circles** melalui layanan [Shodan](https://www.shodan.io/).

### Dampak Terhadap Perekonomian
Dari yang saya amati sampai saat ini, implementasi **TCP-RST attack** masih ada di beberapa *upstream provider* saja. Namun jika hal ini ini terus dilakukan dan diimplementasikan di seluruh *checkpoint* yang keluar dari Indonesia, maka akan berdampak pada minat beli dan investasi ke *Cloud Provider* / *Datacenter* yang berlokasi di Indonesia.

Siapa yang mau jika tiba-tiba *microservices*-nya tidak berfungsi karena **TCP-RST attack** tersebut? Saya sendiri mulai memindahkan VPS-VPS saya ke luar Indonesia karena menurut saya, *server* seharusnya bebas dan tidak ada batasan atas akses kemanapun juga. 

![Moving to AWS](moving-to-aws.png#center)

## Menghindari sensor
Untuk melakukan *bypass* sensor yang berbasis **DNS** seperti *DNS spoofing*, *filtering* dan *redirect*; mengajari orang *awam* memanfaatkan **DNS-over-HTTPS (DoH)** masih cukup mudah. Tetapi untuk melakukan *bypass* DPI dan **TCP RST attack** saya rasa akan sangat sulit dan mustahil dilakukan oleh orang awam.

Salah satu cara adalah menggunakan *tunnel* ke *server* yang berada diluar Indonesia, entah itu **VPN** atau **SOCKS5 proxy**. Itu pun pemerintah dan ISP yang Anda gunakan akan tetap tahu bahwa Anda menggunakan **Proxy** / **VPN**. Bedanya mereka tidak tahu apa yang Anda cari dan kemana setelah itu Anda berkomunikasi.

Jika Anda benar-benar *concern* terhadap privasi, pemilihan **VPN provider** juga harus dilakukan dengan riset yang cukup rumit. Banyak sekali aplikasi di **App Store** yang menawarkan **VPN gratis**, tetapi tidak sedikit **VPN provider** yang pada akhirnya mengelola dan menjual data Anda.

Kita juga berharap bahwa teknologi **QUIC/HTTP3** segera masuk ke babak baru yang **"mungkin"** akan sedikit membantu mengurangi dampak **TCP RST attack**.

## Sumber dan Referensi
- "[Indonesia: Freedom on the Net 2022 Country Report](https://freedomhouse.org/country/indonesia/freedom-net/2022)" - freedomhouse.org.
- "[State of Privacy Indonesia](https://privacyinternational.org/state-privacy/1003/state-privacy-indonesia)" - privacyinternational.org.
- NetBlocks. 2019b: "[Internet disrupted in Papua, Indonesia amid protests and calls for independence](https://netblocks.org/reports/internet-disrupted-in-papua-indonesia-amid-mass-protests-and-calls-for-independence-eBOgrDBZ)" - netblocks.org.
- Thompson, Nik; McGill, Tanya; and Vero Khristianto, Daniel, "[Public Acceptance of Internet Censorship in Indonesia](https://aisel.aisnet.org/acis2021/22)" (2021). ACIS 2021 Proceedings. 22.
- Wildana, F. (2021) "[An Explorative Study on Social Media Blocking in Indonesia](https://journal.unesa.ac.id/index.php/jsm/article/view/12976)", The Journal of Society and Media, 5(2), pp. 456–484. doi: 10.26740/jsm.v5n2.p456-484.
-  Paterson, Thomas (4 May 2019). "[Indonesian cyberspace expansion: a double-edged sword](https://doi.org/10.1080%2F23738871.2019.1627476)". *Journal of Cyber Policy*. 4 (2): 216–234. doi:10.1080/23738871.2019.1627476. ISSN 2373-8871. S2CID 197825581.
- Bill Marczak, John Scott-Railton, Bahr Abdul Razzak, Noura Al-Jizawi, Siena Anstis, Kristin Berdan, and Ron Deibert, "[Pegasus vs. Predator: Dissident’s Doubly-Infected iPhone Reveals Cytrox Mercenary Spyware](https://citizenlab.ca/2021/12/pegasus-vs-predator-dissidents-doubly-infected-iphone-reveals-cytrox-mercenary-spyware/)" - citizenlab.ca.
- Bill Marczak, John Scott-Railton, Siddharth Prakash Rao, Siena Anstis, and Ron Deibert, "[Running in Circles
Uncovering the Clients of Cyberespionage Firm Circles](https://citizenlab.ca/2020/12/running-in-circles-uncovering-the-clients-of-cyberespionage-firm-circles/)" - citizenlab.ca.
- Bill Marczak, John Scott-Railton, Adam Senft, Irene Poetranto, and Sarah McKune, "[Pay No Attention to the Server Behind the Proxy](https://citizenlab.ca/2015/10/mapping-finfishers-continuing-proliferation/)", Mapping FinFisher’s Continuing Proliferation - citizenlab.ca.
- Joseph Cox, "[British Companies Are Selling Advanced Spy Tech to Authoritarian Regimes](https://www.vice.com/en/article/4xaq4m/the-uk-companies-exporting-interception-tech-around-the-world)" - vice.com.
- Thomas Brewster, "[A Multimillionaire Surveillance Dealer Steps Out Of The Shadows and His $9 Million WhatsApp Hacking Van](https://www.forbes.com/sites/thomasbrewster/2019/08/05/a-multimillionaire-surveillance-dealer-steps-out-of-the-shadows-and-his-9-million-whatsapp-hacking-van/)" - forbes.com.
- Moh. Khory Alfarizi, Febriyan, "[Survei Indikator Politik Indonesia: 62,9 Persen Rakyat Semakin Takut Berpendapat](https://nasional.tempo.co/read/1580168/survei-indikator-politik-indonesia-629-persen-rakyat-semakin-takut-berpendapat)" - tempo.co .
- Abba Gabrillin, Krisiandi, "[Selama 2018, Polisi Tangkap 122 Orang Terkait Ujaran Kebencian di Medsos](https://nasional.kompas.com/read/2019/02/15/15471281/selama-2018-polisi-tangkap-122-orang-terkait-ujaran-kebencian-di-medsos)" - kompas.com.
- Tsarina Maharani, Dani Prabowo "[Kontras: Polisi Siber yang Akan Diaktifkan Pemerintah Berpotensi Bungkam Kebebasan Berekspresi](https://nasional.kompas.com/read/2020/12/28/14074121/kontras-polisi-siber-yang-akan-diaktifkan-pemerintah-berpotensi-bungkam)" - kompas.com.