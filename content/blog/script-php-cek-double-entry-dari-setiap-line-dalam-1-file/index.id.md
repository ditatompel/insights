---
title: "Script PHP Cek Double Entry Dari Setiap Line Dalam 1 File"
description: "Script untuk pengecekan double entry dari setiap linenya dalam 1 file. Dapat digunain juga untuk pengecekan wordlist, email, password, proxy, dll"
date: 2012-12-01T20:25:00+07:00
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

Jadi ceritanya kemarin ada **NOC** yang bertanya, bisa ga sih klo kita ngecek entri konfigurasi yang *double* menggunakan script. Terus ane dikasi contoh file yang namanya `nice.rsc`. Setelah saya buka, ternyata file tersebut digunakan untuk menambahkan alamat IP yang terdaftar di **OpenIXP** ke **MikroTik RouterOS**.

<!--more-->

Setelah saya cek lagi dari atas ke bawah, ternyata konfigurasinya 1 line 1 rule. Karena 1 line 1 rule juga saya jadi ingat dengan sistem semacam wordlist untuk melakukan *bruteforce*. =D


Lalu saya iseng dan membuat scriptnya untuk ngecek entry yang double dari setiap linenya dalam 1 file. Jadi bisa digunain juga untuk ngecek wordlist, email, password, proxy, dll yang double2.

Penampakannya kurang lebih seperti di sini :

{{< youtube cCQPADuOHfU >}}

Scriptnya:
```php
<?php
/**
 * This program used to find duplicate entry for each line of text from given
 * file. For example to check list of email, proxy, username:password,
 * configurations, etc.
 * 
 * This is not WebBased PHP program, so use it from CLI.
 * Depend on your machine, you might need to reset your PHP memory_limit to -1
 * for checking large file.
 * 
 * Still very early release, hasn't been tested on Windows and just for fun
 * coding purpose :)
 * 
 * coded by ditatompel
 * Usage : new findDuplicates($argv);
 */

class FindDuplicates
{
    var $cmd = array();
    var $reqFunc = array('file_get_contents', 'fopen', 'fwrite');
    
    function __construct ($opts) {
        $this->checkReqFunc();
        
        $this->cmd = $this->args($opts);
        if ( !array_key_exists('list', $this->cmd) )
            exit( $this->usage($this->cmd['input'][0]) );
        $this->enumValues($this->cmd['list']);
    }
    
    function checkReqFunc() {
        $ok = 1;
        foreach( $this->reqFunc as $func ) {
            if ( !function_exists($func) ) {
                print 'You need function ' . $func . " to execute this tool!\n";
                $ok = 0;
            }
        }
        if(php_sapi_name() != 'cli') {
            print "<strong>This is not WebBased program! Use this tool from CLI.</strong>";
            $ok = 0;
        }
        if ( !$ok ) exit;
    }
    
    /**
     * Check list file
     * @return bool. TRUE if file exists and readable.
     */
    function cekFile ($file) {
        if ( !is_file($file) || !is_readable($file) )
            return false;
        return true;
    }
    
    private function usage($file) {
        $msg = "Usage : ";
        $msg .= $file . " --list=[list]\n";
        $msg .= "\tOptions : \n";
        $msg .= "\t\t-v :\t\t verbose mode.\n";
        $msg .= "\t\t--out=[file] :\t Save non duplicate entry to file.\n";
        $msg .= "Example :\n";
        $msg .= $file . " --list=/path/to/file.txt --out=/path/to/file.txt.new -v\n";
        return $msg;
    }
    
    private function enumValues($filename) {
        if ( !$this->cekFile($filename) )
            exit("File is not readable!\n");
        if ( array_key_exists("out", $this->cmd) ) {
            $this->checkWrite($this->cmd['out']);
            $fh = fopen($this->cmd['out'], 'w');
        }
        $time_start = microtime(1);
        print "File : " . $filename . " (" . $this->format_bytes(filesize($filename)) . ")\n";
        $fGetContents = file_get_contents($filename);
        $content = explode("\n", $fGetContents);
        $totalLines = count($content);
        print "Total : " . $this->plural($totalLines,'line') . "\n";
        $totalDuplicate = 0;
        print "Please be patient, process will be a little longer for large file sizes...\n";
        $unique = array_unique($content);
        if( $totalLines > count($unique) ) {
            for($i = 0; $i < $totalLines; $i++) {
                $percentage = (int)number_format($i/$totalLines, 2, '', '');
                $prog = "Progress : " . $this->ID_nummeric($i) . "/" . $this->ID_nummeric($totalLines) . " " . $percentage . "%";
                echo $prog;
                echo "\033[" . strlen($prog) . "D";
                if(!array_key_exists($i, $unique)) {
                    if ( array_key_exists("v", $this->cmd) )
                        print "Duplicate entry on line " . ($i+1) . ": " . $content[$i] . "\n";
                    $totalDuplicate++;
                }
                else {
                    if ( array_key_exists("out", $this->cmd) ) {
                        if ( !is_writable($this->cmd['out']) )
                            exit("[Error] " . $this->cmd['out'] . " is not writable.\n");
                        fwrite($fh, $content[$i] . "\n");
                    }
                }
            }
        }
        print "Total duplicate entry : " . $this->plural($totalDuplicate)  . "\n";
        if ( array_key_exists("out", $this->cmd) )
            print "New list saved to: " . $this->cmd['out'] . " (" . $this->format_bytes(filesize($this->cmd['out'])) . ")\n";
        $time_end = microtime(1);
        $execution_time = ($time_end - $time_start);
        print 'process complete in ' . $execution_time . " sec\n";
    }

    private function ID_nummeric ($number) {
        return number_format($number, 0, ',','.');
    }
    
    private function checkWrite($location) {
        if ( is_dir($location) )
            exit("[Error] " . $location . " is a directory.\n");
    }
    
    private function plural($number, $txt='item') {
        if ( $number > 1 ) 
            return $this->ID_nummeric($number) . " "  . $txt . "s";
        return $this->ID_nummeric($number) . " "  . $txt;
    }
    
    // yatsynych at gmail dot com
    function format_bytes($a_bytes) {
        if ($a_bytes < 1024) {
            return $a_bytes .' B';
        } elseif ($a_bytes < 1048576) {
            return round($a_bytes / 1024, 2) .' KiB';
        } elseif ($a_bytes < 1073741824) {
            return round($a_bytes / 1048576, 2) . ' MiB';
        } elseif ($a_bytes < 1099511627776) {
            return round($a_bytes / 1073741824, 2) . ' GiB';
        } elseif ($a_bytes < 1125899906842624) {
            return round($a_bytes / 1099511627776, 2) .' TiB';
        } elseif ($a_bytes < 1152921504606846976) {
            return round($a_bytes / 1125899906842624, 2) .' PiB';
        } elseif ($a_bytes < 1180591620717411303424) {
            return round($a_bytes / 1152921504606846976, 2) .' EiB';
        } elseif ($a_bytes < 1208925819614629174706176) {
            return round($a_bytes / 1180591620717411303424, 2) .' ZiB';
        } else {
            return round($a_bytes / 1208925819614629174706176, 2) .' YiB';
        }
    }
    
    /**
     * Make UNIX like parameter command.
     * This function from losbrutos and modified by earomero. Thankyou. =)
     * @author losbrutos <losbrutos@free.fr>
     * @author earomero <earomero@gmail.com>
     * @param array argv
     * @return array
     */
    private function args($argv) {
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
}
?>
```
Tinggal panggil classnya :

```php
$cek = new FindDuplicates ($argv); 
```
Ingat, ini CLI ya.. jadi buat eksekusinya :
```bash
php [nama_script_phpnya] --list=[nama_file_yang_di_cek]
```

Ada 2 option tambahan yang bisa digunakan :

- `-v` : untuk *verbose mode*.
- `--out=[file]` : buat bikin file baru yang udah diilangin duplikatnya.

```bash
php class.FindDuplicates.php --list=openixp.rsc --out=openixp.rsc.new -v
```
Akan menampilkan line yang sama/serupa/sudah ada ke terminal dari file `openixp.rsc` kemudian bikin file baru yang udah '*dibersihin*' dengan nama `openixp.rsc.new`.

Misal file yang mau di cek gede, sampe puluhan mega, mungkin perlu ngeset **PHP** `memory_limit` nya jadi `-1`.

Belum saya test di windows. Silahkan klo ada yg mau mengembangkan.
