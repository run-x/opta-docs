#!/bin/bash

OPTAVERSION=0.19.0

# Architecture check
ARCH=""
case $(uname -m) in
    x86_64) ARCH="amd64" ;;
    arm64) ARCH="arm64" ;;
    *) 
      echo -n "Unknown machine architecture, opta.sh is not supported in this environment"
      exit 1
      ;;
esac

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     OSNAME=Linux;;
    Darwin*)    OSNAME=Darwin;;
    *)          
        echo -n "Unknown OS UNKNOWN:${unameOut}, opta.sh is not supported in this environment"
        exit 1
        ;;
esac

if [[ "$ARCH" == "amd64" && "$OSNAME" == "Linux" ]]; then
#Versions and binary URLs
    echo "Detected Linux + Amd64!"
    OPTAURL="https://dev-runx-opta-binaries.s3.amazonaws.com/linux/$OPTAVERSION/opta.zip"
    TERRAFORMURL="https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip"
    AWSCLI2URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    KUBECTLURL="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$ARCH/kubectl"
    GOOGLEURL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-365.0.1-linux-x86_64.tar.gz"
    DOCKERURL="https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz"
fi

if [[ "$ARCH" == "arm64" && "$OSNAME" == "Darwin" ]]; then
    echo "Detected Apple Silicon Darwin + Arm64!"
    echo "Sorry, Opta docker run is not available for this configuration."
    echo "Please follow the instructions at https://docs.opta.dev/installation/ to install Opta directly on your host."
    exit 1
    # Apple silicon issues, some of these binaries are not working https://github.com/docker/for-mac/issues/5123
    # OPTAURL="https://dev-runx-opta-binaries.s3.amazonaws.com/linux/$OPTAVERSION/opta.zip"
    # TERRAFORMURL="https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip"
    # AWSCLI2URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    # KUBECTLURL="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$ARCH/kubectl"
    # GOOGLEURL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-365.0.1-linux-x86_64.tar.gz"
    # DOCKERURL="https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz"
fi

if [[ "$ARCH" == "amd64" && "$OSNAME" == "Darwin" ]]; then
    echo "Detected Apple Intel Darwin + Amd64!"
    OPTAURL="https://dev-runx-opta-binaries.s3.amazonaws.com/linux/$OPTAVERSION/opta.zip"
    TERRAFORMURL="https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip"
    AWSCLI2URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
    KUBECTLURL="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$ARCH/kubectl"
    GOOGLEURL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-365.0.1-linux-x86_64.tar.gz"
    DOCKERURL="https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz"
fi

if  [ ! "$(command -v docker)" ]; then
    echo "opta.sh requires Docker on your machine, please install docker."
    exit 1
fi

##
MYUID=`id -u ${USER}`
MYGID=`id -g ${USER}`
CONTAINERGID=$(( MYGID < 1000 ? 12345 : MYGID ))



mkdir -p /tmp/opta

cat << EOF > /tmp/opta/install.sh
#! /usr/bin/env bash

set -u

NONINTERACTIVE=1

echo "Going to install opta v$OPTAVERSION"

echo $OPTAURL
echo "Downloading installation package..."
curl -s ${OPTAURL} -o /tmp/opta.zip --fail
if [[ $? != 0 ]]; then
  echo "Version $OPTAVERSION not found."
  echo "Please check the available versions at https://github.com/run-x/opta/releases."
  exit 1
fi


echo "Installing..."
unzip -q /tmp/opta.zip -d /usr/local/bin/opta
chmod u+x /usr/local/bin/opta/opta
chown -R ${USER}:${USER} /usr/local/bin/opta

EOF

chmod +x /tmp/opta/install.sh

cat << EOF > /tmp/opta/Dockerfile
# base image
FROM python:3.8.12-bullseye
RUN apt-get update

# aws cli
RUN apt install unzip curl groff less -y
RUN curl "$AWSCLI2URL" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm  awscliv2.zip

# gcp cli 
RUN curl "$GOOGLEURL" -o "googlecloudsdk.tar.gz"
RUN tar -xvzf googlecloudsdk.tar.gz; sleep 1
RUN rm googlecloudsdk.tar.gz
ENV PATH="$PATH:/google-cloud-sdk/bin"

# terraform
RUN curl "$TERRAFORMURL" -o "terraform.zip"
RUN unzip terraform.zip -d /usr/local/bin
RUN chmod +x /usr/local/bin/terraform
RUN rm terraform.zip

# kubectl
RUN curl -LO "$KUBECTLURL"
RUN chmod +x kubectl
RUN mv kubectl /usr/local/bin

# helm - script is smart enough to handle different architectures
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# locales
RUN apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DOCKER_HOST=tcp://localhost:2375


# build time env args

ARG HOME
ARG OPTAVERSION

# add user
RUN groupadd -g ${CONTAINERGID} ${USER}
RUN useradd ${USER} -m -d ${HOME} -u ${MYUID} -g ${CONTAINERGID} 

# docker (install after adding docker group above)
RUN curl $DOCKERURL -o docker.tar.gz
RUN tar xvzf docker.tar.gz
RUN cp docker/* /usr/local/bin
RUN rm docker.tar.gz
RUN rm -rf docker/

# clean up
RUN apt-get clean

# opta
ADD install.sh /tmp/install.sh
RUN /bin/bash -c "/tmp/install.sh"


USER ${USER}
WORKDIR ${HOME}

ENTRYPOINT ["/usr/local/bin/opta/opta"]
EOF

echo "Building your Opta image"
# Build the docker image
docker build --quiet /tmp/opta \
--build-arg HOME=${HOME} \
--build-arg OPTAVERSION=${OPTAVERSION} \
--tag=opta-${USER}:${OPTAVERSION} 
echo "Done building Opta image"
## Inject Opta-specific env vars from host env shell into the docker container
declare -a opta_envvars=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "MONGODB_ATLAS_PUBLIC_KEY" "MONGODB_ATLAS_PRIVATE_KEY")
>/tmp/opta/opta_env_vars #Empty out any pre-existing file
for i in "${opta_envvars[@]}"
do
if [[  "${i}" ]]; then
    env | grep ${i} >> /tmp/opta/opta_env_vars
fi
done


# Docker proxy to connect to docker daemon on host from the container
cat << EOF > /tmp/opta/proxy_env_vars
AUTH=1
SECRETS=1
POST=1
BUILD=1
COMMIT=1
CONFIGS=1
CONTAINERS=1
DISTRIBUTION=1
EXEC=1
GRPC=1
IMAGES=1
INFO=1
NETWORKS=1
NODES=1
PLUGINS=1
SERVICES=1
SESSION=1
SWARM=1
SYSTEM=1
TASKS=1
VOLUMES=1
EOF

# Docker run docker proxy that controls host docker daemon from inside a container
docker stop  dockerproxy > /dev/null 2>&1
docker rm  dockerproxy  > /dev/null 2>&1
sleep 1
docker container run \
    -d --privileged \
    --name dockerproxy \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 127.0.0.1:2375:2375 \
    --env-file /tmp/opta/proxy_env_vars \
    tecnativa/docker-socket-proxy

# Docker run opta container
docker run -it \
-v $HOME:$HOME \
--env-file /tmp/opta/opta_env_vars \
--net="host" \
--user ${MYUID}:${CONTAINERGID} \
--workdir $PWD \
opta-${USER}:${OPTAVERSION}  $@


# Reset permissions of files on host if needed
# if [[ "$MYGID" != "$CONTAINERGID" ]]; then
#   $(chown -R ${MYUID}:${MYGID} $HOME/.opta)
# fi

# Cleanup
rm -rf /tmp/opta
docker stop  dockerproxy > /dev/null 2>&1
docker rm  dockerproxy  > /dev/null 2>&1
