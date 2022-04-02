FROM alpine:latest

## Install pre-req software
RUN apk update && apk add --no-cache wireguard-tools

WORKDIR /etc/wireguard
ENTRYPOINT [ "ash" ]