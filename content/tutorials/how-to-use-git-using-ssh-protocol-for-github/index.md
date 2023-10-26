---
title: "How To Use Git Using SSH Protocol For GitHub"
description: "How to access your GitHub repositories using SSH protocol. Starting from creating an SSH key pair to adding an SSH public key to your GitHub account."
# linkTitle:
date: 2023-10-26T08:23:15+07:00
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
  - TIL
tags:
  - Git
  - GitHub
  - SSH
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
  - jasmerah1966
  - vie
---

This article may be useful for those of you who want to get started using **Git** and connecting to **GitHub** using the **SSH** protocol. The process starts from creating an **SSH key pair** to adding the **SSH public key** to your GitHub account.

<!--more-->
---

Git is one of the most popular and widely used _version controls_ by software developers around the world. Several _"Cloud" based version controls service build on top of Git_ such as [GitLab](https://about.gitlab.com/), [GitHub](https://github.com/), and [Codeberg](https://codeberg.org/) offer several unique features from each other. However, there is a feature that every provider definitely has, the feature is accessing and Git repositories using the SSH protocol.

The authentication process using the SSH protocol utilizes **SSH public and private keys** so you don't need to provide a _username_ or _personal access token_ every time you want to access or commit to your repository.

In this article, I want to share how to use the SSH protocol as an authentication method for a specific provider: GitHub. But before starting, make sure `git` and `ssh` are installed on your computer and of course you must have an account at GitHub.com.

## Global config
> _**Note**: If you have already setting up your Git global config, you can skip this step._

Run the following command to set your name and email when committing to Git repository:
```shell
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com
```

Change `John Doe` and `johndoe@example.com` with your name and email address.

> _**Note**: Make sure the email address matches with the email address you use at GitHub.com._

## Creting SSH key

When you want to access your private repository or make changes to your GitHub repository using SSH, you need to use an SSH private key for the authentication process. Therefore, create an SSH key pair using the following command:

```shell
mkdir ~/.ssh && chmod 700 ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/github_key -C "SSH key untuk github"
```

The command above will create a `.ssh` folder under your `$HOME` directory, change the directory permission, and put the generated __private key__ in `$HOME/.ssh/github_key` and the __public key__ in `$HOME/.ssh/github_key.pub`. Example of output from the `ssh-keygen` command above:

```plain
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/jasmerah1966/.ssh/github_key
Your public key has been saved in /home/jasmerah1966/.ssh/github_key.pub
The key fingerprint is:
SHA256:dPniZJhVTjmj2gOi5Q4we8gucBs6b+4fpPJ6J2xnj7Q SSH key untuk github
The key's randomart image is:
+--[ED25519 256]--+
|            o.   |
|           =+    |
|        . +..o   |
|  o   o..=..     |
| . =.+ .S++ .    |
|. *o+ . .+o.     |
|o=.+oo    ..     |
|+oO.++.          |
|.@=*E..          |
+----[SHA256]-----+
```

> _**Note**: You will be asked to enter a `passphrase` during the SSH key pair generation process above. It's up to you whether you want to fill or leave your SSH key passphrase empty. If you fill in a passphrase, you will be asked to provide the passphrase when you use the SSH key._

## Using SSH config file

Many tutorials out there use `ssh-agent` as their _SSH key manager_. However, I prefer the trick used by @ditatompel by taking advantage of [using the SSH Config File]({{< ref "/tutorials/automate-cyberpanel-git-push-without-git-manager/index.md#make-use-of-ssh-config-file" >}}) feature.

Add (or create if the file doesn't already exist) the following lines to the SSH config file in `~/.ssh/config`:

```plain
# ~/.ssh/config file
# ...

Host github.com
    User git
    PubkeyAuthentication yes
    IdentityFile ~/.ssh/github_key

# ...
```

Make sure the `IdentityFile` refers to the SSH private key that you created before (example if you follow this article it is `~/.ssh/github_key`).

## Adding your SSH public key to your GitHub account

Once you have your SSH key pair and SSH config file configured, it's time to add your SSH **public key** to your GitHub account.

1. Go to __"Settings"__ > __"SSH and GPG keys"__ > click on __"New SSH key"__ button.
2. Fill __"Title"__ with anything that you can easily remember to identify your SSH key.
3. On __"Key type"__ options, choose __"Authentication Key"__.
4. Finally, go back to your terminal and _paste_ content of your __SSH public key__ (in this tutorial is `~/.ssh/github_key.pub`) to __"Key"__ _textarea_. Then submit by pressing __Add SSH key"__ button.

![Adding new SSH key to GitHub account](github-add-new-ssh-key.jpg#center)

The configuration process is complete and you can try connecting to GitHub with `ssh -T github.com` command from your terminal. You should receive a message that your connection to GitHub was successful: "**Hi jasmerah1966! You've successfully authenticated, but GitHub does not provide shell access**.".

Next: Read [How To Create Verified Sign Git Commit Using SSH or GPG Signature]({{< ref "/tutorials/how-to-create-verified-sign-git-commit/index.md" >}}).
