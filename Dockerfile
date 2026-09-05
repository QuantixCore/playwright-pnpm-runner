# Must match "@playwright/test" in invo's pnpm-workspace.yaml catalog
FROM mcr.microsoft.com/playwright:v1.61.1-noble

ARG PNPM_VERSION="12"

USER root

ENV PNPM_HOME="/usr/local/pnpm"
ENV PATH="$PNPM_HOME/bin:$PATH"
RUN curl -fsSL https://get.pnpm.io/install.sh | \
    env PNPM_VERSION="${PNPM_VERSION}" SHELL=/bin/bash ENV=/root/.bashrc bash - \
    && chmod -R a+rX "$PNPM_HOME" \
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
