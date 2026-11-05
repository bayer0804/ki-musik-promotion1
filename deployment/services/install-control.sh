#!/usr/bin/env bash
# Idempotent setup for an ALREADY BOOTED Ubuntu server that has Docker + Compose.
# Does not wipe disks, reboot, configure SSH, change firewall or expose ports.
set -Eeuo pipefail
umask 077
if [[ $(id -u) -ne 0 ]]; then echo 'Run with sudo: sudo bash install-control.sh'; exit 1; fi
if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  echo 'Docker Engine and the docker compose plugin are required.'
  echo 'Install them using https://docs.docker.com/engine/install/ubuntu/ and rerun.'
  exit 2
fi
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST='/opt/bayerklang/stacks/control'
install -d -m 0700 "$DEST"
install -m 0600 "$HERE/contabo-compose.yml" "$DEST/compose.yml"
if [[ ! -e "$DEST/.env" ]]; then
  if ! command -v openssl >/dev/null 2>&1; then
    echo 'OpenSSL is needed to generate a persistent n8n encryption key.'
    exit 3
  fi
  printf 'N8N_ENCRYPTION_KEY=%s\n' "$(openssl rand -hex 32)" > "$DEST/.env"
  chmod 0600 "$DEST/.env"
  echo 'Generated a local n8n encryption key. It is NOT uploaded to GitHub.'
else
  chmod 0600 "$DEST/.env"
  echo 'Preserved existing n8n encryption key and settings.'
fi
cd "$DEST"
docker compose --env-file .env -f compose.yml config --quiet
docker compose --env-file .env -f compose.yml up -d
docker compose --env-file .env -f compose.yml ps
echo 'Ports are bound to 127.0.0.1 only; connect through SSH tunnel.'
echo 'n8n: http://localhost:5678   Portainer: https://localhost:9443'
