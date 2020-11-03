FROM google/cloud-sdk

ENV SOPS_VERSION=3.0.4
ENV KUBEVAL_VERSION=0.7.3
ENV HELM_VERSION=2.10.0
ENV TERRAFORM_VERSION=0.12.6

# install pip & zip
RUN apt-get update && apt-get install -y python-pip git zip

# install helm
RUN curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
  tar -xzf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
  mv linux-amd64/helm /usr/local/bin && \
  rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

# install sops
RUN curl -LO https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb && \
  dpkg -i sops_${SOPS_VERSION}_amd64.deb && \
  rm sops_${SOPS_VERSION}_amd64.deb

# install kubeval
RUN curl -LO https://github.com/garethr/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz && \
  tar -xzvf kubeval-linux-amd64.tar.gz && \
  mv kubeval /usr/local/bin && \
  rm kubeval-linux-amd64.tar.gz

# install terraform
RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  mv terraform /usr/local/bin && \
  rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# install requirements
COPY requirements.txt /tmp
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
  rm /tmp/requirements.txt

# test it all
RUN pip --version && \
  sops --version && \
  kubeval --version && \
  jinja2 --version && \
  helm version -c && \
  terraform version && \
  aws --version

# install some terraform providers
COPY providers.tf .
RUN mkdir -p /opt/terraform && \
  terraform init && \
  mv .terraform/plugins/linux_amd64 /opt/terraform/plugins && \
  rm -Rf .terraform && \
  rm -Rf providers.tf
