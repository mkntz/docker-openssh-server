FROM alpine

ARG APP_VERSION

ENV PORT=22

RUN apk add --no-cache \
        openssh-server~=${APP_VERSION} \
        sudo \
 && addgroup -S sudoers \
 && echo '%sudoers ALL=(ALL) ALL' > /etc/sudoers.d/sudoers

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]

EXPOSE ${PORT}/tcp
