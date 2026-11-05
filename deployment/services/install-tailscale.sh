#!/usr/bin/env bash
# BAYERKLANG optional Tailscale setup for an existing Ubuntu/Debian host.
# This file does not reinstall the VPS, open firewall ports or auto-enrol devices.
# Run as: sudo bash install-tailscale.sh contabo
#      or sudo bash install-tailscale.sh gpu
set -Eeuo pipefail
if [[ "${EUID}" -ne 0 ]]; then echo 'Run as root using sudo.' >&2; exit 1; fi
ROLE="${1:-}"
case "$ROLE" in
  contabo) HOSTNAME='bayerklang-contabo' ;;
  gpu) HOSTNAME='bayerklang-gpu' ;;
  *) echo 'Usage: sudo bash install-tailscale.sh {contabo|gpu}' >&2; exit 2 ;;
esac
if ! command -v tailscale >/dev/null 2>&1; then
  if ! command -v curl >/dev/null 2>&1; then echo 'Install curl first.' >&2; exit 3; fi
  TEMP_SCRIPT="$(mktemp)"
  trap 'rm -f "$TEMP_SCRIPT"' EXIT
  curl --fail --location --silent --show-error https://tailscale.com/install.sh -o "$TEMP_SCRIPT"
  sh "$TEMP_SCRIPT"
fi
systemctl enable --now tailscaled
echo "Tailscale installed. Enrolling '${HOSTNAME}' requires user authentication."
echo "To join your tailnet, run:"
echo "    sudo tailscale up --hostname=${HOSTNAME} --accept-routes=false"
echo 'The command opens a Tailscale sign-in link. Do not paste that link or auth tokens into public issues.'
echo 'After authorizing the device, check:'
echo '    tailscale status'
echo '    tailscale ip -4'
echo 'No existing SSH, UFW or Docker configuration was modified by this script.'
