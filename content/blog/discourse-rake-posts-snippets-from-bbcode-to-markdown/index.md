---
title: "Discourse Rake Posts Snippets from BBCode to Markdown"
description: "After migrated devilzc0de from MyBB to Discourse, many things needs to be done. One of them is to rake and rebake the BBCode tags posts to Markdown."
date: 2020-06-14T12:55:12+07:00
lastmod:
draft: false
noindex: false
featured: false
pinned: false
# comments: false
series:
#  - 
categories:
  - SysAdmin
tags:
  - Discourse
  - Devilzc0de
  - Ruby
  - MyBB
  - PostgreSQL
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

It's been more than 1 year since I [migrated devilzc0de from MyBB to Discourse]({{< ref "/blog/story-behind-the-all-new-devilzc0de-migration-process/index.md" >}}) and many things needs to be done after the migration process is complete. One of them is to `rake` (and `rebake`, if needed) the **BBCode** tags to **Markdown** for each posts.

<!--more-->

Before you start you need to:
- Backup your forum before perform any actions because you may break every single posts content and PMs.
- Prepare your time and resource, especially if your forum had lots of posts.
- Know that Discourse use PostgreSQL  database which use [POSIX regex](https://www.postgresql.org/docs/9.3/functions-matching.html#FUNCTIONS-POSIX-REGEXP) to perform regex matching and it will be case-sensitive.
- Know that you can use BBCode plugin for Discourse like [discourse-bbcode](https://meta.discourse.org/t/discourse-bbcode/65425) without perform any of these actions.

If you understand the risks (and you have another option) and still want to continue without additional plugins like I do, then go ahead. You need to enter your Discourse app by executing `./launcher enter app` from your root Discourse directory.

## Remove Color, Size, Align, and Font Tags
Color, size, font and align tags may different in each post, like `[color=#ff3333]` or `[color=red]`, `[font=‘Open Sans’, sans-serif]`, `[align=center]`, etc. These rake post command will remove any general BBCode color, size, font, and align tags.

![Discourse Rake](dc-rake.png#center)

![Discourse Replace BBCode to Markdown](feature-dc-rake-01.png#center)

### BBCode Color Tags
```ruby
rake posts:delete_word['\\[color.*?\\]|\\[\\/color\\]',regex]
```

### BBCode Size Tags
```ruby
rake posts:delete_word['\\[size.*?\\]|\\[\\/size\\]',regex]
```
### BBCode Align Tags
```ruby
rake posts:delete_word['\\[align.*?\\]|\\[\\/align\\]',regex]
```

### BBCode Font Tags
```ruby
rake posts:delete_word['\\[font.*?\\]|\\[\\/font\\]',regex]
```

### All of Them Together
```ruby
rake posts:delete_word['\\[color.*?\\]|\\[\\/color\\]|\\[size.*?\\]|\\[\\/size\\]|\\[align.*?\\]|\\[\\/align\\]|\\[font.*?\\]|\\[\\/font\\]',regex]
```

> _**Note**: The regex is **case-sensitive**, tags with **uppercase** will not be removed. You need to check posts again by your self._

## Replace String or Words (Remap)
You can use `rake post:remap` to perform simple replacement. For example, oldest devilzc0de forum post is from 2010 where at that time, we rarely found sites using https.

But now, https is everywhere and browser won't display mixed content. So, to replace `http://` to `https://` for each posts :
```ruby
rake posts:remap["http://","https://"]
```

This works for tagging user tags and emoji too.

> _**Note**: You may increase `sidekiq` workers by updating Discourse `app.yml` `UNICORN_SIDEKIQS` **env** to spin up sidekiq queue for onebox and remote image fetch after remapping http to https._

Unfortunately, rake remap doesn't work for `[code]`, `[spoiler]`, `[php]`, and `[qoute]` tags. Here is the example :

In old MyBB forum, user using `[code]` block following with the actual codes without new line will work. But, markdown code tags works if you use new line after <code>```</code> block.

```plain
[code]var promise = new Promise(function(resolve, reject) {
  // do a thing, possibly async, then…

  if (/* everything is fine */) {
    resolve("Worked!");
  }
  else {
    reject(Error("Didn't work"));
  }
});
[/code]
```

`[code]` tags above will work on **MyBB** and produce:

```javascript
var promise = new Promise(function(resolve, reject) {
  // do a thing, possibly async, then…

  if (/* everything is fine */) {
    resolve("Worked!");
  }
  else {
    reject(Error("Didn't work"));
  }
});
```

But on Discourse which use **Markdown**, if I replace `[code]` tags with <code>```</code> will produce :
<pre>```var promise = new Promise(function(resolve, reject) {
  // do a thing, possibly async, then…

  if (/* everything is fine */) {
    resolve("Worked!");
  }
  else {
    reject(Error("Didn't work"));
  }
});
```
</pre>

Code above **will not recognised as code block**. We need to add **new line** after first opening <code>\```</code> block. Unfortunately (at least for me), using <code>rake posts:remap["[code]","```\n"]</code> doesn't work and only produce the **"\n"** as plain text. The only working solution for me is **directly update raw PG database**.

## PostgreSQL Raw Update
You need to enter **PostgreSQL** on your Discourse app to run all PG query below. If you don't know how to do it, run `su -c 'psql discourse' postgres` after `./launcher enter app` command.

> _**Note**: You need to `rebake` your post after update PostgreSQL post DB. To avoid rebake all your posts, you can use `rebake_match`. See example below._

### Replace Spoiler Tags With Details Tags
```sql
UPDATE posts set raw=replace(raw, '[spoiler]', '[details=Spoiler]'||chr(10)) where raw like '%[spoiler]%';
UPDATE posts set raw=replace(raw, '[spoiler=', '[details=') where raw like '%[spoiler=%';
UPDATE posts set raw=replace(raw, '[/spoiler]', chr(10)||'[/details]') where raw like '%[/spoiler]%';
```

After updating database, exit from postgres user and run rebake post.
```ruby
rake posts:rebake_match["\[details"]
```

### Replace MyBB [php] Tags With Markdown PHP Syntax Highlight
```sql
UPDATE posts set raw=replace(raw, '[php]', '```php'||chr(10)) where raw like '%[php]%';
UPDATE posts set raw=replace(raw, '[/php]', chr(10)||'```') where raw like '%[/php]%';
```

After updating database, exit from postgres user and run rebake post.

```ruby
rake posts:rebake_match["\`\`\`php"]
```

### Replace [code] tags With Markdown Tags
```sql
UPDATE posts set raw=replace(raw, '[code]', '```'||chr(10)) where raw like '%[code]%';
UPDATE posts set raw=replace(raw, '[/code]', chr(10)||'```') where raw like '%[/code]%';
```

After updating database, exit from postgres user and run rebake post.

```ruby
rake posts:rebake_match["\`\`\`"]
```

## ToDo's
- `[ul]`, `[ol]` and `[li]` tags replace to Markdown list tags
- `[quote]` Tags to Markdown quote tags

Please share if you have done mass replace for those two to do lists above.

## Credits
- [Cameron:D](https://meta.discourse.org/t/replace-a-string-in-all-posts/48729/70?u=ditatompel) and [Coin-coin le Canapin](https://meta.discourse.org/t/replace-a-string-in-all-posts/48729/72?u=ditatompel) post.