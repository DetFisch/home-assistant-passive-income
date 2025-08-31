FROM alpine:3.20

# Runtime deps: shell, curl, wget, nc, node
RUN apk add --no-cache bash curl wget jq ca-certificates netcat-openbsd nodejs && \
    adduser -D -h /app app

WORKDIR /app
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && chown -R app:app /app

# Run as root to allow writing to /data (addon persistence)
USER root

ENV UUID="" \
    API_KEY="" \
    DEVICE_NAME="HomeAssistant"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
