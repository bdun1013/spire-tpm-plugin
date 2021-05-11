FROM --platform=${BUILDPLATFORM} golang:1.16.4-alpine3.13 as build

ARG version
ARG binary
ARG TARGETOS
ARG TARGETARCH

ENV binary_env=$binary

RUN apk --no-cache add make && \
    mkdir /app

WORKDIR /app
COPY . .

RUN TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH} BINARY=${binary} make docker-build

FROM --platform=${TARGETPLATFORM} alpine:3.13

WORKDIR /app

ARG binary
ENV binary_env=${binary}

COPY --from=build /app/${binary_env} ./${binary_env}

ENTRYPOINT ./${binary_env}
