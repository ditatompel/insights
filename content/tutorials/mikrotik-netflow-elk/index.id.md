---
title: Analisa Lalu Lintas Jaringan Router MikroTik Menggunakan Traffic Flow, Filebeat, ElasticSearch, dan Kibana
description: Konfigurasikan Filebeat dan MikroTik Traffic Flow untuk mengirim data NetFlow ke ElasticSearch.
summary: Panduan konfigurasi Traffic Flow MikroTik, mengaktifkan modul NetFlow pada Filebeat, dan menyiapkan dasbor Kibana.
date: 2024-11-11T13:26:00+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - TIL
tags:
    - MikroTik
    - NetFlow
    - ElasticSearch
    - Kibana
    - Filebeat
images:
authors:
    - ditatompel
---

Di pertengahan tahun 90-an, **Cisco** memperkenalkan fitur **NetFlow** pada
router yang diproduksinya. Fitur NetFlow ini menyediakan kemampuan untuk
mengumpulkan informasi _packet_ masuk maupun _packet_ keluar dari sebuah
_network interface_. Secara umum, setup NetFlow terdiri dari 3 komponen utama,
yaitu:

-   **Flow Exporter**: Bertugas mengumpulkan _network packets_, kemudian
    mengirimkan ke **Flow Collector**.
-   **Flow Collector**: Bertugas menerima dan melakukan _preprocessing_ data
    yang diterima dari **Flow Exporter**.
-   **Aplikasi Analisis**: Aplikasi yang bertugas menganalisa data yang
    diterima dari **Flow Collector**, dan biasanya memvisualisasikan data yang
    diterima dalam bentuk grafik.

Fitur NetFlow ini kemudian diimplementasikan oleh banyak perusahaan yang
memproduksi _router_ dan _switch_ dengan nama yang berbeda. Sebagai contoh,
**Juniper Networks** menggunakan nama **J-Flow** sedangkan **MikroTik**
menggunakan nama **Traffic Flow**.

Kebetulan, saya menggunakan router **MikroTik RB450G**, dan di kesempatan kali
ini saya ingin berbagi informasi tentang cara menggunakan fitur Traffic Flow
pada router MikroTik, dan mengintegrasikan-nya dengan Filebeat, ElasticSearch
dan Kibana.

{{< youtube yHbH-oJX-Lg >}}

## Prasyarat

Sebelum memulai, Anda perlu menginstall dan memastikan bahwa **Filebeat**,
**ElasticSearch** dan **Kibana** berjalan dengan baik karena saya tidak akan
mengulas cara menginstall aplikasi-aplikasi tersebut disini. Silahkan mengikuti
proses installasi dan konfigurasi dari halaman dokumentasi terkait:

-   [ElasticSearch][elasticsearch-install]
-   [Kibana][kibana-install]
-   [Filebeat][filebeat-install]

Sebagai tambahan informasi terkait artikel ini, saya menginstall Filebeat di
sebuah mesin Linux yang masih berada di satu jaringan dengan router MikroTik
saya. Sedangkan untuk ElasticSearch dan Kibana, saya menginstallnya di sebuah
VPS.

## Hak Akses Untuk Filebeat

Saya membuat 1 user baru dengan hak akses khusus yang nantinya digunakan oleh
Filebeat untuk mengirimkan data yang diproses dari router ke ElasticSearch.
Caranya, dari Dashboard Kibana, masuk ke **"Management"** > **"Security"** >
**"Roles"**. Buat sebuah role baru, dan beri nama yang untuk untuk role
tersebut. Di artikel ini saya menamainya dengan `filebeat_setup`.

Pada bagian **"Cluster privileges"** saya memberikan akses berikut:

-   `monitor`
-   `manage_ilm`
-   `manage_index_templates`
-   `manage_collector`
-   `manage_ingest_pipelines`
-   `manage_logstash_pipelines`
-   `manage_ml`
-   `manage_pipeline`

Kemudian pada bagian **"Index privileges"**, saya memberikan `all`
**Privileges** untuk semua **Incides**.

Masih dari halaman **"Management"** > **"Security"**, masuk ke halaman
**"Users"** dan buat sebuah user baru. Saya menamai user baru tersebut dengan
nama `custom_filebeat`. Pada bagian **"Privileges"**, saya memberikan role
`filebeat_setup` yang sudah kita tambahkan sebelumnya. Selain itu, saya
memberikan role berikut:

-   `kibana_admin`
-   `ingest_admin`
-   `editor`
-   `monitoring_user`
-   `kibana_system`

## Filebeat NetFlow Module

Login ke mesin Linux yang sudah terinstall Filebeat dan sesuaikan konfigurasi
pada `/etc/filebeat/filebeat.yml`, terutama pada bagian `setup.kibana` dan
`output.elasticsearch`. Konfigurasi `filebeat.yml` saya kurang lebih sebagai
berikut:

```yml
setup.kibana:
    host: "https://kibana.ditatompel.com:443"

output.elasticsearch:
    hosts: ["https://elastic-ap-southeast1-ctb1.ditatompel.com:443"]
    username: "custom_filebeat"
    password: "MySuperSecretPasswordThatMayAppearsOnYourFreakinAICompletions"
    ssl:
        enabled: true
```

Kemudian edit `/etc/filebeat/modules.d/netflow.yml.disabled` dan ubah
`netflow_host` ke `0.0.0.0` supaya Filebeat dapat menerima data dari router
MikroTik. Kurang lebih konfigurasi module `netflow` saya seperti berikut:

```yml
- module: netflow
  log:
      enabled: true
      var:
          netflow_host: 0.0.0.0
          netflow_port: 2055
          internal_networks:
              - private
```

Setelah itu, _enable_ `netflow` module dengan menjalankan perintah `sudo
filebeat modules enable filebeat`. Untuk melihat module yang tersedia, baik
yang aktif maupun tidak, gunakan perintah `sudo filebeat modules list`.

Kemudian jalankan perintah `sudo filebeat setup -e` untuk melakukan setup
_index template_ dan _dashboards_ pada Kibana.

Terakhir, restart filebeat service dengan menjalankan perintah `sudo systemctl
restart filebeat`.

## Konfigurasi Traffic Flow MikroTik

Login ke router MikroTik, Anda bisa menggunakan SSH atau **Winbox.** Di artikel
ini, saya menggunakan Winbox untuk mempermudah konfigurasi.

Masuk ke **"IP"** > **"Traffic Flow"**. Klik pada menu **"Targets"** dan
tambahkan target baru. Ubah **"Dst. Address"** ke alamat IP dimana Filebeat
server berjalan. Ubah **"Version"** ke **"IPFIX"** dan pastikan
**checkbox "Enabled"** tercentang. Kemudian tekan tombol **"Ok"**.

Pada menu **"Traffic Flow Settings"**, pilih **"Interfaces"** yang ingin
diproses dan pastikan pastikan **checkbox "Enabled"** tercentang.

## Kibana Dashboard

Untuk hasil NetFlow yang telah diproses, masuk ke **"Analytics"** >
**"Dashboards"**. Disana akan muncul banyak dashboard yang sudah tergenerate
secara otomatis oleh Filebeat. Cari dengan kata kunci _"netflow"_ dan silahkan
mengeksplor berbagai macam informasi yang sudah tersedia.

[elasticsearch-install]: https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html
[kibana-install]: https://www.elastic.co/guide/en/kibana/current/install.html
[filebeat-install]: https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation-configuration.html
