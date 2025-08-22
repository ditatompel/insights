---
title: "Mengatasi Docker dan NVIDIA Container Toolkit ldcache Runtime Error"
description: Mengatasi masalah Docker runtime error saat menjalankan container yang menggunakan NVIDIA GPU.
summary: Mengatasi masalah Docker runtime error saat menjalankan container yang menggunakan NVIDIA GPU.
date: 2025-08-22T10:42:00+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - SysAdmin
tags:
    - Docker
    - NVIDIA
    - Linux
    - Immich
images:
authors:
    - yiliuba168
---

Saya adalah salah satu pengguna **[Immich][immich-web]** dan saya memanfaatkan
**[NVIDIA Container Toolkit][nvidia-ctk-gh]** supaya Immich _container_ dapat
melakukan _encoding_ dan _decoding_ video menggunakan GPU; selain itu, dengan
**NVIDIA Container Toolkit**, Immich juga bisa menggunakan _CUDA core_ untuk
fitur _machine learning_-nya. Namun, beberapa hari lalu setelah melakukan _full
system upgrade_ mesin **Arch Linux**, saya mengalami beberapa kendala saat
mencoba menjalankan _Immich container_ tersebut.

Di artikel ini, saya ingin berbagi pengalaman saya memperbaiki error-error yang
terjadi terkait **NVIDIA container toolkit**, docker runtime, dan format
_"baru" docker compose_ yang digunakan untuk NVIDIA Docker runtime.

Prosesnya juga saya dokumentasikan dalam bentuk video di bawah ini:

{{< youtube qEIO6PDpFmE >}}

## NVIDIA Container Runtime

Error pertama yang saya hadapi saat mencoba menjalankan Immich container
menggunakan NVIDIA adalah sebagai berikut:

`Error response from daemon: failed to create task for container: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error running prestart hook #0: exit status 1, stdout: , stderr: Using requested mode 'cdi' invoking the NVIDIA Container Runtime Hook directly (e.g. specifying the docker --gpus flag) is not supported. Please use the NVIDIA Container Runtime (e.g. specify the --runtime=nvidia flag) instead.`

Error tersebut sepertinya terkait dengan adanya update NVIDIA Container
Runtime. Setelah melakukan pencarian terkait pesan error yang saya alami
diatas, saya menemukan sebuah [post di reddit yang membahas mengenai signal
9 error][reddit-signal-9-err]; dan di kolom komentar, salah satu user dapat
[memperbaiki signal 9 error tersebut dengan mengubah konfigurasi docker
compose-nya][exo-86-solution] dari :

```yaml
    runtime: nvidia
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities:
                - gpu
                - compute
                - video
```

menjadi:

```yaml
    runtime: nvidia
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              device_ids:
                - nvidia.com/gpu=all
              capabilities:
                - gpu
                - compute
                - video
```

Tapi, setelah mencoba mengimplementasikannya ke konfigurasi docker compose
untuk `hwaccel.transcoding.yml` dan `hwaccel.ml.yml`, saya mendapatkan error
lainnya.

## Invalid Runtime Name: NVIDIA

Jadi, saat menjalankan perintah `docker compose up` dengan konfigurasi yang
sudah saya sesuaikan dengan konfigurasi diatas, saya mendapati error berikut:

`Error response from daemon: unknown or invalid runtime name: nvidia`

Kali ini saya mendapatkan solusi untuk error tersebut dari [dokumentasi
mengenai Docker di Arch Linux Wiki][arch-wiki-docker-nvidia-container-runtime].
Disana dikatakan bahwa kita perlu membuat (atau menambahkan) konfigurasi
berikut di `/etc/docker/daemon.json`:

```json
{
  "runtimes": {
    "nvidia": {
      "path": "/usr/bin/nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
```

Setelah membuat konfigurasi tersebut, saya merestart _docker service_. Dan
untuk memastikan bahwa NVIDIA runtime benar-benar sudah tersedia, saya cek
menggunakan perintah `docker info | grep runtime`:

```plain
Runtimes: io.containerd.runc.v2 nvidia runc
Default Runtime: runc
```

Dari output diatas, bisa dipastikan bahwa runtime `nvidia` sudah tersedia, dan
seharusnya error sebelumnya sudah tidak terjadi lagi.

## Docker CDI Runtime

Oke, jadi Nvidia runtime sudah tersedia, kini saatnya mencoba menjalankan
Immich container lagi dengan menjalankan `docker compose down && docker compose
up`. Tapi, sayangnya, saya mengalami error lain sebagai berikut:

`Error response from daemon: failed to create task for container: failed to create task: OCI runtime create failed: could not apply required modification to 0CI specification: error modifying OCI spec: failed to inject CDI devices: failed to inject devices: failed to stat CDI host device "/dev/dri/card0": no such file or directory`

Kali ini, saya menemukan solusi untuk error diatas langsung dari repositori
Nvidia Container Toolkit di GitHub. Di [issue #1246]
[nvidia-container-toolkit-issue-1246], [biuniun][biuniun-gh-profile] memberikan
[penjelasan mengapa error tersebut terjadi][biuniun-solution], sekaligus
memberikan solusi untuk kita.

Pada intinya, kita perlu menjalankan perintah berikut:

```shell
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
sudo nvidia-ctk config --in-place --set nvidia-container-runtime.mode=cdi && sudo systemctl restart docker
```

Setelah menjalankan perintah-perintah diatas, Immich container sudah dapat
berjalan seperti sebelumnya.

## Referensi

- https://www.reddit.com/r/docker/comments/1mqlbg8/keep_getting_signal_9_error_no_matter_what/
- https://wiki.archlinux.org/title/Docker#With_NVIDIA_container_runtime
- https://github.com/NVIDIA/nvidia-container-toolkit/issues/1246#issuecomment-3194219487

[immich-web]: https://immich.app/ "Immich Official Website"
[nvidia-ctk-gh]: https://github.com/NVIDIA/nvidia-container-toolkit "NVIDIA Container Toolkit GitHub Repository"
[reddit-signal-9-err]: https://www.reddit.com/r/docker/comments/1mqlbg8/keep_getting_signal_9_error_no_matter_what/ "Topik di Reddit mengenai Docker signal 9 error"
[exo-86-solution]: https://www.reddit.com/r/docker/comments/1mqlbg8/comment/n8xhgja/ "Solusi dari u/EXO-86 mengatasi signal 9 error di Docker"
[arch-wiki-docker-nvidia-container-runtime]: https://wiki.archlinux.org/title/Docker#With_NVIDIA_container_runtime "Dokumentasi Mengenai Docker di Arch Linux Wiki"
[nvidia-container-toolkit-issue-1246]: https://github.com/NVIDIA/nvidia-container-toolkit/issues/1246 "NVIDIA Container Toolkit issue #1246"
[biuniun-gh-profile]: https://github.com/biuniun "biuniun GitHub Profile"
[biuniun-solution]: https://github.com/NVIDIA/nvidia-container-toolkit/issues/1246#issuecomment-3194219487 "Solusi dari Biuniun"
