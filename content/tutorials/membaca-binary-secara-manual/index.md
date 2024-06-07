---
title: "Reading Binaries Manually"
description: "How to read a set of numbers 0 and 1 (Binary) into decimal. Then how to use the decimal number to translate it into text (ASCII) using an ASII table"
summary: "How to read a set of numbers 0 and 1 (Binary) into decimal. Then how to use the decimal number to translate it into text (ASCII) using an ASII table"
# linkTitle:
date: 2012-01-08T04:29:52+07:00
lastmod:
draft: false
noindex: false
nav_weight: 1000
series:
categories:
  - TIL
tags:
  - Binary
images:
authors:
  - ditatompel
  - jasmerah1966
---

I'd like to share with you a tutorial on reading binary numbers manually, which can be useful for those interested in computer science. This article is based on information gathered from various sources, including **@Capsoel**'s work in **X-Code Magazine issue 6** and **@ditatompel** from **devilzc0de**.

## What are Binary Numbers?

Binary numbers are a fundamental number system used to represent data as a sequence of 0s and 1s. Each digit represents a **power of 2**, allowing for a very efficient representation of large amounts of information. Binary is widely used in computer science, engineering, and various scientific fields.

At first glance, the series of 0s and 1s below may seem puzzling:

```
01000100011001010111011001101001011011000111101001100011001100000110010001100101
```

However, this is actually a binary code. In this article, we will explore how to read these numbers and translate them into decimal and eventually text (ASCII) using the ASCII table.

## Translating Binary to Decimal

To illustrate the process, let's consider an example:

```
10101
```

Imagine five empty slots (`_ _ _ _ _`) that represent the binary code. To read the binary code, start from **right to left**. Each slot has a specific value:

- Slot 1: 1
- Slot 2: 2
- Slot 3: 4
- Slot 4: 8
- Slot 5: 16
- and so on until the 8th slot.

Assigning a 0 or 1 to each slot determines the value of that slot.

For instance, if the first slot is 0 and the second slot is 1 (`_ _ _ 1 0`), the decimal number would be `2` because:

```plain
0 * 1 = 0
1 * 2 = 2
========= +
        2
```

Another example, if the first slot is 1, the second slot is 0, and the third slot is 1 (`_ _ 1 0 1`), the decimal number would be `5` because:

```plain
1 * 1 = 1
0 * 2 = 0
1 * 4 = 4
========= +
        5
```

## Translating Binary to ASCII

Now let's consider a longer binary code:

```
01000100011001010111011001101001011011000111101001100011001100000110010001100101
```

To translate this into decimal and eventually text, split the binary code into eight-digit groups (octets):

```
01000100 01100101 01110110 01101001 01101100 01111010 01100011 00110000 01100100 01100101
```

Then convert each group to a decimal number:

- `01000100` = 68
- `01100101` = 101
- ...

## Translating Decimal to ASCII

To translate the decimal numbers into text, you can use an ASCII table or a Windows-based application like Notepad. The ASCII table is shown below:

![ASCII table](ascii-table.png#center "ASCII table")

Alternatively, on Windows, hold the `<ALT>` key and press the corresponding decimal number to display the ASCII character. For example:

- `68` = `D`
- `101` = `e`

Try experimenting with different combinations to see how they translate!

I hope this revised article is helpful in understanding how to read binary numbers manually and translating them into text.
