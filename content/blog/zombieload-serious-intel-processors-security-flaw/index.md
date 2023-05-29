---
title: "ZombieLoad: Serious Intel Processors Security Flaw"
description: "ZombieLoad is security flaw in Intel processors that allows malicious hacker to steal any data that’s been recently accessed by the processor."
date: 2019-05-15T01:43:22+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - Security
tags:
  - Intel
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

Security researchers discovered security flaw in Intel processors allows malicious hacker to steal any data that’s been recently accessed by the processor. This security flaws called [ZombieLoad](https://zombieloadattack.com/) and almost every computer with an Intel chips since 2011 ([Ivy Bridge](https://en.wikipedia.org/wiki/Ivy_Bridge_(microarchitecture))) are affected by the vulnerabilities.

<!--more-->

ZombieLoad is the latest of serious security flaws that take advantage of a process, known as **speculative execution**, that's built into most modern processors. The *speculative execution* helps processors predict execute future commands from application or operating system might needed next, making application or operating system run faster and efficient. The processor will execute its predictions.

If the prediction was wrong, the pipeline is flushed, and any speculative results are squashed in the reorder buffer. The process leaves some gaping vulnerabilities for attackers to utilize a *cache-based* covert channel to transmit the secret data observed transiently from the microarchitectural domain to an architectural state.

> _ZombieLoad will leak any data that is recently accessed or accessed in parallel on the same processor core._

Apps are usually only able to see their own data, but **this bug allows that data to bleed across the apps or even isolated virtual machine**. It can be exploited to see which websites a person is visiting in real-time, grab passwords or access tokens used to log into a victim’s online accounts.

## Who Affected to This Bug?
Any PCs, laptops, workstations, cloud computers / servers that use Intel Processor since **Ivy Bridge** chips (2011) may be affected. Security researcher provide [ZombieLoad PoC](https://github.com/IAIK/ZombieLoad) in 2 variants (Linux and Windows) and verify the ZombieLoad attack on Intel processor generations released from 2011 onwards.


| Setup | CPU                 | µ-arch          | Status       |
| ----- | ------------------- | --------------- | ------------ |
| Lab   | Core i7-3630QM      | Ivy Bridge      | Affected     |
| Lab   | Core i7-6700K       | Skylake-S       | Affected     |
| Lab   | Core i5-7300U       | Kaby Lake       | Affected     |
| Lab   | Core i7-7700        | Kaby Lake       | Affected     |
| Lab   | Core i7-8650U       | Kaby Lake-R     | Affected     |
| Lab   | Core i7-8565U       | Whiskey Lake    | Not Affected |
| Lab   | Core i7-8700K       | Coffee Lake-S   | Affected     |
| Lab   | Core i9-9900K       | Coffee Lake-R   | Not Affected |
| Lab   | Xeon E5-1630 v4     | Broadwell-EP    | Affected     |
| Cloud | Xeon E5-2670        | Sandy Bridge-EP | Affected     |
| Cloud | Xeon Gold 5120      | Skylake-SP      | Affected     |
| Cloud | Xeon Platinum 8175M | Skylake-SP      | Affected     |
| Cloud | Xeon Gold 5218      | Cascade Lake-SP | Not Affected |


## Note about the ZombieLoad PoC codes
1. You are responsible for protecting yourself, your property and data, and others from any risks caused by this code. This code may cause unexpected and undesirable behavior to occur on your machine. This code may not detect the vulnerability on your machine.
2. If you find that a computer is susceptible to ZombieLoad, you may want to avoid using it as a multi-user system. ZombieLoad breaches the CPU's memory protection. On a machine that is susceptible to ZombieLoad, one process can potentially read all data used by other processes or by the kernel.
3. The code is only for testing purposes. Do not run it on any productive systems. Do not run it on any system that might be used by another person or entity.

[This video](https://zombieloadattack.com/public/videos/demo_720.mp4) show how malicious user can **monitor the websites** the victim is visiting despite using **the privacy-protecting Tor browser _in a virtual machine_** which are **meant to be isolated** from other virtual systems and their host device. **It can be exploited** to grab passwords or access tokens used to log into a victim’s online accounts.

## Patch, Mitigation Techniques and Performance Degradation Effect
The safest workaround to prevent this attack is **running trusted and untrusted applications on different physical machines**.

Disabling Hyperthreading completely does not close the door on attacks on system call return paths that leak data from *kernel space* to *user space*. In other hand, disabling Hyperthreading is not feasible for performance especially for cloud services / servers.


Fixing those vulnerabilities has required patching processors in ways that can slightly slow them down. But the fixes don’t cut off the attack vector entirely. **Intel has released microcode to patch vulnerable processors**, including Intel Xeon, Intel Broadwell, Sandy Bridge, Skylake and Haswell chips.

### Apple
Apple has released security updates in **macOS Mojave** `10.14.5` to protect against speculative execution vulnerabilities in Intel CPUs. **Most users** (common usage of Mac) **won't experience any reduced in performance** but, testing conducted by Apple in May 2019 showed as much as a **40% reduction in performance for those who opt-in to the [full set of mitigations](https://support.apple.com/en-us/HT210108)** that include multithreaded workloads and public benchmarks. Performance tests are conducted using specific Mac computers. Actual results will vary based on model, configuration, usage, and other factors.

List unsupported Mac Model to the fixes and mitigations due to a lack of microcode updates from Intel [can be found here](https://support.apple.com/en-us/HT210107). On the other hand, iPhones, iPads and Apple Watch devices aren't affected by the bugs.

### Google
Google [confirmed](https://support.google.com/faqs/answer/9330250) release patches Android and update Chrome to mitigate on Intel-based Chrome OS devices, updates are handled by Chrome OS. For Intel-based systems that are not Chrome OS devices, users should contact their device manufacturer for available updates.

Some **GCP** products require user action, see [Google Cloud Platform Products and Services](https://support.google.com/faqs/answer/9330250#Google%20Cloud%20Platform%20Products%20and%20Services). Chrome users should follow guidance from their operating system vendor in relation to MDS mitigation, and ensure they [keep Chrome up to date](https://support.google.com/chrome/answer/95414?co=GENIE.Platform%3DDesktop).

### Microsoft
Microsoft has released patches for its operating system and cloud. Customers may need to obtain directly from their device maker microcode updates for their processor. Microsoft is pushing many of the microcode updates itself through Windows Update, but they are also available [from its website](https://support.microsoft.com/en-us/help/4093836/summary-of-intel-microcode-updates).

According to [**TechCrunch**](https://techcrunch.com/) in a call with Intel, the update would have an impact on processor performance. Most patched consumer devices could take a **3% performance slower**, and as much as **9% in a datacenter environment**. But, it was unlikely to be noticeable in most scenarios.

## Credits
ZombieLoad was **discovered and reported** by [Michael Schwarz](https://misc0110.net/), [Moritz Lipp](https://mlq.xyz/), [Daniel Gruss](https://gruss.cc/) ([Graz University of Technology](https://www.iaik.tugraz.at/)), [Jo Van Bulck](https://twitter.com/jovanbulck) ([imec-DistriNet, KU Leuven](https://distrinet.cs.kuleuven.be/)) and [hmad "Daniel" Moghimi](http://www.moghimi.org/) ([Worcester Polytechnic Institute](https://www.wpi.edu/)) and Scientific analysis **research team** [Julian Stecklina](https://twitter.com/blitzclone) and [Thomas Prescher](https://twitter.com/gonzodaruler) ([Cyberus Technology](https://www.cyberus-technology.de/)).

## References

- [https://zombieloadattack.com/](https://zombieloadattack.com/)
- [https://github.com/IAIK/ZombieLoad](https://github.com/IAIK/ZombieLoad)
- [https://www.cyberus-technology.de/posts/2019-05-14-zombieload.html](https://www.cyberus-technology.de/posts/2019-05-14-zombieload.html)
- [https://techcrunch.com/2019/05/14/intel-chip-flaws-patches-released/](https://techcrunch.com/2019/05/14/intel-chip-flaws-patches-released/)
- [https://www.bbc.com/news/technology-48278400](https://www.bbc.com/news/technology-48278400)
- [https://techcrunch.com/2019/05/14/zombieload-flaw-intel-processors/](https://techcrunch.com/2019/05/14/zombieload-flaw-intel-processors/)
