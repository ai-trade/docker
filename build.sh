#!/usr/bin/env sh

cd $(dirname "$0")

# 要想使用 buildx，首先要确保 Docker 版本不低于 19.03，同时还要通过设置环境变量 DOCKER_CLI_EXPERIMENTAL 来启用。
export DOCKER_CLI_EXPERIMENTAL=enabled

# docker buildx create \
#   --use \
#   --config config.toml\
#   --name insecure-builder \
#   --buildkitd-flags '--allow-insecure-entitlement security.insecure --allow-insecure-entitlement network.host' --use
# # #  --driver-opt env.ENV_NAME=ENV_VALUE
# docker buildx use insecure-builder
# docker buildx build --allow security.insecure -t renwucool/dev .
docker build -t renwucool/dev .
# docker buildx build -t renwu/dev .
# docker buildx create --use --name insecure-builder --buildkitd-flags '--allow-insecure-entitlement security.insecure'
