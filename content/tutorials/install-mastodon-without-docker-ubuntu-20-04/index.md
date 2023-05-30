---
title: "Install Mastodon without Docker (Ubuntu 20.04)"
description: "Snippet for running Mastodon instance (Twitter alternative) on Ubuntu 20.04 from source."
# linkTitle:
date: 2022-12-10T04:35:14+07:00
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
  - SysAdmin
  - Self-Hosted
tags:
  - Mastodon
  - PostgreSQL
  - Ruby
  - Nginx
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

**Mastodon** is free and *open-source* software for running *self-hosted* social networking services. It has microblogging features similar to the **Twitter** service, which are offered by a large number of independently run nodes, known as **instances**, each with its own code of conduct, terms of service, privacy policy, privacy options, and moderation policies.

<!--more-->

This article is my personal snippet for running Mastodon instance on Ubuntu 20.04 from source. I use *self-signed* certificate instead of **cerbot** because the instance will be run behind **Cloudflare** reverse proxy.

The **asciinema** video below is the whole process I install Mastodon instance (for reference)

<script id="asciicast-14" src="https://asciinema.ditatompel.com/a/14.js" async></script>

Or the whole YouTube video:

{{< youtube eBUr7JFiGMo >}}

## Pre-requisites
Before starting, there are several things that need to be fulfilled:
- Fresh Ubuntu `20.04` server with root access.
- Domain name (or sub-domain) for the Mastodon instance (in this case I'm using `vr4.me` and the Mastodon instance will be accessed from `https://social.vr4.me`.
- SMTP Server for email delivery service.

## Preparing the system
First, make sure the Ubuntu server we're using is up to date.
```shell
apt update && apt upgrade
```

Install `curl`, `wget`, `gnupg`, `apt-transport-https`, `lsb-release` and `ca-certificates`:
```shell
apt install -y curl wget gnupg apt-transport-https lsb-release ca-certificates
```

Install `NodeJS 16`:
```shell
curl -sL https://deb.nodesource.com/setup_16.x | bash -
```

Use **official PostgreSQL** repository:
```shell
wget -O /usr/share/keyrings/postgresql.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgresql.list
```

Update and install required system package:
```shell
apt update
apt install -y \
  imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
  g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf \
  bison build-essential libssl-dev libyaml-dev libreadline6-dev \
  zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
  nginx redis-server redis-tools postgresql postgresql-contrib \
  certbot python3-certbot-nginx libidn11-dev libicu-dev libjemalloc-dev
```

Enable **NodeJS** `corepack` feature and set **Yarn** version to `classic`:
```shell
corepack enable
yarn set version classic
```

Install **Ruby** with `rbenv`.
> _Note that `rbenv` must be installed for a **single Linux user**, therefore, first we must create linux user where Mastodon services will be running as (we'll create `mastodon` user):_
```shell
adduser --disabled-login mastodon
```

Then switch to mastodon user:
```shell
su - mastodon
```

And as `mastodon` user, proceed to install `rbenv` and `rbenv-build`:
```shell
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec bash
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

Once Ruby environment setup is done, we can than install the required Ruby version and `bundler`:
```shell
RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 3.0.4
rbenv global 3.0.4
gem install bundler --no-document
```

Return to the root user:
```shell
exit
```

## Setting up PostgreSQL
For optimal performance, you may use [pgTune](https://pgtune.leopard.in.ua/) to generate an appropriate configuration and edit values in `/etc/postgresql/15/main/postgresql.conf` before restarting PostgreSQL with `systemctl restart postgresql`.

Now, create a PostgreSQL user that Mastodon service could use. The easiest way is with `ident` authentication so the PostgreSQL user does not have a separate password and can be used by the Linux user with the same username.

Open PostgreSQL prompt:
```shell
sudo -u postgres psql
```

In the `psql` prompt, execute:
```sql
CREATE USER mastodon CREATEDB;
\q
```

The core system requirement is now ready, now we can move forward to setting up Mastodon instance along with it's dependency.

## Setting up Mastodon
It is time to download the Mastodon code. Switch to the `mastodon` user:
```shell
su - mastodon
```

Use `git` to download the latest `stable` release of Mastodon:
```shell
git clone https://github.com/mastodon/mastodon.git live && cd live
git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)
```

Install Ruby and JavaScript dependencies for Mastodon code:
```shell
bundle config deployment 'true'
bundle config without 'development test'
bundle install -j$(getconf _NPROCESSORS_ONLN)
yarn install --pure-lockfile
```

Run the interactive setup wizard:
```shell
RAILS_ENV=production bundle exec rake mastodon:setup
```
The command above will be:
- Create a configuration file
- Run asset pre-compilation
- Create the database schema

The configuration file is saved as `.env.production`.

In my case, I want Mastodon instance can be accessed from `https://social.vr4.me` but use my main domain identity to serve `@ditatompel@vr4.me` (instead of `@ditatompel@social.vr4.me`) So I need to change `LOCAL_DOMAIN` configuration value to `vr4.me` and add `WEB_DOMAIN=social.vr4.me` in the `.env.production` file configuration. Please refer to [documentation on configuration](https://docs.joinmastodon.org/admin/config/) for more detailed information.

When done with the configuration we can switch back to `root` user:
```shell
exit
```

## Setting up Nginx
Copy the Nginx configuration template that comes from Mastodon repository:
```shell
cp /home/mastodon/live/dist/nginx.conf /etc/nginx/sites-available/mastodon
ln -s /etc/nginx/sites-available/mastodon /etc/nginx/sites-enabled/mastodon
```

Then edit `/etc/nginx/sites-available/mastodon` and replace `example.com` to our domain name (in my case `social.vr4.me`).

As I said before, the instance will be serve behind **Cloudflare** reverse proxy and I don't want to use **certbot** to issue my SSL certificate. So I use my own *self-signed* certificate.

If you want to use certbot to issue the SSL certificate:

```shell
systemctl reload nginx
## Replace social.vr4.me with your domain name.
certbot --nginx -d social.vr4.me
```

## Setting up Mastodon systemd services
Copy the `systemd` service templates from the Mastodon directory to `/etc/system/systemd` directory:
```shell
cp /home/mastodon/live/dist/mastodon-*.service /etc/systemd/system/
```

Finally, start and enable Mastodon services:
```shell
systemctl daemon-reload
systemctl enable --now mastodon-web mastodon-sidekiq mastodon-streaming
```
Wait for a few minutes and try to access your instance from your web browser, and enjoy your *self-hosted* Twitter alternative!

If you want to join my instance, please do so : [https://social.vr4.me/invite/G2BtoAfD](https://social.vr4.me/invite/G2BtoAfD). The data stored somewhere in Indonesia.

## Resources
- [https://docs.joinmastodon.org/admin/install/](https://docs.joinmastodon.org/admin/install/)










