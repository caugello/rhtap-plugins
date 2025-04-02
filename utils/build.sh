#!/bin/bash
# PLUGINS_OUTPUT=/tmp/plugins-output/
# PLUGINS_WORKSPACE=$PWD
#
# rm -Rf $PLUGINS_OUTPUT
# mkdir -p PLUGINS_OUTPUT

for plugin in $(ls ${PLUGINS_WORKSPACE}/packages)
do
  echo "$plugin"
  cd "$PLUGINS_WORKSPACE/packages/$plugin" && \
  yarn clean-build && \
  yarn install --immutable && \
  yarn tsc && \
  yarn build && \
  npx --yes @janus-idp/cli@latest package export-dynamic-plugin && \
  npx --yes @janus-idp/cli@latest package package-dynamic-plugins --export-to $PLUGINS_OUTPUT && \
  mv "$PLUGINS_OUTPUT/index.json" "$PLUGINS_OUTPUT/$plugin-index.json"
done
jq -c -s 'flatten' $PLUGINS_OUTPUT/*-index.json > $PLUGINS_OUTPUT/index.json && \
rm -f $PLUGINS_OUTPUT/*-index.json


