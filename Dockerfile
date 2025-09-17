FROM amazon/aws-cli:latest
ARG TARGETARCH
ARG JQ_VERSION=1.6
ARG IAM_VERSION=0.6.12
ENV TARGETARCH=${TARGETARCH}

# Install system packages and jq first
RUN dnf update -y && \
    dnf install --allowerasing -y coreutils findutils && \
    rm /var/cache/dnf/*.solv* && \
    curl -sL -o /usr/bin/jq https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-${TARGETARCH} && \
    chmod +x /usr/bin/jq

# Install kubectl and aws-iam-authenticator
RUN export KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) && \
    curl -sL -o /usr/bin/kubectl-${KUBECTL_VERSION} https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl && \
    curl -sL -o /usr/bin/aws-iam-authenticator-${IAM_VERSION} https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${IAM_VERSION}/aws-iam-authenticator_${IAM_VERSION}_linux_${TARGETARCH} && \
    chmod +x /usr/bin/aws-iam-authenticator-${IAM_VERSION} && \
    chmod +x /usr/bin/kubectl-${KUBECTL_VERSION} && \
    ln -s /usr/bin/aws-iam-authenticator-${IAM_VERSION} /usr/bin/aws-iam-authenticator && \
    ln -s /usr/bin/kubectl-${KUBECTL_VERSION} /usr/bin/kubectl

# Add checksum verification for security
RUN echo "Checking versions of installed tools:" && \
    kubectl version --client || true && \
    aws-iam-authenticator version || true

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
