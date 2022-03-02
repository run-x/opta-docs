---
title: "ECR Access"
linkTitle: "ECR Access"
date: 2021-07-21
draft: false
description: Guide on how to authorize image pulling from ECR
---

With Opta, one is not forced to use the Opta-provisioned ECR repository, nor is the Opta-provisioned ECR repository 
forbidden from being used elsewhere. The following guide explains how.

## Understanding ECR Access
Like an S3 bucket, the governing principal for ECR access is mutual authorization: both the AWS IAM role (this guide is 
identical for IAM users) and the ECR  policy need to allow the action from the role to the ECR resource in order for it 
to succeed. This redundancy is quite useful as:

1) The permission can not just be in the IAM role as then either cross-account access is forbidden or any random person could get access to your ECR
2) If the permission was just in the ECR policy, then it would be overly verbose as one can specify wildcards to, for example, allow any IAM role in the current account access, and then delegate the management over to the IAM role permission assignment.

<a href="/images/ecr_access_1.png" target="_blank">
  <img src="/images/ecr_access_1.png" align="center"/>
</a>

## The IAM Role Permission
From the IAM Role side, the permissioning is standard, like with most AWS service. Within an IAM policy, one needs to specify 
a statement containing `ecr:XXX` actions and a resource, being the arn of an ECR repository, or a wildcard or similar construct.
Once the policy is attached to an IAM role, the role will have the permissions.

AWS comes with a series of pre-defined policies such as AmazonEC2ContainerRegistryReadOnly which makes this quite
straightforward in most cases.

<a href="/images/ecr_access_2.png" target="_blank">
  <img src="/images/ecr_access_2.png" align="center"/>
</a>

**IMPORTANT NOTE**: A common pitfall for users is identifying _WHO_ needs the IAM permission. For any system built on
top of EC2 (e.g. EKS, ECS, bare EC2), you need to give the permission to the IAM role of the machine, as it is the
machine which is pulling the images. For Opta + EKS, that means giving it to the IAM roles created for the nodegroups,
as those are the roles inherited by the machines. They should be pretty easy to identify in the AWS console, and Opta
allows adding extra policies to its managed IAM roles. Having said that, these node groups come with the
AmazonEC2ContainerRegistryReadOnly policy by default and so can pull any ECR image assuming that the repository's
policy allows it.

## The ECR Repository Policy
For the ECR side, the permission is handled by the repository's policy, which can be found on the `Permissions` tab
on the AWS console once the repository is selected. The policy is a subset of standard IAM policies where the resource
is implied to be the repository and the statements specify who can do what action on it. For example, the following
policy json gives all IAM roles in accounts XXXXXXXXXXXX and YYYYYYYYYYYY blanket permissions on the repository (meaning
that access would now be solely dictated by the IAM permissions on the roles)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAllFromAccount",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::XXXXXXXXXXXX:root"
      },
      "Action": "ecr:*"
    },
    {
      "Sid": "AllowAllFromAccount",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YYYYYYYYYYYY"
      },
      "Action": "ecr:*"
    }
  ]
}
```

<a href="/images/ecr_access_3.png" target="_blank">
  <img src="/images/ecr_access_3.png" align="center"/>
</a>

You can find a large set of sample policies courtesy of AWS [here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policy-examples.html)

## Example: Cross Account Access
To complete the guide, let's go through an example. Suppose you have an ECR repository `sample-repository` in account XXXXXXXXXXXX
and you wish to access it from IAM role `sample-role` in account YYYYYYYYYYYY. All you need to do is

1) Make sure that `sample-role` has an IAM policy attached which gives it the permissions for the needed actions on
  `sample-repository`. For example, if you wish to have pull access, a policy like this would do:
```json
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        "Resource": "arn:aws:ecr:YOUR-REPOSITORYS-REGION:XXXXXXXXXXXX:repository/sample-repository"
      }
  ]
}
```

2) Make sure that the policy of `sample-repository` allows access for sample role. For example, a policy like this would do:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::YYYYYYYYYYYY:role/sample-role"
        ]
      },
      "Action": [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}
```

And bear in mind that IAM policies are additive, so if there are pre-existing policies, simply insert the lone `Statement`
entries in the example above to achieve the desired effect and not change existing behavior.

## Further Guides
[Official AWS Guide](https://docs.aws.amazon.com/AmazonECR/latest/userguide/security_iam_service-with-iam.html)
[Official AWS Cross Account ECR Access Guide](https://aws.amazon.com/premiumsupport/knowledge-center/secondary-account-access-ecr/)