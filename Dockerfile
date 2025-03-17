FROM docker:27-dind

# renovate: datasource=repology depName=alpine_3_21/git
ENV GIT_VERSION="2.47.2-r0"
# renovate: datasource=repology depName=alpine_3_21/docker-cli-compose
ENV DOCKER_CLI_COMPOSE_VERSION="2.31.0-r3"
# renovate: datasource=repology depName=alpine_3_21/bash
ENV BASH_VERSION="5.2.37-r0"

LABEL maintainer="Nico Jensch <root@dr460nf1r3.org>"
LABEL description="Docker in Docker with docker-compose and git, ready to use for CI/CD pipelines"
LABEL version="1.0"
LABEL org.opencontainers.image.source="https://github.com/dr460nf1r3/container-manager"
LABEL org.opencontainers.image.authors="Nico Jensch <root@dr460nf1r3.org>"
LABEL org.opencontainers.image.description="Docker in Docker with docker-compose and git, ready to use for CI/CD pipelines"
LABEL org.opencontainers.image.version="1.0"

HEALTHCHECK --interval=15s --timeout=30s --start-period=5s --retries=3 CMD docker ps && wget -O- http://localhost || exit 1

STOPSIGNAL SIGTERM

RUN apk add --no-cache git=${GIT_VERSION} docker-cli-compose=${DOCKER_CLI_COMPOSE_VERSION} bash=${BASH_VERSION}

COPY ./entry_point.sh /entry_point.sh
RUN chmod +x /entry_point.sh

VOLUME [ "/work", "/root/.docker", "/config" ]

EXPOSE 80
EXPOSE 443

ENTRYPOINT [ "/entry_point.sh" ]
