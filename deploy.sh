#!/usr/bin/env bash
export REGISTRY=gcr.io/instana-public
export DEPLOYER_TAG=1.6
export TAG=latest
export APP_NAME=instana-agent

sudo docker build \
--build-arg REGISTRY=$REGISTRY \
--build-arg APP_NAME=$APP_NAME \
--build-arg TAG=$TAG \
--tag $REGISTRY/$APP_NAME/deployer:$DEPLOYER_TAG .

sudo docker push $REGISTRY/$APP_NAME/deployer:$DEPLOYER_TAG
