---
title: "DB Migrations in Opta"
linkTitle: "Opta DB Migrations"
date: 2022-01-03
draft: false
description: >
  How to run db migrations in Opta
---

Database migrations is one of the most tricky subjects when dealing with Opta as there is no clear industry
consensus on them. Some folks may use ORMs whilst others parse SQL more directly (or even use pseudo-ORMs like Pandas),
let alone use different tools depending on their programming language and/or db type. However, to help Opta
users, we have outlined here a guide on some reasonable migration strategies and some **highly recommended** practices
users should absolutely have in place.

## Highly Recommended Best Practices
To begin with, there are a couple of database migration best practices which we would like to share with our users.
These practices are not Opta-specific, but come from the Opta teams' collective experience in managing production
database migrations-- we want our users to succeed. Please consider them heavily.

### Understand when Database Migrations are Needed
Simply put, not all production-grade databases need database migrations. The concept of database migrations have 
historically been tied to relational databases, and other database models (e.g. key-value, document-store, graphs)
may offer easier alternatives. For instance, Kubernetes (which uses the etcd key-value database), has mostly bypassed
database migration issues with its concept of api versioning, where multiple "schema versions" can be supported 
simultaneously. Protocol buffers offer a similar alternative with its versioning system, allowing 
[backwards and forward compatibility](https://stackoverflow.com/questions/8519381/how-does-protocol-buffer-handle-versioning).

If you are using one of these non-relational databases, then consider what alternatives you have at your disposal, before
fully committing.

### Use a Trusted Migration Tool
Nothing is forcing a user to use a particular ORM or SQL client/framework, but it should be noted that many have
developed to aid in database migrations as well. Often, these features are not just about quality-of-life/usability
but also about security and recoverability. Database migrations _are dangerous_, and using a home-brewed tool is not
advised.

For recommended tools, please refer to the documentation of your ORM/client, or even your web framework for cases like
Flask, Ruby on Rails, etc...

### Ensure Forward/Backwards Compatibility
One of the least respected, but most important guidelines: always preserve at least one degree of forward/backwards compatibility.
This rule is not just to help with disaster recovery, but also to maintain the site operational during the migration
as not all servers may be up-to-date at the time of migration, or if they are that means they were functioning with
a database one expected migration behind.

For deprecations, the recommended approach is the 3-point migration:
1. Beginning with your database and server at the original versions, you start by adding any new data/columns but not use them yet.
2. You introduce a backwards compatible change in the database and/or server where the old data is maintained
and the new data is used instead.
3. Once the database and servers are up-to-date, you remove the old, now unused, data from the database.

The 3-point migration is admittedly slower, but it cuts off the vast majority of venues for error.

### Keep an Eye on Database Locks

Depending on the migration tool you are using and the size of the dataset, the migration execution itself could be using 
long-lasting locks based on the amount of data being created/updated/destroyed. This can create serious problems as the
locks may forbid any parallel write operations, meaning your application will fail in any endpoint executing such an
action, and cause downtime. These dangers are more difficult to track as they are typically dependent on the size of the
database, and as staging databases are typically a fraction of the size of production, such QA will not catch the danger.
Aside from a full production replication for testing, the only reasonable deterrent would be a database-educated engineer
approving/guarding db migration addition.

### Validate on non Production instance first

Even in small datasets, database migrations will always face the danger of improper data transformations which cause errors.
One of the best countermeasures for such errors is testing the migrations in non-production databases which closely
resemble production-- the more similar the better as it will test more potential edge cases. Typically, this is done
as part of the deployment to a "staging/qa" environment.

### Have Folks on Standby

Always prepare under the assumption that if something can go wrong, it will go wrong. Hence, always have someone on 
standby monitoring the migration.

### Run Migrations in Low Hours

Always run your migrations in hours of low usage-- not only will it help prevent database congestions due to long lock,
but it will also mitigate the publicity of errors.

## DB Migration Options with Opta
Now that we have the preparations in place, there are several ways which database migrations can be done with Opta,
depending on your needs/situation.

### On a Server's Startup
The simplest form is having the migration command run as part of server startup. This option is arguably the easiest/best
to begin with and possible due to the aforementioned locking nature of migration, ensuring that even if multiple servers 
are started simultaneously your data will not be tainted (assuming you use a tool which keeps track of the migration 
version, which is most-if-not-all popular ones). For instance, consider the following startup script for a 
[flask](https://flask.palletsprojects.com/en/2.0.x/) server which runs the migration and then starts the server.

```shell
set -exo pipefail

export PYTHONPATH=$(pwd)

source $(pipenv --venv)/bin/activate

cd srv
flask db upgrade # Does the migrations
gunicorn -c gunicorn.py wsgi # Starts the server
```

This strategy may potentially cause your health checks to fail if a migration takes too long but as long as the migrations 
are short (< 30 seconds), this option should work fine, keep your database and server changes in lock step and keep your 
ci/cd unchanged.

### In a Running Server's Container
An alternative route is having a user enter one of the running containers via the `opta shell` command and execute the 
migration manually. This option offers more developer control, but now requires a human in the loop, does not enforce
synchronicity between the database and server versions, and users will need to be careful not to trigger a new deployment
while the operation is taking place.

### In a One-Time Job
For a cleaner separation of migration and server deployment, you can also run a migration as a separate 
[kubernetes job](https://kubernetes.io/docs/concepts/workloads/controllers/job/) by using a helm chart module
to create the job with the required inputs. This can be done in either the existing service's manifest, or a new 
manifest which refers to the current manifest for data such as the current container image deploy (we recommend the latter
approach). Take for example the following manifests which starts with a k8s service with a database and then uses a known 
public helm chart which creates a one-time job for the migration in either the same manifest or a new one:

{{< tabs tabTotal="2" >}}
{{< tab tabName="Same Manifest" >}}

```yaml
environments:
  - name: staging
    path: "./staging.yaml"
name: my-service
modules:
  - name: db
    type: postgres
  - name: app
    type: k8s-service
    image: AUTO
    port:
      http: 80
    links:
      - db:
          - DBUSER: DBUSER
            DBHOST: DBHOST
            DBNAME: DBNAME
            DBPASS: DBPASS
  - type: helm-chart
    name: dbmigration1
    namespace: my-service # This should be the name of the service manifest
    create_namespace: false
    repository: https://ameijer.github.io/k8s-as-helm/
    chart: job
    chart_version: 1.0.0
    values:
      nameOverride: "databaseMigration"
      restartPolicy: Never
      containers:
        hello:
          image: "${{module.app.current_image}}"
          extraSettings:
            env:
              - name: DBHOST
                valueFrom:
                  secretKeyRef:
                    name: secret
                    key: DBHOST
                    optional: true
              - name: DBNAME
                valueFrom:
                  secretKeyRef:
                    name: secret
                    key: DBNAME
                    optional: true
              - name: DBPASS
                valueFrom:
                  secretKeyRef:
                    name: secret
                    key: DBPASS
                    optional: true
              - name: DBUSER
                valueFrom:
                  secretKeyRef:
                    name: secret
                    key: DBUSER
                    optional: true
            command:
              - ./home/app/do_migration.sh # The user-created script to run migrations and added in the docker image
```

{{< /tab >}}
{{< tab tabName="New Manifest" >}}

```yaml
environments:
  - name: staging
    path: "./staging.yaml"
name: my-service-migration
modules:
  - type: external-state
    name: external
    backend_type: s3
    config:
      bucket: opta-tf-state-my-org-staging
      key: my-service
      region: us-east-1
  - type: helm-chart
    name: dbmigration1
    namespace: my-service # This should be the name of the original service manifest being referred
    create_namespace: false
    repository: https://ameijer.github.io/k8s-as-helm/
    chart: job
    chart_version: 1.0.0
    values:
      nameOverride: "databaseMigration"
      restartPolicy: Never
      containers:
        hello:
          image: "${{module.external.outputs.current_image}}"
          extraSettings:
            env:
              - name: DBHOST
                valueFrom:
                  secretKeyRef:
                    name: secret
                    key: DBHOST
                    optional: true
              - name: DBNAME
                valueFrom:
                  secretKeyRef:
                    name: secret
                    key: DBNAME
                    optional: true
              - name: DBPASS
                valueFrom:
                  secretKeyRef:
                    name: secret
                    key: DBPASS
                    optional: true
              - name: DBUSER
                valueFrom:
                  secretKeyRef:
                    name: secret
                    key: DBUSER
                    optional: true
            command:
              - ./home/app/do_migration.sh # The user-created script to run migrations and added in the docker image
```
{{< /tab >}}
{{< /tabs >}}

This approach, while more explicit, does require the user to have knowledge of Kubernetes jobs, and to manually
connect the required database secrets from the secret set up for the k8s service link (**DO NOT** reference the db creds
as direct environment variables as they will be very visible-- note how in the examples we referred to the Kubernetes 
secrets created by the k8s service linking). The user will additionally need to update the `nameOverride` 
field for each run as each job run must have a new name (they can streamline this via [input variables](/features/input-variables)).
If these difficulties are manageable, then this approach offers a more formalized solution.

## Migrations Outside Opta
Using Opta does not limit one from using other migration strategies. Like all Opta resources, the database is created in
your cloud account and fully under your control. Opta does set up some networking permissions to restrict access of your
database from external networks (a very typical/expected security feature), but any migration mechanism created with
your network (or connected via a VPN) should have no problem accessing your database (assuming you provide it with the
credentials).
