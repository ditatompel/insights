---
title: "PHP Crypter dengan Passphrase Key"
description: Simple PHP program untuk encode dan decode data menggunakan passphrase dengan Rijndael 256 bit encryption.
date: 2012-06-30T18:08:08+07:00
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

Minggu lalu ceritanya iseng2 bikin script buat encrypt file. Nah karena keterbatasan waktu, ane belom sempet utak atik lagi. Inspirasinya dari PGP yang pake pertukaran public key, bedanya ini pertukarannya pake passphrase keynya. Mungkin ada yg berminat buat ngembangin.

<!--more-->

- Tool Name : **PHP Crypter**
- Program Language : `PHP`
- Environment : **CLI**
- Tested On : **PHP** `5.4.4` (built: Jun 13 2012)
- Linux Requirement : *PHP mcrypt library*
- Description : *Encode or decode data using specific key passphrase with Rijndael256 bit encryption.*
- Repo: [https://github.com/ditatompel/PHP-Crypter](https://github.com/ditatompel/PHP-Crypter).
```php
<?php
/**
 * PHP Crypter
 * 
 * This program used to encode or decode data using specific key passphrase
 * with Rijndael 256 bit encryption.
 * 
 * Still very early release, just for fun coding purpose :)
 *
 * LICENSE :
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published by
 * the Free Software Foundation.
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 * 
 * @author Christian Ditaputratama <ditatompel@devilzc0de.org>
 * 
 * Usage : 
 * new phpCrypter($argv);
 */



class phpCrypter
{
    const V = 0.01; // this is the program version
    const PASSPHARSE = "di7atomp3l"; // change this
    const EXT = '.tpl'; // file extention result
    private $verbose = FALSE; // verbose mode. Default false = off
    private $decrypt = FALSE; // default mode = encrypt
    private $key = NULL; // property for custom key or use PASSPHARSE constant
    
    /* Contructor. Set up arguments, print banner and execute main program. */
    function __construct($opts) {
        $cmd = $this->arguments($opts);
        print $this->banner();
        
        /**
         * Required parameter is "d" for decrypt OR "e" for encrypt.
         * Stop the program if both option has been set.
         */
        if ( array_key_exists('d', $cmd) && array_key_exists('e', $cmd) ) {
            print "\n" . $this->crot("[!] Double method, please choose 1 beetween decrypt / encrypt", 'red') . "\n";
            print $this->usage($cmd['input'][0]);
            exit;
        }
        
        /* Print help screen then exit if file param is not set */
        if ( !array_key_exists('file', $cmd) ) {
            print $this->usage($cmd['input'][0]);
            exit;
        }
        
        if ( array_key_exists('d', $cmd) ) $this->decrypt = TRUE;
        if ( array_key_exists('v', $cmd) ) $this->verbose = TRUE;
        
        if ( array_key_exists('key', $cmd) ) $this->key = is_null ($cmd['key']) ? self::PASSPHARSE :  $cmd['key'];
        else $this->key = self::PASSPHARSE;
        
        if ( $this->cekData($cmd['file']) ) {
            if ( !array_key_exists('o', $cmd) )
                print "\n" . $this->crypter($this->readData($cmd['file']));
            else
                $this->writeData($cmd['file'] . self::EXT, $this->crypter($this->readData($cmd['file'])));
        }
        else
            print $this->crot(" [!] Data is not exist or is not wirtable!", 'red') . "\n";
    }
    
    /**
     * The cool banner
     * @return string
     */
    function banner() {
        $msg = " ________________________________________________________\n";
        $msg .= "|         mm                                             |\n";
        $msg .= "|      /^(  )^\   PHP Crypter " .  $this->crot('v' . self::V,'cyan') . "                      |\n";
        $msg .= "|      \,(..),/   Encode / decode data using specific    |\n";
        $msg .= "|        V~~V     key passphrase with " .  $this->crot('Rijndael 256','red') . " bit   |\n";
        $msg .= "|      encryption. Coded by ditatompel@devilzc0de.org    |\n";
        $msg .= "|________________________________________________________|\n\n";
        return $msg;
    }
    
    /**
     * Help Screen
     * @return string
     */
    function usage($file) {
        $msg = "\nUsage : ";
        $msg .= $file . " --file=[file] [option(s)]\n";
        $msg .= "Example : ";
        $msg .= $file . " --file=/home/dit/private.txt --key=\"RAHASIA\" -dvo\n";
        $msg .= "Option(s) :\n";
        $msg .= " -d : Decrypt | -e : Encrypt (required)\n";
        $msg .= " --key=[key] : passphrase key to encrypt / decrypt file\n";
        $msg .= " -v : verbose mode, print all output to terminal\n";
        $msg .= " -o : write output to [file].tpl\n";
        return $msg;
    }
    
    /**
     * The Crypter
     * Encrypt / Decrypt the data using PHP mcrypt rinjadael 256 ECB mode.
     * @return string
     */
    function crypter($str=NULL) {
        // notify user if the program cannot encrypt/decrypt empty string
        if( is_null($str) ) {
            print $this->crot(" [!] Cannot encrypt/decrypt null string", 'red') . "\n";
            return $str;
        }
        
        $mode = 'encrypt';
        if ( $this->decrypt ) $mode = 'decrypt';
        if ( $this->verbose ) {
            print " [*] Trying to " . $this->crot($mode, 'purple') . " file...\n";
            print " [+] Using " . $this->crot($this->key,'l_cyan') . " as passpharse key\n";
        }
        $data = NULL;
        $header = "-----BEGIN PHP CRYPTER BLOCK-----\n";
        $header .= "Version: " . self::V . " (ditatompel@devilzc0de.org)\n\n";
        $footer = "\n";
        $footer .= "-----END PHP CRYPTER BLOCK-----\n";
        $iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB);
        $iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
        $key_size = mcrypt_get_key_size(MCRYPT_RIJNDAEL_256, MCRYPT_MODE_ECB);
        $key = substr($this->key,0,$key_size);
        
        if( $this->decrypt ) 
            $return = mcrypt_decrypt(MCRYPT_RIJNDAEL_256, $key, base64_decode($str), MCRYPT_MODE_ECB, $iv);
        else {
            $strings = str_split(base64_encode(mcrypt_encrypt(MCRYPT_RIJNDAEL_256, $key, $str, MCRYPT_MODE_ECB, $iv)), 65);
            foreach ( $strings as $string )
                $data .= $string . "\n";
            $return = $header . $data . $footer;
        }
        return $return;
    }
    
    /**
     * Human readable file size function
     * @return string
     */
    function xfilesize($size) {
        switch ( $size ) {
            case $size > 1099511627776 :
                $size = number_format($size / 1099511627776, 2, ".", ",") . " TB";
            break;
            case $size > 1073741824 :
                $size = number_format($size / 1073741824, 2, ".", ",") . " GB";
            break;
            case $size > 1048576 :
                $size = number_format($size / 1048576, 2, ".", ",") . " MB";
            break;
            case $size > 1024 :
                $size = number_format($size / 1024, 2, ".", ",") . " kB";
            break;
            default :
                $size = number_format($size, 2, ".", ",") . " Bytes";
        }
        return $size;
    }
    
    /**
     * Check target data
     * @return bool. TRUE if file exists and readable.
     */
    function cekData ($file) {
        if ( $this->verbose ) print "\n [*] Checking " . $file . " if it's exists..\n";
        if ( !is_file($file) || !is_readable($file) )
            return false;
        else {
            if ( $this->verbose )
                print $this->crot(" [+] File " . $file . " is exists and readable..", 'l_green') . "\n";
            return true;
        }
    }
    
    /**
     * Read target data
     * @return string.
     */
    function readData ($file) {
        $msg = NULL;
        $read = fopen($file, "r");
        $msg .= fread($read, filesize($file));
        if ( $this->verbose )
            print " [*] File size is " . $this->xfilesize(filesize($file)) ."\n";
        if ( $this->decrypt ) {
            $msg = explode("\n\n", $msg);
            $msg = str_replace("\n", '', $msg[1]);
        }
        fclose($read);
        return $msg;
    }
    
    /**
     * Create file and and write data to the file.
     * @return bool
     */
    function writeData ($file, $data) {
        $fh = fopen($file, 'wx+');
        fwrite($fh, $data);
        fclose($fh);
        if ( $this->verbose )
            print $this->crot(" [*] Data has been writed to " . $file, 'l_green') . "\n";
        return true;
    }
    
    
    /**
     * Make UNIX like parameter command.
     * This function from losbrutos and modified by earomero. Thankyou. =)
     * @author losbrutos <losbrutos@free.fr>
     * @author earomero <earomero@gmail.com>
     * @param array argv
     * @return array
     */
    function arguments($argv) {
        $_ARG = array();
        foreach ($argv as $arg) {
            if (preg_match('#^-{1,2}([a-zA-Z0-9]*)=?(.*)$#', $arg, $matches)) {
                $key = $matches[1];
                switch ($matches[2]) {
                    case '':
                    case 'true':
                    $arg = true;
                    break;
                    case 'false':
                    $arg = false;
                    break;
                    default:
                    $arg = $matches[2];
                }
                
                // make unix like -afd == -a -f -d
                if(preg_match("/^-([a-zA-Z0-9]+)/", $matches[0], $match)) {
                    $string = $match[1];
                    for($i=0; strlen($string) > $i; $i++) {
                        $_ARG[$string[$i]] = true;
                    }
                } else {
                    $_ARG[$key] = $arg;    
                }            
            } else {
                $_ARG['input'][] = $arg;
            }        
        }
        return $_ARG;    
    }
    
    /**
     * Function to print colorful output to terminal.
     * @param string    $string    String to be colored.
     * @param string    $fontColor The available color
     *        Available color :
     *                  black, dark_gray, blue, green, l_green, cyan, l_cyan
     *                  red, l_red, purple, l_purple, brown, yellow, l_gray,
     *                  white.
     * @return string
     */
    private function crot($string, $fontColor=NULL) {
        switch ($fontColor) {
            case 'black' : $color = '0;30'; break;
            case 'dark_gray' : $color = '1;30'; break;
            case 'blue' : $color = '0;34'; break;
            case 'l_blue' : $color = '1;34'; break;
            case 'green' : $color = '0;32'; break;
            case 'l_green' : $color = '1;32'; break;
            case 'cyan' : $color = '0;36'; break;
            case 'l_cyan' : $color = '0;36'; break;
            case 'red' : $color = '0;31'; break;
            case 'l_red' : $color = '1;31'; break;
            case 'purple' : $color = '0;35'; break;
            case 'l_purple' : $color = '1;35'; break;
            case 'brown' : $color = '0;33'; break;
            case 'yellow' : $color = '1;33'; break;
            case 'l_gray' : $color = '0;37'; break;
            case 'white' : $color = '1;37'; break;
        }
        $colored_string = "";
        $colored_string .= "\033[" . $color . "m";
        $colored_string .=  $string . "\033[0m";
        return $colored_string;
    }
}
?>
```

Contoh `exec.php` :
```php
<?php
set_time_limit(0);
ini_set('memory_limit', '-1'); // use this for large data file
require_once('phpCrypter.php');
new phpCrypter($argv);
?>
```
```plain
Usage : file.php --file=[file] [option(s)]
Option(s) :
-d : Decrypt | -e : Encrypt (required)
--key=[key] : passphrase key to encrypt / decrypt file
-v : verbose mode, print all output to terminal
-o : write output to [file].tpl
```

## Contoh melakukan *encrypt*
```bash
/home/dit/PHP-Crypter/exec.php --file=/home/dit/private.txt --key="RAHASIA" -evo
```
atau
```bash
/home/dit/PHP-Crypter/exec.php -e -v -o --file=/home/dit/private.txt --key="RAHASIA"
```

Dari contoh command di atas :

dia akan mengenkripsi file `private.txt` pada direktori `/home/dit` dengan **passphrase key** `RAHASIA` lalu menuliskan hasil enkripsi ke file `private.txt.tpl` di direktori yg sama.

## Contoh melakukan *decrypt*
```bash
/home/dit/PHP-Crypter/exec.php --file=/home/dit/private.txt.tpl --key="RAHASIA" -dvo
```
atau
```bash
/home/dit/PHP-Crypter/exec.php -d -v -o --file=/home/dit/private.txt.tpl --key="RAHASIA"
```
Dia akan mendekrip file p`rivate.txt.tpl` pada direktori `/home/dit` dengan **passphrase key** `RAHASIA` lalu menuliskan hasil dekripsi ke file `private.txt.tpl.tpl` di direktori yg sama.

_**Note** : Jika option "`o`" tidak di set maka dia akan menampilkan output ke terminal, bukan ke file._

## TODO:
- Ketika mengenkripsi file, dia akan membuat file baru dengan penambahan extension .tpl. Sedangkan akan lebih baik jika ketika mendekrip file akan kembali ke file extension semula.
- Belum bisa mengetahui apakah file tersebut benar2 terdekrip atau tidak.