---
title: "Compliance"
linkTitle: "Compliance"
date: 2022-01-03
weight: 2
description: >
    SOC 2 and PCI compliance of Opta infrastructure.
---

## Overview
Good infrastructure design is not only important for security, but for adhering to legal compliance
barriers protecting common business actions. To that end Opta has been taking these needs into account
and has brought its cloud infrastructure to these standards wherever possible. Opta aims to make SOC 2
and PCI compliance of infrastructure as default as possible, with minimal user interference. We have detailed
below the current state of SOC2 and PCI compliance per cloud provider, the exceptions, the extra steps,
and the methodology used to verify our compliance.

### NOTE: Does this mean your company is now SOC2/PCI compliant?

No. SOC2 and PCI compliance goes far beyond the cloud infrastructure resources and has requirements on
multiple levels of the organization and software. Opta aims to fulfill the requirements just for the
cloud infrastructure level so that no dramatic change in devops or product downtime is needed. The Opta
team strongly encourages any user to seek the services of a respectable compliance readiness/assistance
security company.

## Our Methodology
Runx has been using [Fugue](https://www.fugue.co/) to validate the compliance of the cloud resources it creates.
Before each release, a sample environment exercising the full feature sets of opta are created in each
of our supported clouds, and scanned by Fugue's compliance dashboard. Opta furthermore uses the 
[regula](https://github.com/fugue/regula/) project to enfore most of the common compliance rules on its CI,
catching errors before manual checks are needed.

Any SOC 2 or PCI compliance violations
found are then addressed, either by fixing the issue when possible, or otherwise recording the breach and adding it
to the sections below. To keep backwards compatibility, Opta never makes breaking changes in releases uness mentioned 
specifically, but such needed changes will be added on newer resources created afterwards 
(please check release notes for more info on such non-intrusive changes).


## Compliance Status
Below you can see the SOC 2 and PCI compliance status of opta cloud infrastructures per cloud.
Any identified violations will be mentioned below as well as known remediations.

### AWS
AWS Infrastructure is SOC2 and PCI compliant, with the right settings. Those settings are the following:

1. S3 buckets must have a policy denying non-SSL traffic
2. S3 buckets must enable the same_region_replication feature so that Opta can create a backup.
3. Postgres databases must have the `multi_az` variable enabled.

Please see the following yaml for example
```yaml
environments:
  - name: production
    path: "../environments/aws-prod.yaml"
name: baloney
modules:
  - name: db
    type: aws-postgres
    multi_az: true
  - name: s3
    type: aws-s3
    same_region_replication: true
    bucket_name: "{parent_name}-{layer_name}"
    bucket_policy: {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "denyInsecureTransport",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:*",
          "Resource": [
              "arn:aws:s3:::{parent_name}-{layer_name}/*",
              "arn:aws:s3:::{parent_name}-{layer_name}"
          ],
          "Condition": {
            "Bool": {
              "aws:SecureTransport": "false"
            }
          }
        }
      ]
    }
```

Auditor may further raise concerns for the following:

1. The dynamodb table for the terraform lock is unencrypted. This is fine as it holds zero customer data, and 
   merely maintains a list of hashes for the lock-- no real parsable data.
2. The tf state bucket does not have logging. This is because it is created before the environment log bucket, leading
   a potentially nasty chicken-vs-egg scenario, especially if ever deleting. A use should feel free
   to [manually create the link](https://docs.aws.amazon.com/AmazonS3/latest/userguide/ServerLogs.html) to the logging bucket which opta creates.
3. The logging bucket does not have logging for itself enabled for obvious reasons.

### GCP
GCP infrastructure is near-SOC2 and PCI compliant. This lack of coverage is due to the following reasons:

1. The VMs of the GKE nodegroups do not have block-project-ssh-keys enabled. There does not seem to be a way to disable
   this in GKE at the moment.
2. The Vms of the GKE nodegroups do not have their disks encrypted by a KMS key. The reason for this is that this 
   feature is still in beta, at least in the terraform specs. We will update this as soon as it becomes GA.

These are important Security Overview which the opta team will keep an eye out until a feasible solution is found.
Furthermore, the following default settings will have to be modified:


1. The terraform GCS bucket does not have uniform level bucket access control enabled by default as doing so would make
   the user have to tediously grant access to read/write to everyone that will run opta, EVEN IF THEY ARE PROJECT ADMINS.
2. The gcr bucket (gcr is powered by a gcs bucket) for the environment's repo also does not
   have uniform level bucket access control for the same reason. Again, the opta user can manually enable this by
   themselves if they so wish without affecting opta, but then docker push/pull permissions becomes very tedious.

### Azure
Azure infrastructure is SOC2 and PCI compliant, with only one extra user step:

1. Enable flow logs for the [agent pool security group](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/aks-security-baseline#12-monitor-and-log-the-configuration-and-traffic-of-virtual-networks-subnets-and-nics)
