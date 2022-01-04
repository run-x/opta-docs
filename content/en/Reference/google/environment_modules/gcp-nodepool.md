---
title: "gcp-nodepool"
linkTitle: "gcp-nodegpool"
date: 2021-07-21
draft: false
weight: 1
description: Creates an additional nodepool for the primary GKE cluster.
---

This module creates an additional nodepool for the primary GKE cluster. Note that the
`gcp-gke` module creates a default nodepool so this should only be used when
you want one more.

## IAM Permissions given to the Nodepool
Along with the nodepool, Opta creates a [GCP IAM service account](https://cloud.google.com/iam/docs/service-accounts)
that is attached to each VM in the pool and handles all of the machine's (and Kubernetes actions done by the kubelet
in the machine like, for example, downloading a gcr image) IAM permissions. Opta gives this service account the
following roles:
* logging.logWriter
* monitoring.metricWriter
* monitoring.viewer
* stackdriver.resourceMetadata.writer
* storage.objectViewer on the project's gcr bucket

The first 4 roles are the default roles/permissions [required by GKE](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#permissions)
while the last ensures that each VM can pull docker images stored in your project's gcr bucket. If you need more 
permissions, feel free to add them via the `gcloud` cli or gcp web ui console-- assuming you do not destroy/modify the
existing roles attached there should be no problem.

THIS SERVICE ACCOUNT IS NOT THE ONE USED BY YOUR CONTAINERS RUNNING IN THE CLUSTER-- Opta handles creating appropriate
service accounts for each K8s service, but for any non-opta managed workloads in the cluster, please refer to this
[GCP documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity).

## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `max_nodes` | The maximum number of nodes to be set by the autoscaler in for the current nodegroup PER AVAILABILITY ZONE (there's almost always 3). | `5` | False |
| `min_nodes` | The minimum number of nodes to be set by the autoscaler in for the current nodegroup PER AVAILABILITY ZONE (there's almost always 3). | `1` | False |
| `node_disk_size` | The size of disk to give the nodes' vms in GB. | `20` | False |
| `node_instance_type` | The [gcloud machine type](https://cloud.google.com/compute/docs/machine-types) for the nodes. | `n2-highcpu-4` | False |
| `gke_channel` | The GKE K8s [release channel](https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels) to bind the cluster too. Gives you automatic K8s version management for the cluster and node pools. | `REGULAR` | False |
| `preemptible` | A boolean specifying whether to use [preemptible instances](https://cloud.google.com/compute/docs/instances/preemptible) for the default nodegroup or not. The preemptible instances will be configured to have the max price equal to the on-demand price (so no danger of overcharging). _WARNING_: By using preemptible instances you must accept the real risk of frequent abrupt node terminations and possibly (although extremely rarely) even full blackouts (all nodes die). The former is a small risk as containers of Opta services will be automatically restarted on surviving nodes. So just make sure to specify a minimum of more than 1 containers -- Opta by default attempts to spread them out amongst many nodes.  | `False` | False |