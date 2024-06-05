---
title: "Lessons from MyBB FB Connect Plugin XSS Attack"
description: This article aims to share knowledge on how to counter-attack against attackers, specifically those using third-party Facebook applications.
summary: This article aims to share knowledge on how to counter-attack against attackers, specifically those using third-party Facebook applications.
date: 2011-12-01T23:53:39+07:00
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
  - Privasi
  - TIL
tags:
  - MyBB
  - XSS
  - Facebook
images:
authors:
  - ditatompel
---

A few days ago, I was surprised to see that my website's logs were filled with security testing attempts originating from an IP address in Indonesia. One of these attempts was a successful XSS attack targeting the MyBB plugin within one of my online forums.

> _**NOTICE**: In this article, I will not use the actual Facebook attacker's ID and this guide is only for sharing knowledge._

As mentioned by **@badwolves1986** at `http://devilzc0de.org/forum/thread-11110.html`, there was a **XSS bug** in the **plugin fbconnect** for **MyBB**.

When I discovered the bug, I didn't manage to _'patch'_ the bugs. I only managed to add _"additional permissions"_ to the plugin, which allowed me to update Facebook account status used for registration. Note the image below:

![FB Connect Permission Request](fbconnect-xss1.jpg#center)

From there, we can get the attacker's data. Let's look at the database:

```bash
SELECT uid, username, fbuid FROM [usertable] WHERE uid = '[uidattacker]'
```

Please note that the `fbuid` field will automatically exist if you install **FB Connect Plugin** for **MyBB**.

From the query above, we get the **Facebook Attacker's User ID**.

![SQL Query Result](fbconnect-xss2.jpg#center)

What can we do next? Let's recap again...

1. We already have Facebook attacker's user ID.
2. We already have permission to update status and access data for that user ID, even when offline!

That's right, **Facebook API**!

We can utilize **PHP Facebook SDK** from [https://github.com/facebook/php-sdk](https://github.com/facebook/php-sdk).

After downloading and uploading it to the web server, let's create a simple script to update the attacker's profile status.

![PHP Facebook SDK](fbconnect-xss3.jpg#center)

Here is an example of the code:

```php
<?php
require 'location-pf-facebook-sdk.php';
/**
 * Facebook
 */
$app_id = "[your-app-id]";
$app_secret = "[your-app-secret]";

//build content
$fbinfo = 'Your message';
$facebook = new Facebook(array(
    'appId'  => $app_id,
    'secret' => $app_secret
));
$response = $facebook->api(array(
    'method' => 'stream.publish',
    'uid' => '[attacker-user-id-from-the-database]',
    'message' => $fbinfo
));
echo $fbinfo;
?>
```

After that, upload it to your site and execute the script. Then, you will have successfully updated the Facebook attacker's account status.

![Posting using Facebook API](fbconnect-xss4.jpg#center)

From here, we learn a few things:

1. _Covering tracks_ are necessary when performing attacks on a website.
2. Do not use your real identity during illegal penetration testing.

What if I've already given an app permission to access my data?

Log in to `http://www.facebook.com/settings/?tab=privacy`, then select **"Edit Settings"** under the **Apps and Websites** menu.

In the **"Apps you use"** menu, you can revoke or remove unnecessary apps.

For those who want to remain _anonymous_, be cautious with Facebook, as it truly collects our data.

> _Don't forget, always use 'extra protection' when performing illegal activities.._
