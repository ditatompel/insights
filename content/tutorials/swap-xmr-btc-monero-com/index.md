---
title: "Using Monero.com To Exchange Monero XMR to IDR (Indonesia Rupiah)"
description: This article provides a step-by-step guide on how to use the Monero.com website to exchange XMR for BTC and then sell it to Rupiah via Indodax.
summary: This article provides a step-by-step guide on how to use the Monero.com website to exchange XMR for BTC and then sell it to Rupiah via Indodax.
date: 2025-04-14T03:50:00+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
categories:
    - TIL
tags:
    - Monero
images:
authors:
    - ditatompel
---

Since the end of December 2024, all cryptocurrency exchange service providers
in Indonesia have delisted [Monero][get-monero] (**XMR**). For those who
usually cash out Monero (XMR) into IDR (Indonesian Rupiah) through exchanges
such as **Indodax** or **Tokocrypto**, you will have to find another way to
cash out the funds.

Personally, I often use [Feather Wallet][feather-wallet-gh] to make Monero
transactions. Before this delisting, I used to transfer a certain amount of XMR
from my wallet using Feather Wallet to the XMR deposit address at Indodax or
Tokocrypto. After that, I sold it and exchanged the Rupiah.

However, now this method can no longer be used. There are several alternative
methods to exchange Monero into Rupiah:

1. By Cash on Delivery or direct face-to-face exchange,
2. Exchanging Monero into other cryptocurrencies such as Bitcoin, then selling
   it on a cryptocurrency exchange.

{{< youtube Zm8a0AenuV0  >}}

## Exchanging Monero for Bitcoin

To exchange XMR to BTC or other cryptocurrencies, you can use _peer-to-peer_
(P2P) exchanges like [bisq][bisq-web] or [BasicSwap][basicswap-web], or
services that implement _atomic swaps_ like [Majestic Bank][majestic-bank-web]
and [SimpleSwap][simpleswap-web].

### A Glimpse of monero.com by Cake Wallet

Apart from what I mentioned above, there is a service called [Monero.com by
Cake Wallet][monero-com-web]. **Monero.com by Cake Wallet** is a [Monero
Wallet][monero-download-page] maintained by [Cake Labs][cake-labs-web], the
company or team that also developed [Cake Wallet][cake-wallet-web]. However,
it's worth noting that if Cake Wallet supports various crypto wallets,
Monero.com by Cake Wallet is **exclusively** for Monero wallets only.

> **Note**: Monero.com by Cake Wallet **IS NOT** an official site or wallet
> from The Monero Project.

In addition to providing Monero wallets for iOS and Android, monero.com
provides cryptocurrency swap services on their site page. Unlike P2P exchanges,
which require downloading and running software on your computer, web-based
cryptocurrency swaps only require a browser to use them.

### Using the monero.com Web-Based Swap

Now, I want to share how to use the Monero.com website to exchange XMR for BTC
and then sell it to Rupiah via Indodax.

1. Visit the cryptocurrency exchange page at
   [https://monero.com/trade](https://monero.com/trade).
2. Click the **"Swap"** button on the form that appears to show that you will
   exchange a certain amount of XMR for BTC.
   ![swap button](xmr-idr-01.jpg#center)
3. Fill in the form with how much you want to exchange, then press the
   **"Exchange"** button.
4. After that, a modal window will appear with transaction details that you
   need to complete.
   ![details window](xmr-idr-02.jpg#center)
5. Because I am selling the BTC via Indodax, enter the BTC address used to
   deposit BTC into your Indodax account in the **"Recipient Wallet"** field.
   To obtain your BTC address, log in to the Indodax site, from the menu,
   select **"Wallet"** > **"BTC"** > **"Deposit"**. If you are using another
   cryptocurrency exchange, adjust these steps.
6. In the **"Refund Wallet"** section, enter your XMR wallet address. Funds
   will be returned to the Refund Wallet if the transaction is unsuccessful.
   Then, click the **"Exchange"** button.
7. The modal window display will change to show the amount and where the XMR is
   sent. Copy the XMR wallet address that appears, then send funds to that
   address from your _non-custodial wallet_ according to the requested amount.
   ![send funds window](xmr-idr-03.jpg#center)
8. Wait for the swap process to complete, and finally, check whether the fund
   s have been received in your BTC wallet on Indodax.

Keep in mind that the swap process takes quite a long time, and confirmation of
deposit transactions on Indodax can also take around 10-30 minutes.

Once the deposit status changes from **"Pending"** to **"Berhasil"**, you just
need to sell the BTC from the swap you have done, then transfer the proceeds
to your bank account.

![indodax deposit history](xmr-idr-04.jpg#center)

> **Note**: This article is based on my personal experience using Monero.com by
> Cake Wallet. **I do not receive any sponsorship or affiliation** with
> monero.com by Cake Wallet or other parties mentioned above.

Hope this helps!

[get-monero]: https://www.getmonero.org "The Monero Project Official Website"
[feather-wallet-gh]: https://github.com/feather-wallet/feather "Feathet Wallet GitHub Repository"
[bisq-web]: https://bisq.network "bisq Official Website"
[basicswap-web]: https://basicswapdex.com "BasicSwap Official Website"
[xmr-atomic-swap]: https://www.getmonero.org/2021/08/20/atomic-swaps.html "getmonero.org Atomic Swap Article"
[simpleswap-web]: https://simpleswap.io "SimpleSwap Website"
[majestic-bank-web]: https://majesticbank.sc "MajesticBank Website"
[monero-exchanges]: https://www.getmonero.org/community/merchants/ "Monero Merchants and Exchanges"
[monero-com-web]: https://monero.com "Monero.com by Cake Wallet Official Website"
[monero-download-page]: https://www.getmonero.org/downloads/ "Halaman Download Monero Software"
[cake-labs-web]: https://cakelabs.com "Cake Labs Official Website"
[cake-wallet-web]: https://cakewallet.com "Cake Wallet Official Website"
