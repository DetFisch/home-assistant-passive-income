# Home Assistant ProxyRack Add-on

This add-on runs a Proxyrack PoP client using a multi-arch wrapper image that downloads and launches the official client script at runtime.

## Quick Configuration Guide

1. If you don't have a ProxyRack account, sign up at https://peer.proxyrack.com.
2. Generate a device UUID (as per the image docs) and optionally obtain an API key if you want the device auto-added to your dashboard.
3. In Home Assistant, go to Supervisor > Add-on Store > ProxyRack > Configuration and set:
   - `UUID`: your generated device UUID (required)
   - `API_KEY`: your API key (optional)
   - `DEVICE_NAME`: display name for the device (optional, defaults to "HomeAssistant")
   - `PR_SCRIPT_URL`: URL of the official Proxyrack client script (required on Raspberry Pi/ARM; see notes)
4. Save the configuration and start the add-on.
5. Check the logs to ensure the client starts and, if `API_KEY` is set, that the device is added to your dashboard.

## Notes

- Architectures: amd64, aarch64, armv7, armhf. On Raspberry Pi, set `PR_SCRIPT_URL` so the wrapper can download the official client script at runtime.
- Environment variables match the Docker Hub example: `UUID`, `API_KEY`, `DEVICE_NAME`.
- To discover the official script URL from the upstream image, run the included GitHub Action "Inspect upstream proxyrack/pop" in your fork. It uploads the likely entrypoint/start scripts as artifacts and logs their contents.
- After confirming the script URL, add it as `PR_SCRIPT_URL` in the add-on configuration.
- For details and the latest usage notes, see https://hub.docker.com/r/proxyrack/pop
