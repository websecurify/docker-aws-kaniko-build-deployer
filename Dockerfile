FROM gcr.io/kaniko-project/executor as kaniko

# ---
# ---
# ---

FROM golang:alpine AS amazon-ecr-credential-helper

RUN true \
    && apk add --no-cache \
        git \
        curl

WORKDIR /work

RUN true \
    && go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login

# ---
# ---
# ---

FROM alpine:latest

COPY --from=kaniko / /

RUN true \
    && apk add --no-cache bash curl git git-lfs zip unzip jq python3 py-pip \
    && pip install awscli

COPY --from=amazon-ecr-credential-helper /go/bin/docker-credential-ecr-login /bin/docker-credential-ecr-login

ENTRYPOINT ["executor"]

# copied from https://github.com/GoogleContainerTools/kaniko/blob/master/deploy/Dockerfile
ENV HOME /root
ENV USER root
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/kaniko
ENV SSL_CERT_DIR=/kaniko/ssl/certs
ENV DOCKER_CONFIG /kaniko/.docker/
ENV DOCKER_CREDENTIAL_GCR_CONFIG /kaniko/.config/gcloud/docker_credential_gcr_config.json
WORKDIR /workspace

# ---
