---
title: "Menggunakan Monero.com Untuk Menukarkan Monero XMR ke Rupiah"
description: Panduan langkah demi langkah tentang cara menggunakan situs web Monero.com untuk menukar XMR dengan BTC dan kemudian menjualnya ke Rupiah melalui Indodax.
summary: Panduan langkah demi langkah tentang cara menggunakan situs web Monero.com untuk menukar XMR dengan BTC dan kemudian menjualnya ke Rupiah melalui Indodax.
date: 2025-04-14T03:30:00+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - TIL
tags:
    - Monero
images:
authors:
    - ditatompel
---

Sejak akhir Desember 2024, seluruh penyedia layanan pertukaran mata uang kripto
di Indonesia telah melakukan _delisting_ **[Monero][get-monero] (XMR)**. Bagi
Anda yang biasanya mencairkan mata uang kripto Monero (XMR) ke mata uang Rupiah
melalui _exchange_ seperti **Indodax** hingga **Tokocrypto** tentu harus
mencari cara lain untuk mencairkan dana tersebut.

Saya pribadi sering menggunakan [Feather Wallet][feather-wallet-gh] untuk
melakukan transaksi Monero. Sebelum terjadinya _delisting_ ini, saya biasanya
mentransfer sejumlah XMR dari _Wallet_ saya menggunakan _Feather Wallet_ ke
alamat deposit XMR yang berada di Indodax atau Tokocrypto. Setelah itu, barulah
saya menjual dan mencairkannya ke mata uang Rupiah.

Namun, sekarang metode tersebut sudah tidak dapat digunakan. Ada beberapa
metode alternatif untuk menukarkan Monero ke Rupiah:

- Dengan cara COD atau pertukaran tatap muka secara langsung, atau
- Menukarkan Monero ke mata uang kripto lainnya seperti Bitcoin, lalu
  menjualnya di _cryptocurrency exchange_.

## Menukar Monero >< Bitcoin

Untuk menukarkan XMR ke BTC atau mata uang kripto lain, Anda bisa menggunakan
_P2P exchanges_ seperti [bisq][bisq-web] atau [BasicSwap][basicswap-web], atau
layanan yang mengimplementasikan [atomic swap][xmr-atomic-swap] seperti
[Majestic Bank][majestic-bank-web] dan [SimpleSwap][simpleswap-web].

> **Catatan**: Untuk informasi mengenai Monero _P2P exchange_, _Atomic Swap_,
> dan _Merchant_ lainnya, silahkan kunjungi halaman [Monero Merchants &
> Exchange][monero-exchanges].

### Sekilas Tentang monero.com by Cake Wallet

Selain daripada yang saya sebutkan diatas, ada sebuah layanan dengan nama
[Monero.com by Cake Wallet][monero-com-web]. **Monero.com by Cake Wallet**
adalah [Monero Wallet][monero-download-page] yang dimaintenance oleh [Cake
Labs][cake-labs-web], perusahaan atau _team_ yang juga mendevelop [Cake
Wallet][cake-wallet-web]. Jika _Cake Wallet_ mensupport berbagai macam berbagai
macam dompet kripto, _Monero.com by Cake Wallet_ secara eksklusif hanya untuk
dompet Monero saja.

> **Catatan**: Perlu diketahui bahwa _Monero.com by Cake Wallet_ **BUKAN**
> merupakan situs maupun wallet resmi dari The Monero Project.

Selain menyediakan Monero _wallet_ untuk iOS dan Android, monero.com
menyediakan layanan _cryptocurrency swap_ di halaman situs mereka. Tidak
seperti _P2P exchanges_ yang Anda perlu mendownload dan menjalankannya di
komputer Anda, _cryptocurrency swap_ berbasis web hanya membutuhkan browser
untuk menggunakannya.

### Menggunakan monero.com Web Based Swap

Sekarang, saya ingin berbagi cara menggunakan Monero.com website untuk
menukarkan XMR ke BTC, kemudian menjualnya ke Rupiah melalui Indodax.

1. Kunjungi halaman penukaran mata uang kripto di
   [https://monero.com/trade](https://monero.com/trade).
2. Klik tombol _"swap"_ pada form yang tampil sehingga form menunjukan bahwa
   Anda akan menukarkan sejumlah XMR ke BTC.
   ![tombol swap](xmr-idr-01.jpg#center)
3. Isi form berapa nominal yang ingin Anda tukarkan, kemudian tekan tombol
   **"Exchange"**.
4. Setelah itu, akan muncul _modal window_ mengenai detail transaksi yang perlu
   Anda lengkapi.
   ![detail window](xmr-idr-02.jpg#center)
5. Karena saya akan menjual BTC tersebut melalui Indodax, masukkan alamat BTC
   yang digunakan untuk deposit BTC ke akun Indodax Anda ke field **"Recipient
   Wallet"**. Untuk mendapatkannya alamat BTC Anda, login ke situs Indodax,
   pilih menu **"Wallet"** > **"BTC"** > **"Deposit"**. Jika Anda menggunakan
   _cryptocurrency exchange_ lain, sesuaikan langkah tersebut.
6. Di bagian **"Refund Wallet"**, masukkan alamat wallet XMR milik Anda. Dana
   akan dikembalikan ke _Refund Wallet_ tersebut jika transaksi tidak berhasil
   dilakukan. Setelah itu, klik tombol **"Exchange"**.
7. Tampilan _modal window_ akan berubah dimana dia akan menampilkan jumlah dan
   kemana XMR tersebut dikirimkan. Copy alamat _wallet_ XMR yang tampil,
   kemudian kirimkan dana ke alamat tersebut dari _non-custodial wallet_ Anda
   sesuai dengan jumlah yang diminta.
   ![send funds window](xmr-idr-03.jpg#center)
8. Setelah itu, tunggu hingga proses _swap_ selesai dan terakhir, cek apakah
   dana sudah diterima di _wallet_ BTC Anda di Indodax.

Perlu diingat, proses swap memerlukan waktu cukup lama, dan konfirmasi
transaksi deposit di Indodax juga cukup lama (sekitar 10 - 30 menit).

Setelah status deposit berudah dari **"Pending"** ke **"Berhasil"**, Anda
tinggal menjual BTC hasil _swap_ yang sudah Anda lakukan, kemudian mentransfer
hasil penjualan ke rekening bank Anda.

![indodax deposit history](xmr-idr-04.jpg#center)

> **Catatan**: Tulisan ini murni dari pengalaman pribadi menggunakan
> Monero.com by Cake Wallet. **Saya tidak menerima sponsor apapun** dari
> monero.com by Cake Wallet maupun pihak-pihak lain yang sudah saya sebutkan
> di atas.

Semoga membantu.

[get-monero]: https://www.getmonero.org "The Monero Project Official Website"
[feather-wallet-gh]: https://github.com/feather-wallet/feather "Feathet Wallet GitHub Repository"
[bisq-web]: https://bisq.network "bisq Official Website"
[basicswap-web]: https://basicswapdex.com "BasicSwap Official Website"
[xmr-atomic-swap]: https://www.getmonero.org/2021/08/20/atomic-swaps.html "getmonero.org Atomic Swap Article"
[simpleswap-web]: https://simpleswap.io "SimpleSwap Website"
[majestic-bank-web]: https://majesticbank.sc "MajesticBank Website"
[monero-exchanges]: https://www.getmonero.org/community/merchants/ "Monero Merchants and Exchanges"
[monero-com-web]: https://monero.com "Monero.com by Cake Wallet Official Website"
[monero-download-page]: https://www.getmonero.org/downloads/ "Halaman Download Monero Software"
[cake-labs-web]: https://cakelabs.com "Cake Labs Official Website"
[cake-wallet-web]: https://cakewallet.com "Cake Wallet Official Website"
