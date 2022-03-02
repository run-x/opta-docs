---
title: "GCR Access"
linkTitle: "GCR Access"
date: 2021-07-21
draft: false
description: Guide on how to authorize image pulling from GCR
---

With Opta, one is not forced to use the Opta-provisioned GCR repository, nor is the Opta-provisioned GCR repository
forbidden from being used elsewhere. The following guide explains how.

## Understanding GCR Access
It's same as GCS basically. GCR is simply a (powerful) convenience layer around object storage in a GCS
bucket, with the interfaces needed to do docker `push`, `pull`, etc... but at the end of the day it is just a wrapper
around GCS, as is its IAM system. When starting off with GCR, with or without Opta, the first step is to create a host
GCS bucket, usually following the format of `artifacts.PROJECT-ID.appspot.com`. This bucket contains all the images
pushed and maintained for your current GCP account.

So to grant access to push/pull images one merely needs to grant access to read/write from this bucket. Due to GCS 
limitations, this permissioning is an "all or nothing" deal -- a service account gets either full read or full write
access to all present and future GCR images in your project. GCP does not plan on updating this as it is pushing its
users to use [artifact registry](https://cloud.google.com/artifact-registry), which Opta will be doing soon. For now,
simply go to the GCP console, to your storage buckets, and find the `artifacts.PROJECT-ID.appspot.com` bucket. Enter it, 
and in the permissions tab click to add a permission. Add the emails for the service accounts/users in mind and grant
it `roles/storage.objectViewer` to pull access, and `roles/storage.legacyBucketWriter` for push access. That's it! One
of the benefits of GCP's separation of IAM and projects is that there are no extra steps for cross-account access
(and because of GCS, neither for cross region).

<a href="/images/gcr_access_1.png" target="_blank">
  <img src="/images/gcr_access_1.png" align="center"/>
</a>

**IMPORTANT NOTE**: A common pitfall for users is identifying _WHO_ needs the IAM permission. For any system built on
top of GCP VMs (e.g. GKE, bare VMs), you need to give the permission to the service account of the machine, as it is the
machine which is pulling the images. For Opta + GKE, that means giving it to the service accounts created for the node pools,
as those are the roles inherited by the machines. They should be pretty easy to identify in the GCP console, and Opta
allows adding extra policies to its managed service accounts.

## Further Guides
[Official GCP Guide](https://cloud.google.com/container-registry/docs/access-control)