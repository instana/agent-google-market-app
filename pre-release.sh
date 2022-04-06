#!/usr/bin/env bash
set -o errexit

# mpdev tooling version
# https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/releases
MARKETPLACE_TOOLS_TAG=$(<MARKETPLACE_TOOLS_TAG xargs)

REGISTRY=gcr.io/instana-public

VERSION=$(<VERSION xargs)
DEPLOYER_TAG=${VERSION%.*}
APP_NAME=instana-agent

LEADER_ELECTOR_VERSION=$(<LEADER_ELECTOR_VERSION xargs)

# Change version of chart/instana-agent/templates/application.yaml
# for macOS you need gnu-sed to get the same result
# https://formulae.brew.sh/formula/gnu-sed
SED_CMD="sed"
if [ -x "$(command -v gsed)" ]; then SED_CMD="gsed"; fi
("$SED_CMD" -r "s/^(\s*version\s*:\s*).*/\1'${VERSION}'/" -i chart/instana-agent/templates/application.yaml)

# build and push new deployer
docker build \
  --build-arg REGISTRY="$REGISTRY" \
  --build-arg APP_NAME=$APP_NAME \
  --build-arg TAG="$VERSION" \
  --build-arg MARKETPLACE_TOOLS_TAG="$MARKETPLACE_TOOLS_TAG" \
  --build-arg DEPLOYER_TAG="$DEPLOYER_TAG" \
  --file deployer/Dockerfile \
  --tag "$REGISTRY/$APP_NAME/deployer:$DEPLOYER_TAG" .
docker image tag "$REGISTRY/$APP_NAME/deployer:$DEPLOYER_TAG" "$REGISTRY/$APP_NAME/deployer:$VERSION"
docker image push --all-tags "$REGISTRY/$APP_NAME/deployer"

# build and push new tester
docker build --tag "$REGISTRY/$APP_NAME/tester:$VERSION" apptest/tester
docker image tag "$REGISTRY/$APP_NAME/tester:$VERSION" "$REGISTRY/$APP_NAME/tester:$DEPLOYER_TAG"
docker image push --all-tags "$REGISTRY/$APP_NAME/tester"

# update leader-elector image
LEADER_ELECTOR_SRC="icr.io/instana/leader-elector:$LEADER_ELECTOR_VERSION"
LEADER_ELECTOR_DST="gcr.io/instana-public/instana-agent/leader-elector"
docker pull "$LEADER_ELECTOR_SRC"
docker image tag "$LEADER_ELECTOR_SRC" "$LEADER_ELECTOR_DST:$LEADER_ELECTOR_VERSION"
docker image tag "$LEADER_ELECTOR_SRC" "$LEADER_ELECTOR_DST:$VERSION"
docker image tag "$LEADER_ELECTOR_SRC" "$LEADER_ELECTOR_DST:$DEPLOYER_TAG"
docker image push --all-tags "$LEADER_ELECTOR_DST"

# update agent image
AGENT_SRC="gcr.io/instana-public/instana-agent:latest"
AGENT_DST="gcr.io/instana-public/instana-agent"
docker pull "$AGENT_SRC"
docker image tag "$AGENT_SRC" "$AGENT_DST:$VERSION"
docker image tag "$AGENT_SRC" "$AGENT_DST:$DEPLOYER_TAG"
docker image push --all-tags "$AGENT_DST"

# Tool Prerequisites https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/tool-prerequisites.md
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"

# verify new pre-release
mpdev verify --deployer="$REGISTRY/$APP_NAME/deployer:$DEPLOYER_TAG"
