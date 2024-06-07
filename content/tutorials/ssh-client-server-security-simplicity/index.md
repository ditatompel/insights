---
title: "SSH Client - Server (Security & Simplicity)"
description: Hardening SSH access by disabling root SSH access, change the default port, and utilize public and private keys.
summary: Hardening SSH access by disabling root SSH access, change the default port, and utilize public and private keys.
# linkTitle:
date: 2012-05-17T17:09:21+07:00
lastmod:
draft: false
noindex: false
# comments: false
nav_weight: 1000
series:
#  - Tutorial
categories:
  - SysAdmin
  - Security
tags:
  - Linux
  - SSH
images:
authors:
  - ditatompel
---

For System Administrators, using **SSH** instead of **Telnet** is likely a daily routine when accessing Linux/Unix-based systems. Although the password transmitted to the server has been encrypted and no longer appears as plaintext, the default installation of OpenSSH is considered somewhat insecure.

This time, I'd like to share some common tricks for tightening up SSH access. This includes disabling SSH access for the root user, utilizing public and private keys, and even modifying the default port. Additionally, I'll be sharing a few tips to make server management easier and simpler.

To participate in this discussion, you should have:

- A client PC with Linux running KDE 4.8.
- A remote SSH server (Remote PC) with an IP address of 202.150.169.245.
- Basic understanding of Linux command-line interfaces, such as `chmod`, `ssh`, `groupadd`, and `useradd`.
- The ability to use text editors like `vi`/`vim`/`nano`/`pico`, etc.

## Disabling Root Access via SSH

The "root" user is undoubtedly present on Unix/Unix-like systems. If we don't disable this user, it will make it easier for attackers to perform brute-force attacks against the root account.

Before disabling root access, we need to create a new user with the right to use the SSH service and add them to the sudoers list.

1. Access the SSH server using the "root" user first.

```bash
ssh root@202.150.169.245
```

2. Once logged in to the SSH server, create a new user and group. (You can refer to `man useradd` for more information)

```bash
groupadd ditatompel
useradd -s /bin/bash -d /home/ditatompel -g ditatompel -G root -m ditatompel
```

3. Set the password for this new user with the command `passwd ditatompel`.

![Create User](create-user.png#center)

4. Then, add the "ditatompel" user to the sudoers list. Edit the `/etc/sudoers` file and add the following permission:

```plain
ditatompel     ALL=(ALL)    ALL
```

5. Next, edit the `/etc/ssh/sshd_config` file and add/edit the following configuration:

```plain
PermitRootLogin no
AllowUsers ditatompel
```

6. Restart the SSH daemon:

```bash
service sshd restart #(For CentOS, etc.)
/etc/init.d/ssh restart #(for Debian)
/etc/rc.d/sshd restart #(FreeBSD, Arch, Gentoo, etc.)
```

> **Important:** After restarting, ensure that any currently connected SSH sessions do not get terminated or closed so you can still access and edit the configuration if there's an error.

7. Try accessing the SSH server using the new user, which is "ditatompel".

```bash
ssh ditatompel@202.150.169.245
```

## Changing the Default SSH Port (Optional)

Changing the default SSH port (`22`) can help prevent brute-force attacks that simply grab scripts from the internet since most brute-force SSH scripts default to port `22` for their attack attempts.

**NOTE:** If your server's firewall is active, you'll need to open access to the new port, for example if you're using `iptables`:

```bash
iptables -A INPUT -p tcp --dport 1337 -j ACCEPT
iptables save
service iptables restart
```

- Remember not to close any existing SSH connections that are already connected to avoid unwanted issues.

Next, to change the port, edit the `/etc/ssh/sshd_config` file and add/edit the following configuration:

```plain
Port 1337
```

Then, restart the SSH daemon.

As we can see, the SSH daemon is now listening on port `1337`. To confirm this, you can use the `netstat` command.

```bash
netstat -plnt
```

Finally, always test again to ensure that your server can be accessed.

## Using Public and Private Keys

1. First, create a _keypair_ for SSH client and SSH server using `ssh-keygen`.

```bash
ssh-keygen -b 4048 -f oldServer-169-245 -t rsa -C "ditatompel@oldServer-169-245"
```

This will generate two files: `oldServer-169-245` (private key) and `oldServer-169-245.pub` (public key). The former is our private key, while the latter is our public key that we'll place on our server.

2. Move these two files to the `~/.ssh` directory and change their permissions to `600`.

```bash
mv oldServer-169-245 oldServer-169-245.pub ~/.ssh/
find ~/.ssh/ -type f -exec chmod 600 {} +
```

![SSH-keygen](sshkeygen.jpg#center)

3. On the server, create a hidden directory `.ssh` in the user's home directory (`ditatompel`) and change its permissions to `700`.

```bash
mkdir ~/.ssh; chmod 700 ~/.ssh
```

4. Copy our public key to the remote PC (_SSH Server_) with the name `authorized_keys` and file permission `600`. (You can use `sftp` or `scp` to copy the file):

Example:

```bash
cd ~/.ssh
sftp -P 1337 ditatompel@202.150.169.245
```

```plain
sftp> put oldServer-169-245.pub /home/ditatompel/.ssh/authorized_keys
sftp> chmod 600 /home/ditatompel/.ssh/authorized_keys
```

![SFTP](sftp.png#center)

5. After that, edit the file `/etc/ssh/sshd_config` and add/configure the following to prevent users from accessing shells even if they know the password, and force them to use private keys:

```plain
PasswordAuthentication no
```

6. Restart SSH _daemon_ and try again with the command:

```bash
ssh -i ~/.ssh/oldServer-169-245 -p 1337 ditatompel@202.150.169.245
```

![SSH pass](ssh-pass.png#center)

## Managing Server Using FISH Protocol

This is my favorite part, and I think there might be some people who don't know about it yet.

**FISH** (_Files transferred over Shell protocol_) is a network protocol that uses **Secure Shell (SSH)** or **Remote Shell (RSH)** to transfer files between computers. We use **Dolphin**, which is already built-in with **KDE**. In addition to Dolphin, KDE users can also use `Konqueror` for the FISH protocol. For Gnome users, you can also use `Nautilus` with a third-party plugin.

To do this, simply click on the breadcrumb navigation directory and type `{protocol}{user}@{server}:{port}/{directory}` and press Enter.

Example :

```plain
fish://ditatompel@202.150.169.245:1337/var/www/path/to/directory/you/want/to/access/
```

![Fish protocol](fish.png#center)

After that, we will be prompted to enter our SSH password. However, there is a problem that FISH protocol on Dolphin/Konqueror does not know whether we are using public and private keys to access the server.

So, we can take advantage of the **ssh config** feature (located in `~/.ssh/config` for per-user configuration or `/etc/ssh/sshd_config` for system-wide).

For per-user configuration, there is usually no file `~/.ssh/config`, so we need to create it first by adding a configuration `IdentityFile` so that the program knows that we must use our **private key** SSH:

```plain
IdentityFile /home/dit/.ssh/oldServer-169-245
```

What if we have many servers and many private keys for each server? Let's continue reading.

## Configuring ~/.ssh/config

For system administrators responsible for managing numerous servers with diverse login access requirements, recalling port numbers, passwords, users, and so on can be a daunting task. Not to mention keeping track of application access on each server. Therefore, we can utilize the SSH config feature that enables us to access the shell by simply remembering the IP address and passphrase of each server.

Here is an example configuration for multi-server identities:

```plain
Host 202.150.169.245
Hostname 202.150.169.245
        User ditatompel
        Port 1337
        IdentityFile /home/dit/.ssh/oldServer-169-245

Host xxx.xx.xx.xxx
HostName xxx.xx.xx.xxx
        User ditakeren
        Port 12345
        IdentityFile /home/dit/.ssh/blahblah1

Host xxx.xxx.xxx.xx
Hostname xxx.xxx.xxx.xx
        User ditacakep
        Port 23213
        IdentityFile /home/dit/.ssh/blahblah2

# dan seterusnya
```

![~/.ssh/config](ssh-config.png#center)

With this, we can use the SSH command with:

```bash
ssh 202.150.169.245
```

or by adding it to a network directory by accessing **Network** > **Add Network directory**, and filling in the necessary remote PC (SSH server) information.

![Fish Protocol](fish-protocol1.png#center)

That's all from me for now; please feel free to add or correct as you see fit, I would greatly appreciate it.

References:

- [http://linux.die.net/man/5/ssh_config](http://linux.die.net/man/5/ssh_config).
- [http://kb.mediatemple.net/questions/1625/Using+an+SSH+Config+File](http://kb.mediatemple.net/questions/1625/Using+an+SSH+Config+File).
