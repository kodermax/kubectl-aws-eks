#!/bin/sh

set -e

# Check if KUBE_CONFIG_DATA environment variable is set
if [ -z "$KUBE_CONFIG_DATA" ]; then
    echo "Error: KUBE_CONFIG_DATA environment variable is not set"
    exit 1
fi

# Extract the base64 encoded config data and write this to the KUBECONFIG
echo "$KUBE_CONFIG_DATA" | base64 -d > /tmp/config
export KUBECONFIG=/tmp/config

# Check if config was successfully decoded
if [ ! -s /tmp/config ]; then
    echo "Error: Failed to decode KUBE_CONFIG_DATA"
    exit 1
fi

if [ ! -z "${KUBECTL_VERSION}" ]; then
    if [ ! -e /usr/bin/kubectl-${KUBECTL_VERSION} ]; then
        echo "Pulling kubectl for version $KUBECTL_VERSION"
        curl -sL -o /usr/bin/kubectl-${KUBECTL_VERSION} https://storage.googleapis.com/kubernetes-release/release/"$KUBECTL_VERSION"/bin/linux/$TARGETARCH/kubectl && \
            chmod +x /usr/bin/kubectl-${KUBECTL_VERSION} && \
            ln -f -s /usr/bin/kubectl-${KUBECTL_VERSION} /usr/bin/kubectl
    else
      ln -f -s /usr/bin/kubectl-${KUBECTL_VERSION} /usr/bin/kubectl
    fi
fi
echo "Using kubectl version: $(kubectl version --client 2>&1)"

if [ ! -z "${IAM_VERSION}" ]; then
    if [ ! -e /usr/bin/aws-iam-authenticator-${IAM_VERSION} ]; then
        echo "Pulling aws-iam-authenticator for version $IAM_VERSION"
        curl -sL -o /usr/bin/aws-iam-authenticator-${IAM_VERSION} https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v"$IAM_VERSION"/aws-iam-authenticator_"$IAM_VERSION"_linux_$TARGETARCH && \
            chmod +x /usr/bin/aws-iam-authenticator-${IAM_VERSION} && \
            ln -f -s /usr/bin/aws-iam-authenticator-${IAM_VERSION} /usr/bin/aws-iam-authenticator
    else
        ln -f -s /usr/bin/aws-iam-authenticator-${IAM_VERSION} /usr/bin/aws-iam-authenticator
    fi
fi
echo "Using aws-iam-authenticator version: $(aws-iam-authenticator version 2>&1)"

# Check if tools were successfully installed
if ! command -v kubectl >/dev/null 2>&1; then
    echo "Error: kubectl is not installed or not executable"
    exit 1
fi

if ! command -v aws-iam-authenticator >/dev/null 2>&1; then
    echo "Error: aws-iam-authenticator is not installed or not executable"
    exit 1
fi

if [ -z "$RUN_COMMAND" ] ; then
    sh -c "kubectl $*"
else
    sh -c "kubectl $RUN_COMMAND"        
fi
