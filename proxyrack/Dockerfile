FROM proxyrack/pop:latest

# Home Assistant wrapper to set persistence and env, then call upstream run script
COPY entrypoint.sh /usr/local/bin/ha-wrapper.sh
RUN chmod +x /usr/local/bin/ha-wrapper.sh

ENV UUID="" \
    API_KEY="" \
    DEVICE_NAME="HomeAssistant"

# Ensure we can write to /data
USER root

ENTRYPOINT ["/usr/local/bin/ha-wrapper.sh"]
