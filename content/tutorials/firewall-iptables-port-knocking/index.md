---
title: "Implementing Firewall Protection via Iptables Port Knocking"
description: "Strengthening server security by leveraging port knocking techniques in conjunction with iptables firewall functionality."
summary: "Strengthening server security by leveraging port knocking techniques in conjunction with iptables firewall functionality."
date: 2013-07-01T22:16:19+07:00
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
  - iptables
  - Port Knocking
  - Linux
images:
authors:
  - ditatompel
---

This time, I'd like to share some tips on how to enhance server security by utilizing the technique of _port knocking_. Port knocking is a method for opening a specific port by sending packets to predetermined ports beforehand.

> _Q: What's the purpose?_

A: The objective is to thwart attacks from penetration testers who conduct port scanning to identify services that might be exploitable by them. If the penetration tester fails to knock on the previously designated ports in sequence, the protected port will remain inaccessible.

> _Q: Can you elaborate?_

A: For instance, suppose we have an SSH service listening on port 22, while the penetration tester has a 0-day remote root exploit for OpenSSH. Therefore, our server's security is at risk due to the open port 22. By employing the technique of port knocking, only those who know which ports to "hit" first can
unlock and access port 22.

To clarify, I'll provide an example from my previous thread about **Lawang Sewu CTF** (`http://devilzc0de.org/forum/thread-20071.html`). The second challenge involves port knocking.

This port knocking technique can be configured using the iptables firewall, which is typically already possessed by the Linux kernel on most Linux distributions.

On this occasion, I'll share how to configure port knocking with iptables.

> **Disclaimer**: By following this tutorial, the author have no responsibility for any errors or loss of remote access to the server.

VIDEO TUTORIAL : [http://youtu.be/0zFQocf7C_0](http://youtu.be/0zFQocf7C_0).

What you need for this tutorial:

- Server & Client with Linux OS (in this tutorial, I'm using CentOS)
- `iptables` (server firewall)
- `nmap` (for scanning and knocking ports from the client)
- Basic knowledge of `iptables`

**Case Study:**

I have a server with IP address `192.168.0.100`, and I'm using SSH for remote management of that server. The default SSH port for remote access is `22`. I want to close port `22` and only make it available when needed.

This is where we use the technique of port knocking, which I've already set up so that users need to send a TCP packet to, for example, ports `1111`, then `2222`, then `3333`, and finally `4444` before port `22` (SSH) becomes accessible.

- Server IP: `192.168.0.100`.
- OS: **CentOS**.
- SSH Port: `22`.
- **Port Knocking** Scheme: TCP packet to ports `1111` => `2222` => `3333` => `4444` => Port `22` becomes accessible.

By default, the CentOS server's firewall has already opened port 22 for SSH.

![Port 22 open](pk-01.png#center)

So we need to reconfigure the `iptables` firewall. We can use the command `iptables-save > iptables.rules` to perform a dump/back up of the firewall rules.

Let's take a look at the new firewall configuration that we just dumped, which is roughly as follows (for CentOS):

```plain
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
```

![iptables dump config](pk-02.png#center)

Note the following firewall rules:

```plain
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
```

It appears that `iptables` allows access through port 22.

Let's create an `iptables` rule according to our wishes in this case study, namely we want to close port `22` and only make it accessible when ports `1111`, `2222`, `3333`, and `4444` receive a sequential TCP packet.

Copy the previous `iptables.rules` file to `iptables-new.rules`, then edit:

```bash
cp iptables.rules iptables-new.rules
vi iptables-new.rules
```

and edit it as shown below:

![iptables port knocking rules](pk-03.png#center)

In other words, I opened port `80`, then added a new firewall rule that dynamically opens port `22` for 15 seconds if ports `1111`, `2222`, `3333`, and `4444` receive sequential TCP packets within a 5-second timeframe.

After it's deemed okay, we restore the new firewall configuration using `iptables-restore`, then restart the iptables service.

```bash
iptables-restore < iptables-new.rules
service iptables save
service iptables restart
```

Then, to ensure the new rules are running, use the command:

```bash
iptables -L -n
```

![iptables rules list](pk-04.png#center)

Now that's done, let's try checking port `22` on our server from our computer using `nmap`, and it will show that the port is closed by the firewall.

```bash
nmap -Pn 192.168.0.100 -p22
```

![nmap port 22](pk-05.png#center)

After that, we'll create a simple bash script to perform port knocking.

```bash
#!/bin/bash
HOST=$1
shift
for ARG in "$@"
do
    nmap -PN --host_timeout 201 --max-retries 0 -p $ARG $HOST
done
```

Save it as `knock.sh` and then run `chmod +x` so that the script can be executed.

Usage:

```bash
# ./knock.sh [ip server] [list port]
# Example:
./knock.sh 192.168.0.100 1111 2222 3333 4444
```

By knocking on ports `1111`, `2222`, `3333`, and `4444` in sequence, the port `22` we specified in the firewall rules will become accessible. This way, you can establish an SSH connection to the server.

![nmap port knocking](pk-06.png#center)

That's it for this port knocking tutorial.

Feel free to develop it further on your own with creativity, using a combination of protocols such as **TCP**, **UDP**, or even **ICMP**.

Reference:

- [http://en.wikipedia.org/wiki/Port_knocking](http://en.wikipedia.org/wiki/Port_knocking)
- [http://www.faqs.org/docs/iptables/index.html](http://www.faqs.org/docs/iptables/index.html)
- [https://wiki.archlinux.org/index.php/Port_Knocking](https://wiki.archlinux.org/index.php/Port_Knocking)
- Additional resource by **@od3yz**: [http://www.overflow.web.id/source/Metode-Port-Knocking-dengan-Iptables.pdf](http://www.overflow.web.id/source/Metode-Port-Knocking-dengan-Iptables.pdf)
