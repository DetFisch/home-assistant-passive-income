FROM alpine:3.20

RUN apk add --no-cache bash curl jq ca-certificates && \
    adduser -D -h /app app

WORKDIR /app
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && chown -R app:app /app

USER app

ENV UUID="" \
    API_KEY="" \
    DEVICE_NAME="HomeAssistant" \
    PR_SCRIPT_URL=""

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

