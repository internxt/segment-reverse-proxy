FROM golang:1.14.4-alpine3.11 as builder

LABEL maintainer="Joan Mora Grau <joanmoragrau@gmail.com>"

RUN apk add --update ca-certificates git

ENV SRC https://github.com/internxt/segment-reverse-proxy
ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV GOOS=linux
ENV GOARCH=amd64
ENV PORT=8080

ARG VERSION

COPY . /go/src/${SRC}
WORKDIR /go/src/${SRC}

RUN go build -a -installsuffix cgo -ldflags "-w -s -extldflags '-static' -X main.version=$VERSION" -o /proxy

FROM scratch

COPY --from=builder /etc/letsencrypt/live/ps.internxt.com/fullchain.cert /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /proxy /proxy

EXPOSE ${PORT}

ENTRYPOINT ["/proxy"]