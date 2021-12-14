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

## Rules

We are creating an app with building blocks from our existing helm chart. 
There are rules different rules for Helm chart and Google market app. 
While helm recommends RBAC and SA, that is forbidden with Google Marketplace App. 
ClusterRole, ClusterRoleBinding and ServiceAccount are defined in `schema.yaml`.

## Required params for Instana Agent

```
- name
- namespace
- zone.name | default "k8s-cluster"
- agent.key
- agent.endpointHost | default "ingress-red-saas.instana.io"
- agent.endpointPort | default "443"
```

## Test & Upload

This will upload deployer and tester image to the registry.
The GCP Marketplace will copy these images to the Marketplace registry after a new App is releases.

To test your changes, run:

```
./verify.sh
```
