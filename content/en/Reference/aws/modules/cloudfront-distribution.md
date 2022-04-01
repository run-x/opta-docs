---
title: "cloudfront-distribution"
linkTitle: "cloudfront-distribution"
date: 2021-11-16
draft: false
weight: 1
description: Set up a cloudfront distribution
---

This module sets up a cloudfront distribution for you.

1. It can be tailored towards serving static websites/files from an Opta s3 
bucket (currently just for a single S3, but will expand for more complex usage in the future). Now, hosting your 
static site with opta can be as simple as:

```yaml
name: testing-cloufront
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXXXXXXXX
modules:
  - type: aws-s3
    name: testmodule
    bucket_name: "a-unique-s3-bucket-name"
    files: "./my-site-files" # See S3 module for more info about uploading your files t S3
  - type: cloudfront-distribution
    # Uncomment the following and fill in to support your domain with ssl
#    acm_cert_arn: "arn:aws:acm:us-east-1:XXXXXXXXXX:certificate/cert-id"
#    domains:
#      - "your.domain.com"
    links:
      - testmodule
```

Once you Opta apply, run `opta output` to get the value of your `cloudfront_domain`. `index.html` is automatically served at this domain.
2. It can be tailored to serve as a CDN for the Load Balancer for the Cluster.
```yaml
name: testing-cloufront
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXXXXXXXX
modules:
  - type: base
  - type: k8s-cluster
  - type: k8s-base
    name: testbase
  - type: cloudfront-distribution
#    Uncomment the following and fill in to support your domain with ssl
#    acm_cert_arn: "arn:aws:acm:us-east-1:XXXXXXXXXX:certificate/cert-id"
#    domains:
#      - "your.domain.com"
    links:
      - testbase
```

### Non-opta S3 bucket handling
If you wish to link to a bucket created outside of opta, then you can manually set the `bucket_name` and 
`origin_access_identity_path` fields to the name of the bucket which you wish to link to, and the path of an
origin access identity that has read permissions to your bucket.

### Cloudfront Caching
While your S3 bucket is the ultimate source of truth about what cloudfront serves, Cloudfronts flagship feature is its
caching capabilities. That means that while delivery speeds are significantly faster, cloudfront may take some time
(~1hr) to reflect changes into your static site deployment. Please keep this in mind when deploying such changes. You
may immediately verify the latest copy by downloading from your S3 bucket directly.

### Using your own domain
If you are ready to start hosting your site with your domain via the cloudfront distribution, then proceed as follows:
1. Get an [AWS ACM certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html) for your site. 
   Make sure that you get it in region us-east-1. If you already have one at hand in your account (e.g. from another 
   active Opta deployment), then feel free to reuse that.
2. [Validate](https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html) the certificate by adding the correct CNAME entries in your domain's DNS settings. Specific instructions for popular domain providers are [explained here](https://docs.aws.amazon.com/amplify/latest/userguide/custom-domains.html).
3. Create a new separate CNAME record for the domain you wish to use for cloudfront and point it at the `cloudfront_domain` gotten above.
3. Set the acm_cert_arn and domains fields in opta accordingly
4. Opta apply and you're done!

### AWS WAF with Cloudfront

[AWS WAF](https://aws.amazon.com/waf/) is a web application firewall that helps protect your web applications or APIs against common web exploits and bots that may affect availability, compromise security, or consume excessive resources. In this section we explain how to configure AWS WAF with your Cloudfront distribution. 

As a pre-requisite, follow the steps in the previous section (__Using your own domain__) to create a and validate a certificate for the custom domain. After completing those steps, users have the ability to access your services at `https://your-custom-domain`; and because your CNAME record for your custom domain points to the cloudfront distribution URL, traffic will be directed through your cloud-front distribution.

Next, we need to create an AWS WAF to protect our service and cloudfront CDN cache. We do this via the [AWS WAF GUI](https://us-east-1.console.aws.amazon.com/wafv2/homev2).

Here are a few screen shots showing how the WAF GUI values can be configured for a "passthrough" WAF to start with.

We start at the WAF landing page in the AWS Console:

<a href="/images/opta-aws-1.png" target="_blank">
  <img src="/images/opta-aws-1.png" align="center"/>
</a>

We configure the WAF to use the cloudfront distribution we created with Opta:

<a href="/images/opta-aws-2.png" target="_blank">
  <img src="/images/opta-aws-2.png" align="center"/>
</a>

The initial configuration of the WAF allows all traffic:

<a href="/images/opta-aws-3.png" target="_blank">
  <img src="/images/opta-aws-3.png" align="center"/>
</a>

Finally, please [configure AWS WAF rules](https://docs.aws.amazon.com/waf/latest/developerguide/waf-chapter.html) for your specific application protection needs.



## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `bucket_name` | The name of the s3 bucket to link to this cloudfront distribution | `` | False |
| `origin_access_identity_path` | The Cloudfront OAI path to use to access the buckets | `` | False |
| `default_page_file` | The name of the existing s3 object in your bucket which will serve as the default page. | `index.html` | False |
| `status_404_page_file` | The name of the existing s3 object in your bucket which will serve as the 404 page. | `None` | False |
| `status_500_page_file` | The name of the existing s3 object in your bucket which will serve as the 500 page. | `None` | False |
| `price_class` | The cloudfront price class for this distribution. Can be PriceClass_All, PriceClass_200, or PriceClass_100 | `PriceClass_200` | False |
| `acm_cert_arn` | The ACM certificate arn you wish to use to handle ssl (needed if you want https for your site) | `None` | False |
| `domains` | The domains which you want your cloudfront distribution to support. | `[]` | False |
| `links` | The linked s3 buckets to attach to your cloudfront distribution (currently only supports one). | `[]` | False |
| `allowed_methods` | HTTP methods CloudFront processes and forwards to your Amazon S3 bucket or your custom origin. | `['GET', 'HEAD', 'OPTIONS']` | False |
| `cached_methods` | CloudFront caches the response to the specified HTTP method requests. | `['GET', 'HEAD', 'OPTIONS']` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `cloudfront_domain` | The domain of the cloudfront distribution |