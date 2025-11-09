# Multi-stage build
FROM golang:1.20-alpine AS builder

WORKDIR /app
RUN apk add --no-cache git build-base

# Cache go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o /app/lottery cmd/main.go

# Runtime image
FROM alpine:3.18
RUN apk add --no-cache ca-certificates tzdata && \
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
	echo "Asia/Shanghai" > /etc/timezone

WORKDIR /app
COPY --from=builder /app/lottery /usr/local/bin/lottery
# copy default configs; docker-compose can mount a different config for container
COPY configs/config.yml /app/configs/config.yml

ENV CONFIG_FILE=/app/configs/config.yml
ENV GO_ENV=production
EXPOSE 8081
WORKDIR /app
ENTRYPOINT ["/usr/local/bin/lottery"]
