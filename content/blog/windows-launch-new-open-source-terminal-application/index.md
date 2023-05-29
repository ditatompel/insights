---
title: "Windows launch New Open-source Terminal Application"
description: "Windows launch is a new terminal application for command-line users with features like tabs &amp; theming. As of today, the Windows Terminal &amp; Windows Console is open source."
date: 2019-05-08T01:27:44+07:00
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
  - Windows
  - CLI
  - Open Source
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

On May 2019, **Windows** launch is a new *terminal* application for *command-line* users. It includes many of the features like **Unix**/**Unix-like** terminal apps such as tabs, rich text, theming & styling, and more. As of today, the Windows Terminal and Windows Console have been made [open source](https://github.com/Microsoft/Terminal)!

<!--more-->

According to [Kayla Cinnamon](https://devblogs.microsoft.com/commandline/author/cinnamonmicrosoft-com/), Windows Terminal will be delivered via the **Microsoft Store** in **Windows 10** and will be updated regularly, ensuring their users are always up to date and able to enjoy the newest features and latest improvements with minimum effort.

{{< youtube 8gw0rXPMMPE >}}

The Windows Terminal is in the very early alpha stage, and not ready for the general public, so there are no *binaries* to download quite yet. If you want to jump in early, you can [try building Windows Terminal yourself from source](https://github.com/Microsoft/Terminal#building-the-code).

## Windows Terminal Features

### Multiple tabs
You will now be able to open any number of tabs, each connected to a *command-line shell* or app of your choice, e.g. Command Prompt, PowerShell, Ubuntu on WSL, a Raspberry Pi via SSH, etc.

### Eye-catching Text
The Windows Terminal uses a **GPU** accelerated **DirectWrite**/**DirectX-based** text rendering engine. This new text rendering engine will display text characters, *glyphs*, and *symbols* present within fonts on user PC, including CJK ideograms, emoji, powerline symbols, icons, programming ligatures, etc. This engine also renders text much faster than the previous Console’s *GDI engine*.

![Windows Terminal Emoji](windows-terminal-emojis.png#center)

### Settings and configurability
Windows Terminal provides many settings and configuration options to control over the Terminal’s appearance. Settings are stored in a structured text file making it easy for users and/or tools to configure. These *profiles configuration* can have their own combination of font styles and sizes, color themes, background blur/transparency levels, etc. User can also create their own custom-styled Terminal like another Unix & Unix like operation system.

## Going Open Source
Microsoft devs announce that they are open sourcing not just Windows Terminal, but also the Windows Console which hosts the command-line infrastructure in Windows and provides the traditional Console UX.

By creating a new *open-source* terminal application, and open-sourcing Windows Console, Microsoft invite the community to collaborate to improve the code and leveraging it in their respective projects. If you like to get involved, visit the repo at [https://github.com/Microsoft/Terminal](https://github.com/Microsoft/Terminal) to clone, build, test, and run the Terminal.

## Sources
- [https://devblogs.microsoft.com/commandline/introducing-windows-terminal/](https://devblogs.microsoft.com/commandline/introducing-windows-terminal/)
- [https://github.com/Microsoft/Terminal](https://github.com/Microsoft/Terminal)
