FROM docker:27-dind

LABEL maintainer="Nico Jensch <root@dr460nf1r3.org>"
LABEL description="Docker in Docker with docker-compose and git, ready to use for CI/CD pipelines"
LABEL version="1.0"
LABEL org.opencontainers.image.source="https://github.com/dr460nf1r3/container-manager"
LABEL org.opencontainers.image.authors="Nico Jensch <root@dr460nf1r3.org>"
LABEL org.opencontainers.image.description="Docker in Docker with docker-compose and git, ready to use for CI/CD pipelines"
LABEL org.opencontainers.image.version="1.0"

HEALTHCHECK --interval=15s --timeout=30s --start-period=5s --retries=3 CMD docker ps && wget -O- http://localhost || exit 1

STOPSIGNAL SIGTERM

RUN apk add --no-cache git=2.47.1-r0 docker-cli-compose=2.31.0-r0 bash=5.2.37-r0

COPY ./entry_point.sh /entry_point.sh
RUN chmod +x /entry_point.sh

VOLUME [ "/work", "/root/.docker", "/config" ]

EXPOSE 80
EXPOSE 443

ENTRYPOINT [ "/entry_point.sh" ]
