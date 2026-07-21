FROM mcr.microsoft.com/playwright:v1.61.1-noble

ARG NODE_VERSION="24.18.0"
ARG PNPM_VERSION="11"

USER root

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

# matches our gh runner uid/gid
ARG RUNNER_UID=2001
ARG RUNNER_GID=2001

RUN set -eux; \
    usermod -l runner pwuser; \
    usermod -d /home/runner -m runner; \
    groupmod -g "${RUNNER_GID}" pwuser; \
    usermod  -u "${RUNNER_UID}" runner; \
    chown -R "${RUNNER_UID}:${RUNNER_GID}" /home/runner

USER runner
WORKDIR /home/runner
