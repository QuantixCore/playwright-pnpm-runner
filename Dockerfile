FROM mcr.microsoft.com/playwright:v1.61.1-noble

ARG NODE_VERSION="24.18.0"
ARG PNPM_VERSION="11"

USER root

# Add Infisical APT repository
RUN curl -1sLf \
'https://artifacts-cli.infisical.com/setup.deb.sh' \
| bash

# Install required packages
RUN apt-get update && apt-get install -y curl wget gnupg ca-certificates xz-utils

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
