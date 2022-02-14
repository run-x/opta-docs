---
title: "Custom image"
linkTitle: "Custom Image"
date: 2022-01-03
draft: false
description: >
  Instructions to use a custom docker image
---

To use your own custom docker image, you can set `image: AUTO` in your service module.
{{< highlight yaml "hl_lines=10" >}}
name: hello
environments:
  - name: staging
    path: "opta.yaml"
modules:
  - name: hello
    type: k8s-service
    port:
      http: 80
    image: AUTO
    healthcheck_path: "/"
    public_uri: "/hello"
{{< / highlight >}}

For this example, we will make a simple change to our hello application (also available on [github](https://github.com/run-x/opta-examples/tree/main/hello-app)).

{{< tabs tabTotal="2" >}}
{{< tab tabName="app.py" >}}

{{< highlight py "hl_lines=5" >}}
from flask import Flask
app = Flask(__name__)
@app.route('/')
def hello_world():
    return "<p>Hello, World! v2</p>"
{{< / highlight >}}

{{< /tab >}}
{{< tab tabName="Dockerfile" >}}

{{< highlight dockerfile >}}
FROM python:3.8-slim-buster

ENV FLASK_APP=app

WORKDIR /app

RUN pip install Flask==0.12 
COPY . /app
ENV PORT 80

CMD python3 -m flask run \-\-host=0.0.0.0 \-\-port=${PORT}
{{< / highlight >}}

{{< /tab >}}
{{< /tabs >}}

Build the image locally:
```bash
docker build . -t hello-app:v2
```

Deploy the new image to the kubernetes cluster:
```bash
opta deploy --image hello-app:v2
```

This will:
1. Push the image to the private container registry (ECR, GCR, ACR) - this registry is created during environment creation.
1. Update the kubernetes deployment to use the new container image.
1. Create new pods to use the new container image - automatically done by kubernetes.


No need to manually manage the repositories!

> Note:
> If you deploy an Image with an already existing tag image, Opta would still detect those changes and make sure the image is deployed again.