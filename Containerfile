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
    dnf -y install jq

RUN bash utils/build.sh && \
    mkdir -p $PLUGINS_OUTPUT/licenses && \
    cp -R $PLUGINS_WORKSPACE/LICENSE.TXT $PLUGINS_OUTPUT/licenses

USER 1001

FROM scratch

LABEL name="RHTAP backstage plugins" \
      com.redhat.component="rhtap" \
      vendor="Red Hat, Inc." \
      version="1" \
      release="5" \
      description="Artifact with Backstage plugins for RHTAP" \
      summary="Artifact with Backstage plugins for RHTAP" \
      url="https://github.com/redhat-appstudio/backstage-community-plugins" \
      distribution-scope="public"

COPY --chown=1001:1001 --from=builder /plugin-output /
