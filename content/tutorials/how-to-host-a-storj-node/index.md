---
title: "How to Host a STORJ Node"
description: "Step by step guide to run STORJ Node, an open-source cloud storage platform, S3-compatible platform and suite of decentralized applications."
# linkTitle:
date: 2021-10-26T23:12:05+07:00
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
  - StorJ
  - S3
  - Docker
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

**Storj** (pronounced as *"storage"*), is an open-source cloud storage platform, *S3-compatible* platform and suite of decentralized applications that allows you to store data in a secure and decentralized manner. Basically, it uses a decentralized network of nodes to host user data. The platform also secures hosted data using advanced encryption.

<!--more-->

In a [white paper](https://storj.io/whitepaper) published in December,2014, Storj was first introduced to the world as a concept. It was to be a decentralized peer-to-peer encrypted cloud storage platform.

To host a Node, your hardware and bandwidth will need to meet a few requirements:
- One processor core
- Minimum 550GB of available disk space
- Minimum of 2TB of available bandwidth a month
- Minimum upstream bandwidth of 5 Mbps
- Minimum download bandwidth of 25 Mbps
- Keep your node online 24/7
- Read and agree to the [Storj Storage Node Operator Terms and Conditions](https://storj.io/storj-operator-terms)

If you can follow above requirement, you are good to go. In this article, I use Ubuntu 18.04 running on VPS with public IP address, 4 cores processor, 2GB RAM and 600GB additional disk partition for Storj data.

## Request authorization token
[Sign up](https://registration.storj.io/) and request authorization token. Make sure you have received your personal single-use authorization token. It looks like this:

![StorJ Auth Token](storj-node-auth-token.png#center)

The entire string, including your email is your auth token.

## Prepare the system
Make sure your system is up to date by running `apt update` and `apt upgrade`.

### UDP config
UDP transfers on high-bandwidth connections can be limited by the size of UDP recieve buffer.

Storj sofware attemps to increase the UDP recieve buffer size. However, on Linux, an application is only allowed to increase the buffer size up to a max value set in the kernel, and the the default maximum value is too small for high bandwidth UDP transfers.

Its is recommended to increase the max buffer size by running the following command to increase it to 2.5MB.

```shell
echo "net.core.rmem_max=2500000" >> /etc/sysctl.conf
sysctl -w net.core.rmem_max=2500000
```
### Generate node identity
Every node is required to have a unique identifier on the network.

You need to download StorJ identity binary to generate your node identity (**as regular user, not as root**):
```shell
curl -L https://github.com/storj/storj/releases/latest/download/identity_linux_amd64.zip -o identity_linux_amd64.zip
unzip -o identity_linux_amd64.zip
chmod +x identity
sudo mv identity /usr/local/bin/identity
```
Run command below to create an identity:
```shell
identity create storagenode
```
This process can take several minutes or hours or days, depending on your machines processing power and luck.

This process will continue until it reaches a difficulty of at least 36. On completion, it will look something like this:

```plain
Generated 5186393 keys; best difficulty so far: 36
Found a key with difficulty 36!
Unsigned identity is located in "/home/USERNAME/.local/share/storj/identity/storagenode"
Please *move* CA key to secure storage - it is only needed for identity management and isn't needed to run a storage node!
        /home/USERNAME/.local/share/storj/identity/storagenode/ca.key
```
### Authorize the identity
Authorize your Storage Node identity using your single-use authorization token from **"Request authorization token"** section above. (_replace the placeholder `<email:characterstring>` to your actual authorization token_):

```shell
identity authorize storagenode <email:characterstring>
```
When it's done and success, you will get result similar like this:

```plain
2021/10/26 02:07:22 proto: duplicate proto type registered: node.SigningRequest
2021/10/26 02:07:22 proto: duplicate proto type registered: node.SigningResponse
Identity successfully authorized using single use authorization token.
Please back-up "/home/USERNAME/.local/share/storj/identity/storagenode" to a safe location.
```

To make sure the authorizing identity is successful, run these 2 following commands:
```shell
grep -c BEGIN ~/.local/share/storj/identity/storagenode/ca.cert
grep -c BEGIN ~/.local/share/storj/identity/storagenode/identity.cert
```

The first command should return `2`, and the second command should return `3`.

### Move the identity to the subfolder in the storage location (optional)
In this example, I use `/dev/sdb1` partition and mount it to `/mnt/storj1` directory using `/etc/fstab` conffiguration file (_don't forget to change the `/mnt/storj1` ownership to your regular user using `chown` command_).

Create 2 folder named `identity` and `data` under `/mnt/storj1` directory (we will use them latter).

```shell
mkdir /mnt/storj1/{identity,data}
```

Then, copy your **generated identity folder** to `/mnt/storj1/identity` :
```shell
cp -rfv ~/.local/share/storj/identity/storagenode /mnt/storj1/identity/
```

### Install docker and download the Storage Node Docker Container
To setup a Storage Node, you first must have Docker installed. You can follow this official [Ubuntu Docker Installation](https://docs.docker.com/install/linux/docker-ce/ubuntu/).

After docker is successfully installed and running, download the Storage Node Docker Container:
```shell
docker pull storjlabs/storagenode:latest
```

### Setting up the storage node
> _You must static mount your storage partition via /etc/fstab. Failure to do so will put you in high risk of failing audits and getting disqualified._

> _The setup step must be performed only once. If a node has already been set up, running with the SETUP flag will result in failure._


```shell
docker run --rm -e SETUP="true" \
    --mount type=bind,source="<identity-dir>",destination=/app/identity \
    --mount type=bind,source="<storage-dir>",destination=/app/config \
    --name storagenode storjlabs/storagenode:latest
```
Replace the `<identity-dir>` and `<storage-dir>` with your parameters.

In this article I use `/mnt/storj1/identity/storagenode` for `<identity-dir>` and `/mnt/storj1/data` for `<storage-dir>` (see section **"Move the identity to the subfolder in the storage location"** above).

After running the command above, your node has been set up.

## Run the Storage Node
Run the command below (edit the `WALLET`, `EMAIL`, `ADDRESS`, `STORAGE` and replace the `<identity-dir>`, and `<storage-dir>` with your parameters)

```shell
docker run -d --restart unless-stopped --stop-timeout 300 \
    -p 28967:28967/tcp \
    -p 28967:28967/udp \
    -p 14002:14002 \
    -e WALLET="0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
    -e EMAIL="youremail@example.com" \
    -e ADDRESS="host.yourdomain.com:28967" \
    -e STORAGE="500GB" \
    --mount type=bind,source="<identity-dir>",destination=/app/identity \
    --mount type=bind,source="<storage-dir>",destination=/app/config \
    --name storagenode storjlabs/storagenode:latest
```
You're officially a Storage Node operator! You can also check to see if the node was started properly by by running the following command in the terminal
```shell
docker ps -a
```

### Check the status of your node
You can check the status of your node, along with many other statistics by accessing web dashboard from browser: `http://host.yourdomain.com:14002`.

Or using command line:
```shell
docker exec -it storagenode /app/dashboard.sh
```

## Resources:
- [https://docs.storj.io/node/](https://docs.storj.io/node/)
- [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)