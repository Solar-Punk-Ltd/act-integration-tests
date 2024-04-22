FROM golang:1.21 AS build

RUN mkdir -p /repo; \
    cd /repo;  \
    git clone --branch act https://github.com/Solar-Punk-Ltd/bee.git

WORKDIR /repo/bee/
RUN go mod download

RUN make binary

FROM debian:12.4-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    groupadd -r bee --gid 999; \
    useradd -r -g bee --uid 999 --no-log-init -m bee;

# make sure mounted volumes have correct permissions
RUN mkdir -p /home/bee/.bee && chown 999:999 /home/bee/.bee

COPY --from=build /repo/bee/dist/bee /usr/local/bin/bee

EXPOSE 1633 1634 1635
USER bee
WORKDIR /home/bee
VOLUME /home/bee/.bee

ENTRYPOINT ["bee", "dev"]
