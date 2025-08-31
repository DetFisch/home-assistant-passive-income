#!/usr/bin/env sh
set -eu

echo "[proxyrack-pop] starting..."

if [ -z "${UUID:-}" ]; then
  echo "[proxyrack-pop] ERROR: UUID is required. Set UUID in add-on config." >&2
  sleep 5
  exit 1
fi

: "${DEVICE_NAME:=HomeAssistant}"

if [ -z "${PR_SCRIPT_URL:-}" ]; then
  echo "[proxyrack-pop] ERROR: PR_SCRIPT_URL not set."
  echo "Set PR_SCRIPT_URL to the official Proxyrack client script URL (as used by proxyrack/pop)." >&2
  sleep 5
  exit 1
fi

WORKDIR=/app
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "[proxyrack-pop] downloading client script from: $PR_SCRIPT_URL"
if ! curl -fsSL "$PR_SCRIPT_URL" -o client.sh; then
  echo "[proxyrack-pop] ERROR: failed to download client script" >&2
  sleep 5
  exit 1
fi

chmod +x client.sh || true

echo "[proxyrack-pop] launching client with environment: UUID, API_KEY (optional), DEVICE_NAME=${DEVICE_NAME}"
export UUID API_KEY DEVICE_NAME

exec /bin/sh ./client.sh

