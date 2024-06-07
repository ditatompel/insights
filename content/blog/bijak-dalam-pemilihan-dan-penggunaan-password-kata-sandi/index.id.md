---
title: "Bijak Dalam Pemilihan Dan Penggunaan Password / Kata Sandi"
description: "Membahas bagaimana seharusnya Anda membuat dan memperlakukan kata sandi Anda serta tips menggunakan password manager untuk mempermudah manajemen password yang unik dan acak di setiap situs / aplikasi yang Anda gunakan"
summary: "Membahas bagaimana seharusnya Anda membuat dan memperlakukan kata sandi Anda serta tips menggunakan password manager untuk mempermudah manajemen password yang unik dan acak di setiap situs / aplikasi yang Anda gunakan"
date: 2022-09-09T19:47:48+07:00
lastmod:
draft: false
noindex: false
featured: true
pinned: false
series:
#  -
categories:
  - Security
tags:
  - Bitwarden
  - KeepassXC
images:
authors:
  - ditatompel
---

Password adalah sesuatu yang rahasia, artikel ini membahas bagaimana seharusnya Anda membuat dan memperlakukan kata sandi Anda serta [tips menggunakan password manager](#gunakan-password-manager-yang-open-source) untuk mempermudah manajemen password yang unik dan acak di setiap situs / aplikasi yang Anda gunakan.

Di lingkungan saya, masih banyak teman-teman saya menggunakan password yang sama di berbagai macam situs. Hal ini sudah menjadi kebiasaan dan akan berdampak sangat buruk jika password yang sama tersebut bocor ke publik, apa lagi di era yang serba digital ini.

Jadi, bagaimana seharusnya kita memperlakukan dan membuat password yang baik? Berikut ini 5 poin paling penting (menurut saya) mengenai password dan tips menggunakan **password manager**.

## Jangan pernah membagikan password Anda kepada siapapun

Saya ingin nenanamkan salah satu [_Cypherpunk's Manifesto_](https://www.activism.net/cypherpunk/manifesto.html) mengenai perbedaan _private_ (pribadi) dengan _secret_ (rahasia) kepada Anda. **_Secret_ adalah sesuatu yang <u>hanya</u> Anda yang tahu**, tidak ada orang lain yang boleh tau. Sedangkan **_private_ adalah sesuatu yang Anda tidak ingin seluruh dunia tau**. _Private_ itu seperti alamat rumah, nomor telepon, bentuk alat kela.... (_ah sudahlah..._), dsb. Orang-orang terdekat Anda boleh tahu tentang suatu yang private / pribadi mengenai diri Anda.

Sedangkan password adalah sesuatu yang rahasia, cuma Anda dan hanya Anda yang boleh tau. Tanamkan pada pikiran Anda bahwa ketika Anda sudah membagikan password Anda sendiri, Anda telah melakukan sesuatu yang sangat berdosa dan tidak dapat diampuni, paham? Bahkan jika Anda memiliki istri / suami dan meminta password Anda secara paksa, CERAIKAN! :smiling_imp:

## Jangan gunakan password yang sama

Selalu gunakan password yang berbeda di SETIAP situs / aplikasi yang Anda gunakan. Ini wajib hukumnya, kenapa? Karena kita tidak pernah tahu bagaimana mekanisme atau kebijakan situs tempat kita mendaftar.

Apakah mereka sudah mengimplementasikan penyimpanan password sesuai standard? Apakah hanya menggunakan _one-way-hash_ tanpa mengimplementasikan [_salt_](<https://en.wikipedia.org/wiki/Salt_(cryptography)>) saat menyimpan password? Apakah algoritma _hash_ yang digunakan cukup aman dari serangan seperti [Dictionary Attack](https://en.wikipedia.org/wiki/Dictionary_attack) atau [Rainbow Attack](https://www.beyondidentity.com/glossary/rainbow-table-attack)? Bahkan, bagi yang belum tau, situs sekelas [**Facebook** pernah menyimpan password penggunanya dalam bentuk _plain-text_](https://techcrunch.com/2019/03/21/facebook-plaintext-passwords/). :clap: :shit:

Kita semua yang hidup didunia teknologi yakin dan percaya bahwa tidak ada sistem yang sempurna, karena kesempurnaan hanya milik ~~saya~~ Tuhan :angel:. Kalau kita berandai-andai sistem dari situs yang kita gunakan sempurna tanpa cacat dari _layer 1_ hingga _layer 7_ [OSI model](https://en.wikipedia.org/wiki/OSI_model), ingat bahwa sebuah sistem tetap dioperasikan oleh manusia.

Saya sebagai _SysAdmin_ / _programmer_ dapat dengan mudah menyisipkan beberapa baris kode yang memerintahkan untuk (misalnya) mengirimkan username / email dan password yang diinput oleh _user_ ke email pribadi saya, baru menyimpannya dengan _salted hash_ ke database yang digunakan. Jadi jangan pernah mempercayakan sesuatu yang penting begitu saja, terutama ke perusahaan yang memperkejakan orang semacam saya :smiling_imp:.

Ketika password Anda sudah didapatkan, apa lagi dalam bentuk _plain-text_, akun Anda di situs lain dapat diakses dengan mudah, apa lagi jika Anda tidak mengaktifkan fitur semacam [2FA](https://en.wikipedia.org/wiki/Multi-factor_authentication).

## Gunakan password yang panjang dan kompleks

![Password Brute Force Table](feature-password-brute-time-table.png#center "Password Brute Force Table")

Gambar table diatas menginformasikan berapa lama waktu yang dibutuhkan untuk mendapatkan _plain-text password_ menggunakan **Nvidia GeForce 1080** dengan asumsi dapat melakukan _brute force attack_ sebanyak 30 juta kali dalam 1 detik.

Tentu saja simulasi tersebut bervariasi tergantung kemampuan _hardware_ terhadap algoritma _hash_ yang digunakan. Gunakanlah **password minimal 12 karakter acak yang mengandung angka, simbol, huruf besar dan huruf kecil**. Semakin panjang akan semakin baik karena teknologi dan kemampuan hardware berkembang sangat cepat.

> Maksud **password acak** disini adalah password yang sama sekali tidak terlihat sebagai sebuah kata, entah itu kata benda maupun kata sifat. Contoh password acak : `i7#xYkU9Txd@5Y`

> Meskipun terdapat faktor lain yang dapat mempersingkat waktu yang dibutuhkan untuk mendapatkan _plan-text password_ karena adanya [_Hash collision_](https://en.wikipedia.org/wiki/Hash_collision), tapi dengan password yang kompleks setidaknya memperkecil pilihan yang dapat digunakan _cracker_ sehingga mereka tidak dengan mudah mendapatkan _plain-text password_ kita.

## Hindari menggunakan password yang mengandung identifikasi pribadi

Rata-rata, orang memilih menggunakan dan menyantumkan suatu yang personal di password mereka. Misalnya:

- **Tanggal lahir**: ditatompel09111978 atau 19781109dita
- **Alamat**: tompelBrooklyn12St
- **Nomor Telepon**: dita7576
- **Hobi**: Colly3x24

_\*Yang terakhir abaikan_ :speak_no_evil:.

Hal-hal yang dapat ditebak dari informasi tersebut dapat dimanfaatkan untuk melakukan [_Brute Force_](https://en.wikipedia.org/wiki/Brute-force_attack) terhadap password Anda. Jadi **gunakan password yang susah ditebak dan sama sekali tidak ada hubungannya dengan Anda**.

## Jangan simpan password Anda di browser atau mencatatnya ke dokumen digital tanpa enkripsi

Jangan pernah simpan password Anda di browser. Fitur penyimpanan password dari sebagian besar browser _mainstream_ tidak mengimplementasikan enkripsi, jadi password Anda kemungkinan besar disimpan dalam bentuk _plain-text_. Dan ketika PC / laptop kita dipinjam oleh teman atau kerabat, hanya butuh beberapa detik saja untuk mengambil password yang tersimpan di browser.

Begitu pula dengan fitur penyimpanan password bawaan dari ponsel, sebisa mungkin hindari menyimpan di sana dan gunakan **Password Manager** yang _open-source_ yang nanti akan saya bahas juga di akhir artikel.

## Mengubah password secara berkala sudah tidak relevan

![OTP menurut Kominfo](pak-menkom-johnny-ngomong-otp-harus-selalu-diganti-lmao.jpg#center "OTP menurut Kominfo")

Dikutip dari situs [tempo.co](https://bisnis.tempo.co/read/1630039/kebocoran-data-pribadi-terjadi-lagi-johnny-plate-masyarakat-harus-sering-ganti-password), {{< katex formula="\large yang" inline=true />}} {{< katex formula="\large mulia" inline=true />}} **Mentri Kemenkominfo** {{< katex formula="\large maha" inline=true />}} {{< katex formula="\scriptstyle da" inline=true />}}{{< katex formula="\cal S\Eta\Iota\large T" inline=true />}}, Pak **Johnny G Plate** mengatakan :

> _"One time password itu harus selalu kita ganti sehingga kita bisa menjaga agar data kita tidak diterobos,"_.

{{< katex >}}
{one + time + password \above{2pt} harus + selalu + kita + ganti} \\\
\\

\begin{Bmatrix}
W + k + W + k + W + k \\
w + K + W + k + w + K
\end{Bmatrix} ^{8x} \\
\underbrace{TROLLLol0lol0lol0lol0lol0lol}\_{\LARGE \text{ \textdagger} RIP \text{ } \xcancel{teknologi}\text{ \textdagger}} \\\
\\
{{< /katex >}}

_Ahemmm..._ Jadi yang sama sekali belum mengerti bahasa _enggres_, **OTP** atau _one-time password_ artinya password yang hanya digunakan 1 kali saja. Setelah digunakan **atau** sudah melewati batas waktu tertentu, password tersebut sudah tidak dapat digunakan lagi. Jadi _by nature_ dia selalu berubah dan bukan kita yang menentukan nilai dari **OTP** tersebut.

> _Saya yakin pak mentri bukannya tidak mengerti, tapi memang salah bicara. Maksud beliau pasti password biasa, bukan OTP. Ya pak ya? Ya kan pak? Ya kan?_ :worried:

Kembali ke topik mengenai kenapa menurut saya mengubah password secara berkala sudah tidak relevan, karena untuk mengingat situs atau aplikasi yang kita pernah mendaftar saja sudah sangatlah susah, apa lagi harus mengubahnya secara berkala dengan password acak yang berbeda.

Menurut saya pribadi, dengan mengimplementasikan poin-poin yang sudah saya sebutkan di atas sudah cukup (untuk orang-orang pada umumnya).

## Gunakan Password Manager yang open-source

Poin-poin diatas yang saya sebutkan akan sangat sulit dilakukan tanpa adanya _sofware_ **Password Manager**. Gunakanlah password manager yang _open-source_ yang sudah dan dapat diaudit secara bebas kapan saja oleh publik.

Ada banyak software password manager yang _open-source_ seperti [Bitwarden](https://bitwarden.com/), [KeepassXC](https://keepassxc.org/), [Padloc](https://padloc.app/), dsb. Jika Anda **memiliki infrastruktur dan kemampuan** dalam membangun dan memanage _self-hosted server_ dari password manager tersebut, akan lebih baik jika Anda menggunakan versi *self-hosted*nya.

### Tips menggunakan password manager

Untuk dapat mengikuti tips saya ini, Anda memerlukan:

- 2 buah akun email, 1 diantaranya adalah email yang **tidak pernah** Anda gunakan untuk registrasi **dimanapun**.
- Mampu mengingat paling tidak 3 buah password kompleks yang berbeda (**minimal 12 karakter yang mengandung angka, simbol, huruf besar dan huruf kecil**).

Taruh kata, saya sudah mempunyai 2 buah alamat email berikut:

1. `ditatompel@gmail.com`
2. `administrator@ditatompel.com`

Email pertama saya gunakan untuk setiap registrasi website yang memerlukan verifikasi email. Ingat dan catat baik-baik password untuk login email tersebut di **OTAK** Anda (jangan pernah tuliskan password login tersebut dimanapun, termasuk password manager).

Email kedua **HANYA** saya gunakan untuk fitur _recovery_ / lupa password dari email pertama. Jangan beritahu kepada siapapun alamat email kedua ini kecuali _provider_ email pertama.

Biasanya email _provider_ sekelas **Gmail** juga akan mengirimkan notifikasi ke email _recovery_ jika ada aktifitas yang dianggap mencurigakan dari akun Anda. Gunakan password yang berdeda dari email yang pertama untuk megakses email _recovery_ ini (Ingat dan catat baik-baik password untuk login email tersebut di **OTAK** Anda (jangan pernah tuliskan password login dimanapun, termasuk password manager).

Register ke situs penyedia password manager menggunakan email pertama. Biasanya password manager akan meminta anda untuk menentukan **_Master Password_** Anda. Gunakan password yang berbeda dari password email pertama dan kedua. Dan, lagi-lagi: ingat dan catat baik-baik **_Master Password_** tersebut di **OTAK** Anda (jangan pernah tuliskan **Master Password** dimanapun, termasuk password manager itu sendiri).

Jangan lupa aktifkan **2FA/OTP** (jika _provider_ menyediakan fitur tersebut) untuk mengakses 3 akun penting diatas (email pertama, kedua, dan password manager).

Gunakan password manager untuk _mengenerate_ dan menyimpan semua password situs atau aplikasi yang Anda gunakan **diluar** email pertama, email kedua, dan master password dari pasword manager yang Anda gunakan tersebut.

Dengan begitu, Anda benar-benar memiliki password acak yang berbeda untuk setiap situs atau aplikasi yang Anda gunakan tanpa harus repot mengingat. Semoga artikel ini berguna dan dapat menambah wawasan.

> Catatan khusus mengenai email, jika Anda menggunakan penyedia layanan email seperti Yahoo! atau Google, Anda bisa kehilangan akun email Anda jika Anda tidak pernah melakukan login dalam kurun waktu tertentu. Pembahasan mengenai hal ini saya tulis dalam bahasa Inggris di berjudul [_"Why Inactive Email Accounts is Dangerous"_](https://insights.ditatompel.com/en/blog/2020/06/why-inactive-email-accounts-is-dangerous/).
> Jadi, selalu sempatkan login ke penyedia layanan email yang Anda gunakan minimal 2 bulan sekali.
