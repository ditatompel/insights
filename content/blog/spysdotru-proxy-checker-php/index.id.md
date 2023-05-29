---
title: "spys[dot]ru Proxy Checker [PHP]"
description: "Script untuk cek list proxy dari spys.ru dengan fitur pengecekan proxy tersebut cukup cepat atau tidak sesuai dengan koneksi internet yang digunakan."
date: 2013-02-21T21:31:51+07:00
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
tags:
  - PHP
  - Proxy
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

Script untuk cek *list proxy* dari `spys.ru` dengan fitur pengecekan *proxy* tersebut cukup cepat atau tidak sesuai dengan koneksi internet yang digunakan. Caranya melalui *respond* dari *proxy server* / *timeout*-nya (*default*nya saya buat 3 detik).

<!--more-->
```php
<?php
/**
 * spys.ru Proxy Checker
 * 
 * This program designed to display a list of proxies from spys.ru site.
 * In addition, you can also show 'good proxy' that fit with your current
 * internet connection..
 * 
 * Still very early release, just for fun coding purpose :)
 * 
 * @author <ditatompel@devilzc0de.org>
 * 
 * Example usage : 
 * $proxy = new spysRU();
 * $proxy->goodProxy(); // show proxies fits your current internet connection.
 * [or]
 * $proxy->goodProxy(1); // show debug for error connection from proxy server.
 * [or]
 * $proxy->showProxy(); // show any available free proxy from spys.ru
 * 
 *
 * LICENSE :
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published by
 * the Free Software Foundation.
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 */

class spysRU {
    
    protected $url = 'http://spys.ru/en/free-proxy-list/';
    protected $defaultTimeOut = 3; // in seconds
    private $data = '';
    private $ports = array();
    private $proxyData;
    private $userAgent = array(
        'Mozilla/5.0 (X11; Linux i686) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.52 Safari/536.5',
        'Mozilla/5.0 (Windows; U; Windows NT 5.1; it; rv:1.8.1.11) Gecko/20071127 Firefox/2.0.0.11',
        'Opera/9.25 (Windows NT 5.1; U; en)',
        'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
        'Mozilla/5.0 (compatible; Konqueror/3.5; Linux) KHTML/3.5.5 (like Gecko) (Kubuntu)',
        'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.12) Gecko/20070731 Ubuntu/dapper-security Firefox/1.5.0.12',
        'Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.102011-10-16 20:23:50',
        'Mozilla/5.0 (BlackBerry; U; BlackBerry 9800; en) AppleWebKit/534.1+ (KHTML, like Gecko) Version/6.0.0.337 Mobile Safari/534.1+2011-10-16 20:21:10',
        'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; en) Opera 8.0',
        'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6'
    );
    
    function __construct() {
        $postValue = array('sto' => 'View 150 per page');
        $eva = curl_init();
        curl_setopt($eva, CURLOPT_URL, $this->url);
        curl_setopt($eva, CURLOPT_USERAGENT, $this->userAgent[array_rand($this->userAgent)]); 
        curl_setopt($eva, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($eva, CURLOPT_POST, 1);
        curl_setopt($eva, CURLOPT_POSTFIELDS, $postValue);
        $this->data = curl_exec($eva);
        
        preg_match('/<\/table><script type="text\/javascript">(.*?)<\/script>/', $this->data, $js ); // get the javascript
        preg_match_all('/[a-z0-9]{6}=[0-9]/', $js[1], $jsPort, PREG_SET_ORDER );
        preg_match_all('/<font class=spy14>(.\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3})<script type="text\/javascript">(.*?)<\/script>/', $this->data, $proxys, PREG_SET_ORDER ); // proxy data
        curl_close($eva);
        
        $this->ports = $this->jsToArrayPort($jsPort);
        $this->proxyData = $proxys;
        
    }
    
    function showProxy($print=1) {
        $proxy = '';
        foreach ( $this->proxyData as $proxyK ) {
            if ( !$print )
                $proxy[] = $proxyK[1] . ':' . $this->replacePort($proxyK[2]);
            else
                print $proxyK[1] . ':' . $this->replacePort($proxyK[2]) . "\n";
        }
        return $proxy;
    }
    
    private function replacePort ($string) {
        $string = str_replace('document.write("<font class=spy2>:<\/font>"', '', $string);
        $string = explode("+", $string);
        $port = '';
        foreach ( $string as $encPort ) {
            $plainPort = preg_replace(array("/\^[a-z0-9]{4}/", "/[^a-z0-9]+/i"), array("",""), $encPort);
            if ( array_key_exists($plainPort, $this->ports) )
                $port .= $this->ports[$plainPort];
        }
        return $port;
    }
    
    private function jsToArrayPort ($arr) {
        foreach ( $arr as $key => $val ) {
            $arrayimu = explode("=", $val[0]);
            $port[$arrayimu[0]] = $arrayimu[1];
        }
        return $port;
    }
    
    function goodProxy ($debug=0) {
        $status = '';
        if ( $debug )
            $status = " [OK]";
        foreach ( $this->showProxy(0) as $proxy ) {
            $part = explode(':',$proxy);
            if($con = @fsockopen($part[0], $part[1], $errNum, $errStr, $this->defaultTimeOut)) {
                print $proxy . $status . "\n";
                fclose($con);
            }
            else
                if ( $debug )
                    print $proxy . " [" . $errStr . "]\n";
        }
    }
}
?>
```

**Cara penggunaannya:**

pertama panggil dulu classnya, misal:
```php
$proxy = new spysRU(); 
```

Lalu eksekusi *public function*nya. Misal :
```php
$proxy->showProxy(); // untuk menampilkan proxy yg tersedia 
$proxy->goodProxy(); // untuk menampilkan proxy yg cukup sesuai dengan koneksi internet kita 
$proxy->goodProxy(1); // debug, menampilkan juga pesan error dari proxy server. 
```

_Feel free to use / modify._