---
title: "Continuous Deployment"
linkTitle: "Continuous Deployment"
date: 2022-01-03
draft: false
description: >
  Instructions to integrate with the CI/CD platform of your choice
---

## Github Action

If you are using Github Actions for your CI, you can use the [`run-x/deploy-action`](https://github.com/run-x/deploy-action) action. This action will push your local docker image up to a remote registry and then deploy that image.

### Authentication

In order for the deploy action to execute properly, you will need to use other github actions for authentication.

1. [`webfactory/ssh-agent`](https://github.com/webfactory/ssh-agent), to allow access to other repositories' Opta configuration files. Note that you only need to use this if you have `opta.yaml` files in other repos.
2. [`aws-actions/configure-aws-credentials`](https://github.com/aws-actions/configure-aws-credentials), to allow push and deploy to AWS. Make sure that the API key associated with this account has admin permissions.

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

      # You only need to include this step if you have Opta files outside of this repo
      - name: Setup ssh
        uses: webfactory/ssh-agent@v0.4.1
        with:
          # if you don't have a github SSH key, you can generate one here:
          # https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
          ssh-private-key: ${{ secrets.GITHUB_SSH_KEY }}

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          # This aws account should have admin permissions
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Build image
        run: docker build -t app:latest -f Dockerfile .

      - name: Update deployment
        uses: run-x/deploy-action@v1.0
        with:
          env: runx-staging
          image: app:latest
          tag: ${{ github.sha }}
```
