---
title: "Automate CyberPanel Git push without it's default Git Manager feature"
description: "Alternative way to commit CyberPanel websites changes to GitHub without Git Manager with a little bit better security practice by using GitHub Deploy keys."
# linkTitle:
date: 2023-01-04T05:16:48+07:00
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
  - Self-Hosted
  - SysAdmin
tags:
  - CyberPanel
  - Git
  - Automation
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
  - ditatompel
---

When I tried [CyberPanel's Git Manager](https://community.cyberpanel.net/t/how-to-use-cyberpanel-git-manager-for-complete-automation/30630/1) feature, I ran into some problems. One of them is error that said: **"You are not authorized to access this resource"** (even I following the exact same step of it's official community guide).

<!--more-->

Following official community guide by [giving SSH keys generated by CyberPanel to the main GitHub account](https://community.cyberpanel.net/t/how-to-use-cyberpanel-git-manager-for-complete-automation/30630/1#add-ssh-key-on-github-to-connect-cyberpanel-git-manager-8) also **give access to all repositories** belonging to that GitHub account. **This could be bad** if one day someone is able to put a backdoor / webshell on your webapp. Besides that, the default access to `.git` directory under `public_html` is **not restricted** by **OpenLiteSpeed** nor **CyberPanel**, anyone can see `.git/config` files for that site.

In this article, I like to share alternative way to commit CyberPanel websites changes with a little bit better security practice by using GitHub **Deploy keys** feature for specific repository instead of global SSH access keys to the main account.

I use this method for years under **OpenLiteSpeed** environment. Anyway, it doesn't matter what's your machine environment is, you only need to adapt the method to the system environment.

## Important Notice
1. This guide **doesn't support pull / webhook feature** like the one from official CyberPanel Git Manager does. **It's only commit and push changes to remote git repository**.
2. The git working directory is different from official CyberPanel Git Manager. Official Git Manager use `/home/USERNAME/public_html` as root repository, this method use user HOME directory (`/home/USERNAME`).
3. Due to notice number 2, **DO NOT use both method together on the same website! Pick only one that suite to your style. YOU HAVE BEEN WARNED!**
4. Always test on your local environment before applying to production environment!
5. The official CyberPanel backup feature only backup your `public_html` folder, `vhost` config and `databases`. So, if one day you restore your website, you need to start it all over again.

## Configurations
I assume you already have a Github account and running (and healthy) CyberPanel on your server.

### Create GitHub deploy key
Login to your CyberPanel server using SSH for website you want to use this method (or create one from CyberPanel interface if you don't have any).

Create GitHub public & private **Deploy Key** for specific repo by running:
```shell
ssh-keygen -t rsa -f ~/.ssh/example_com_github_rsa -C "example.com github auto push"
```
Replace `example_com_github_rsa` with your desired key name and comment for easier management. When promoted to enter `passpharse key`, leave that **empty** since we want to use for automation (without password).

Now, create GitHub repository for the website, and navigate to **Your Repository** -> **Settings** -> **Deploy keys** -> **Add deploy keys**.

![](github-deploy-key-01.png#center)

![](github-deploy-key-02.png#center)

![](github-deploy-key-03.png#center)

Paste generated **public key** content (in this example `~/.ssh/example_com_github_rsa.pub`) to **Key field** and make sure **Allow write access** is **checked**.

### Make use of SSH config file
Now, add (or create if it doesn't exists) this line to your user SSH config file under `~/.ssh` directory:
```plain
Host example_com
    HostName github.com
    User git
    IdentityFile ~/.ssh/example_com_github_rsa
```
**TLDR** config above: **`Host example_com` is an alias**. The configuration tells SSH to **connect** to `github.com` using **user** `git` with **private key `~/.ssh/example_com_github_rsa` when ``ssh`` command option to `example_com`** is performed.

Check your SSH connection by running `ssh -T example_com`. It should return message that you're successfully authenticated: **"Hi your_github_username/example-repo! You've successfully authenticated, but GitHub does not provide shell access."**.

### Creating .gitignore file
Since this method use user **HOME** directory instead of user `public_html` directory, you need to **ignore** CyberPanel generated files like `~/.bash_history`, `~/logs` folder, etc.

Create `.gitignore` file under your home website directory and fill these following **gitignore** config:
```plain
# Ignore hidden files and directory
.*
!/.gitignore
!/public_html/.*

# Ignore backup and logs directory
/backup/
/logs/

# Optional, but recommended:
# Ignore WordPress upload folder
/public_html/wp-content/uploads
# if you want to ignore wp-config.php file
/public_html/wp-config.php
```

### Git remote connection
Now, it's time to create git remote. Run:
```shell
git init
git remote add origin example_com:your_git_username/example-repo.git
```
> **Important note on `git remote add`** command:   
> the `example_com` should match with **Host** variable on your `~/.ssh/config` file and replace `your_git_username/example-repo` with your repository.

It's always good idea if we check our `.gitignore` config file by running `git status`. It's should only return `.gitignore` and `public_html/` on untracked files.

![Git status](git-status-cyber-panel-1.png#center)

## First commit
Before running automation, let's do our first commit, create remote branch (default: `main`), and push to remote. This step also verifying that everything works as expected.
```shell
# create git config user and email if not specified yet
git config user.email "your_github_registered_email@example.com"
git config user.name "Your Name"

git add .
git commit -m "first commit"
git branch -M main
git push -u origin main
```
Check your GitHub repository, your initial commit should appears.

## Automation
Create bash script to execute commit and push command. Place it anywhere under your user home directory (except `public_html` directory):
```bash
#!/bin/bash

cd ~/
git add .
git commit -m "Updated: `date +'%Y-%m-%d %H:%M:%S'`"
git push origin main
```
Don't forget to make the script executable by running `chmod +x your-script-name.sh`.

Then on your **CyberPanel Web UI**, go to your website **Cron Job** page and add task to execute the bash script we've create before:

```plain
/bin/bash /home/example.com/backup.sh >/dev/null 2>&1
```
Change `example.com` to your website domain name. I recommend you not to run it too often. Twice a day usually enough.

> _**WARNING**: Run smoothly on my env doesn't mean it run well on your machine. Always test any tutorials from the internet on your local isolated environment before directly on production servers!_