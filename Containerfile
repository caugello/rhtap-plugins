FROM registry.redhat.io/ubi9/nodejs-20:latest AS builder

WORKDIR /plugin-workspace

ENV PLUGINS_OUTPUT="/plugin-output"
ENV PLUGINS_WORKSPACE="/plugin-workspace"

USER root

COPY . .

# Remove local settings
RUN rm -f .npmrc

# The recommended way of using yarn is via corepack. However, corepack is not included in the UBI
# image. Below we install corepack so we can install yarn.
# https://github.com/nodejs/corepack?tab=readme-ov-file#default-installs
# RPMs required for isolated-vm build
# https://github.com/laverdet/isolated-vm?tab=readme-ov-file#requirements
RUN \
    node --version && \
    npm install -g corepack && \
    corepack --version && \
    corepack enable yarn && \
    corepack use 'yarn@4' && \
    yarn --version && \
    mkdir -p $PLUGINS_OUTPUT && \
    dnf -y install zlib-devel brotli-devel jq

RUN bash utils/build.sh

FROM scratch

LABEL name="Backstage community plugins" \
      com.redhat.component="rhtap" \
      vendor="Red Hat, Inc." \
      version="1" \
      release="5" \
      description="Collection of Backstage community plugins" \
      io.k8s.description="Collection of Backstage community plugins" \
      url="https://github.com/redhat-appstudio/backstage-community-plugins" \
      distribution-scope="public"

COPY --from=builder $PLUGINS_OUTPUT /
