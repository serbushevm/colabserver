FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/opt/1C/1CE/components/1c-enterprise-ring-0.19.5+12-x86_64:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl gawk procps sysvinit-utils \
    && rm -rf /var/lib/apt/lists/*

# Both the Java runtime and ECS installer are the supplied distributions.
COPY dist/axiomjdk_jdk11.deb /tmp/axiomjdk.deb
RUN apt-get update \
    && apt-get install -y /tmp/axiomjdk.deb \
    && rm -rf /tmp/axiomjdk.deb /var/lib/apt/lists/*

COPY dist/1c_cs.tar.gz /tmp/1c_cs.tar.gz
RUN mkdir /tmp/1c_cs \
    && tar -xzf /tmp/1c_cs.tar.gz -C /tmp/1c_cs \
    && cd /tmp/1c_cs \
    && chmod +x 1ce-installer-cli \
    && ./1ce-installer-cli install --ignore-signature-warnings \
    && rm -rf /tmp/1c_cs /tmp/1c_cs.tar.gz

COPY ecs/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8086 8087
ENTRYPOINT ["docker-entrypoint.sh"]
