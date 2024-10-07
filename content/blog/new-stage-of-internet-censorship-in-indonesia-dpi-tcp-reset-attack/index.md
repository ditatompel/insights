---
title: "New Stage of Internet Censorship in Indonesia: DPI & TCP Reset Attack"
description: "Some upstream providers in Indonesia perform TCP Reset Attacks to block access to websites that are considered illegal."
summary: "Some upstream providers in Indonesia perform TCP Reset Attacks to block access to websites that are considered illegal."
date: 2023-06-04T01:19:36+07:00
lastmod:
draft: false
noindex: false
featured: true
pinned: false
# comments: false
series:
#  -
categories:
    - TIL
    - Privacy
tags:
    - MiTM
    - VPN
    - Proxy
    - DNS-over-HTTPS
images:
authors:
    - ditatompel
---

Unlike before that using **DNS filtering**, several _upstreams_ have performed
a **TCP Reset Attack** to block access to websites that are considered illegal.
And why you (especially Indonesian) should care for this mess.

## Background

A few months ago, I started facing problems when trying to access
**reddit.com** from my home connection, even though all devices in my home
network already use **DNS-over-HTTPS (DoH)**. The same thing happened even I
route all my traffic to my server located in **Indonesia Data Center** using
_**VPN** tunnel_.

My browser always shows **_"The connection was reset"_** error message when
I try to access reddit.com. My **libreddit** service that I provided to access
**Reddit** without **NSFW** contents stopped working (Previous server location:
**Indonesia Data Center Duren Tiga** or **IDC-3D**).

After discussing with colleagues and make some observations, I'm sure that I've
become a victim of **TCP reset attack (TCP RST)** and it happened at the
_upstream provider_ / _network checkpoint_ that I used. It seems (in my
personal opinion), my _upstream provider_ is _"forced"_ to carry out this
_"evil"_ activity.

Why do I say _"forced"_? Because most _upstream providers_ are typically
business oriented, and one of their business goals is to get the maximum
profit. Meanwhile, doing **Deep Packet Inspection (DPI)** for large amount of
traffic is not cheap. Just search for the price of **Palo Alto 5200** series,
**Cisco Firepower 9300** series, or **FortiGate 6000** series if you did not
believe in me. That's just hardware costs, not for maintenance costs, and
operational expenses such as training, salaries, and others.

I'm aware that _enterprise firewall_ devices like the ones I mentioned above
must be owned by large ISP companies, especially at _network checkpoints_. But
I'm sure, business people will prefer to save _resources_ and avoid complaints
from their customers (_downstream_) rather than to _deploy_ and _integrate_ DPI
in their network infrastructure they already run.

If the cost of doing **DPI** will be very expensive, is it possible that the
**TCP-RST attack** is implemented at every _checkpoint_ on a national scale? It
is just impossible, right? _Hold my beer_, read how _"rich"_ our country is to
buy and implement such things in [#Privacy](#privacy) section.

## Investigation

I did a very simple investigation to prove whether it was true that **TCP-RST
attack** was automatically performed. There are 2 things that I do:

1. Simply use my browsers _inspect element_ feature (_simple_).
2. Directly check from my server in Indonesia and do network capture using
   `tcpdump` (_advanced_).

> _NOTE: From what I have observed, **TCP-RST attack** has not been implemented
> in all *checkpoint* / *upstream*. So there are still many providers who have
> not been affected._

### Using browser's _inspect element_ feature (_simple_)

![Browser error: connection reset](browser-connection-reset.png#center)

The easiest (but less detail) way is to use your browser. When you can't access
reddit.com (or any other government-blocked site) and get
**_"The connection was reset"_** error message; most likely your ISP (or
_upstream_ ISP) already implemented this method.

In a more detailed way, before trying to access reddit.com, _right-click_ on
your browser and look for something like "_inspect_" or "_developer tools_".
Go to the "**Network**" tab and try to access reddit.com. The
"_CONNECTION_RESET_" information message in the _status_ column appears when
the server sends _packet reset_ (**RST**).

### Using `tcpdump` and `curl` (_advanced_)

> In order to understand this method, you need to know **basic concepts of
> TCP/IP** and [**3-Way-Handshake**][3_way_handshake_wiki].

I tried to do a direct investigation from my server which is at **Indonesia
Data Center Duren Tiga**. The method is quite _simple_, by sending **HTTP GET**
using `curl` to reddit.com and do packet capture using `tcpdump` simultaneously.

Below, `151.101.xx.xxx` is one of the reddit.com IPs that I got from **DNS
resolver** when doing testing, and `xxx.xxx.x06.26` is my server public IP.

Sample `curl https://reddit.com -vvv` output:

```plain
*   Trying 151.101.xx.xxx:443...
* TCP_NODELAY set
* Connected to reddit.com (151.101.xx.xxx) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* OpenSSL SSL_connect: Connection reset by peer in connection to reddit.com:443
* Closing connection 0
curl: (35) OpenSSL SSL_connect: Connection reset by peer in connection to reddit.com:443
```

sample `tcpdump -i ens18 dst 151.101.xx.xxx or src 151.101.xx.xxx -Nnn` output:

```plain
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ens18, link-type EN10MB (Ethernet), capture size 262144 bytes
00:54:25.646807 IP xxx.xxx.x06.26.43020 > 151.101.xx.xxx.443: Flags [S], seq 1624542501, win 64240, options [mss 1460,sackOK,TS val 3865742701 ecr 0,nop,wscale 7], length 0
00:54:25.659369 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [S.], seq 2720903651, ack 1624542502, win 65535, options [mss 1460,sackOK,TS val 1136396143 ecr 3865742701,nop,wscale 9], length 0
00:54:25.659407 IP xxx.xxx.x06.26.43020 > 151.101.xx.xxx.443: Flags [.], ack 1, win 502, options [nop,nop,TS val 3865742714 ecr 1136396143], length 0
00:54:25.666249 IP xxx.xxx.x06.26.43020 > 151.101.xx.xxx.443: Flags [P.], seq 1:518, ack 1, win 502, options [nop,nop,TS val 3865742721 ecr 1136396143], length 517
00:54:25.666843 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [R.], seq 1, ack 518, win 16, length 0
00:54:25.666850 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [R.], seq 1, ack 518, win 16, length 0
00:54:25.666931 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [R.], seq 1, ack 518, win 16, length 0
00:54:25.678672 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [.], ack 518, win 285, options [nop,nop,TS val 1136396162 ecr 3865742721], length 0
00:54:25.678708 IP xxx.xxx.x06.26.43020 > 151.101.xx.xxx.443: Flags [R], seq 1624543019, win 0, length 0
00:54:25.683731 IP 151.101.xx.xxx.443 > xxx.xxx.x06.26.43020: Flags [P.], seq 1:3717, ack 518, win 285, options [nop,nop,TS val 1136396167 ecr 3865742721], length 3716
00:54:25.683753 IP xxx.xxx.x06.26.43020 > 151.101.xx.xxx.443: Flags [R], seq 1624543019, win 0, length 0
```

**Note from the `tcpdump` _flag_ result above**:

| TCP Flag  | tcpdump flag | Description          |
| --------- | ------------ | -------------------- |
| `SYN`     | `S`          | Connection start     |
| `FIN`     | `F`          | Connection end       |
| **`RST`** | **`R`**      | **Connection reset** |
| `PUSH`    | `P`          | Data _push_          |
| `ACK`     | `.`          | _Acknowledgment_     |

> _\* Flag may be combined, for example `[s.]` is `SYN-ACK` packet._

![TCP-RST attack](tcp-rst-attack.png#center)

It is clear that after _handshakes_ and first _data packet_ was sent from my
server, I immediately receive a `RST` (_reset_) _flag_.

## Why you should care?

Even though it is not (yet) in the same class as [The Great Firewall of China
(GFW)][gfw_wiki], the indications _going to be there_ are very high. The
previous method were just **DNS spoofing**, **DNS Filtering** and **DNS
Redirect**; but now using _Deep Packet Inspection_ and _TCP reset attack_ which
impossible for majority _non-tech_ people in Indonesia to _bypass_.

[Quoted from Wikipedia][dpi_id_wiki], the Indonesian government through
**Telkom Indonesia** (government-owned ISP) supported by **Cisco Meraki**
**DPI** technology perform country-wide surveillance by the way of _Deep Packet
Inspection_ and _map_ National Identity Number (**NIK**) of its citizens that
registered to the state-owned ISP.

The purpose of **Deep Packet Inspection (DPI)** includes _filtering_
pornographic content, hate speech and reducing tension (for example in Papua
2019). Indonesian government also plans to
[scale up the surveillance](wikipedia-dpi-indonesia.png#center) to the next
level until 2030.

### Increasingly limited access to information

In the future, obtaining information that is considered _"forbidden"_ by the
government will be very difficult. Want to see and try the real examples by
yourself? Try using a search engine from China called [Baidu][baidu_web] and
do a search with **"Tiananmen Square"** keyword. Compare search results from
**Baidu** with other search engines results.

I've experienced it myself, although it's not like and as bad as in China, but
it's very inconvenient and annoying. For example, when I try to search
something related to **IT** problems, Reddit discussion usually appears on
search engine results, the solution was there (or at least, link to the
solution was there). But to access it, I have to route all my laptop internet
traffic to my VPN server (outside Indonesia) first before entering the reddit
link page of the search results.

### Damage to human rights and democratic values

Restrictions on digital rights can undermine human rights and reduce democratic
values. For example, at the beginning of 2021, residents of **desa Wadas** who
had rejected the Andesite stone mining project (for the purposes of the
**Bendungan Bener** project). Over the next few months, residents of _desa
Wadas_ are still launched a series of protests and using social media as online
mobilization tools and raise awareness. However, their internet connectivity
was (believed to be) restricted by the authorities in response to citizen
protests in February 2022.

_Wadas_ protesters reported difficulty accessing their Twitter accounts that
same week, though it remains unclear how authorities limiting their access to
their own Twitter accounts. Read more complete article from **DetikX**:
"[_Derasnya Penindasan Hak Digital di Wadas_][detik_1]" written in Bahasa
Indonesia.

### _Chilling Effect_ and the death of freedom of expression

[_Chilling Effect_][chilling_effect_wiki] is a concept of public fear that
arises due to ambiguous laws or regulations (_EHEMMMMM… [UUITE][ite_law_wiki].
Ehemmmm… Sorry for coughing suddenly_). In Indonesia _chilling effect_ usually
is related defamation or hate speech (_Ehemmm… sorry cough again…_).

During 2018, [police arrested 122 people for hate speech on social
media][kompas_1] (written in Bahasa Indonesia). There are five types of crimes,
ranging from _hoaxes_, fake news, blasphemy, to defamation said
**Brigjen Pol. Rachmad Wibowo** who at that time served as **Direktur Tindak
Pidana Siber Badan Reserse Kriminal Polri** (_Director of cyber crime at the
[Indonesian National Police][indonesian_police_wiki]'s criminal investigation
agency_).

Then in 2021, the _"activation"_ of [**Indonesia Cyber Police**][ugm_1] drive
civils to increasingly practice [self-censorship][self_censorship_wiki],
especially regarding [freedom of speech][freedom_of_speech_wiki]. That
statement was conveyed by the Coordinator of **Komisi untuk Orang Hilang dan
Tindak Kekerasan** (**Kontras**, the _Commission for Missing Persons and Acts
of Violence_), **Fatia Maulidiyanti**.

And in February 2022, the survey results from **Indikator Politik Indonesia**
showed that 62.9% (using the _stratified random_ method out of 1,200
respondents with a _margin of error_ of around 2.9%) respondents agreed and
strongly agreed that [the public is now increasingly afraid of expressing
opinions][tempo_1] (written in Bahasa Indonesia).

> _"If (for example) you get terrible (fake) news, then report it to the
> police, in a few minutes it will be known from whom, where from, then the
> culprit is found and then arrested." — **Mahfud MD**_

### Privacy

Actually, **Deep Packet Inspection** was initially created to measure and
manage network security and protect users and prevent the spread of _malware_.
However, using this technology as a surveillance tool will have a very bad
impact on ~~your~~ our privacy. In addition, DPI can also be used to study the
behavior or _interest_ of an individual or institution from their activities on
the internet which can be used for _targeted (behavioral) marketing_.

Various reports have linked authorities with the purchase and use of _spyware_
and other sophisticated _surveillance_ tools. For example, in 2015,
**Citizen Lab**; a research group based in **Toronto** [alleges that the
Indonesian government use **FinFisher** _spyware_][citizenlab_finfishers] which
collects data such as **Skype** audio, _key log_, and screenshots.

In 2016, [**Joseph Cox**][joseph_cox] [revealed][vice_1] that **International
Mobile Subscriber Identity-catchers** ([**IMSI-catchers**][imsi_catcher_wiki])
was sold to Indonesia from Switzerland and British companies. **IMSI-catcher**
is a device used to intercept traffic of cellphone networks and track the
location of cellphone users. You could say, it's like a _"fake BTS"_ as an
intermediary between the user's cellphone and the ISP's original BTS.

In December 2021, **Citizen Lab**, stated that there was a high probability
that the Indonesian government had become a **Cytrox** (selling **Predator
Spyware**) customer. In addition, **Citizen Lab** also reported in
December 2020 that Indonesia is very likely to have purchased technology from
[**Circles**][dimse_circles], a company that sells exploits of global cellular
systems who later joined the [NSO group][nsogroup_web]. The method used by
**Citizen Lab** to find out their report is by doing _scanning & signature
fingerprinting_ of _firewall checkpoint_ on **Circles** devices through
[Shodan][shodan] service.

### Economic impact

So far (from what I have observed), **TCP-RST attack** implementations still only exist in several _upstream providers / checkpoints_. However, if this continues to be carried out and implemented in all _checkpoints_ that leaving Indonesia (_outbound traffic_), then it will definitely have an impact on buying interest for _Cloud Provider_ / _Datacenter_ located in Indonesia.

Who wants their _microservices_ suddenly stopped working because of this **TCP-RST attack**? I started moving my VPSes somewhere outside Indonesia, because in my opinion, server / cloud infrastructures should not be (suddenly) restricted (without prior notification) to access public data or APIs.

![Moving to AWS](moving-to-aws.png#center)

## Evading censorship

To _bypass_ **DNS** based censorship such as **DNS spoofing**,
**DNS filtering** and **DNS redirect**; teaching _non-tech_ people to use
**DNS-over-HTTPS (DoH)** is quite easy. But to _bypass_ **DPI** and **TCP RST
attack** would be very difficult and impossible for majority _non-tech_ people
in Indonesia to do.

A few way to avoid censorship is use _network tunnel_ to a _server_ outside
Indonesia, whether it's **VPN** or **SOCKS5 proxy**. Even then, the government
and the ISP you use will still know that you are using a **Proxy** / **VPN**.
The difference is: they only know that you are connecting to VPN / SOCKS5
servers and where the VPN / SOCKS5 server is located. Other than that, they
don't know anything (only you and VPN / Server / Proxy provider know what
service / host you communicate with).

If you are really _concern_ about privacy, choosing a **VPN provider** must
also be done with quite complicated research. Lots of apps on the **App Store**
offer **free VPN**, but most of them end up with selling your data.

And I hope, **QUIC/HTTP3** technology will enter a new chapter soon that
_"may"_ help us mitigate the impact of **TCP RST attack** a bit.

## Sources and references

-   "[Indonesia: Freedom on the Net 2022 Country Report][foh_id_2022]" -
    freedomhouse.org.
-   "[State of Privacy Indonesia][privacyinternational_id]" -
    privacyinternational.org.
-   NetBlocks. 2019b: "[Internet disrupted in Papua, Indonesia amid protests
    and calls for independence][netblocks_2019b]" - netblocks.org.
-   Thompson, Nik; McGill, Tanya; and Vero Khristianto, Daniel, "[Public
    Acceptance of Internet Censorship in Indonesia][aisanet_1]" (2021). ACIS
    2021 Proceedings. 22.
-   Wildana, F. (2021) "[An Explorative Study on Social Media Blocking in
    Indonesia][unesa_journal_1]", The Journal of Society and Media, 5(2),
    pp. 456–484. doi: 10.26740/jsm.v5n2.p456-484.
-   Paterson, Thomas (4 May 2019). "[Indonesian cyberspace expansion: a
    double-edged sword][doi_1]". _Journal of Cyber Policy_. 4 (2): 216–234.
    doi:10.1080/23738871.2019.1627476. ISSN 2373-8871. S2CID 197825581.
-   Bill Marczak, John Scott-Railton, Bahr Abdul Razzak, Noura Al-Jizawi,
    Siena Anstis, Kristin Berdan, and Ron Deibert, "[Pegasus vs. Predator:
    Dissident’s Doubly-Infected iPhone Reveals Cytrox Mercenary
    Spyware][citizenlab_cytrox]" - citizenlab.ca.
-   Bill Marczak, John Scott-Railton, Siddharth Prakash Rao, Siena Anstis, and
    Ron Deibert, "[Running in Circles Uncovering the Clients of Cyberespionage
    Firm Circles][citizenlab_circles]" - citizenlab.ca.
-   Bill Marczak, John Scott-Railton, Adam Senft, Irene Poetranto, and
    Sarah McKune, "[Pay No Attention to the Server Behind the
    Proxy][citizenlab_finfishers]", Mapping FinFisher’s Continuing
    Proliferation - citizenlab.ca.
-   Joseph Cox, "[British Companies Are Selling Advanced Spy Tech to
    Authoritarian Regimes][vice_1]" - vice.com.
-   Thomas Brewster, "[A Multimillionaire Surveillance Dealer Steps Out Of The
    Shadows and His $9 Million WhatsApp Hacking Van][forbes_1]" - forbes.com.
-   Moh. Khory Alfarizi, Febriyan, "[Survei Indikator Politik Indonesia:
    62,9 Persen Rakyat Semakin Takut Berpendapat][tempo_1]" - tempo.co.
-   Abba Gabrillin, Krisiandi, "[Selama 2018, Polisi Tangkap 122 Orang Terkait
    Ujaran Kebencian di Medsos][kompas_1]" - kompas.com.
-   Tsarina Maharani, Dani Prabowo "[Kontras: Polisi Siber yang Akan Diaktifkan
    Pemerintah Berpotensi Bungkam Kebebasan Berekspresi][kompas_2]" -
    kompas.com.

[indonesian_police_wiki]: https://en.wikipedia.org/wiki/Indonesian_National_Police "Indonesian National Police"
[3_way_handshake_wiki]: https://en.wikipedia.org/wiki/Handshake_(computing)#TCP_three-way_handshake "TCP three-way handshakewiki"
[ite_law_wiki]: https://en.wikipedia.org/wiki/Internet_censorship_in_Indonesia#ITE_Law "ITE Law"
[ugm_1]: https://cfds.fisipol.ugm.ac.id/2021/02/05/the-existence-of-indonesia-cyber-police-what-does-it-mean-for-us-netizens/ "Indonesia Cyber Police"
[self_censorship_wiki]: https://en.wikipedia.org/wiki/Self-censorship "Self Censorship Wiki"
[freedom_of_speech_wiki]: https://en.wikipedia.org/wiki/Freedom_of_speech "Freedom of Speech Wiki"
[gfw_wiki]: https://en.wikipedia.org/wiki/Great_Firewall "The Great Firewall of China (GFW)"
[dpi_id_wiki]: https://en.wikipedia.org/wiki/Deep_packet_inspection#Indonesia "Country-wide Surveillance by Indonesian Goverment"
[baidu_web]: https://www.baidu.com/ "Baidu Website"
[detik_1]: https://news.detik.com/x/detail/investigasi/20220221/Derasnya-Penindasan-Hak-Digital-di-Wadas/ "Derasnya Penindasan Hak Digital di Wadas"
[chilling_effect_wiki]: https://en.wikipedia.org/wiki/Chilling_effect "Chilling Effect"
[kompas_1]: https://nasional.kompas.com/read/2019/02/15/15471281/selama-2018-polisi-tangkap-122-orang-terkait-ujaran-kebencian-di-medsos "Selama 2018, Polisi Tangkap 122 Orang Terkait Ujaran Kebencian di Medsos"
[kompas_2]: https://nasional.kompas.com/read/2020/12/28/14074121/kontras-polisi-siber-yang-akan-diaktifkan-pemerintah-berpotensi-bungkam "Polisi Siber yang Akan Diaktifkan Pemerintah Berpotensi Bungkam Kebebasan Berekspresi"
[tempo_1]: https://nasional.tempo.co/read/1580168/survei-indikator-politik-indonesia-629-persen-rakyat-semakin-takut-berpendapat "Survei Indikator Politik Indonesia: 62,9 Persen Rakyat Semakin Takut Berpendapat"
[citizenlab_finfishers]: https://citizenlab.ca/2015/10/mapping-finfishers-continuing-proliferation/ "Pay No Attention to the Server Behind the Proxy"
[citizenlab_cytrox]: https://citizenlab.ca/2021/12/pegasus-vs-predator-dissidents-doubly-infected-iphone-reveals-cytrox-mercenary-spyware/ "Pegasus vs. Predator: Dissident’s Doubly-Infected iPhone Reveals Cytrox Mercenary Spyware"
[citizenlab_circles]: https://citizenlab.ca/2020/12/running-in-circles-uncovering-the-clients-of-cyberespionage-firm-circles/ "Running in Circles Uncovering the Clients of Cyberespionage Firm Circles"
[joseph_cox]: https://www.vice.com/en/contributor/joseph-cox "Joseph Cox"
[vice_1]: https://www.vice.com/en/article/4xaq4m/the-uk-companies-exporting-interception-tech-around-the-world "British Companies Are Selling Advanced Spy Tech to Authoritarian Regimes"
[imsi_catcher_wiki]: https://en.wikipedia.org/wiki/IMSI-catcher "international mobile subscriber identity-catcher"
[dimse_circles]: https://dimse.info/circles/ "Circles surveillance firm"
[nsogroup_web]: https://www.nsogroup.com/ "NSO Group Website"
[shodan]: https://www.shodan.io/ "Shodan.io Website"
[foh_id_2022]: https://freedomhouse.org/country/indonesia/freedom-net/2022 "Indonesia: Freedom on the Net 2022 Country Report"
[privacyinternational_id]: https://privacyinternational.org/state-privacy/1003/state-privacy-indonesia "State of Privacy Indonesia"
[netblocks_2019b]: https://netblocks.org/reports/internet-disrupted-in-papua-indonesia-amid-mass-protests-and-calls-for-independence-eBOgrDBZ "Internet disrupted in Papua, Indonesia amid protests and calls for independence"
[aisanet_1]: https://aisel.aisnet.org/acis2021/22 "Public Acceptance of Internet Censorship in Indonesia"
[unesa_journal_1]: https://journal.unesa.ac.id/index.php/jsm/article/view/12976 "An Explorative Study on Social Media Blocking in Indonesia"
[doi_1]: https://doi.org/10.1080%2F23738871.2019.1627476 "Indonesian cyberspace expansion: a double-edged sword"
[forbes_1]: https://www.forbes.com/sites/thomasbrewster/2019/08/05/a-multimillionaire-surveillance-dealer-steps-out-of-the-shadows-and-his-9-million-whatsapp-hacking-van/ "A Multimillionaire Surveillance Dealer Steps Out Of The Shadows and His $9 Million WhatsApp Hacking Van"
