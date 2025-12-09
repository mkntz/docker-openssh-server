ARG ALPINE_VERSION=latest

FROM alpine:${ALPINE_VERSION}

ENV PORT=22

RUN apk add --no-cache \
        openssh-server \
        sudo \
 && addgroup -S sudoers \
 && echo '%sudoers ALL=(ALL) ALL' > /etc/sudoers.d/sudoers

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]

EXPOSE ${PORT}/tcp
