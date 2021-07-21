---
title: "Custom image"
linkTitle: "Custom Image"
date: 2021-07-21
draft: false
description: >
  Instructions to use a custom docker image
---

To use your own custom docker image, you can set `image: AUTO` in your service module.

Now you should first build your docker container via `docker build` and then run:

```
opta deploy --image <image>:<tag>
```

This will upload your image to the appropriate cloud repository (ECR or GCR) and then initiate a deploy with this image.

No need to manually manage the repositories!
