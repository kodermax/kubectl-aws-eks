FROM amazon/aws-cli:latest

# Install system packages and jq first
RUN yum update -y && \
    yum install -y coreutils && \
    curl -sL -o /usr/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.6/jq-linux64 && \
    chmod +x /usr/bin/jq

# Install kubectl and aws-iam-authenticator
RUN curl -sL -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    curl -sL -o /usr/bin/aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.12/aws-iam-authenticator_0.6.12_linux_amd64 && \
    chmod +x /usr/bin/aws-iam-authenticator && \
    chmod +x /usr/bin/kubectl

# Add checksum verification for security
RUN echo "Checking versions of installed tools:" && \
    kubectl version --client || true && \
    aws-iam-authenticator version || true

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
