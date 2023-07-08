# Docker and Github Action for Kubernetes CLI

This action provides `kubectl` for Github Actions.

## Usage

`.github/workflows/push.yml`

```yaml
on: push
name: deploy
jobs:
  deploy:
    name: deploy to cluster
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-2
    
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1

    - name: deploy to cluster
      uses: kodermax/kubectl-aws-eks@master
      env:
        KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA_STAGING }}
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: my-app
        IMAGE_TAG: ${{ github.sha }}
      with:
        args: set image deployment/$ECR_REPOSITORY $ECR_REPOSITORY=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        
    - name: verify deployment
      uses: kodermax/kubectl-aws-eks@master
      env:
        KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
      with:
        args: rollout status deployment/my-app
```

## Secrets

`KUBE_CONFIG_DATA` – **required**: A base64-encoded kubeconfig file with credentials for Kubernetes to access the cluster. You can get it by running the following command:

### Bash
```bash
cat $HOME/.kube/config | base64
```
### PowerShell
```PowerShell
$base64Data = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\.kube\config"))
Write-Output $base64Data
```

Make sure that your `$HOME/.kube/config` doesn't contain a `AWS_PROFILE`, i.e. remove the following section if it exists before doing the base64 encoding:

```yaml
env:
- name: AWS_PROFILE
    value: github-actions
```

## Configurable Variables

`KUBECTL_VERSION` - **optional**: By default, this action pulls the latest version of kubectl. To prevent potential dependency issue, you have the option to only use specific version.

```yaml
      - name: deploy to cluster
        uses: kodermax/kubectl-aws-eks@master
        env:
          KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA_STAGING }}
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: my-app
          IMAGE_TAG: ${{ github.sha }
          KUBECTL_VERSION: "v1.22.0"
        with:
          args: set image deployment/$ECR_REPOSITORY $ECR_REPOSITORY=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
```

`IAM_VERSION` - **optional**: By default, this action pulls the latest version of aws-iam-authenticator. To prevent potential dependency issue, you have the option to only use specific version.

```yaml
      - name: deploy to cluster
        uses: kodermax/kubectl-aws-eks@master
        env:
          KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA_STAGING }}
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: my-app
          IMAGE_TAG: ${{ github.sha }
          KUBECTL_VERSION: "v1.22.0"
          IAM_VERSION: "0.5.6"
        with:
          args: set image deployment/$ECR_REPOSITORY $ECR_REPOSITORY=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
```
