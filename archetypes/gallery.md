---
title: "{{ replace .Name "-" " " | title }}"
description: 
date: {{ .Date }}
lastmod:
draft: true
resources:
  - src: foo.jpg
    title: Foo
    params:
      author:
      source:
---
