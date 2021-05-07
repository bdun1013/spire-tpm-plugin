FROM --platform=${TARGETPLATFORM} golang:1.16.4-alpine3.13

ARG version
ARG binary

ENV binary_env=$binary

RUN apk --no-cache add make && \
    mkdir /app

WORKDIR /app
COPY . .

RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o ${binary} cmd/${binary}/main.go

ENTRYPOINT ./${binary_env}
