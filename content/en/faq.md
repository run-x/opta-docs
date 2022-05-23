---
title: "FAQ"
linkTitle: "FAQ"
date: 2022-05-2
draft: false
weight: 1
description: Frequently Asked Questions
---

## What clouds do you support?
AWS, GCP, and Azure to a lesser extent, but we also allow local environments running on your machine and
BYO kubernetes clusters w/o any cloud specifications.

## How much does Opta cost?
Zero-- Opta itself is free and open source but the _resources_ which you create in your cloud accounts with it
are not.

## My docker containers built on my new M1 macbook keep failing to run.
That's because of the M1 chips. Without extra configuration docker containers built with the M1 chips won't run
on the regular intel/amd chips used by cloud vms. To fix this, simply `docker build` again but passing the flag
`--platform=linux/amd64` and use that image.

## My docker containers won't run on the new Graviton 2 EC2s
See previous answer-- Graviton 2 uses a different chip too. To fix this, simply `docker build` again but passing 
the flag `--platform=linux/arm64` and use that image.

## I can't seem to have access to my Kubernetes Cluster
Are you sure it's not an RBAC issue? For all clouds the role which created the cluster is automatically an admin,
but additional roles require extra steps/specifications. Please see the details in the references.

## I am unable to remove the delegated DNS Module in AWS infrastructure as it's stuck in Certificate deletion.
This is a known issue with AWS. There is a dependency between the AWS Load Balancer and Certificate for the 
Domain. Delete the Helm Release with ingress-nginx and then try to remove the DNS Module from the configuration.
Note: This will lead to a new Load Balancer to be created with a different URL.
