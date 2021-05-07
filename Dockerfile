FROM golang:1.16.4-alpine3.13

ARG binary

RUN apk --no-cache add file make && mkdir /app

WORKDIR /app
COPY . .

RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o ${binary} cmd/${binary}/main.go