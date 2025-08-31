#!/usr/bin/env sh
set -eu

echo "[proxyrack-pop] starting..."

if [ -z "${UUID:-}" ]; then
  echo "[proxyrack-pop] ERROR: UUID is required. Set UUID in add-on config." >&2
  sleep 5
  exit 1
fi

: "${DEVICE_NAME:=HomeAssistant}"

APP_DIR=/app
PERSIST_DIR=/data
API_FILE="$PERSIST_DIR/api.cfg"
SCRIPT_JS="$APP_DIR/script.js"
VERSION_URL="https://app-updates.sock.sh/peerclient/script/version.txt"
SCRIPT_URL="https://app-updates.sock.sh/peerclient/script/script.js"

mkdir -p "$APP_DIR" "$PERSIST_DIR"
cd "$APP_DIR"

echo "[proxyrack-pop] connectivity check to point-of-presence.sock.sh:443"
if nc -z point-of-presence.sock.sh 443 >/dev/null 2>&1; then
  echo "[proxyrack-pop] connectivity OK"
else
  echo "[proxyrack-pop] WARNING: connectivity check failed; client may still retry"
fi

echo "[proxyrack-pop] updating client script..."
rm -f "$SCRIPT_JS" 2>/dev/null || true
if ! wget -qO "$SCRIPT_JS" "$SCRIPT_URL"; then
  echo "[proxyrack-pop] ERROR: failed to download $SCRIPT_URL" >&2
  sleep 5
  exit 1
fi

echo "[proxyrack-pop] fetching client version..."
VERSION=$(curl -fsSL "$VERSION_URL" || echo "")
if [ -z "$VERSION" ]; then
  echo "[proxyrack-pop] WARNING: could not fetch version; proceeding without explicit version"
fi

maybe_add_device() {
  if [ -f "$API_FILE" ]; then
    echo "[proxyrack-pop] $API_FILE exists; skipping device registration"
    return 0
  fi
  if [ -z "${API_KEY:-}" ]; then
    echo "[proxyrack-pop] no API_KEY provided; skipping device registration"
    return 0
  fi
  device_name="${DEVICE_NAME:-Device-$UUID}"
  echo "[proxyrack-pop] attempting device registration as '$device_name'"
  while :; do
    response=$(curl -fsS -X POST \
      https://peer.proxyrack.com/api/device/add \
      -H "Api-Key: ${API_KEY}" \
      -H 'Content-Type: application/json' \
      -H 'Accept: application/json' \
      -d '{"device_id":"'"$UUID"'","device_name":"'"$device_name"'"}') || response=""
    if echo "$response" | grep -q '"status": *"error"'; then
      echo "[proxyrack-pop] device not found yet, retrying in 60s..."
      sleep 60
    elif [ -n "$response" ]; then
      echo "[proxyrack-pop] device added successfully"
      : > "$API_FILE"
      break
    else
      echo "[proxyrack-pop] registration request failed, retrying in 60s..."
      sleep 60
    fi
  done
}

# Launch registration in background (if applicable)
maybe_add_device &

echo "[proxyrack-pop] launching Node client (UUID set; DEVICE_NAME=$DEVICE_NAME)"
set -- node "$SCRIPT_JS" \
  --homeIp point-of-presence.sock.sh \
  --homePort 443 \
  --id "$UUID" \
  --clientKey proxyrack-pop-client \
  --clientType PoP
if [ -n "$VERSION" ]; then
  set -- "$@" --version "$VERSION"
fi

exec "$@"
