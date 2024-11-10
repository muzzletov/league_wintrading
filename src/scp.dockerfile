# Build Stage
FROM golang:1.23.2 as builder

ARG vkey_host="localhost"
ARG vkey_port="6732"
ARG vkey_pass="password"

ENV VKEY_HOST $redisHost
ENV VKEY_PORT $redisPort
ENV VKEY_PASSWORD $redisPass

ARG host="localhost"
ARG port="5552"

ENV SCP_APP_HOST $host
ENV SCP_APP_PORT $port

ARG fcm_host="localhost"
ARG fcm_port="5551"

ENV FCM_APP_HOST $fcm_host
ENV FCM_APP_PORT $fcm_port

WORKDIR /app

COPY ./shared ./shared
COPY ./scrapy ./scrapy
COPY ./middleware ./middleware

WORKDIR /app/scrapy

RUN go mod download
RUN CGO_ENABLED=0 go install -ldflags "-s -w -extldflags '-static'" github.com/go-delve/delve/cmd/dlv@latest
RUN CGO_ENABLED=0 go build -gcflags "all=-N -l" -o ./out # -N disables optimization, so the breakpoints correspond truly with what you see in the editor

FROM gcr.io/distroless/static-debian12

COPY --from=builder /app/scrapy/out /scrapy
COPY --from=builder /go/bin/dlv /dlv

WORKDIR /

CMD ["/dlv", "--listen=:12221", "--headless=true", "--api-version=2", "--accept-multiclient", "exec", "/scrapy"]