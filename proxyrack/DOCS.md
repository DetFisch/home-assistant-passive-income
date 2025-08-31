# Home Assistant ProxyRack Add-on

This add-on runs a Proxyrack PoP client using a multi-arch image that automatically downloads and launches the official client script at runtime.

## Quick Configuration Guide

1. If you don't have a ProxyRack account, sign up at https://peer.proxyrack.com.
2. Generate a device UUID (as per the image docs) and optionally obtain an API key if you want the device auto-added to your dashboard.
3. In Home Assistant, go to Supervisor > Add-on Store > ProxyRack > Configuration and set:
   - `UUID`: your generated device UUID (required)
   - `API_KEY`: your API key (optional; used to auto-add device)
   - `DEVICE_NAME`: display name for the device (optional, defaults to "HomeAssistant")
4. Save the configuration and start the add-on.
5. Check the logs to ensure the client starts and, if `API_KEY` is set, that the device is added to your dashboard.

## Notes

- Architectures: amd64, aarch64, armv7, armhf.
- Environment variables: `UUID` (required), `API_KEY` (optional), `DEVICE_NAME` (optional).
- The add-on downloads `script.js` and reads the upstream version from
  `https://app-updates.sock.sh/peerclient/script/version.txt` and runs
  the client with `--homeIp point-of-presence.sock.sh --homePort 443`.
- If `API_KEY` is set, the add-on tries to auto-add your device to the
  dashboard (POST https://peer.proxyrack.com/api/device/add) and creates
  `/data/api.cfg` as a marker so it won’t re-register on subsequent starts.
- For details and the latest upstream usage notes, see https://hub.docker.com/r/proxyrack/pop
