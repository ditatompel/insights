---
title: "Monero Timeline (Cypherpunks, Bitcoin, Bytecoin, and BitMonero) (draft)"
url: "blog/2021/09/monero-timeline"
description: "The origin of Monero (timeline, notable event, moment and incident). Note: This article is not done yet, working on progress"
date: 2021-09-09T22:11:11+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - TIL
tags:
  - Monero
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

The origin of Monero (timeline, notable event, moment and incident). Note: This article is not done yet, working on progress.

<!--more-->

## 1980s
In October 10, 1985 **David Chaum** wrote extensively on topics such as anonymous digital cash and pseudonymous reputation systems, which he described in his paper ["Security without Identification: Transaction Systems to Make Big Brother Obsolete"](https://www.chaum.com/publications/Security_Wthout_Identification.html).

## 1992s
In late 1992, **Eric Hughes**, **Timothy C May**, and J**ohn Gilmore** founded a small group. At one of the first meetings, **Jude Milhon** (a hacker and author better known by her pseudonym **St. Jude**) described the group as the **“Cypherpunks”**.

The Cypherpunks mailing list was formed at about the same time, and just a few months later, Eric Hughes published ["A Cypherpunk's Manifesto"](https://www.activism.net/cypherpunk/manifesto.html) (March 9, 1993).

> _"Privacy is necessary for an open society in the electronic age. Privacy is not secrecy.  A private matter is something one doesn't want the whole world to know, but a secret matter is something one doesn't want anybody to know. Privacy is the power to selectively reveal oneself to the world."_

> _"Since we desire privacy, we must ensure that each party to a transaction have knowledge **only of that which is directly necessary for that transaction**."_

## 1997
[Adam Back](http://www.cypherspace.org/adam/) created [Hashcash](http://www.hashcash.org/), which was designed as an anti-spam mechanism that would add time and computational cost to sending email, thus making spam uneconomical.

## 1998
[Wei Dai](https://en.wikipedia.org/wiki/Wei_Dai) published a proposal for "b-money", a practical way to enforce contractual agreements between anonymous parties.

## 2004
[Hal Finney](https://en.wikipedia.org/wiki/Hal_Finney_(computer_scientist)) (deceased) (the first Bitcoin recipient) created reusable proof of work (RPOW), which built on **Adam Back** Hashcash.

Finney was a Cypherpunks and said :
> _It seemed so obvious to me: "Here we are faced with the problems of loss of privacy, creeping computerization, massive databases, more centralization - and **[David] Chaum** offers a completely different direction to go in, one which puts power into the hands of individuals rather than governments and corporations. The computer can be used as a tool to liberate and protect people, rather than to control them."_

## 2005
[Nick Szabo](https://en.wikipedia.org/wiki/Nick_Szabo) inventor of smart contracts, a precursor to Bitcoin published a proposal for **"bit gold"** in 2005 – a digital collectible that built upon **Finney's** RPOW proposal.

## 2008
In October 31, 2008 [Satoshi Nakamoto](https://en.wikipedia.org/wiki/Satoshi_Nakamoto), a pseudonym for a still-unidentified individual or individuals, published the [Bitcoin whitepaper](https://bitcoin.org/bitcoin.pdf), citing both **hashcash** and **b-money**. Satoshi emailed **Wei Dai** directly and mentioned that he learned about b-money from **Adam Back**.

## 2009
- In January 2009, [first Bitcoin block](https://www.blockchain.com/btc/block/000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f) was mined by Satoshi earned a total reward of 50 BTC.
- Jan 21, 2009 **Hal Finney**, [tweets](https://twitter.com/halfin/status/1136749815) **"Looking at ways to add more anonymity to bitcoin"**. Just 18 days after Bitcoin had begun.

## 2010
- August 13, 2010 Satoshi [discusses](https://bitcointalk.org/index.php?topic=770.msg9074#msg9074) something about *"Ring Signatures"* & *"Stealth Addresses"*. These became 2 of the 3 key pillars for privacy on Monero. See [u/binaryFate](https://www.reddit.com/user/binaryFate/) tweet about the forum post [here](https://twitter.com/binaryFate/status/1215265006146719746).

## 2014
**Nicolas van Saberhagen's** [Cryptonote Whitepaper](https://cryptonote.org/whitepaper.pdf) aims to solve specific problems identified on the Bitcoin protocol. It included "untraceable transactions" through ring signatures, an ASIC resistant mining algorithm and a smooth emission curve.

The release date is [controversial](https://bitcointalk.org/index.php?topic=740112.0) that the author(s) faked the release date, and it was really released in March 2014, not in 2012 and 2013.

- March 3, 2014 **Bytecoin** launches, and is the first coin to implement the Cryptonote protocol - see Github [commit](https://github.com/amjuarez/bytecoin/commit/296ae46ed8f8f6e5f986f978febad302e3df231a). Unfortunately it had at least 1 large flaw - [82% of the coins were already mined](https://bitcointalk.org/index.php?topic=512747.msg6043629#msg6043629) before its "public" release.
- April 09, 2014, **Bitmonero** launches without Bytecoin's pre-mine.
User named **thankful_for_today** create a post [Bitmonero - a new coin based on CryptoNote technology](https://bitcointalk.org/index.php?topic=563821.msg6146656#msg6146656). [[Archive](https://web.archive.org/web/20140510175315/https://bitcointalk.org/index.php?topic=563821.0)]
- April 25, 2014, **BitMonero is forked away** from thankful_for_today, **after he failed to collaborate with the community**, and is renamed to **Monero**. Read full BitcoinTalk [thread](https://bitcointalk.org/index.php?topic=563821.msg6146656#msg6146656) if you want to know what was happened.
- Apr 30, 2014, The first exchange for cryptonote based coins is created (cryptonote.exchange.to), and Monero is listed with ticker name **MRO** at that time. [[Archive](https://web.archive.org/web/20160323204020/https://forum.cryptonote.org/viewtopic.php?f=6&t=162)]
- May 21, 2014, first recorded Monero price from Kraken with close price : $1.72
- [June 02, 2014](https://bitcointalk.org/index.php?topic=583449.msg7098497#msg7098497) New Logo & Change ticket Symbol **from MRO to XMR** (in order to maintain ISO 4217 which MRO is code for Mauritania's currency). According to 1st Monero Missive, Monero core team (in no particular order) - **tacotime**, **eizh**, **smooth**, **fluffypony**, **othe**, **davidlatapie**, **NoodleDoodle**.
> _In order to maintain ISO 4217 compliance, we are changing our ticker symbol from MRO to XMR effective immediately. This change primarily effects exchanges at this early stage, as we are sure that MRO will continue to be used colloquially and in general discussion. We are aware that this may cause a little confusion, but we feel it necessary to make this change early on rather than later when Monero is more widely spread._
- [June 10, 2014](https://bitcointalk.org/index.php?topic=583449.msg7241339#msg7241339), Mnemonic Seeds Added   
A feature we all take for granted now, mnemonic seeds, wasn't present in the first cryptonote implementations. Until added, you had to back up the inidividual keys. [[Archive](https://web.archive.org/web/20201024092322/https://forum.cryptonote.org/viewtopic.php?f=6&t=162&start=10)]
- [June 18, 2014](https://bitcointalk.org/index.php?topic=583449.msg7386715#msg7386715), Begin peer review cryptonote whitepaper from highly qualified academics in the fields of mathematics and cryptography.   
    - Moneromooo's first BitcoinTalk Post   
    Prolific Monero developer Moneromooo makes his [first post](https://bitcointalk.org/index.php?action=profile%3Bu%3D345026%3Bsa%3DshowPosts%3Bstart%3D1260) on the BitcoinTalk forums about mining Monero and setting up a mining pool from his home connection.
- June 23, 2014 Listed to **MinPal**
- [June 27, 2014](https://bitcointalk.org/index.php?topic=583449.msg7542304#msg7542304), add **AES-NI** support in slow_hash, listed to exchange: **BTer**.
- July 03, 2014 Listed to *HitBTC*
- July 06, 2014 Transaction auto-splitting is now in the main codebase
- [July 13](https://bitcointalk.org/index.php?topic=583449.msg7847156#msg7847156), 2014 Major work has begun on moving to an embedded database.
- [July 20, 2014](https://bitcointalk.org/index.php?topic=583449.msg7944353#msg7944353) Embedded database work in progress the hope is to reduce ram requirements, daemonising Monero work is largely completed, welcoming Pavel Kravchenko as a key technical contributor to Monero. With a PhD in Information Security, specialising in public key infrastructures.
- [July 23, 2014](https://bitcointalk.org/index.php?topic=583449.msg7989030#msg7989030) BSD 3-clause license changes, listed to **Poloenix**
- August 2014, Monero devs plan to moves from storing the blockchain as a flat file in RAM, to the [ACID](https://en.wikipedia.org/wiki/ACID) compliant LMDB database. You can see **Howard Chu** (author of LMDB) answer [Why did Monero choose LMDB over alternative database types?](https://monero.stackexchange.com/questions/702/why-did-monero-choose-lmdb-over-alternative-database-types) along with IRC transcripts from the time the choice of DB was being made.
- [August 03, 2014](https://bitcointalk.org/index.php?topic=583449.msg8195249#msg8195249), XMR pairs rise to 5830 XMR of volume after first 12 days. Monero added to **coinSource** Trust Index with a score of 6 out of 7 stars.
- Many miners start notice that the difficulty is went up to unrealistic value ([posts from BitcoinTalk](https://bitcointalk.org/index.php?topic=583449.msg8249737#msg8249737)). In additional [FUD about "Monero is dead" and P&D on Bittrex](https://bitcointalk.org/index.php?topic=583449.msg8276735#msg8276735) [[Pict](2014-08-10-pnd1.png)] see what fluffypony reply.
- August 09, 2014, **thefunkybits** started a Twitter campaign to mention Monero to major exchanges and news outlets and [he is paying 0.4 XMR per Tweet](https://bitcointalk.org/index.php?topic=731365.0).
- [August 10, 2014](https://bitcointalk.org/index.php?topic=583449.msg8388985#msg8388985), First look at the GUI in the first fireside chat was positively received. CoinGecko release Monero price ticker.
- August 12, 2014, **Atrides**, the admin of **DwarfPool**, [released an open-source Monero stratum proxy](https://bitcointalk.org/index.php?topic=735738.0).
- [August 16, 2014](https://bitcointalk.org/index.php?topic=583449.msg8388993#msg8388993), GUI test release available. Abstraction and refactoring Blockchain functions ready for some performance testing.
- August 23, 2014, [Monero Devs notices that Monero Network is under a spam attack](https://bitcointalk.org/index.php?topic=583449.msg8501165#msg8501165) [[Pict](2014-08-23-monero-spam-attack1.png)] and [respond within minutes](https://bitcointalk.org/index.php?topic=583449.msg8504683#msg8504683) with temporary fix [[Pict](2014-08-23-monerodev-resp-spam-attack2.png)]. See [pull request](https://github.com/monero-project/monero/pull/104) to the repo. [[Summary 1](https://bitcointalk.org/index.php?topic=583449.msg8519146#msg8519146)] [[Summary 2](https://bitcointalk.org/index.php?topic=583449.msg8527258#msg8527258)] [[Summary 3](https://bitcointalk.org/index.php?topic=583449.msg8667761#msg8667761)] [[Summary 4](https://bitcointalk.org/index.php?topic=583449.msg8677607#msg8677607)] [[Summary 5](https://bitcointalk.org/index.php?topic=583449.msg8835838#msg8835838)]
- August 25, 2014, FUD: [Unveiling the truth over the major Monero scam](https://bitcointalk.org/index.php?topic=755840.msg8523601#msg8523601)
- September 01, 2014 FUD: [Is Monero officially dead?](https://bitcointalk.org/index.php?topic=765587.msg8628358#msg8628358)
- September 12, 2014 [MRL-0001](https://www.getmonero.org/resources/research-lab/pubs/MRL-0001.pdf) and [MRL-0002](https://www.getmonero.org/resources/research-lab/pubs/MRL-0002.pdf) published. Emergency release [v0.8.8.3](https://github.com/monero-project/monero/releases/tag/v0.8.8.3) to fix the [block 202612](https://monero.stackexchange.com/questions/421/what-happened-at-block-202612) spam attack.
- [September 15, 2014](https://bitcointalk.org/index.php?topic=583449.msg8835838#msg8835838), Introducing the **Monero Research Lab**, an open collective and a multi-faceted academic group focused on analysis and improvement of the underlying core of Monero to make sure that the theories and cryptography behind Monero continue to remain robust and sound. FreeBSD Compatability: Monero works on FreeBSD out the box. Recovered from a spam attack.
- September 17, 2014, FUD about very specific exploits in CN that have not been fixed that will affect to Monero. [The original post is deleted](https://bitcointalk.org/index.php?topic=786201.0) but you still can read from the quoted replies or from [BCX and Monero - Setting The Record Straight](https://web.archive.org/web/20150930050557/https://bitcointalk.org/index.php?topic=786201.0) archive. [Monero (XMR) - Is It True? video on YouTube by Nemesis Tyrant](https://www.youtube.com/watch?v=2ofpaF5pkE8) show how "they" are FUDing the Monero (from July) in the Poloenix trollbox.
- September 20, 2014, another FUD : [Monero Exploit Confirmed Independently](https://bitcointalk.org/index.php?topic=789978.0) (again, original has post was deleted, but you can see the 1st post from [web archive](https://web.archive.org/web/20140920231925/https://bitcointalk.org/index.php?topic=789978.0)). Reacting with the news, devs keep monitor the network and publish precaution update.

Monero is doomed for over 3 months downtrend from $2 to $0.22. But Monero devs keep going even when [dev funds in a negative balance and covering out with their own pockets](https://bitcointalk.org/index.php?topic=583449.msg8849246#msg8849246).

- September 25, 2014, [MRL-0003 : Monero is Not That Mysterious](https://www.getmonero.org/resources/research-lab/pubs/MRL-0003.pdf) published.
- September 26, 2014, [DDoS attack hit moneropool.com](https://bitcointalk.org/index.php?topic=583449.msg8978116#msg8978116) (largest Monero mining pool at the time).
- [October 06, 2014](https://bitcointalk.org/index.php?topic=583449.msg9109547#msg9109547), New official Monero forum launched. DNS check pointing added. PoW algorithm annotated in the code and documented by **dga**.
- [October 13, 2014](https://bitcointalk.org/index.php?topic=583449.msg9190733#msg9190733), DNS checkpointing is now asynchronous, and doesn't prevent blocks from being received. Mnemonic lists now support a variable trim length (instead of the previous fixed trim length).
- [October 20, 2014](https://bitcointalk.org/index.php?topic=583449.msg9271342#msg9271342), Blockchain database implementation. Lightning Memory-Mapped Database, LMDB ready for limited testing by next week. Implementing DNSSEC trust anchors with the assistance of NLnet Labs.

> **TO BE CONTINUED**

## Sources
- [The Cypherpunks and Bitcoin. The years before bitcointalk](https://bitcointalk.org/index.php?topic=4356808.0)
- [https://www.getmonero.org/resources/roadmap/](https://www.getmonero.org/resources/roadmap/)
- [https://resilience365.com/monero-timeline/](https://resilience365.com/monero-timeline/)
- [Whirlwind missives October 14, 2014](https://bitcointalk.org/index.php?topic=583449.msg9195532#msg9195532), [Whirlwind missives (Updated 09/12)](https://bitcointalk.org/index.php?topic=583449.msg8488694#msg8488694) by [Globb0](https://bitcointalk.org/index.php?action=profile%3Bu%3D244243)
- [What happened at block 202612?](https://monero.stackexchange.com/questions/421/what-happened-at-block-202612)
- [Is It True?](https://www.youtube.com/watch?v=2ofpaF5pkE8)

## Credits
- [https://github.com/monero-project/monero/graphs/contributors](https://github.com/monero-project/monero/graphs/contributors)
- Those in every link I post
- You

