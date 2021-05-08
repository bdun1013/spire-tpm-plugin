FROM --platform=${TARGETPLATFORM} golang:1.16.4-alpine3.13

ARG version
ARG binary

ENV binary_env=$binary

RUN apk --no-cache add make && \
    mkdir /app

WORKDIR /app
COPY . .

RUN BINARY=${binary} make docker-build

ENTRYPOINT ./${binary_env}
