# Tool Prerequisites

## Dev image
Install Docker and pull dev tools necessary for developing app:
`sudo docker pull gcr.io/cloud-marketplace-tools/k8s/dev`

You can omit `sudo` by adding your account do docker group and rebooting your PC:
```
sudo usermod -aG docker $USER
```

Extract tools:
```
BIN_FILE="$HOME/bin/mpdev"
docker run \
  gcr.io/cloud-marketplace-tools/k8s/dev \
  cat /scripts/dev > "$BIN_FILE"
chmod +x "$BIN_FILE"
```
## Run the doctor tool

Run the following to diagonose and correctl setup your environment:
```
mpdev /scripts/doctor.py
```

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

# Install CRD

To run this kind of apps, k8s needs installed CRD.

```
git clone https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools.git
cd marketplace-k8s-app-tools/crd
kubectl apply -f app-crd.yaml
```

# Rules

We are creating an app with our existing helm chart. There are rules different rules for Helm chart and Google market app. While helm recommends RBAC and SA, that is forbidden with Google market App.
ClusterRole, ClusterRoleBinding and ServiceAccount are defined in schema.yaml

# Required params for Instana Agent

```
- name
- namespace
- instana.zone | default "k8s-cluster"
- instana.agent.key
- instana.agent.endpoint.host | default "saas-us-west-2.instana.io"
- instana.agent.endpoint.port | default "443"
```

# RUN
```
#!/usr/bin/env bash
export REGISTRY=gcr.io/k8s-brewery
export APP_NAME=instana-agent
sudo docker build --tag $REGISTRY/$APP_NAME/deployer .
sudo docker push $REGISTRY/$APP_NAME/deployer
mpdev /scripts/install \
--deployer=$REGISTRY/$APP_NAME/deployer \
--parameters='{
"name": "instana-agent",
"namespace": "instana-agent",
"instana.zone": "k8s-testing",
"instana.agent.key": "key",
"instana.agent.endpoint.host": "saas-eu-west-1.instana.io",
"instana.agent.endpoint.port": "443"}'
```
