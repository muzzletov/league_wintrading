# Build Stage
FROM golang:1.23.2 as builder

ARG project_id="wintrading-233a5"

ENV FCM_PROJECT_ID $project_id

ARG vkey_host="localhost"
ARG vkey_port="6379"
ARG vkey_pass="password"

ENV VKEY_HOST $vkey_pass
ENV VKEY_PORT $vkey_port
ENV VKEY_PASSWORD $vkey_pass

ARG host="localhost"
ARG port="5552"

ENV FCM_APP_HOST $host
ENV FCM_APP_PORT $port

WORKDIR /app

COPY ./shared ./shared
COPY ./fcm ./fcm
COPY ./middleware ./middleware

WORKDIR /app/fcm

RUN go mod download

# RUN CGO_ENABLED=0 go build -o out
RUN CGO_ENABLED=0 go install -ldflags "-s -w -extldflags '-static'" github.com/go-delve/delve/cmd/dlv@latest
RUN CGO_ENABLED=0 go build -gcflags "all=-N -l" -o ./out # -N disables optimization, so the breakpoints correspond truly with what you see in the editor

FROM gcr.io/distroless/static-debian12

COPY --from=builder /app/fcm/out /fcm
COPY --from=builder /go/bin/dlv /dlv

WORKDIR /

# CMD ["/fcm"]
CMD ["/dlv", "--listen=:12222", "--headless=true", "--api-version=2", "--accept-multiclient", "exec", "/fcm"]