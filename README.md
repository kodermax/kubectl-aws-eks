# Docker and GitHub Action for AWS EKS Kubernetes CLI

This action provides a Docker container with `kubectl`, `aws-cli`, and `aws-iam-authenticator` pre-installed for GitHub Actions workflows. It's specifically designed for managing Kubernetes clusters on AWS EKS (Elastic Kubernetes Service).

## Overview

This container includes:
- AWS CLI (latest version)
- kubectl (configurable version)
- aws-iam-authenticator (configurable version)

It allows you to easily run kubectl commands against your AWS EKS clusters directly from your GitHub Actions workflows.

## Basic Usage

Create a workflow file (e.g., `.github/workflows/deploy.yml`):

```yaml
name: Deploy to EKS
on: push
jobs:
  deploy:
    name: Deploy to EKS cluster
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-2
    
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1

    - name: Deploy to EKS cluster
      uses: kodermax/kubectl-aws-eks@v1
      env:
        KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: my-app
        IMAGE_TAG: ${{ github.sha }}
      with:
        args: set image deployment/$ECR_REPOSITORY $ECR_REPOSITORY=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        
    - name: Verify deployment
      uses: kodermax/kubectl-aws-eks@v1
      env:
        KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
      with:
        args: rollout status deployment/my-app
```

## Required Secrets

### `KUBE_CONFIG_DATA` (Required)

A base64-encoded kubeconfig file with credentials for Kubernetes to access the cluster. You can generate this using:

#### Bash
```bash
cat $HOME/.kube/config | base64
```

#### PowerShell
```powershell
$base64Data = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\.kube\config"))
Write-Output $base64Data
```

> **Important Security Note**: Before encoding your kubeconfig, ensure it doesn't contain an `AWS_PROFILE` section. If present, remove the following section:
> ```yaml
> env:
> - name: AWS_PROFILE
>   value: github-actions
> ```

## Configurable Environment Variables

### `KUBECTL_VERSION` (Optional)

By default, this action uses the latest stable version of kubectl. To use a specific version:

```yaml
- name: Deploy to EKS cluster
  uses: kodermax/kubectl-aws-eks@v1
  env:
    KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
    ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
    ECR_REPOSITORY: my-app
    IMAGE_TAG: ${{ github.sha }}
    KUBECTL_VERSION: "v1.27.3"
  with:
    args: set image deployment/$ECR_REPOSITORY $ECR_REPOSITORY=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
```

### `IAM_VERSION` (Optional)

By default, this action uses the latest version of aws-iam-authenticator. To use a specific version:

```yaml
- name: Deploy to EKS cluster
  uses: kodermax/kubectl-aws-eks@v1
  env:
    KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
    ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
    ECR_REPOSITORY: my-app
    IMAGE_TAG: ${{ github.sha }}
    IAM_VERSION: "0.6.2"
  with:
    args: set image deployment/$ECR_REPOSITORY $ECR_REPOSITORY=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
```

## Advanced Use Cases

### Port Forwarding with Database Migrations

This example shows how to use the action as a service to forward a port from a Kubernetes service to your GitHub Actions runner, allowing database migrations to be applied:

```yaml
name: Deploy Database Migrations
on:
  pull_request:
    branches: [main]
    paths:
      - 'packages/database/**'
jobs:
  deploy:
    runs-on: ubuntu-latest
    services:
      db:
        image: kodermax/kubectl-aws-eks:latest
        env:
          KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA_TEST }}
          RUN_COMMAND: port-forward svc/postgresql-1697720510 5432:5432 --address='0.0.0.0'
        ports:
          - 5432:5432/tcp
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - name: Install dependencies
        run: pnpm install
      - name: Apply all pending migrations to the database
        env:
          DATABASE_URL: ${{ secrets.TEST_DATABASE_URL }}
        run: pnpm db-deploy
```

### Running Custom kubectl Commands

You can run any kubectl command by passing it as the `args` parameter:

```yaml
- name: Get pod information
  uses: kodermax/kubectl-aws-eks@v1
  env:
    KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
  with:
    args: get pods -n my-namespace
```

### Applying Kubernetes Manifests

```yaml
- name: Apply Kubernetes manifests
  uses: kodermax/kubectl-aws-eks@v1
  env:
    KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
  with:
    args: apply -f ./kubernetes/manifests/
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Ensure your KUBE_CONFIG_DATA is correctly base64 encoded and contains valid credentials.

2. **Version Compatibility**: If you encounter compatibility issues, try specifying explicit versions for kubectl and aws-iam-authenticator.

3. **Permission Issues**: Verify that the service account in your kubeconfig has the necessary permissions to perform the actions in your workflow.

## Security Best Practices

1. Store your KUBE_CONFIG_DATA as a GitHub secret, never hardcode it in your workflow files.

2. Use the principle of least privilege when configuring your kubeconfig file.

3. Consider using short-lived credentials or service accounts with limited permissions.

4. Regularly rotate your credentials and audit your GitHub Actions workflows.

