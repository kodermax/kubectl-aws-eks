FROM amazon/aws-cli

RUN curl -LO https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.15/2022-10-31/bin/linux/amd64/kubectl && \
    curl -o /usr/local/bin/aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64 && \
    chmod +x /usr/local/bin/aws-iam-authenticator && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/bin/kubectl 

RUN kubectl version --client
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
