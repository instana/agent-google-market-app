#!/usr/bin/env bash

# mpdev tooling version
# https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/releases
MARKETPLACE_TOOLS_TAG=$(<MARKETPLACE_TOOLS_TAG xargs)

REGISTRY=gcr.io/instana-public

DEPLOYER_TAG=$(<DEPLOYER_TAG xargs)
TAG="${DEPLOYER_TAG}.$(<PATCH_VERSION xargs)"
APP_NAME=instana-agent


# build and push new deployer
docker build \
  --build-arg REGISTRY="$REGISTRY" \
  --build-arg APP_NAME=$APP_NAME \
  --build-arg TAG=$TAG \
  --build-arg MARKETPLACE_TOOLS_TAG="$MARKETPLACE_TOOLS_TAG" \
  --build-arg DEPLOYER_TAG="$DEPLOYER_TAG" \
  --file deployer/Dockerfile \
  --tag "$REGISTRY"/$APP_NAME/deployer:"$DEPLOYER_TAG" .
docker push "$REGISTRY"/$APP_NAME/deployer:"$DEPLOYER_TAG"

# build and push new tester
docker build --tag "$REGISTRY"/$APP_NAME/tester:"$TAG" apptest/tester
docker push "$REGISTRY"/$APP_NAME/tester:"$TAG"

mpdev verify --deployer="$REGISTRY"/$APP_NAME/deployer:"$DEPLOYER_TAG"
