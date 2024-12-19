FROM docker:27-dind

LABEL maintainer="Nico Jensch <root@dr460nf1r3.org>"
LABEL description="Docker in Docker with docker-compose and git, ready to use for CI/CD pipelines"
LABEL version="1.0"
LABEL org.opencontainers.image.source="https://github.com/dr460nf1r3/container-manager"
LABEL org.opencontainers.image.authors="Nico Jensch <root@dr460nf1r3.org>"
LABEL org.opencontainers.image.description="Docker in Docker with docker-compose and git, ready to use for CI/CD pipelines"
LABEL org.opencontainers.image.version="1.0"

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD docker ps || exit 1

RUN apk add --no-cache git docker-compose bash

COPY ./entry_point.sh /entry_point.sh
RUN chmod +x /entry_point.sh

VOLUME [ "/work", "/root/.docker", "/config" ]

EXPOSE 80
EXPOSE 443

ENTRYPOINT [ "/entry_point.sh" ]
