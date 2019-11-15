FROM launcher.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/instana-agent /tmp/chart

RUN cd /tmp && tar -czvf /tmp/instana-agent.tar.gz chart

# This should be uncommented when tests will be implemented
ADD apptest/deployer/instana-agent /tmp/test/chart
RUN cd /tmp/test && tar -czvf /tmp/test/instana-agent.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml

ARG REGISTRY
ARG APP_NAME
ARG TAG

RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "APP_NAME=$APP_NAME" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml

ADD apptest/deployer/schema.yaml /tmp/apptest/schema.yaml

RUN cat /tmp/apptest/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "APP_NAME=$APP_NAME" "TAG=$TAG" envsubst \
    > /tmp/apptest/schema.yaml.new \
    && mv /tmp/apptest/schema.yaml.new /tmp/apptest/schema.yaml

# Using GCP Marketplace HELM deployer
FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm
COPY --from=build /tmp/instana-agent.tar.gz /data/chart/
# this should be uncommented when tests will be implemented
COPY --from=build /tmp/test/instana-agent.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/
