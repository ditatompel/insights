---
title: "Manipulasi Enkripsi Password"
description: "Manipulasi enkripsi password MD5 ke SHA1 Melakukan manipulasi MD5 hash seolah-olah menjadi sebuah SHA1 hash."
date: 2013-07-28T22:57:25+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Programming
  - Security
tags:
  - PHP
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

Sampai saat ini, banyak CMS telah mengimplementasikan / mengembangkan menggunakan `hash` dan `salt` untuk metode penyimpanan password pada database. Namun masih banyak aplikasi website lainnya yang masih menggunakan fungsi `MD5`/`SHA1` *hash* saja.

<!--more-->

`MD5`/`SHA1` itu sendiri banyak dirasa kurang aman. Karena begitu populernya digunakan maka banyak yang menggunakan *brute* direktori *list hash* sampai ke tingkat yang lebih kompleks yaitu **rainbow table**. Maka tidak heran *plaintext* dari *hash* password-password umum dapat dengan mudah didapatkan.

Misalnya (`md5`):
- `admin`:`21232f297a57a5a743894a0e4a801fc3`
- `password`:`5f4dcc3b5aa765d61d8327deb882cf99`

Kali ini saya ingin sedikit melakukan **manipulasi MD5 hash menjadi seolah-olah sebuah SHA1 hash**.

Seperti yang kita ketahui bahwa **MD5 hash** memiliki karakteristik **hexadecimal** sepanjang **32 karakter**. Sedangkan **SHA1** memiliki karakteristik **hexadecimal** sepanjang **40 karakter**.

```plain
md5 = ^[a-f0-9]{32}
sha1 = ^[a-f0-9]{40}
```
maka supaya MD5 hash bisa menjadi seolah-olah sebuah SHA1 hash, kita perlu menambahkan lagi **hexadecimal** sepanjang **8 karakter** ke **MD5 hash**.

```plain
random code = ^[a-f0-9]{8}
```

## Contoh Script PHP

fungsi `php` di bawah ini yang nanti akan kita gunakan untuk menciptakan karakter acak:

```php
function randomCode($length=10) {
    $chars = 'abcdef0123456789';
    $randomString = '';
    for ($i = 0; $i < $length; $i++)
        $randomString .= $chars[rand(0, strlen($chars) - 1)];
    return $randomString;
}
```

kemudian kita buat fungsi lagi untuk melakukan '*manipulasi*' password:
```php
function customPasswd ($action="check", $plain=0, $hash=0) {
    if ( $action == "check" ) {
        if ( !preg_match('/^[a-f0-9]{40}$/i', $hash) )
            return false;
        $split = str_split($hash, 16);
        $randomCode = str_split($split[1], 8);
        $newPass = md5($plain . $randomCode[0]);
        $split2 = str_split($newPass, 16);
        $newPwd = $split2[0] . $randomCode[0] . $split2[1];
        return $newPwd == $hash ? true : false;
    }
    else {
        $randomCode = randomCode(8);
        $hash = md5($plain . $randomCode);
        $split = str_split($hash, 16);
        $hash = $split[0] . $randomCode . $split[1];
        return $hash;
    }
    return FALSE;
}
```
Dari fungsi tersebut, dapat digunakan untuk menggenerate password dan melakukan pengecekan password sesuai dengan metode manipulasi password yang telah kita buat.

Sebelumnya saya akan mencoba menjelaskan bagaimana berjalannya fungsi tersebut.

### Generate Password
Contoh penggunaan :
```php
$password = customPasswd('generate', 'passwordnya'); 
```

Kita pelajari terlebih dahulu metode generate passwordnya yang berada pada *block* `else { }`.
```php
// snip
else {
    $randomCode = randomCode(8);
    $hash = md5($plain . $randomCode);
    $split = str_split($hash, 16);
    $hash = $split[0] . $randomCode . $split[1];
    return $hash;
}
```

Dimana :
```php
$randomCode = randomCode(8);
```
Nilai yang nantinya kita ditambahkan dibelakang plain password yang kemudian kita enkripsi dengan MD5. (*string 8 char length*).

```php
$hash = md5($plain . $randomCode);
```
`$hash` diatas adalah hasil **MD5** dari *plaintext* password + kode random yang tadi kita ciptakan.

```php
$split = str_split($hash, 16);
$hash = $split[0] . $randomCode . $split[1];
```
Tepat setelah karakter ke 16 pada hasil MD5 hash, kita sisipkan kode random yang sebelumnya sudah kita siapkan.

Misalnya kita mendapatkan nilai kode random '`77979b20`', sedangkan plaintext password adalah '`rahasia`'.

Maka hasil *hash* pertama (`rahasia77979b20`) adalah `dc236dbb5b9d3f6f672957167a5375d2`.

Setelah itu dari hasil hash `dc236dbb5b9d3f6f672957167a5375d2` kita sisipkan kode *random* tadi setelah karakter ke 16, sehingga menjadi : `dc236dbb5b9d3f6f77979b20672957167a5375d2`.

nilai itulah yang kita simpan pada database.

### Check Password
Contoh penggunaan :
```php
if ( customPasswd('check', 'password', '22d1df7893539061bdee309156ce1530b913a6f6' ) ) {
    echo 'Password valid' . "\n";
}
else {
    echo 'Password invalid' . "\n";
}
```

Untuk metode pengecekan passwordnya, lihat pada *block* `if ( $action == "check" ) { }`:

```php
if ( !preg_match('/^[a-f0-9]{40}$/i', $hash) )
    return false;
$split = str_split($hash, 16);
$randomCode = str_split($split[1], 8);
$newPass = md5($plain . $randomCode[0]);
$split2 = str_split($newPass, 16);
$newPwd = $split2[0] . $randomCode[0] . $split2[1];
return $newPwd == $hash ? true : false;
```

Dimana :
```php
if ( !preg_match('/^[a-f0-9]{40}$/i', $hash) )
    return false;
```
Digunakan untuk pengecekan format password (karena sebelumnya sudah kita tentukan untuk memanipulasi sehingga mirip dengan **SHA1**, maka **regular expression** yang digunakan adalah `[a-f0-9]{40}`).

Jika format password dirasa benar, maka kita ambil nilai kode random yang kita sisipkan :

```php
$split = str_split($hash, 16);
$randomCode = str_split($split[1], 8);
```

Setelah itu kita lanjutkan ke proses berikutnya dengan melakukan metode yang sama saat kita menggenerate password. Cocokan hasilnya dengan yang ada pada database. Jika nilainya sama, maka passwordnya valid, jika tidak password tidak valid.

```php
$newPass = md5($plain . $randomCode[0]);
$split2 = str_split($newPass, 16);
$newPwd = $split2[0] . $randomCode[0] . $split2[1];
return $newPwd == $hash ? true : false;
```

Menggunakan **MD5** dan **SHA1** hanyalah sebuah contoh, dan peletakan kode random di tengah-tengah *hash* **MD5** juga sebuah contoh. Anda dapat mengembangkan sesuai dengan kreatifitas masing-masing.





