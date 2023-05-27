---
title: "IspCP Auto New Zone Transfer to Secondary Dns Server"
description: Cara sinkronisasi primary DNS ispCP ke secondary DNS server.
date: 2012-01-10T21:36:41+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - SysAdmin
tags:
  - IspCP
  - Bind
  - DNS
  - Apache
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

Kali ini ane mau share cara sinkronisasi *primary DNS* **ispCP** ke *secondary DNS server*. Tapi sebelumnya, apa itu **ispCP**?

<!--more-->

> _**isp Control Panel (ispCP)** is an open source project founded to build a Multi Server Control and Administration Panel. This Control Panel is usable by any Internet Service Provider (ISP)._

Nah [ispCP](http://isp-control.net/) sendiri mengemas aplikasi2 hosting seperti **Apache**, **Bind9**, **Courier**, **Postfix**, **ProFTP**, dan **Awstats**. dan sampai saat ini support untuk beberapa *linux distro* seperti **Debian** (**Etch**, **Lenny**, **Squeeze**), **Ubuntu**, dan **FreeBSD**.

Kalau dibandingkan dengan **cPanel** secara pribadi jelas lebih nyaman cPanel. Tp krn ini open source dan gratis, worth bgt buat dicoba dan digunakan.

Yuk, langsung aja... Ane asumsikan temen2 udah pada berhasil install ispCP ini.

Yang diperlukan :

2 buah server ( 1 untuk **primary DNS** di ispCP itu sendiri dan 1 lagi buat **secondary DNS** nya )

_Tested with ispCP Version_ : `1.7` on **Debian Lenny**

## ispCP server (Primary)

1. Edit `/etc/ispcp/ispcp.conf` dan tambahkan *IP server secondary DNS* pada bagian **"# BIND data section".**
2. masuk ke folder `/var/www/ispcp/gui/domain` ( buat folder tersebut jika belum ada )
3. Buat file `index.php` dan masukan script berikut :

```php
<?php
require '../include/ispcp-lib.php';
 
$cfg = ispCP_Registry::get('Config');
$sql = ispCP_Registry::get('Db');
 
$count_query = "SELECT COUNT(`domain_id`) AS cnt FROM `domain`";
$start_index = 0;
$rows_per_page = 100;
 
$query = "SELECT `domain_name` FROM `domain`
    ORDER BY `domain_id` ASC
    LIMIT $start_index, $rows_per_page";
 
$rs = exec_query($sql, $count_query);
$records_count = $rs->fields['cnt'];
$rs = exec_query($sql, $query);
$count_query1 = "SELECT COUNT(`alias_id`) AS cnt1 FROM `domain_aliasses`";
$start_index1 = 0;
$rows_per_page1 = 100;
 
$query1 = "SELECT `alias_name` FROM `domain_aliasses`
    ORDER BY `alias_id` ASC
    LIMIT $start_index1, $rows_per_page1";
 
$rs1 = exec_query($sql, $count_query1);
 
$records_count1 = $rs1->fields['cnt1'];
$rs1 = exec_query($sql, $query1);
$all_records_count=$records_count+$records_count1;
if ($rs->rowCount() == 0) {
    echo "//NO DOMAINS LISTED";
} else {
    echo "//$all_records_count DOMAINS LISTED ON $cfg->SERVER_HOSTNAME [$cfg->BASE_SERVER_IP]\n";
    while (!$rs->EOF){
        echo "zone \"".$rs->fields['domain_name']."\"{\n";
        echo "\ttype slave;\n";
        echo "\tfile \"/var/cache/bind/".$rs->fields['domain_name'].".db\";\n";
        echo "\tmasters { $cfg->BASE_SERVER_IP; };\n";
        echo "\tallow-notify { $cfg->BASE_SERVER_IP; };\n";
        echo "};\n";
        $rs->moveNext();
    }
}
 
if ($rs1->rowCount() == 0) {
    echo "//END DOMAINS LIST\n";
}
else {
    while (!$rs1->EOF){
        echo "zone \"".$rs1->fields['alias_name']."\"{\n";
        echo "\ttype slave;\n";
        echo "\tfile \"/var/cache/bind/".$rs1->fields['alias_name'].".db\";\n";
        echo "\tmasters { $cfg->BASE_SERVER_IP; };\n";
        echo "\tallow-notify { $cfg->BASE_SERVER_IP; };\n";
        echo "};\n";
        $rs1->moveNext();
    }
echo "//END DOMAINS LIST\n";
}
?>
```

4. Buat file `.htaccess` supaya `index.php` tersebut hanya bisa diakses melalui IP secondary DNS server.

```apache
Order Deny,Allow
Deny from all
Allow from [IP.SECONDARY.DNS.SERVERMU]
```

5. Ubah konfigurasi `Apache AllowOverride None` menjadi `AllowOverride Limit` supaya `.htaccess` dapat berfungsi.


```bash
vi /etc/apache2/sites-enabled/00_master.conf
```

6. Ubah kepemilikan file pada `/var/www/ispcp/gui/domain`
```bash
chown vu2000:www-data -R /var/www/ispcp/gui/domain
```

7. *Generate key* untuk **secure zone transfer (TSIG)**

```bash
cd /etc/bind; dnssec-keygen -a hmac-md5 -b 128 -n HOST TRANSFER
```
Hasil *key* ada pada file `transfer.+[bla-bla-bla].private`. Didalamnya ada kode yang nantinya digunakan untuk sinkron *auth*. Misal : Key: `6alK9JEHMqH/ZDpFHtlstg==`

Masukan kode tersebut pada konfigurasi **BIND**

```bash
vi /etc/bind/named.conf.options
```

```bind
//
//SECONDARY NS
//
key "TRANSFER" {
    algorithm hmac-md5;
    secret "6alK9JEHMqH/ZDpFHtlstg==";
};
server [IP.SECONDARY.DNS.SERVERMU] {
    keys {
        TRANSFER;
    };
};
```

Konfigurasi pada *primary DNS server* sudah selesai. Lalu kita masuk ke tahap berikutnya, yaitu :

## konfigurasi pada secondary DNS server
> _Saya asumsikan BIND sudah terinstall di server Secondary DNS ini._

1. Edit konfiurasi BIND (`/etc/bind/named.conf`) dan tambahkan `include "/etc/bind/named.conf.backup"`.
2. Buat keys zone transfer
```bash
vi /etc/bind/named.conf.options
```
dan tambahkan konfigurasi berikut :
```bind
//
//SECONDARY NS
//
key "TRANSFER" {
    algorithm hmac-md5;
    secret "6alK9JEHMqH/ZDpFHtlstg==";
};
server [IP.ISPCP.SERVER] {
    keys {
        TRANSFER;
    };
};
```

3. Buat script untuk cronjob: `vi /etc/cron.d/dnsupdate`
dan tambahkan :
```
* */12 * * * root      /usr/bin/wget http://[IP.ISPCP.SERVER]/domain/ -O /etc/bind/named.conf.backup && /etc/init.d/bind9 reload
```
4. Terakhir, coba reload cronjob untuk memastikan trik kita sukses.
```bash
/etc/init.d/cron reload
```