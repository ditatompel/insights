---
title: "Installing Self-Hosted HiSHtory: A Step-by-Step Guide"
description: Learn how to install the self-hosted version of HiSHtory, a program that stores terminal history context. Follow this easy-to-follow guide for a smooth setup process.
summary: HiSHtory is a powerful tool that stores terminal history context, including command execution dates, directories, and duration. This article shows you how to install the self-hosted version of HiSHtory, allowing you to manage your terminal history with ease.
date: 2025-03-20T22:00:00+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - Self-Hosted
tags:
    - Bash
    - Zsh
    - HiSHtory
    - Linux
images:
authors:
    - ditatompel
---

If you frequently work using the Linux Terminal, the _history_ feature on the
shell we use can greatly help increase our productivity. However, by default,
shells such as `bash` or `zsh` have some limited command history features,
for example:

- The information from which directory a command was run is not saved.
- There is no information about whether a command was successfully executed
  or not.
- There is no information on how long it takes for your computer to complete
  a command.

For most Linux users, these features are indeed more than sufficient and not
essential. Storing extra information can, in effect, increase disk I/O and
affect machine performance too. However, for some other Linux users, this
feature can be very helpful when conducting investigations or troubleshooting
on a system.

If this information can be stored centrally and searched based on specific
keywords, it will certainly help alleviate the task of Linux System
Administrators who often use many complex commands with pipelines. Fortunately,
there is a program called **HiSHtory**.

## Introduction to HiSHtory

[HiSHtory][hishtory-gh] is a program that stores terminal history context,
including the date and time when the command was executed, the location of the
active directory when the command was executed, and the duration of command
execution. This information can be stored locally (on a per-machine basis) or
centrally through a client-server architecture.

In other words, you can easily perform complex shell pipeline searches from
a server or another machine, even if you're accessing them from your laptop or
one of your computers, without having to physically or remotly switch between
machines.

## Using Self-hosted HiSHtory

In this article, I will demonstrate self-hosted HiSHtory setup using 2 laptops
with Linux operating systems. The details of the laptops are as follows:

- The laptop with hostname T420, having IP address 192.168.2.22, will serve as
  both the server and client.
- The laptop with hostname P50 will act as the client.

Please note that I will be utilizing the Docker version of the HiSHtory server,
so ensure that the server computer has Docker installed and configured to
run properly.

### Configuring HiSHtory Server

1. Log in to the server computer and clone the repository
   [ddworken/hishtory][hishtory-gh] and enter the directory:

```shell
git clone https://github.com/ddworken/hishtory.git
cd hishtory
```

2. Edit the `backend/server/docker-compose.yml` file and adjust the
   configuration as needed. Since I'm using PostgreSQL as my backend database,
   I updated the `POSTGRES_PASSWORD` environment variable from
   `TODO_YOUR_POSTGRES_PASSWORD_HERE` to `MyStrongPassword`. Additionally,
   because the default PostgreSQL password configuration has changed, I also
   need to update the value of the `HISTORY_POSTGRES_DB` environment variable
   to match the new password. Furthermore, since port 80 on the server is
   already in use by another process, I've updated the HiSHtory server listen
   port on the host machine from port 80 to port 45680.

![HiSHtory backend docker-compose](hishtory-server-docker-compose.jpg#center)

Here's an overview of my `backend/server/docker-compose.yml` configuration:

```yml
version: "3.8"
networks:
    hishtory:
        driver: bridge
services:
    postgres:
        image: postgres
        restart: unless-stopped
        networks:
            - hishtory
        environment:
            POSTGRES_PASSWORD: MyStrongPass
            POSTGRES_DB: hishtory
            PGDATA: /var/lib/postgresql/data/pgdata
        volumes:
            - postgres-data:/var/lib/postgresql/data
        healthcheck:
            test: pg_isready -U postgres
            interval: 10s
            timeout: 3s
    hishtory:
        depends_on:
            postgres:
                condition: service_healthy
        networks:
            - hishtory
        build:
            context: ../../
            dockerfile: ./backend/server/Dockerfile
        restart: unless-stopped
        deploy:
            restart_policy:
                condition: on-failure
                delay: 3s
        environment:
            HISHTORY_POSTGRES_DB: postgresql://postgres:MyStrongPass@postgres:5432/hishtory?sslmode=disable
            HISHTORY_COMPOSE_TEST: $HISHTORY_COMPOSE_TEST
        ports:
            - 45680:8080
volumes:
    postgres-data:
```

3. Next, build the Docker image by running this command:

```shell
docker compose -f backend/server/docker-compose.yml build
```

4. After the build process is complete, try running the HiSHtory server using
   this command:

```shell
docker compose -f backend/server/docker-compose.yml up
```

Wait a few moments and ensure that the HiSHtory server is running properly.
This can be verified by using the `docker ps` command or checking directly with
the HiSHtory HTTP server: `curl -sIL http://127.0.0.1:45680` (adjust the
IP:port according to your configuration).

### Configuring HiSHtory Clients

One important consideration is that, since we will be using a self-hosted
setup, you **must** add the environment variable
`HISHTORY_SERVER=http://<ip>:<port>` to your `.bashrc` or `.zshrc`
file (adjust the IP address and port used).

Additionally, by default, HiSHtory client is installed in `~/.hishtory`.
However, to keep my `$HOME` directory organized, I will use the
`~/.config/hishtory` directory. This can be achieved by adding
`HISHTORY_PATH=.config/hishtory` to your `.bashrc` or `.zshrc`.

So, my `.bashrc` or `.zshrc` has the following additional configuration:

```shell
export HISHTORY_PATH=.config/hishtory
# adjust IP and port below with your environment settings
export HISHTORY_SERVER="http://192.168.2.22:45680"
```

After adding these environment variables, reload your shell session,
then download and run the available install script:

```shell
curl https://hishtory.dev/install.py | python3 -
```

The script will automatically generate your device ID and secret key as well
as various other basic configurations. Save the secret key that appears so you
can use it for synchronization on other computers.

To configure on a second computer or server, repeat this process on each
computer or server. After completing the HiSHtory installation using the last
install script above, run the following command:

```shell
hishtory init $YOUR_HISHTORY_SECRET_FROM_FIRST_DEVICE
```

Replace `$YOUR_HISHTORY_SECRET_FROM_FIRST_DEVICE` with the secret key from
the first device.

> **Note**: The secret key can also be displayed by running the
> `hishtory status` command on the first device.

I hope this helps!

[hishtory-gh]: ttps://github.com/ddworken/hishtory "Official HiSHtory Repository"
