---
title: "IAM Guidance for Opta"
linkTitle: "IAM Guidance for Opta"
date: 2020-02-01
description: >
   How to configure your iam to work with Opta
---

# Overview
Identity access management, IAM, is how a user can control permissions to read and/or modify resources in their
cloud accounts. When opta runs, it uses your currently configured credentials for your role/user of your cloud provider
to read your state, and update/create resources as needed. Due to the large amount and variety of resources opta
is responsible for, we recommend folks to use a role/user with account admin privileges for opta, but we hope to
begin providing more specific policies in the future. Furthermore, the k8s cluster needs authentication and 
authorization to read and write resources to itself, which is tied to the cloud provider's IAM. Below, we go over the 
specifics for the setup for each cloud.

# AWS
When creating a new AWS account, there are two routes you can go by
1. Create and link accounts with [AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_tutorials_basic.html) 
   and then use [AWS SSO](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html) (yes, there are other SSO
   options, but we won't cover those).
2. Create separate AWS accounts the old-fashioned way.

We recommend using the AWS Organization route as, although it's a little extra setup, will make your life way easier when
scaling to multiple environments and accounts and AWS accounts themselves don't cost anything so fiscal prudence is not
a problem. Nonetheless, here are the instructions for both routes.

## Org + SSO
For this approach, you will need a "root account" to start with, which you can create via the traditional method. As
the creator, you will be bestowed with admin privileges. From there you can follow the official steps [here](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_tutorials_basic.html)
to setup your organization-- you'll want to focus on the "Create a member account" section, and don't worry about the
organizational units or service control policies for now. 

Once that's setup, we can create SSO for your Organization by going to the root AWS account and following the official
[steps](https://docs.aws.amazon.com/singlesignon/latest/userguide/step1.html). You'll want to focus on steps 1, 2, and
3 for now, and for step 2 if you're using gsuite, go ahead and use that as your source by following [this](https://aws.amazon.com/blogs/security/how-to-use-g-suite-as-external-identity-provider-aws-sso/).
Once that's settled, you can [assign user access](https://docs.aws.amazon.com/singlesignon/latest/userguide/useraccess.html#assignusers)
to the different accounts in your organization. For opta usage, we recommend to use the SSO Admin access/permission set.

_NOTE_ If you want to deploy opta in the root account (which we advise against), feel free to use the New Account section
instructions from down below

## New Account
Outside of SSO, if one were to use opta then you have to create a new IAM for opta which your human teammates 
could then "[assume](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html)". This assumption allows IAM
users (and other roles too) to get credentials for the assumed role (time limited) and interact with the AWS API on their
behalf. _This way many people can get the same permissions and act as the same entity without compromising their own
personal credentials_. For role assumption, two things are required:
1. The role to be assumed must have its trust policy include the role that would assume it (explicitly or through a group).
   ![image alt text](/images/iam_tutorial_image_1.png)
2. The assumer role/user must have the IAM permission to assume the opta role.
   ![image alt text](/images/iam_tutorial_image_2.png)

To create such a role and permission, you can start by following the official IAM role creation instructions
[here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user.html#roles-creatingrole-user-console).
When prompted "Specify accounts that can use this role" add the own account id. This satisfies requirement 1 as now
the role will be ok with ANY IAM role/user in your account to assume it (you can refine the list later). Continue and 
give it the Administrator Access policy (should be one of the first on the list), and create it (you can add tags if you 
so wish). Now you have a role capable of executing AWS requests with admin privileges.
![image alt text](/images/iam_tutorial_image_3.png)

To satisfy requirement 2, all you have to do is follow this [guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_permissions-to-switch.html)
for all the IAM users/roles you have in question. You can then test it out by running the following with you current credentials:
```shell
aws sts assume-role --role-arn "THE_OPTA_ROLE_ARN" --role-session-name DUMMY_SESSION
```

The output should be the temporary credentials to assume the opta role. Just set the envars as so:
```shell
export AWS_ACCESS_KEY_ID=RoleAccessKeyID
export AWS_SECRET_ACCESS_KEY=RoleSecretKey
export AWS_SESSION_TOKEN=RoleSessionToken
```

You can now run opta and any other AWS cli/sdk with the opta role.

### Cross Account Access
If you want to give a user access to run opta in account a while their IAM role/user is in account b, simply refine
the opta role you created in account a to allow role assumption from account b (again, you can further specify which
iam users/roles are) and make sure that you allowed role assumption in the assumer to the new account.

### Long Term Credentials
For long term credentials (e.g. to hardcode into a CI system), we recommend you create an IAM user who can then assume
the role used by opta and using its credentials, assuming the opta role as part of the process.
