---
title: "Compile Nginx Latest Stable Version Dari Source Code"
description: Bukan rahasia umum bahwa sampai saat ini web server yang paling banyak digunakan adalah Apache, tapi bagaimana dengan web server lain? Apakah tidak se-powerful Apache?
# linkTitle:
date: 2011-08-25T18:00:31+07:00
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
#  - Tutorial
categories:
  - SysAdmin
tags:
  - Nginx
  - Linux
  - SysVinit
  - Web Server
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

Bukan rahasia umum bahwa sampai saat ini web server yang paling banyak digunakan adalah **Apache**, tapi bagaimana dengan *web server* lain? Apakah tidak *se-powerful* Apache?

**Nginx**, sebuah *web server* yang di-develop oleh **Igor Sysoev** pada tahun 2002 Menjadi sebuah alternatif baru pengganti **Apache**.

<!--more-->

> _**CATATAN**: Artikel ini dibuat di tahun 2011, jadi Anda perlu beradaptasi dalam mengikuti tutorial ini. Terelebih lagi, saat ini mayoritas distribusi Linux sudah banyak meninggalkan `sysVinit` beralih menggunakan `SystemD`._


Nginx (pengucapan **"Engine X"**) adalah *web server* / *reverse proxy* dan *e-mail* (**IMAP**/**POP3**) *proxy* yang ringan dengan kinerja tinggi , dilisensikan di bawah **lisensi BSD**. Berjalan pada **UNIX**, **GNU/Linux**, **Solaris**, **Varian BSD** seperti **Mac OS X**,  dan **Microsoft Windows**.

## Kenapa Nginx?

1. **Kecepatan**: Cukup satu *core processor* untuk menangani ribuan koneksi, sehingga beban CPU dan konsumsi *memory* jauh lebih ringan.

2. **Mudah digunakan**: Konfigurasi file jauh lebih mudah dimengerti dan dimodifikasi daripada konfigurasi web server lainnya seperti Apache. Beberapa baris saja sudah cukup untuk menciptakan sebuah `virtual host` yang cukup lengkap.

3. **Plug-in system** ( disini disebut sebagai "`modules`" )

4. dan yang paling penting, **Open Source** (BSD-like license)

Beberapa contoh website besar yang menggunakan Nginx entah itu sebagai web server atau sebagai *reserve proxy* sebagai backend Apache antara lain : **kaskus.us**, **indowebster.com**, **wordpress.com**, **sourceforge.net**, **github.com**, dll.

## Latar Belakang Melakukan Kompilasi
Dalam proses instalasi web server, dibutuhkan beberapa *tools* dan parameter yang harus kita putuskan pada saat kompilasi, dan beberapa konfigurasi tambahan yang harus dilakukan dan disesuaikan dengan sistem kita.

Nah, kali ini kita memilih untuk *men-download* *source code* aplikasi dan menginstalnya secara manual daripada menginstal menggunakan *package manager*. Ada beberapa alasan kenapa orang memilih melakukan instalasi secara manual :

1. Mengenal lebih jauh bagaimana sistem (terutama *web server*) yang kita gunakan itu bekerja.
2. (Mungkin) belum tersedia dalam repositori dari distribusi Linux yang sedang digunakan.

Disamping itu jarang repositori yang menawarkan untuk *men-download* dan menginstall Nginx menggunakan *package manager* (`yum`|`apt`|`yast`) untuk versi yang terbaru (kecuali pada distribusi *rolling-release* seperti **Arch Linux**). Kebanyakan menyediakan versi lama yang kurang *up-to-date* alias basi. x_x.

## Proses Kompilasi Nginx
Berikut ini ada *capture screen video* yang sudah saya buat sebelumnya. Mungkin bisa membantu dalam proses installasi. (tidak perlu sama persis, yang penting tau proses dan cara kerja-nya)

{{< youtube AtJ5OBOj1gE >}}

### Download source-code
Pertama, mari kita download web server kita dari [http://nginx.org/download/nginx-1.0.5.tar.gz](http://nginx.org/download/nginx-1.0.5.tar.gz) (saat saya menulis artikel ini versi stable terbarunya adalah `1.0.5`).

```bash
wget http://nginx.org/download/nginx-1.0.5.tar.gz
```
setelah itu,*copy source* tersebut ke `/usr/local/src/` kemudian *extract*.

```bash
sudo cp nginx-1.0.5.tar.gz /usr/local/src/
cd /usr/local/src/
sudo tar -xvzf nginx-1.0.5.tar.gz
```

**Catatan:**
1. Sebelum proses installasi, lebih baik cek apakah `port 80` sedang digunakan atau tidak. Saya menggunakan distro **BackTrack** dan secara default **Apache** menggunakan `port 80` pada saat *startup*. `/etc/init.d/apache2 stop` atau `killall apache2`.
2. Nginx adalah program yang dibuat menggunakan **bahasa C**, jadi untuk dapat menggunakannya pertama-tama kita harus punya *tools* seperti **GNU Compiler Collection (GCC)** pada komputer kita. **GCC** biasanya sudah terinstall pada kebanyakan Linux distro.

Untuk memastikannya, jalankan saja perintah "`gcc`" (tanpa quote) melalui terminal. Jika anda mendapatkan *output* *"gcc: no input files"* berarti GCC sudah terinstall pada komputer anda. Jika tidak, anda perlu menginstallnya terlebih dahulu.

Oke, lanjott..

### ./configure dan make install
masuk ke folder `nginx-1.0.5` pada direktori `/usr/local/src/` dan mulai lakukan kompilasi.
```bash
cd nginx-1.0.5
./configure
```

Secara default, **HTTP rewrite module** onomatis ikut terinstall saat instalasi default Nginx. Module ini memerlukan **PCRE (Perl Compatible Regular Expression) library** karena **Rewrite** dan **HTTP Core modules** dari Nginx menggunakan PCRE sebagai syntax *regular expression* mereka.

Sekarang tergantung pilihan kita, jika kita :

1. membutuhkan *rewrite module*, kita harus install PCRE terlebih dahulu:

```bash
apt-get install libpcre3 libpcre3-dev
```
2. jika kita tidak membutuhkannya :

```bash
./configure --without-http_rewrite_module
```
Pilihan kita jatuh pada opsi pertama karena nantinya kebanyakan situs yang digunakan sangat membutuhkan *rewrite module* tersebut. Maka setelah melakukan instalasi PCRE, kita harus melakukan konfigurasi kembali.

```bash
./configure
```

lakukan proses installasi :
```bash
make && make install
```
proses instalasi default yang kita lakukan di atas akan menempatkan *"ruang kerja"* Nginx pada direktori `/usr/local/nginx`

### Membuat SysVinit untuk Nginx

buat file dengan nama `nginx` pada direktori `/etc/init.d`
```bash
nano /etc/init.d/nginx
```

kemudian copy paste shell script di bawah ini kemudian save

```bash
#! /bin/sh
### BEGIN INIT INFO
# Provides:          nginx
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the nginx web server
# Description:       starts nginx using start-stop-daemon
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/local/nginx/sbin/nginx
NAME=nginx
DESC="nginx daemon"

test -x $DAEMON || exit 0

# Include nginx defaults if available
if [ -f /etc/default/nginx ] ; then
    . /etc/default/nginx
fi

set -e

case "$1" in
    start)
        echo -n "Starting $DESC: "
        start-stop-daemon --start --quiet --pidfile /usr/local/nginx/logs/nginx.pid \
            --exec $DAEMON -- $DAEMON_OPTS
        echo "$NAME."
        ;;
    stop)
        echo -n "Stopping $DESC: "
        start-stop-daemon --stop --quiet --pidfile /usr/local/nginx/logs/nginx.pid \
            --exec $DAEMON
        echo "$NAME."
        ;;
    restart|force-reload)
        echo -n "Restarting $DESC: "
        start-stop-daemon --stop --quiet --pidfile \
            /usr/local/nginx/logs/nginx.pid --exec $DAEMON
        sleep 1
        start-stop-daemon --start --quiet --pidfile \
            /usr/local/nginx/logs/nginx.pid --exec $DAEMON -- $DAEMON_OPTS
        echo "$NAME."
        ;;
    reload)
        echo -n "Reloading $DESC configuration: "
        start-stop-daemon --stop --signal HUP --quiet --pidfile /usr/local/nginx/logs/nginx.pid \
            --exec $DAEMON
        echo "$NAME."
        ;;
    *)
    N=/etc/init.d/$NAME
    echo "Usage: $N {start|stop|restart|force-reload}" >&2
    exit 1
    ;;
esac
exit 0
```

`chmod +x` supaya *script* dapat dieksekusi

```bash
chmod +x /etc/init.d/nginx
```

Setelah ini, maka kita dapat melakukan **start**, **stop**, **restart** atau **reload** proses Nginx melalui *script* tersebut. Mari kita coba jalankan Nginx:

```bash
/etc/init.d/nginx start
```

Maka seharusnya kita mendapatkan pesan sambutan *"welcome to nginx!"* saat mengakses `localhost` dari brwoser Anda.

## Instalasi dan konfigurasi PHP FAST CGI (spawn-fcgi) dengan Nginx

Download PHP `spawn-fcgi`

```bash
apt-get install php5-cgi spawn-fcgi
```

Setelah proses installasi melalui *package manager* selesai, buat file bernama `php-fastcgi` pada direktori `/etc/init.d`

```bash
nano /etc/init.d/php-fastcgi
```

Copy paste *shell init script* di bawah ini.

```bash
#!/bin/bash
BIND=127.0.0.1:9000
USER=www-data
PHP_FCGI_CHILDREN=15
PHP_FCGI_MAX_REQUESTS=1000

PHP_CGI=/usr/bin/php-cgi
PHP_CGI_NAME=`basename $PHP_CGI`
PHP_CGI_ARGS="- USER=$USER PATH=/usr/bin PHP_FCGI_CHILDREN=$PHP_FCGI_CHILDREN PHP_FCGI_MAX_REQUESTS=$PHP_FCGI_MAX_REQUESTS $PHP_CGI -b $BIND"
RETVAL=0

start() {
    echo -n "Starting PHP FastCGI: "
    start-stop-daemon --quiet --start --background --chuid "$USER" --exec /usr/bin/env -- $PHP_CGI_ARGS
    RETVAL=$?
    echo "$PHP_CGI_NAME."
}
stop() {
    echo -n "Stopping PHP FastCGI: "
    killall -q -w -u $USER $PHP_CGI
    RETVAL=$?
    echo "$PHP_CGI_NAME."
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)
    echo "Usage: php-fastcgi {start|stop|restart}"
    exit 1
    ;;
esac
exit $RETVAL
```

jangan lupa `chmod +x` supaya *script* dapat dieksekusi

```bash
chmod +x /etc/init.d/php-fastcgi
```

Kemudian sebelum menjalankan `php-fastcgi` tersebut, kita bangun dulu struktur website yang akan kita gunakan. (saya memilih direktori `/var/www/nginx`)

```bash
mkdir -p /var/www/nginx; cd nginx
```

buat file dengan nama `info.php` berisi `phpinfo();` (sekedar melakukan testing apakah PHP sudah berjalan atau belum)

```bash
echo "<?php phpinfo(); ?>" > info.php
```

kemudian edit konfigurasi Nginx agar sesuai dengan struktur website yang sedang kita bangun.

```bash
nano /usr/local/nginx/conf/nginx.conf
```

Karena *root public html* kita berada di `/var/www/nginx` maka konfigurasi sebagai berikut :

```nginx
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   /var/www/nginx;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /var/www/nginx$fastcgi_script_name;
            fastcgi_param  PATH_INFO  $fastcgi_script_name;
            include        fastcgi_params;
        }

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443;
    #    server_name  localhost;

    #    ssl                  on;
    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_timeout  5m;

    #    ssl_protocols  SSLv2 SSLv3 TLSv1;
    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers   on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}
```

perhatikan bahwa saya mengganti konfigurasi `root` dan `fastcgi_param SCRIPT_FILENAME` ( video menit 7.00 )

untuk melakukan testing apakah konfigurasi yang kita buat sudah benar maka kita bisa jalankan perintah sebagai berikut :

```bash
/usr/local/nginx/sbin/nginx -t
```

jika syntax dan test sukses, maka restart Nginx menggunakan file init yang tadi pada awal sudah kita buat.

```bash
/etc/init.d/nginx restart
```

Test akses file `info.php` tadi melalui browser `http://localhost/test.php`

Dari situ kita dapat menentukan apakah nNginx sudah dapat berjalan dan melakukan koneksi ke `php-fastcgi` atau belum..

## Security Issue

Layaknya sebuah aplikasi, pasti tidak akan lepas dari yang namanya bugs. Begitu juga dengan Nginx.

### Nginx “*no input file specified”* PHP fast-cgi 0day Exploit


Setelah Nginx dan PHP CGI berjalan, cobalah test mengakses http://localhost/terserah.php

Jika browser menunjukan *“no input file specified”*, konfigurasi kita masih rentan dan belum layak dipakai.

**Exploit** : Buat file `apaaja.gif` menggunakan **GIMP**. Pada kotak komentar isi dengan *script PHP* `<?php phpinfo(); ?>` dan letakan pada direktori nginx server root (jika dalam artikel kali ini `/var/www/nginx/apaaja.gif`).

![Nginx 0day](nginx-0day.png#center)

Secara normal, jika kita akses dari browser `http://localhost/apaaja.gif` akan nampak sebagai gambar `.gif` biasa. Tapi coba akses url dengan tersebut dari `http://localhost/apaaja.gif/terserah.php` maka hasilnya luar biasa :

![Nginx 0day Exploit](nginx-0day-exploit.png#center)

File `.gif` tersebut dieksekusi sebagai file PHP (ingat *comment* pada file `.gif` `<?php phpinfo(); ?>`).

Tentu saja `http://localhost/apaaja.gif/terserah.php` sebenarnya tidak ada. Tapi tiap request yang diakhiri dengan `.php` akan **DIEKSEKUSI** sebagai script PHP oleh Nginx  melalui fitur `cgi.fix_pathinfo` sehingga Nginx mengeksekusi file `.gif` tersebut sebagai script PHP!

Cara mengatasi :

1. Ubah `cgi.fix_pathinfo=1` menjadi `cgi.fix_pathinfo=0` pada `php.ini`

2. Edit `/usr/local/nginx/conf/nginx.conf` dan tambahkan sctipt berikut di antara *block* `server { }`

```nginx
error_page   400 402 403 404  /40x.html;
   location = /40x.html {
       root   html;
}
```

## LIBRARY

### Nginx Configure Module options

Saat proses konfigurasi, beberapa *module* akan aktif secara default, dan beberapa *module* perlu diaktifkan secara manual.

#### Otomatis aktif
Berikut ini *module-module* yang **otomatis aktif** saat command `./configure` dijalankan, tambahkan perintah-perintah di bawah untuk *me-disable* module tersebut:

`--without-http_charset_module`: Menonaktifkan *module* *Charset* untuk *re-encoding* halaman web.

`--without-http_gzip_module`: Menonaktifkan *module* kompresi **Gzip**.

`--without-http_ssi_module`: Menonaktifkan **Server Side Include module**.

`--without-http_userid_module`: Menonaktifkan *User ID module* yang menyediakan identifikasi pengguna menggunakan cookies.

`--without-http_access_module`: Menonaktifkan *module* pembatasan akses yang memungkinkan kita untuk konfigurasi akses untuk **IP range** tertentu. misal : `deny 192.168.1.1/24`.

`--without-http_auth_basic_module`: Menonaktifkan **Basic Authentication module**. (seperti **Auth Basic Apache**)

`--without-http_autoindex_module`: Menonaktifkan **Automatic Index module**.

`--without-http_geo_module`: Menonaktifkan *module* yang memungkinkan kita untuk mendefinisikan *variabel* menurut **IP range** tertentu.

`--without-http_map_module`: Module ini memungkinkan kita untuk mengklasifikasikan suatu nilai menjadi nilai yang berbeda, menyimpan hasilnya dalam bentuk *variabel*.

`--without-http_referer_module`: Module ini memungkinkan untuk memblokir akses berdasarkan *header* `http referer`.

`--without-http_rewrite_module`: Menonaktifkan module **Rewrite**.

`--without-http_proxy_module`: Menonaktifkan **module HTTP proxy** untuk request transfer ke server lain (*reverse proxy*).

`--without-http_fastcgi_module`: Menonaktifkan *module* untuk interaksi dengan proses **FastCGI**.

`--without-http_memcached_module`: Menonaktifkan *module* untuk interaksi dengan daemon *memcache*.

`--without-http_limit_zone_module`: Module ini memungkinkan untuk membatasi jumlah koneksi untuk alamat / direktori tertentu.

`--without-http_limit_req_module`: Menonaktifkan **module limit request** yang memungkinkan kita untuk membatasi jumlah *request per user*.

`--without-http_empty_gif_module`: Menampilkan gambar `.gif` transparan berukuran 1px x 1px. (sangat berguna untuk web designer)

`--without-http_browser_module`: Menonaktifkan module yang menungkinkan kita untuk membaca *string* **User Agent**.

`--without-http_upstream_ip_hash_module`: Menonaktifkan **module IP-hash** untuk load-balancing ke *upstream* server.

#### Tidak otomatis aktif

Berikut ini module-module yang tidak aktif saat command `./configure` dijalankan, tambahkan perintah-perintah di bawah untuk *me-enable module* tersebut:

`--with-http_ssl_module`: Mengaktifkan **module SSL** untuk website menggunakan protokol `https://`.

`--with-http_realip_module`: Mengaktifkan *module* untuk membaca alamat IP yang sebenarnya dari sebuah request (biasanya didapat dari **HTTP header** *trusted proxy*).

`--with-http_addition_module`: Mengaktifkan *module* yang memungkinkan kita menambahkan data ke halaman website.

`--with-http_xslt_module`: Mengaktifkan *module* untuk transformasi XSL ke XML. Catatan: Perlu menginstal `libxml2` dan `libxslt` *library*.

`--with-http_image_filter_module`: Mengaktifkan *module* yang memungkinkan kita untuk modifikasi gambar. Catatan: Perlu menginstal `libgd` *library* untuk *module* ini.

`--with-http_sub_module`: Mengaktifkan *module* untuk melakukan *replace* teks dalam halaman web.

`--with-http_dav_module`: Mengaktifkan fitur **WebDAV**

`--with-http_flv_module`: Mengaktifkan *module* khusus untuk *meng-handle* *flash video file* (`.flv`).

`--with-http_gzip_static_module`: Mengaktifkan **module GZIP static compression**.

`--with-http_random_index_module`: Mengaktifkan *module* untuk memilih file secara acak sebagai *index file* pada suatu direktori.

`--with-http_secure_link_module`: Mengaktifkan *module* untuk memeriksa request URL dengan *security token* yang dibutuhkan. (Mantap juga buat antisipasi **CSRF**)

`--with-http_stub_status_module`: Mengaktifkan *module* yang *menggenerate* server statistik dan informasi proses web server.

#### Miscellaneous options

`--with-ipv6`: Mengaktifkan IPv6

Menambahkan third-party module yang bisa di download dari internet. Misal dari [http://wiki.nginx.org/3rdPartyModules](http://wiki.nginx.org/3rdPartyModules) (asli keren2).

```bash
--add-module=/folder/ke/module/tambahan
```

Seperti yang kita lihat, perintah yang cukup mudah untuk konfigurasi sebuah web server. Pada umunya kita hanya perlu untuk menambahkan **module SSL** untuk konten **HTTPS**, dan **"Real IP"** untuk mengambil alamat IP pengunjung jika menggunakan *proxy* atau kita menjalankan **Nginx** sebagai *backend server* dengan web server lain.

Contoh untuk konfigurasi dengan semua *module* :

```bash
./configure --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module --with-http_image_filter_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module
```

Untuk referensi bahan bacaan :

* [http://wiki.nginx.org/](http://wiki.nginx.org/)
* [http://markmail.org/browse/ru.sysoev.nginx](http://markmail.org/browse/ru.sysoev.nginx)
* [http://www.joeandmotorboat.com/2008/02/28/apache-vs-nginx-web-server-performance-deathmatch/](http://www.joeandmotorboat.com/2008/02/28/apache-vs-nginx-web-server-performance-deathmatch/)