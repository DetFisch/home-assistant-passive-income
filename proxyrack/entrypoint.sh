#!/bin/sh
set -eu

echo "[proxyrack-pop] starting wrapper..."

if [ -z "${UUID:-}" ]; then
  echo "[proxyrack-pop] ERROR: UUID is required. Set UUID in add-on config." >&2
  sleep 5
  exit 1
fi

: "${DEVICE_NAME:=HomeAssistant}"

APP_DIR=/app
PERSIST_DIR=/data
API_FILE="$PERSIST_DIR/api.cfg"

mkdir -p "$APP_DIR" "$PERSIST_DIR" "$PERSIST_DIR/.config" "$PERSIST_DIR/.cache"

# Set persistent homes so upstream logs/config use /data
export HOME="$PERSIST_DIR"
export APPDATA="$PERSIST_DIR"
export XDG_CONFIG_HOME="$PERSIST_DIR/.config"
export XDG_CACHE_HOME="$PERSIST_DIR/.cache"
mkdir -p "$APPDATA/Roaming/PoP"

# Keep upstream marker persistent
if [ ! -e "$APP_DIR/api.cfg" ]; then
  ln -sf "$API_FILE" "$APP_DIR/api.cfg" || true
fi

echo "[proxyrack-pop] UUID set; DEVICE_NAME=$DEVICE_NAME"

# Hand off to upstream script (path varies; prefer /run.sh)
if [ -x /run.sh ]; then
  exec /bin/bash /run.sh
elif [ -x /app/run.sh ]; then
  exec /bin/bash /app/run.sh
else
  echo "[proxyrack-pop] upstream run.sh not found; using fallback launcher" >&2

  APP_DIR=/app
  SCRIPT_JS="$APP_DIR/script.js"
  VERSION_URL="https://app-updates.sock.sh/peerclient/script/version.txt"
  SCRIPT_URL="https://app-updates.sock.sh/peerclient/script/script.js"
  mkdir -p "$APP_DIR"
  cd "$APP_DIR"

  echo "[proxyrack-pop] connectivity check to point-of-presence.sock.sh:443"
  if command -v nc >/dev/null 2>&1; then
    nc -z point-of-presence.sock.sh 443 >/dev/null 2>&1 && echo "[proxyrack-pop] connectivity OK" || echo "[proxyrack-pop] WARN: connectivity check failed"
  fi

  if ! command -v node >/dev/null 2>&1; then
    echo "[proxyrack-pop] ERROR: node runtime not found in base image; cannot continue" >&2
    sleep 5
    exit 1
  fi

  echo "[proxyrack-pop] downloading client script..."
  rm -f "$SCRIPT_JS" 2>/dev/null || true
  if command -v wget >/dev/null 2>&1; then
    wget -qO "$SCRIPT_JS" "$SCRIPT_URL" || true
  fi
  if [ ! -s "$SCRIPT_JS" ] && command -v curl >/dev/null 2>&1; then
    curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_JS" || true
  fi
  if [ ! -s "$SCRIPT_JS" ]; then
    echo "[proxyrack-pop] ERROR: failed to download client script" >&2
    sleep 5
    exit 1
  fi

  echo "[proxyrack-pop] fetching client version..."
  VERSION=""
  if command -v curl >/dev/null 2>&1; then
    VERSION=$(curl -fsSL "$VERSION_URL" || true)
  elif command -v wget >/dev/null 2>&1; then
    VERSION=$(wget -qO- "$VERSION_URL" || true)
  fi
  [ -n "$VERSION" ] || echo "[proxyrack-pop] WARN: could not fetch version"

  # Optional: background device registration if API_KEY provided (persist marker in /data)
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
      response=""
      if command -v curl >/dev/null 2>&1; then
        response=$(curl -fsS -X POST \
          https://peer.proxyrack.com/api/device/add \
          -H "Api-Key: ${API_KEY}" \
          -H 'Content-Type: application/json' \
          -H 'Accept: application/json' \
          -d '{"device_id":"'"$UUID"'","device_name":"'"$device_name"'"}') || response=""
      fi
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
  maybe_add_device &

  echo "[proxyrack-pop] launching Node client"
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
fi
