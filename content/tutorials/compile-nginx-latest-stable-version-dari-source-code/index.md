---
title: "Compiling the Latest Stable Version of Nginx from Source Code"
description: "While Apache remains a popular choice for web servers, there are alternative options like Nginx that offer unique features and benefits. In this article, we'll explore how to compile the latest stable version of Nginx from its source code."
summary: "While Apache remains a popular choice for web servers, there are alternative options like Nginx that offer unique features and benefits. In this article, we'll explore how to compile the latest stable version of Nginx from its source code."
date: 2011-08-25T18:00:31+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
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
authors:
  - ditatompel
---

**Nginx**, a web server developed by **Igor Sysoev** in 2002, is a new alternative to **Apache**.

> _**NOTE**: This article was written in 2011, so you need to adapt in following this tutorial. Moreover, currently the majority of Linux distributions switched from `sysVinit` to `SystemD`._

Nginx (pronounced **"Engine X"**) is a lightweight web server and reverse proxy and email proxy with high performance, running on Windows, UNIX, GNU/Linux, Solaris, and BSD variants such as macOS.

## Why Nginx?

1. **Speed**: One core processor can efficiently handle thousands of connections, resulting in significantly reduced CPU load and memory consumption.

2. **Easy to use**: Configuration files are much easier to understand and modify than other web server configurations such as Apache. Just a few lines are enough to create a fairly complete `virtual host`.

3. **Plug-in system** (here referred to as "`modules`")

4. and most importantly, **Open Source** (BSD-like license)

Some examples of large websites that use Nginx either as a web server or as a reverse proxy to Apache include: **kaskus.us**, **indowebster.com**, **wordpress.com**, **sourceforge. net**, **github.com**, etc.

## Why compile?

In the web server installation process, several tools and parameters are required that we have to decide on during compilation, and several additional configurations that must be carried out and adapted to our system.

Well, this time we choose to download the source code of the application and install it manually rather than installing using the package manager. There are several reasons why people choose to install manually:

1. To get to know more about how the system (especially the web server) that we use works.
2. (Probably) not yet available in the repositories of the Linux distribution being used.

Besides that, repositories rarely offer to download and install Nginx using the package manager (`yum`, `apt`, or `yast`) for the latest version (except on rolling-release distributions such as Arch Linux). Most provide old versions that are not up to date.

## Nginx Compilation Process

Below is a capture screen video that I made previously. Perhaps it can help in the installation process. (It doesn't need to be exactly the same; the important thing is to know the process and how it works.)

{{< youtube AtJ5OBOj1gE >}}

### Download source code

First, let's download our web server from [http://nginx.org/download/nginx-1.0.5.tar.gz](http://nginx.org/download/nginx-1.0.5.tar.gz) (when I wrote this article, the latest stable version was 1.0.5).

```bash
wget http://nginx.org/download/nginx-1.0.5.tar.gz
```

After that, copy the source to `/usr/local/src/` and extract it.

```bash
sudo cp nginx-1.0.5.tar.gz /usr/local/src/
cd /usr/local/src/
sudo tar -xvzf nginx-1.0.5.tar.gz
```

**Notes:**

1. Before the installation process, it's better to check whether port 80 is being used or not. I'm using the BackTrack distro and by default Apache uses port 80 at startup. Run `/etc/init.d/apache2 stop` or `killall apache2`.
2. Nginx is a program created using the C programming language, so to be able to compile it, we first need to have tools such as the GNU Compiler Collection (GCC) on our computer. GCC is usually installed on most Linux distros.

To confirm, just run the command `gcc` (without quotes) in the terminal. If you get output "gcc: no input files", it means GCC is already installed on your computer. If not, you need to install it first.

OK, let's continue...

### ./configure dan make install

Go to the `nginx-1.0.5` directory under `/usr/local/src/` directory and start compiling.

```bash
cd nginx-1.0.5
./configure
```

By default, the **HTTP rewrite module** is automatically installed during the default Nginx installation. This module requires the **PCRE (Perl Compatible Regular Expression) library** because the **Rewrite** and **HTTP Core modules** of Nginx use PCRE as their _regular expression_ syntax.

Now it depends on our choice; if we:

1. require a rewrite module, we have to install PCRE first:

```bash
apt-get install libpcre3 libpcre3-dev
```

2. If we don't need it:

```bash
./configure --without-http_rewrite_module
```

Our choice fell on the first option because most of the sites we use needs the rewrite module. So after installing PCRE, we have to configure it again.

```bash
./configure
```

carry out the installation process:

```bash
make && make install
```

The default installation process that we did above will place the Nginx "workspace" in the `/usr/local/nginx` directory

### Creating a SysVinit Script for Nginx

Create a file with the name `nginx` in the `/etc/init.d/` directory:

```bash
nano /etc/init.d/nginx
```

Then copy and paste the shell script below, then save.

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

`chmod +x` so that the script can be executed.

```bash
chmod +x /etc/init.d/nginx
```

After this, we can **start**, **stop**, **restart**, or **reload** the Nginx process via the script. Let's try running Nginx:

```bash
/etc/init.d/nginx start
```

Then, we should get a welcome message "Welcome to nginx!" when accessing `localhost` from your browser.

## Installation and configuration of PHP FastCGI (spawn-fcgi) with Nginx

Install `spawn-fcgi`.

```bash
apt-get install php5-cgi spawn-fcgi
```

After the installation process via the package manager is complete, create a file named `php-fastcgi` in the `/etc/init.d/` directory:

```bash
nano /etc/init.d/php-fastcgi
```

Copy and paste the shell init script below:

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

Don't forget to `chmod +x` so that the script can be executed.

```bash
chmod +x /etc/init.d/php-fastcgi
```

Then, before running `php-fastcgi`, we first build the website structure that we will use. (I chose the `/var/www/nginx` directory.)

```bash
mkdir -p /var/www/nginx; cd nginx
```

Create a file with the name `info.php` containing `phpinfo();` (just to test whether PHP is running or not):

```bash
echo "<?php phpinfo(); ?>" > info.php
```

Then, edit the Nginx configuration to suit the structure of the website we are building.

```bash
nano /usr/local/nginx/conf/nginx.conf
```

Because our root public HTML is in `/var/www/nginx`, then the configuration is as follows:

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

Note that I changed the `root` and `fastcgi_param SCRIPT_FILENAME` configuration (video minute 7:00).

To test whether the configuration we created is correct, we can run the following command:

```bash
/usr/local/nginx/sbin/nginx -t
```

If the syntax and test are successful, then restart Nginx using the init file that we created earlier.

```bash
/etc/init.d/nginx restart
```

Test accessing the `info.php` file via the browser at `http://localhost/info.php`.

From there, we can determine whether Nginx can run and connect to PHP-FastCGI or not.

## Security Issue

In terms of computer and software security, we know that no system is perfect and free from bugs.

### Nginx “_no input file specified”_ PHP fast-cgi 0day Exploit

After Nginx and PHP CGI are running, try accessing http://localhost/whatever.php

If the browser displays "_No input file specified_", our configuration remains vulnerable and is not yet suitable for use.

**Exploit** : Create `anything.gif` file using **GIMP**. In the comment box, fill in the PHP _script_ `<?php phpinfo(); ?>` and place it in the nginx server root directory (in this article `/var/www/nginx/anything.gif`).

![Nginx 0day](nginx-0day.png#center)

Normally, if we access it from the browser `http://localhost/anything.gif` it will appear as a normal `.gif` image. But try accessing the URL from `http://localhost/anything.gif/whatever.php` then the results are amazing:

![Nginx 0day Exploit](nginx-0day-exploit.png#center)

The `.gif` file is executed as a PHP file (remember the _comment_ on the `.gif` file `<?php phpinfo(); ?>`).

Of course `http://localhost/anything.gif/whatever.php` doesn't actually exist. But every request that ends with `.php` will be **EXECUTED** as a PHP script by Nginx via the `cgi.fix_pathinfo` feature so that Nginx executes the `.gif` file as a PHP script!

How to overcome :

1. Change `cgi.fix_pathinfo=1` to `cgi.fix_pathinfo=0` in `php.ini`
2. Edit `/usr/local/nginx/conf/nginx.conf` and add the following sctipt between _block_ `server { }`

```nginx
error_page   400 402 403 404  /40x.html;
   location = /40x.html {
       root   html;
}
```

## Modules

### Nginx Configure Module Options

During the configuration process, some modules will be enabled by default, and some need to be explicitly enabled.

#### Enabled by Default

The following modules are **enabled by default** when the `./configure` command is executed. To disable a module, add the commands below:

`--without-http_charset_module`: Disables _module_ _Charset_ for _re-encoding_ web pages.

`--without-http_gzip_module`: Disables _module_ **Gzip** compression.

`--without-http_ssi_module`: Disables **Server Side Include module**.

`--without-http_userid_module`: Disables the _User ID module_ which provides user identification using cookies.

`--without-http_access_module`: Disables the access restriction _module_ which allows us to configure access for a specific **IP range**. for example: `deny 192.168.1.1/24`.

`--without-http_auth_basic_module`: Disables **Basic Authentication module**. (like **Auth Basic Apache**)

`--without-http_autoindex_module`: Disables **Automatic Index module**.

`--without-http_geo_module`: Disables the _module_ that allows us to define _variables_ according to a specific **IP range**.

`--without-http_map_module`: This module allows us to classify a value into different values, storing the results in the form of a _variable_.

`--without-http_referer_module`: This module allows to block access based on the `http referer` _header_.

`--without-http_rewrite_module`: Disables the **Rewrite** module.

`--without-http_proxy_module`: Disables **HTTP proxy module** for transfer requests to another server (_reverse proxy_).

`--without-http_fastcgi_module`: Disables the _module_ for interaction with the **FastCGI** process.

`--without-http_memcached_module`: Disables the _module_ for interaction with the _memcache_ daemon.

`--without-http_limit_zone_module`: This module allows to limit the number of connections for a specific address / directory.

`--without-http_limit_req_module`: Disables **module limit requests** which allows us to limit the number of _requests per user_.

`--without-http_empty_gif_module`: Returns a 1px x 1px transparent `.gif` image. (very useful for web designers)

`--without-http_browser_module`: Disables the module that allows us to read the **User Agent** _string_.

`--without-http_upstream_ip_hash_module`: Disables the **IP-hash** module for load-balancing to the _upstream_ server.

#### Disabled by Default

The following modules are disabled by default. To enable these modules, add the commands below:

`--with-http_ssl_module`: Enables **SSL module** for websites using the `https://` protocol.

`--with-http_realip_module`: Enables the _module_ to read the actual IP address of a request (usually obtained from the **HTTP header** _trusted proxy_).

`--with-http_addition_module`: Enables _module_ which allows us to add data to website pages.

`--with-http_xslt_module`: Enables _module_ for XSL to XML transformation. Note: Need to install `libxml2` and `libxslt` _library_.

`--with-http_image_filter_module`: Enables the _module_ that allows us to modify images. Note: Need to install `libgd` _library_ for this _module_.

`--with-http_sub_module`: Enables the _module_ to perform _replace_ text in a web page.

`--with-http_dav_module`: Enables the **WebDAV** feature

`--with-http_flv_module`: Enables a special _module_ to _handle_ _flash video files_ (`.flv`).

`--with-http_gzip_static_module`: Enables **module GZIP static compression**.

`--with-http_random_index_module`: Enables the _module_ to randomly select a file as the _index file_ in a directory.

`--with-http_secure_link_module`: Enables the _module_ to check URL requests with the required _security token_. (Also great for anticipating **CSRF**)

`--with-http_stub_status_module`: Enables a _module_ that _generates_ server statistics and web server process information.

#### Miscellaneous options

`--with-ipv6`: Enable IPv6 support

As we can see, configuring a web server is quite easy. In general, we only need to add an **SSL module** for serving HTTPS content and "Real IP" to retrieve the visitor's IP address if we use a proxy or run Nginx as a backend server with another web server.

Example of configuration with all modules:

```bash
./configure --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module --with-http_image_filter_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module
```

references:

- [http://wiki.nginx.org/](http://wiki.nginx.org/)
- [http://markmail.org/browse/ru.sysoev.nginx](http://markmail.org/browse/ru.sysoev.nginx)
- [http://www.joeandmotorboat.com/2008/02/28/apache-vs-nginx-web-server-performance-deathmatch/](http://www.joeandmotorboat.com/2008/02/28/apache-vs-nginx-web-server-performance-deathmatch/)
