---
title: "Creating a virtualization lab on a local network with VirtualBox (2012)"
description: "This comprehensive guide leverages VirtualBox to build a virtualization lab on a local network, offering a flexible and cost-effective testing environment."
summary: "This comprehensive guide leverages VirtualBox to build a virtualization lab on a local network, offering a flexible and cost-effective testing environment."
# linkTitle:
date: 2012-12-21T20:40:14+07:00
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
  - VirtualBox
  - Linux
  - MySQL
images:
authors:
  - ditatompel
---

Recently, several friends have asked and are interested in learning to build servers. Most of them think that to learn to build or maintain a server, you need a Virtual Private Server (VPS) or even a dedicated server. Is that true? Although the price for VPS for some students is considered quite high, let alone a dedicated server.

Actually, if we just want to learn, we don't have to rent a VPS; instead, we can use something called virtualization (It's called learning, so you don't need a public IP that can be accessed by anyone; that's why we use a local network).

There are many ways to do this virtualization: **OpenVZ**, **VirtualBox**, **Xen**, **VMware**, etc. - from _para-virtualization_ to _full-virtualization_, from community (free) to enterprise (paid) versions. Each has its advantages and disadvantages (although I don't want to debate this issue).

This time, I used VirtualBox because many users already use it on their personal computers. Before continuing, I will first inform you of the situation and conditions at the time this guide was created.

- Subnet: `/24`
- Gateway: `192.168.0.2`
- Host OS: IP=`192.168.0.242`, OS=`Linux`

I want to create two virtual servers - one for a database server (MySQL server) and another server for something I haven't thought of yet. ;p

So what's needed:

- VirtualBox with `vboxnetfit` module
- ISO CentOS 6.x netinstall
- Internet connection

Video:

{{< youtube r5s8lBDNBXI >}}

## Part 1: Setting Guest Hosts (virtual servers)

Firstly, we definitely need VirtualBox. Please download it if you don't have it already. Then, install the `vboxnetfit` module for bridged adapter to virtual server. You may also need the `vboxdrv` module (optional for running a custom kernel). Activate it by issuing `modprobe [module_name]` command.

Next, let's run VirtualBox and create a virtual host. To do this, click the New icon at the top left, then enter the name and OS information used. For example:

- **Name** : CentOS Server Example III
- **Type** : Linux
- **Version** : RedHat (32/64 according to Host CPU)

Then press the Next button.

![Add New VirtualBox Host](feature-virtual-lab-jar-lokal-01.png#center)

Next, determine the **RAM** capacity that will be used by the virtual server, just give it **512MB**, then press the next button again.

![VirtualBox Set Guest RAM](virtual-lab-jar-lokal-02.png#center)

Next, create a virtual HDD, select option 2 **"Create a virtual hard drive now"** then press next.

![VirtualBox Set Guest Virtual HDD](virtual-lab-jar-lokal-03.png#center)

After that, another option appears for the hard drive type. If you don't want to move to another virtualization later, just select default **VDI**. But this time I chose **QEMU**.

![VirtualBox Set Guest Virtual HDD Type](virtual-lab-jar-lokal-04.png#center)

Later on the left there will be a list of Virtual Guests that have been created. Right click on the menu we just created and select **"Settings"**.

In the **Storage** => **Controller IDE** menu, select the image file used. I'm using **ISO CentOS 6.2 Netinstall 64-bit**.

![VirtualBox Set Guest OS](virtual-lab-jar-lokal-05.png#center)

Then in the **Network** menu -> **Adapter 1**, change **Attached to** from **NAT** to **Bridged Adapter**. The name corresponds to the interface being used (in my case: `eth0`).

![VirtualBox Set Bridged Adapter](virtual-lab-jar-lokal-06.png#center)

Click **Ok**, then Start **Virtual Guest**.

So, the installation process is the same as installing a regular OS.

![Linux install method](virtual-lab-jar-lokal-07.png#center)

What you need to pay attention to is: Use a static IP/_Static DHCP_ address from the router, not dynamic. Because if our IP is dynamic it will be difficult to remote, especially the SSH fingerprint problem.

![Linux install IP setting](virtual-lab-jar-lokal-08.png#center)

This time I gave the IP `192.168.0.152`, Gateway `192.168.0.2` and use Google's DNS server (`8.8.8.8`).

Then fill in the **CentOS** image URL, I used `mirror.nus.edu.sg`, please change it via `kambing.ui.ac.id` / whatever that is. What is clear is that it suits the architecture you are using. For example (`http://kambing.ui.ac.id/centos/6.3/os/x86_64` for those using **64-bit**).

![Linux setup URL](virtual-lab-jar-lokal-09.png#center)

Then click ok and wait for the installation process finished; then you will be asked to _reboot_ the OS.

**Reboot**/**Poweroff** the virtual guest. We edit the **primary boot** from **CD-ROM** to **Hard Disk**. The method:

**Setting** -> **System** -> **Motherboard** -> **Boot Order** -> Raise the **Hard Disk** menu to the first position / uncheck **Floppy** and **CD/DVD-ROM**.

![VirtualBox Boot Order](virtual-lab-jar-lokal-10.png#center)

Try running Virtual Guest again. You can use **CLI** so that the virtual host can run in the background:

- display the Virtual Guest list with the command: `VBoxManage list vms`
  ![VBoxManage list vms](virtual-lab-jar-lokal-11.png#center)
- run the following command to run the virtual guest in the background: `VBoxManage startvm "virtual machine name" --type=headless`.

For example:

```bash
VBoxManage startvm "CentOS Server Example III" --type=headless
```

Once it's running, try `ping` the virtual guest IP that we created earlier (`192.168.0.152`), wait for it to come up and log in via **SSH**.

```bash
ssh root@192.168.0.152
```

From there you can set the hostname, update software, etc.

## Part 2: Install another Guest Host

Repeat **Part 1** to create another _Virtual Guest_ so that we have two _virtual hosts_, and run it simultaneously with the headless option. Give this second virtual guest the IP `192.168.0.151`. For example, this time, we will use the second virtual guest as a database server.

In this second virtual guest, install MySQL server:

```bash
yum install mysql mysql-devel mysql-server
```

Start MySQL server

```bash
service mysqld start
```

Setup the MySQL server by running the command `/usr/bin/mysql_secure_installation`. This will prompt an interactive sequence of questions to secure the MySQL server installation.

Then, log in to the MySQL server as the `root` user to create a new user and database.

```bash
mysql -h localhost -u root -p
```

You will be asked to enter the MySQL password for the `root` user. Once logged in, create a new user:

```bash
CREATE USER 'ditatompel'@'192.168.0.%' IDENTIFIED BY 'password';
```

Where:

- `ditatompel` is **username**
- `192.168.0.%` represents the hostname/IP from which it makes remote connections to the MySQL server (note: this is equivalent to `192.168.0.0/24`)
- `password` is the password used

```sql
CREATE DATABASE IF NOT EXISTS db_testing;
```

Where `db_testing` is the name of the database that we will use later.

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON db_testing.* TO 'ditatompel'@'192.168.0.%';
```

Where `SELECT`, `INSERT`, `UPDATE`, and `DELETE` are user permissions granted from host `192.168.0.%` on all tables in the `db_testing` database (`db_testing`.\*). Don't forget to execute **FLUSH PRIVILEGES** afterwards.

```sql
FLUSH PRIVILEGES;
```

Also ensure that the default **MySQL** port (3306) is not blocked by your _firewall_.

![iptables](virtual-lab-jar-lokal-12.png#center)

Afterward, try connecting to the MySQL server from the first virtual guest or from our PC using the following command:

```bash
mysql -h 192.168.0.151 -u ditatompel -p
```

Where `192.168.0.151` is the IP address of the MySQL server and `ditatompel` is the user that we created on the MySQL server previously.

![iptables](virtual-lab-jar-lokal-13.png#center)

> **Q**: If I want to create 5 virtual guests and my laptop/PC RAM is only 1GB, that's not possible, then what?

**A**: Then use/bring a friend's laptop home, plug it into the same network, and run VirtualBox on that machine. Do the steps above to set up the virtual environment. If you have multiple laptops and can dedicate one laptop per three virtual guests, you could potentially create 12 virtual guests.

So, once everything is connected and communicating, that's essentially it. You can also conduct testing to learn about port knocking, firewall configuration, intrusion detection systems (IDS)/intrusion prevention systems (**IPS**), load balancing, and clustering. However, the results will still be far from optimal.
