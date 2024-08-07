FROM golang:1.22 AS build
ARG BEE_REPO='https://github.com/Solar-Punk-Ltd/bee.git'
ARG BEE_BRANCH=act

RUN mkdir -p /repo; \
    cd /repo;  \
    git clone --branch $BEE_BRANCH $BEE_REPO

WORKDIR /repo/bee/
RUN go mod download

RUN make binary

FROM debian:12.4-slim

ENV DEBIAN_FRONTEND=noninteractive \
    HURL_VERSION=4.2.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl libxml2 ca-certificates nodejs npm; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    groupadd -r bee --gid 999; \
    useradd -r -g bee --uid 999 --no-log-init -m bee;

RUN curl -LO https://github.com/Orange-OpenSource/hurl/releases/download/${HURL_VERSION}/hurl-${HURL_VERSION}-aarch64-unknown-linux-gnu.tar.gz && \
    tar -xvf hurl-${HURL_VERSION}-aarch64-unknown-linux-gnu.tar.gz && \
    mv hurl-${HURL_VERSION}-aarch64-unknown-linux-gnu/hurl /usr/local/bin/ && \
    rm hurl-${HURL_VERSION}-aarch64-unknown-linux-gnu.tar.gz

RUN npm install --global @ethersphere/swarm-cli

RUN mkdir -p /home/bee/.bee && chown 999:999 /home/bee/.bee

COPY --from=build /repo/bee/dist/bee /usr/local/bin/bee

COPY tests/ /home/bee/tests/
COPY test.sh /home/bee/test.sh
COPY test_suite.sh /home/bee/test_suite.sh
COPY updown.hurl /home/bee/updown.hurl

EXPOSE 1633 1634
USER bee
WORKDIR /home/bee

RUN cd /home/bee && \
    bee dev & \
    sleep 10 && \
    ./test.sh

ENTRYPOINT ["bee", "dev"]