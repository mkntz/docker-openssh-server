FROM alpine

RUN apk add --no-cache \
        openssh-server \
        sudo \
 && addgroup -S sudoers \
 && echo '%sudoers ALL=(ALL) ALL' > /etc/sudoers.d/sudoers

COPY docker-entrypoint.sh /

ENTRYPOINT [ "/docker-entrypoint.sh" ]

EXPOSE 22
