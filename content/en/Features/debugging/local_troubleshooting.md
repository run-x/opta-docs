---
title: "Local Troubleshooting"
linkTitle: "Local Troubleshooting"
date: 2021-10-11
draft: false
weight: 2
description: >
  Troubleshooting Opta Local
---

## Troubleshooting

If things don't seem to be working as expected, here are some places to start debugging Opta Local

### Docker

Opta Local runs two containers on the local machine. Confirm both are running; like so

```bash
# Command
 docker ps

 # Output
CONTAINER ID   IMAGE                  COMMAND                  CREATED      STATUS        PORTS                                                                    NAMES
71d2f8a13961   kindest/node:v1.21.1   "/usr/local/bin/entr…"   2 days ago   Up 10 hours   0.0.0.0:8080->80/tcp, 0.0.0.0:6443->443/tcp, 127.0.0.1:39499->6443/tcp   opta-local-cluster-control-plane
ac9b78c91776   registry:2             "/entrypoint.sh /etc…"   2 days ago   Up 10 hours   127.0.0.1:5000->5000/tcp                                                 opta-local-registry

```

If these containers are not running, then debug the docker containers so Opta Local can start correctly.

### Kind Kubernetes Cluster

1. Confirm that the `kubectl` context is correctly set.
   
``` bash
# Command
kubectl config get-contexts  
# Output
...
*         kind-opta-local-cluster                                        kind-opta-local-cluster                                        kind-opta-local-cluster     
...
```
  Note the "*" in front of the `kind-opta-local-cluster`. In case the current context is not set to the kind cluster, you can set it like so:

```bash
# Command
kubectl config use-context kind-opta-local-cluster
# Output
Switched to context "kind-opta-local-cluster".
```

2. Check that the Kind Kubernetes Cluster is functioning
```bash  
# Command
kubectl cluster-info
# Output
Kubernetes master is running at https://127.0.0.1:42937
CoreDNS is running at https://127.0.0.1:42937/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

# Command
kubectl cluster-info
  # Output
Kubernetes master is running at https://127.0.0.1:42937
CoreDNS is running at https://127.0.0.1:42937/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

To further debug and diagnose cluster problems, use `kubectl cluster-info dump` and `kubectl get node`

```bash
# Command
kubectl get node
# Output
  NAME                               STATUS   ROLES                  AGE   VERSION
  opta-local-cluster-control-plane   Ready    control-plane,master   14m   v1.21.1
```
3. You can interact with the local Kubernetes cluster with the `kubectl` cli tool. Browse through additional  `kubectl` commands [here](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### Container Registry

Opta Local creates a local Docker container registry at `http://localhost:5000`. This is used during [Opta Deploy](/features/continuous_deployment/) to host your images. Confirm it is functioning:

  1. Curl the address `http://localhost:5000/v2/`
```bash
  # Command
  curl -v http://localhost:5000/v2/ 

  # Output
  *   Trying 127.0.0.1:5000...
  * TCP_NODELAY set
  * Connected to localhost (127.0.0.1) port 5000 (#0)
  > GET /v2/ HTTP/1.1
  > Host: localhost:5000
  > User-Agent: curl/7.68.0
  > Accept: */*
  > 
  * Mark bundle as not supporting multiuse
  < HTTP/1.1 200 OK
  < Content-Length: 2
  < Content-Type: application/json; charset=utf-8
  < Docker-Distribution-Api-Version: registry/2.0
  < X-Content-Type-Options: nosniff
  < Date: Mon, 27 Sep 2021 02:05:38 GMT
  < 
  * Connection #0 to host localhost left intact
  {}

```

Note the `200 OK` Http response and the {} braces in the output.
  
  2. Confirm that images can be tagged and pushed into the docker registry. Example:
     
```bash
  # Command
  docker pull alpine

  #Output
  Using default tag: latest
  latest: Pulling from library/alpine
  a0d0a0d46f8b: Pull complete 
  Digest: sha256:e1c082e3d3c45cccac829840a25941e679c25d438cc8412c2fa221cf1a824e6a
  Status: Downloaded newer image for alpine:latest
  docker.io/library/alpine:latest
  
  # Command
  docker tag alpine:latest localhost:5000/alpine:latest
  docker push localhost:5000/alpine:latest 
  
  # Output
  The push refers to repository [localhost:5000/alpine]
  e2eb06d8af82: Pushed 
  latest: digest: sha256:69704ef328d05a9f806b6b8502915e6a0a4faa4d72018dc42343f511490daf8a size: 528
```

### Clean up and start over

If you are stuck and are unable to troubleshoot the issue that you are facing, you can start over.

Follow these [instructions](/getting-started/local/#uninstallation-and-cleanup) to clean up the local environment and run `opta apply` again.