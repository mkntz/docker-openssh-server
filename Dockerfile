FROM alpine

ARG OPENSSH_SERVER_VERSION

ENV PORT=22

RUN apk add --no-cache \
        openssh-server~=${OPENSSH_SERVER_VERSION} \
        sudo \
 && addgroup -S sudoers \
 && echo '%sudoers ALL=(ALL) ALL' > /etc/sudoers.d/sudoers

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]

EXPOSE ${PORT}/tcp
