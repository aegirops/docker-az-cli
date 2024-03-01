FROM --platform=linux/amd64 debian:bookworm-slim AS az_cli

# Install curl and gnupg2
RUN apt-get update -y
RUN apt-get install -y \
    curl \
    gnupg2 \
    apt-transport-https \
    dnsutils

# Add docker apt repository
RUN echo "deb [arch=amd64] https://download.docker.com/linux/debian bookworm stable" >> /etc/apt/sources.list \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

# Install dependencies
RUN apt-get update -y
RUN apt-get install -y \
    sudo \
    curl \
    ca-certificates \
    wget \
    git \
    gettext-base \
    jq \
    net-tools \
    python3 \
    python3-pip \
    python3-magic

# Install docker
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y docker-ce-cli docker-compose-plugin

# Install azure cli and kubelogin plugin
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
RUN az aks install-cli

# Install postgresql
RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
RUN sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN sudo apt-get update -y
RUN sudo apt-get install postgresql-client-15 -y

# Add new user ci and set sudo without password
RUN adduser --disabled-password --gecos "" ci
RUN echo "ci     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install kubectl from google official source
RUN curl -o /usr/local/bin/kubectl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Install ytt yaml templating tool
RUN curl -o /usr/local/bin/ytt -LO https://github.com/vmware-tanzu/carvel-ytt/releases/download/v0.45.3/ytt-linux-amd64 \
    && chmod +x /usr/local/bin/ytt

# Install s3cmd
RUN rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED
RUN pip3 install s3cmd

# Cleanup
RUN apt-get clean -y

# Use ci user and run bash
USER ci

CMD ["bash"]

FROM az_cli AS az_cli_nodejs_18

# Use root user
USER root

# Install node from linux binaries

RUN curl -o /tmp/node.tar.xz -LO https://nodejs.org/dist/v18.19.1/node-v18.19.1-linux-x64.tar.xz

RUN tar -xf /tmp/node.tar.xz -C /tmp

RUN cp -r /tmp/node-v18.19.1-linux-x64/lib/*  /lib/.

RUN cp -r /tmp/node-v18.19.1-linux-x64/bin/*  /bin/.

RUN rm -f /tmp/node.tar.xz

RUN node -v

