FROM pipelineai/ubuntu:16.04-cpu-master

WORKDIR /root

RUN \
  rm /bin/sh \
  && ln -s /bin/bash /bin/sh

# Install Python with conda
RUN wget -q https://repo.continuum.io/miniconda/Miniconda3-4.3.21-Linux-x86_64.sh -O /tmp/miniconda.sh  && \
    echo 'c1c15d3baba15bf50293ae963abef853 */tmp/miniconda.sh' | md5sum -c - && \
    bash /tmp/miniconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes python=3.6 sqlalchemy tornado jinja2 traitlets requests pip && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/miniconda.sh

ENV \
  PATH=/opt/conda/bin:$PATH

RUN \
  conda install --yes openblas scikit-learn numpy scipy ipython jupyter matplotlib pandas

ENV KUBERNETES_VERSION=1.8.4
ENV KUBERNETES_HOME=/root/kubernetes/

RUN \
  wget https://storage.googleapis.com/kubernetes-release/release/v$KUBERNETES_VERSION/kubernetes.tar.gz \
  && tar -xzvf kubernetes.tar.gz \
  && rm kubernetes.tar.gz

RUN \
  wget https://storage.googleapis.com/kubernetes-release/release/v$KUBERNETES_VERSION/bin/linux/amd64/kubectl \
  && chmod a+x kubectl \
  && mv kubectl /usr/local/bin/kubectl

RUN \
  wget https://storage.googleapis.com/kubernetes-release/release/v$KUBERNETES_VERSION/bin/linux/amd64/kubefed \
  && chmod a+x kubefed \
  && mv kubefed /usr/local/bin/kubefed

#RUN \
#  echo -en "\n" | $KUBERNETES_HOME/cluster/get-kube-binaries.sh

#ENV \
#  PATH=$KUBERNETES_HOME/client/bin:$PATH

ENV KOPS_VERSION=1.8.0-beta.1
ENV KOPS_HOME=/root/kops/

RUN \
  mkdir -p $KOPS_HOME \
  && cd $KOPS_HOME \
  && wget https://github.com/kubernetes/kops/releases/download/$KOPS_VERSION/kops-linux-amd64 \
  && mv kops-linux-amd64 kops \
  && chmod a+x kops

ENV \
  PATH=$KOPS_HOME:$PATH

ENV \
  TERRAFORM_VERSION=0.11.0

ENV \
  TERRAFORM_HOME=/root/terraform

RUN \
  mkdir -p $TERRAFORM_HOME \
  && cd $TERRAFORM_HOME \ 
  && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ENV \
  PATH=$TERRAFORM_HOME:$PATH

RUN \
  apt-get update

# Install AWS CLI
RUN \
  pip install --upgrade awscli

RUN \
  pip install --upgrade packaging 

RUN \
  pip install --upgrade appdirs

# Install Google Cloud SDK
# Note:  This includes kubectl and others that may be older version.   
#        We will override these versions later.
RUN \
  echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN \
  apt-get update \
  && apt-get install -y google-cloud-sdk

RUN \
  apt-get update && apt-get install -y libssl-dev libffi-dev python-dev build-essential \
  && echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/azure-cli/ wheezy main" | tee /etc/apt/sources.list.d/azure-cli.list \
  && apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893 \
  && apt-get install -y apt-transport-https \
  && apt-get update \
  && apt-get install -y azure-cli 

# Create empty ~/.kube directory.
# Note:  This is where the Kubernetes config is stored by default
RUN \
  mkdir -p ~/.kube

# Install Helm
ENV \
  HELM_VERSION=2.7.2
RUN \
  wget https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  && tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && rm helm-v${HELM_VERSION}-linux-amd64.tar.gz

# Install Minikube
ENV MINIKUBE_VERSION=0.23.0
RUN \
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/v${MINIKUBE_VERSION}/minikube-linux-amd64 \
  && chmod a+x minikube \
  && mv minikube /usr/local/bin/

# Install Istio
ENV ISTIO_VERSION=0.2.12
RUN \
  curl -L https://git.io/getLatestIstio | ISTIO_VERSION=${ISTIO_VERSION} sh - 

# Install Docker
RUN \
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

RUN \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88

RUN \
  add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  && apt-get update

RUN \
  apt-get install -y docker-ce

ENV PIPELINE_CLI_VERSION=1.4.16
RUN \
  pip install cli-pipeline==${PIPELINE_CLI_VERSION}
