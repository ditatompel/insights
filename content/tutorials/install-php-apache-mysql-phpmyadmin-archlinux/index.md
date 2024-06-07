---
title: "Installing PHP, Apache, MySQL, and phpMyAdmin on Arch Linux"
description: "A step-by-step guide to installing PHP, Apache, MySQL, and phpMyAdmin on Arch Linux."
summary: "A step-by-step guide to installing PHP, Apache, MySQL, and phpMyAdmin on Arch Linux."
date: 2012-02-18T05:01:30+07:00
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
  - Linux
  - MySQL
  - Apache
  - PHP
images:
authors:
  - ditatompel
---

Why Arch Linux? Because I'm comfortable using Arch, and with its package manager, we can easily install the latest and most up-to-date kernel and software.

**Video (in Indonesian):**

{{< youtube zr7TVU7SZUs >}}

1. First, we ensure that our system is up to date by running:

```bash
pacman -Syu
```

2. Next, we install the necessary packages using:

```bash
pacman -S php apache php-mcrypt phpmyadmin mysql
```

3. We then navigate to the `/etc/webapps/phpmyadmin` directory and copy the `phpmyadmin` configuration file to `/etc/httpd/conf/extra`:

```bash
cp /etc/webapps/phpmyadmin/apache.example.conf /etc/httpd/conf/extra/httpd-phpmyadmin.conf
```

4. We include the configuration in the main `httpd.conf` file located in the `/etc/httpd/conf` directory by adding:

```apache
# phpmyadmin configuration
Include conf/extra/httpd-phpmyadmin.conf
```

![Apache Config PHPMyAdmin](phpmyadmin-include.png#center)

Then, we can access `localhost` and `phpmyadmin` in the browser.

6. If there is a forbidden message in **phpmyadmin**, we need to add the `DirectoryIndex index.html index.php` configuration to `/etc/httpd/conf/extra/httpd-phpmyadmin.conf`, then restart the http server.

![DirectoryIndex Apache](directoryIndex.png#center)

7. If **PhpMyAdmin** can be accessed, but there is still an error message "The mysqli extension is missing." or "The mcrypt extension is missing"; We need to enable the extension in `php.ini` by removing the semicolon (`;`) from the required extension.

![PHP Extension](extension.png#center)

```ini
extension=mcrypt.so
extension=mysqli.so
extension=mysql.so
```

Then, we can restart the http server again.

FYI: On Arch Linux, by default `httpd` runs as user `http` and group `http`. To make it more comfortable and avoid error messages on certain CMS installations, we need to change the permissions and owner of the `/srv/http` folder (where the `public_html` folder is located) using:

```bash
chown -R http:http /srv/http
```

The installation process for Apache, PHP, MySQL, and PhpMyAdmin is now complete.

For now, this concludes the basics.
