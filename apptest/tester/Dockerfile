FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.4

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/kubectl/1.22 \
    && wget -q -O /opt/kubectl/1.22/kubectl \
       https://storage.googleapis.com/kubernetes-release/release/v1.22.4/bin/linux/amd64/kubectl \
    && chmod 755 /opt/kubectl/1.22/kubectl \
    && ln -s /opt/kubectl/1.22/kubectl /usr/bin/kubectl

COPY tests /tests
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]