---
title: "Continuous Deployment"
linkTitle: "Continuous Deployment"
date: 2020-02-01
draft: false
description: >
  Instructions to integrate with CI/CD platform of your choice
---

## Github Action
If you are using Github Actions for your CI, you can use the [`run-x/deploy-action`](https://github.com/run-x/deploy-action) action. This action will push your local docker image up to a remote registry and then deploy that image.

### Authentication
Before calling `run-x/deploy-action`, you will need to call two other Github actions:
1. [`webfactory/ssh-agent`](https://github.com/run-x/webfactory/ssh-agent), to allow access to other repositories' opta configuration files.
2. [`aws-actions/configure-aws-credentials`](https://github.com/run-x/aws-actions/configure-aws-credentials), to allow push and deploy to AWS.

### Example

```yml

name: CI-CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  opta-deploy-staging:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v2

      - name: Setup ssh
        uses: webfactory/ssh-agent@v0.4.1
        with:
          ssh-private-key: ${{ secrets.SSH_KEY }}

      - name: Configure AWS credentials	
        uses: aws-actions/configure-aws-credentials@v1	
        with:	
          aws-access-key-id: ${{ secrets.DEPLOYER_AWS_ACCESS_KEY }}	
          aws-secret-access-key: ${{ secrets.DEPLOYER_AWS_SECRET_ACCESS_KEY }}	
          aws-region: us-east-1	

      - name: Build image
        run: docker build -t app:latest -f Dockerfile .

      - name: Update deployment
        uses: run-x/deploy-action@v0.6
        with:
          env: runx-staging
          image: app:latest
          tag: ${{ github.sha }}

```
