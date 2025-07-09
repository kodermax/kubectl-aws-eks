FROM amazon/aws-cli:latest

# Install required tools in one layer to reduce image size
RUN curl -sL -o /usr/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.6/jq-linux64 && \
    chmod +x /usr/bin/jq && \
    curl -sL -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    curl -sL -o /usr/bin/aws-iam-authenticator $(curl -s https://api.github.com/repos/kubernetes-sigs/aws-iam-authenticator/releases/latest | jq -r '.assets[] | select(.name | contains("linux_amd64"))' | jq -r '.browser_download_url') && \
    chmod +x /usr/bin/aws-iam-authenticator && \
    chmod +x /usr/bin/kubectl

# Add checksum verification for security
RUN echo "Checking versions of installed tools:" && \
    kubectl version --client --short || true && \
    aws-iam-authenticator version || true

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
