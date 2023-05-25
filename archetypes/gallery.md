---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
lastmod:
draft: true
description: 
resources:
  - src: foo.jpg
    title: Foo
    params:
      author:
      source:
---
