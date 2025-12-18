# Dockerfile (top-level for Part 2)
FROM docker:24-dind

# Install utilities, curl, bash
RUN apk add --no-cache bash curl tar gzip make git jq

# Install kubectl 
ENV KUBECTL_VERSION=v1.31.0
RUN curl -fsSL https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# Install k3d 
ENV K3D_VERSION=v5.8.3
RUN curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | \
    TAG=${K3D_VERSION} bash

# Install helm 
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

WORKDIR /workspace
COPY . /workspace

COPY run_cluster.sh /run_cluster.sh
RUN chmod +x /run_cluster.sh

ENTRYPOINT ["/run_cluster.sh"]
