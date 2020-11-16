FROM alpine:latest AS builder

ARG DNSDIST_VERSION=1.5.1

RUN apk add --no-cache \
        build-base \
        boost-dev \
        lua-dev \
        libedit-dev \
        openssl-dev \
        h2o-dev \
    && \
    wget -O - https://downloads.powerdns.com/releases/dnsdist-$DNSDIST_VERSION.tar.bz2 | tar xj && \
    cd dnsdist-$DNSDIST_VERSION && \
    ./configure --enable-dns-over-tls --enable-dns-over-https && \
    make && \
    make install DESTDIR=/build


FROM alpine:latest

COPY --from=builder /build /

RUN apk add --no-cache lua libedit openssl h2o && \
    addgroup -g 500 -S dnsdist && \
    adduser -u 500 -D -H -S -g dnsdist -s /sbin/nologin -G dnsdist dnsdist

USER dnsdist

ENTRYPOINT ["/usr/local/bin/dnsdist"]
