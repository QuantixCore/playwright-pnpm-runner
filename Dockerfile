FROM mcr.microsoft.com/playwright:v1.57.0-noble

ARG NODE_VERSION="24.12.0"
ARG PNPM_VERSION="latest"
ARG JAVA_VERSION="25"

USER root

# Add Infisical APT repository
RUN curl -1sLf \
'https://artifacts-cli.infisical.com/setup.deb.sh' \
| bash

# Install required packages
RUN apt-get update && apt-get install -y curl wget gnupg ca-certificates xz-utils infisical

# Install GraalVM
RUN wget https://download.oracle.com/graalvm/${JAVA_VERSION}/latest/graalvm-jdk-${JAVA_VERSION}_linux-x64_bin.tar.gz -O /tmp/graalvm.tar.gz && \
    mkdir -p /opt/graalvm && \
    tar -xzf /tmp/graalvm.tar.gz -C /opt/graalvm --strip-components=1 && \
    rm /tmp/graalvm.tar.gz

ENV GRAALVM_HOME=/opt/graalvm
ENV JAVA_HOME=/opt/graalvm
ENV PATH="$JAVA_HOME/bin:${PATH}"

# Required by keycloakify to build theme jar
# https://docs.keycloakify.dev/testing-your-theme/inside-of-keycloak#ubuntu-debian
RUN apt-get install -y maven

# Install Node.js
RUN wget --https-only "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -O /tmp/node.tar.xz && \
    tar -C /usr/local -xf /tmp/node.tar.xz --strip-components=1 --exclude="CHANGELOG.md" --exclude="LICENSE" --exclude="README.md" && \
    rm /tmp/node.tar.xz

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN npm install -g --no-update-notifier corepack@latest \
    && corepack enable \
    && corepack install --global pnpm@${PNPM_VERSION} \
    && echo "pnpm version $(pnpm --version)"

# Rename pwuser > runner, and rename its home directory
RUN usermod -l runner pwuser && \
    usermod -d /home/runner -m runner

USER runner
WORKDIR /home/runner
