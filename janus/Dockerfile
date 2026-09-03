FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      autoconf automake build-essential ca-certificates cmake git libconfig-dev \
      libcurl4-openssl-dev libglib2.0-dev libjansson-dev libmicrohttpd-dev \
      libnice-dev libogg-dev libopus-dev libsrtp2-dev libsofia-sip-ua-dev \
      libssl-dev libtool pkg-config gengetopt \
    && rm -rf /var/lib/apt/lists/*

# The 1C fork is required for compatibility with ECS.
RUN git clone --depth=1 https://github.com/1C-Company/janus-gateway.git /src/janus \
    && cd /src/janus \
    && ./autogen.sh \
    && ./configure --prefix=/opt/janus --disable-data-channels --disable-rabbitmq --disable-mqtt \
    && make -j"$(nproc)" \
    && make install \
    && make configs

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
      libconfig9 libcurl4 libglib2.0-0 libjansson4 libmicrohttpd12 libnice10 \
      libogg0 libopus0 libsrtp2-1 libsofia-sip-ua0 libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/janus /opt/janus
COPY janus/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p /var/records

EXPOSE 8188/tcp 10000-10200/udp
ENTRYPOINT ["docker-entrypoint.sh"]
