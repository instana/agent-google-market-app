# Tool Prerequisites

## Google Marketplace App tools

See the [official documentation](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/building-deployer.md#using-the-mpdev-development-tools) to review the prerequisites and install the required tools.

## gcloud

Install gcloud and authenticate:
```
gloud login auth
```

Install gcloud docker-credential-gcr and configure private registry:
```
gcloud components install docker-credential-gcr
docker-credential-gcr configure-docker
```

# Rules

We are creating an app with building blocks from our existing helm chart. There are rules different rules for Helm chart and Google market app. While helm recommends RBAC and SA, that is forbidden with Google Marketplace App. ClusterRole, ClusterRoleBinding and ServiceAccount are defined in `schema.yaml`.

# Required params for Instana Agent

```
- name
- namespace
- zone.name | default "k8s-cluster"
- agent.key
- agent.endpointHost | default "saas-us-west-2.instana.io"
- agent.endpointPort | default "443"
```

# RUN

To test your changes:
```
mpdev /scripts/install \
--deployer=$REGISTRY/$APP_NAME/deployer \
--parameters='{
"name": "instana-agent",
"namespace": "instana-agent",
"zone.name": "k8s-testing",
"agent.key": "key",
"agent.endpointHost": "saas-eu-west-1.instana.io",
"agent.endpointPort": "443"}'
```

To push your changes to GCR, see [`deploy.sh`](deploy.sh)
