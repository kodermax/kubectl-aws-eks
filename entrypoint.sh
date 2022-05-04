#!/bin/sh

set -e

# Extract the base64 encoded config data and write this to the KUBECONFIG
echo "$KUBE_CONFIG_DATA" | base64 -d > /tmp/config
export KUBECONFIG=/tmp/config

if [ -z ${KUBECTL_VERSION+x} ] ; then
    echo "Using kubectl version: $(kubectl version --client --short)"
else
    echo "Pulling kubectl for version $KUBECTL_VERSION"
    rm /usr/bin/kubectl
    curl -sL -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/"$KUBECTL_VERSION"/bin/linux/amd64/kubectl && \
        chmod +x /usr/bin/kubectl
    echo "Using kubectl version: $(kubectl version --client --short)"
fi

if [ -z ${IAM_VERSION+x} ] ; then
    echo "Using aws-iam-authenticator version: $(aws-iam-authenticator version)"
else
    echo "Pulling aws-iam-authenticator for version $IAM_VERSION"
    rm /usr/bin/aws-iam-authenticator
    curl -sL -o /usr/bin/aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v"$IAM_VERSION"/aws-iam-authenticator_"$IAM_VERSION"_linux_amd64 && \
    chmod +x /usr/bin/aws-iam-authenticator
    echo "Using aws-iam-authenticator version: $(aws-iam-authenticator version)"
fi

sh -c "kubectl $*"
