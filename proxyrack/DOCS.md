# Home Assistant ProxyRack Add-on

This add-on uses the official Docker image `proxyrack/pop` to run a Proxyrack PoP client.

## Quick Configuration Guide

1. If you don't have a ProxyRack account, sign up at https://peer.proxyrack.com.
2. Generate a device UUID (as per the image docs) and optionally obtain an API key if you want the device auto-added to your dashboard.
3. In Home Assistant, go to Supervisor > Add-on Store > ProxyRack > Configuration and set:
   - `UUID`: your generated device UUID (required)
   - `API_KEY`: your API key (optional)
   - `DEVICE_NAME`: display name for the device (optional, defaults to "HomeAssistant")
4. Save the configuration and start the add-on.
5. Check the logs to ensure the client starts and, if `API_KEY` is set, that the device is added to your dashboard.

## Notes

- Architectures: amd64, aarch64, armv7, armhf. Running on Raspberry Pi is possible but not recommended and may require additional configuration (e.g., cross-architecture emulation). Stability and performance can vary.
- Environment variables match the Docker Hub example: `UUID`, `API_KEY`, `DEVICE_NAME`.
- For details and the latest usage notes, see https://hub.docker.com/r/proxyrack/pop
