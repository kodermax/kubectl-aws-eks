#!/bin/sh

set -e

# Extract the base64 encoded config data and write this to the KUBECONFIG
echo "$KUBE_CONFIG_DATA" | base64 -d > /tmp/config
export KUBECONFIG=/tmp/config
if [ -z ${KUBECTL_VERSION+x} ] ; then
    echo "kubectl version: $(kubectl version --client --short)"
else
    echo "Repulling kubectl for version $KUBECTL_VERSION"
    rm /usr/bin/kubectl 
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl && \
        chmod +x kubectl && \
        mv kubectl /usr/local/bin/
    echo "kubectl version: $(kubectl version --client --short)"
fi
sh -c "kubectl $*"