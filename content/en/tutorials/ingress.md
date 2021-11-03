---
title: "Ingress"
linkTitle: "Ingress"
date: 2021-07-21
description: >
  How to expose your app on the internet
---

By default, all environments which have applied the k8s-base module has as output either a dns name or ip address for the load balancer
handling the http/grpc requests for the environment. These are called:

* `load_balancer_raw_ip` in Azure and GCP
* `load_balancer_raw_dns` in AWS

You can get the values simply by running `opta output` after the apply.

These domains/ip are always valid and can be used to serve traffic immediately, but without ssl (and as extension grpc)
or "real" names. To get those features, Opta offers 2 options:

1. You will need to execute either the dns delegation steps or the external ssl and CNAME steps outlined below (invalid option for Azure).
2. You "import" your SSL certificate into the Opta system and point your DNS zone straight to the load balancer's ip/dns name

### Setting the domain for an Environment via Domain Delegation

***NOTE: Our Azure offering currently does not support domain delegation. Please use the external ssl and CNAME option below***

With Opta, you can specify a domain for each environment which can be used by all the services running in that
environment. This is done with the aws-dns/gcp-dns module like so:
{{< tabs tabTotal="2" tabID="1" tabName1="AWS" tabName2="GCP" >}}
{{< tab tabNum="1" >}}

```yaml
name: aws-staging
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: base
  - type: dns # <-- this entry
    domain: staging.startup.com
  - type: k8s-cluster
  - type: k8s-base
```

{{< /tab >}}
{{< tab tabNum="2" >}}

```yaml
name: gcp-staging
org_name: runx
providers:
  google:
    region: us-central1
    project: jds-throwaway-1
modules:
  - type: base
  - type: dns # <-- this entry
    domain: staging.example.com
    subdomains:
      - myapp
    delegated: false
  - type: k8s-cluster
  - type: k8s-base
```

{{< /tab >}}
{{< /tabs >}}

As is, the dns module will create the "hosted zone" resource which manages your dns rules
for the domain you listed. In order for it to receive public traffic and get ssl
(to have https instead of http connections), you have to do some extra setup which
_proves_ that you own it.

This extra setup is updating the domain's nameservers to point to your Opta environment's AWS/GCP "hosted zone". This is how you do it:

- Run `opta apply` on the yaml file at least once to create the underlying resources
- Run `opta output` and note down the nameservers that get printed. It's usually a set of 4 servers.
- Assuming you own example.com and want to map staging.example.com to this environment. Then you'd add the following NS records in your domain registrar, where ns1-ns4 are the nameservers from the previous step.
  ```
  staging				1h			ns1
  staging				1h			ns2
  staging				1h			ns3
  staging				1h			ns4
  ```

It will take a few minutes for this change to sync with the internet, so just go and grab some coffee for 10 minutes.

You can verify that you did this properly by running this command:

```shell
dig staging.startup.com NS
```

You should see your name servers under the `ANSWER SECTION` part.

Once this is done and verified, please update your Opta yaml aws-dns/gcp-dns section to have a new field `delegated: true` like
so:
{{< tabs tabTotal="2" tabID="2" tabName1="AWS" tabName2="GCP" >}}
{{< tab tabNum="1" >}}

```yaml
name: aws-staging
org_name: runx
providers:
  aws:
    region: us-east-1
    account_id: XXXX
modules:
  - type: base
  - type: dns
    domain: staging.startup.com
    delegated: true # <-- THIS
  - type: k8s-cluster
  - type: k8s-base
```

{{< /tab >}}
{{< tab tabNum="2" >}}

```yaml
name: gcp-staging
org_name: runx
providers:
  google:
    region: us-central1
    project: jds-throwaway-1
modules:
  - type: base
  - type: dns
    domain: staging.example.com
    subdomains:
      - myapp
    delegated: true # <-- THIS
  - type: k8s-cluster
  - type: k8s-base
```

{{< /tab >}}
{{< /tabs >}}

Now run `opta apply` one more time and Opta will now generate your ssl certificates and attach them. Congratulations,
your environment will now be picking up public traffic on your domain and have https!

### External SSL and CNAME Setup
For the users which can not/do not wish to undergo the dns delegation steps, we do offer the simpler method of passing in
an external ssl certificate and manually adding appropriate CNAME records. 

To add your ssl cert, simply include the external-ssl-cert module in the environment yaml prior to the k8s-base module like so:

```yaml
name: gcp-live-example
org_name: runx
providers:
  google:
    region: us-central1
    project: gcp-opta-live-example
modules:
  - type: base
  - type: external-ssl-cert
    domain: "baloney.runx.dev"
    private_key_file: "./privkey.pem"
    certificate_body_file: "./cert_body.pem"
    certificate_chain_file: "./cert_chain.pem"
  - type: k8s-cluster
    max_nodes: 6
  - type: gcp-k8s-base
```

Note the relative paths to the different certificate files:
- `private_key_file` -- This is the relative path to the pem private key file for your cert. Is of the form `-----BEGIN PRIVATE KEY-----...-----END PRIVATE KEY-----`
- `certificate_body_file` -- This is the relative path to the certicate body file. This is sometimes called "cert.pem" and is a file
  consisting of a single `-----BEGIN CERTIFICATE-----...-----END CERTIFICATE-----` block. If you only have one big pem file with
  many such blocks, then create a new file and add **just** the first block.
- `certificate_chain_file` -- This is the relative path to the certicate chain file. This is sometimes called "chain.pem" and is a file
  consisting of one or (usually) more `-----BEGIN CERTIFICATE-----...-----END CERTIFICATE-----` blocks. If you only have one big pem file with
  many such blocks, then create a new file and add all the blocks **except** the first one.
  
Run `opta apply` once more and your ssl certificate will be utilized (you can check by going to the `load_balancer_raw_ip` 
or `load_balancer_raw_dns` in your browser).

To then make traffic go to your environment for your given domain, simply go to your domain's hosted zone (e.g. 
Route53 if you bought it with AWS, Google domains if bought with google, etc...) find the list of DNS records and
ask to add 2 new A records if you have a `load_balancer_raw_ip`, or 2 new CNAME records if you have a `load_balancer_raw_dns`.
These records should be named YOUR_DOMAIN, and *.YOUR_DOMAIN and should point to the respective ip/dns.

Once that final step is done, your environment should be live in your domain and utilizing your imported ssl!

### Exposing a service

A service can be exposed on a subdomain of the environment domain or on a path via the public_uri field.

#### Exposing on a subdomain

```yaml
meta:
  name: myapp
  envs:
    - parent: "staging/opta.yml"
modules:
  myapp:
    type: k8s-service
    public_uri: "myapp.{parent.domain}"
    ...
```

Following the domain examples above, this will expose the service at https://myapp.staging.startup.com

#### Exposing on a path

```yaml
meta:
  name: myapp
  envs:
    - parent: "staging/opta.yml"
modules:
  myapp:
    type: k8s-service
    public_uri: "{parent.domain}/myapp"
    ...
```

Following the domain examples above, this will expose the service at https://staging.startup.com/myapp

### Combine both

```yaml
meta:
  name: myapp
  envs:
    - parent: "staging/opta.yml"
modules:
  myapp:
    type: k8s-service
    public_uri: "myapp.{parent.domain}/v1"
    ...
```

Following the domain examples above, this will expose the service at https://myapp.staging.startup.com/v1

## External SSL Certificate and DNS Zone

If for some reason you prefer/need to handle DNS and SSL certificate creation yourself, then Opta supports you as well.
Opta now has an `external-ssl-cert` module which is capable of reading ssl cert files from the local filesystem and
automatically integrating it. Let us show by example:

Suppose you own a certain domain called "blah.dev" which you purchased from a particular cloud provider or dns seller.
You know wish to create an opta environment using the "staging.blah.dev" subdomain, but do not wish to undergo the dns
delegation. At this point you can purchase an ssl certificate from your domain provider or another 3rd party (NOTE: some 
providers like AWS do not allow you to download your provisioned ssl certificate), or use [certbot](https://certbot.eff.org/)
(a.k.a let's encrypt) to get a short-term (3 month lifespan) credential for free. You can do so by 
[downloading](https://certbot.eff.org/docs/install.html) the `certbot` cli and executing the following command:

```shell
certbot certonly -d blah.dev -d "*.blah.dev" --manual --preferred-challenges dns --config-dir . --work-dir . --logs-dir .
```

Certbot will then prompt you for certain input, including steps where you will manually add the domain validation TXT
records into your public DNS Zone. Sometimes the propagation of your TXT records may take sometime, and you can also 
validate that you have done the step correctly by executing `dig blah.dev TXT` and checking for your addenda there.

Once completed you should now have valid ssl certificate files under the relative path `./live/blah.dev`:

```
# ls ./live/blah.dev
README        cert.pem      chain.pem     fullchain.pem privkey.pem
```

Of these files, the 3 which are important are cert.pem, chain.pem, and privkey.pem (note that fullchain.pem is just 
the cert and chain files fused together). We can then add them to the opta environment by including an instance of the
external-ssl-cert file like so:

```yaml
.
.
.
modules:
  - type: base
  - type: external-ssl-cert
    domain: "baloney.runx.dev"
    private_key_file: "./live/privkey.pem" # NOTICE THE RELATIVE PATH
    certificate_body_file: "./live/cert.pem"
    certificate_chain_file: "./live/chain.pem"
.
.
.
```

After applying with this, you will note that your load balancer ip/dns now handles ssl and redirects http over to https.
The final step is to add a CNAME/A record (former if you have a load balancer dns, latter if it's an IP) from your DNS
Zone (the same one modified for the ssl cert verification, this will be a sibling record) pointing to your load balancer.
With that complete your environment will be live to the public and secured with ssl.

## Advanced Topic: Adding Extra Annotations to Ingress Objects

While Opta will automatically add the ingress object and required annotations, you an add extra [Nginx ingress annotations]((https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/)) to control traffic via Nginx ingress for your service. For example:

```yaml
meta:
  name: myapp
  envs:
    - parent: "staging/opta.yml"
modules:
  myapp:
    type: k8s-service
    annotations:
      ingress:
        nginx.ingress.kubernetes.io/client-body-buffer-size: 10k
        nginx.ingress.kubernetes.io/limit-rps: 10
        foo: bar
    ...
```