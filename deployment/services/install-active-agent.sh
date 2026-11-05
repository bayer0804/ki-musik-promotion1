#!/usr/bin/env bash
# Install only the OPTIONAL second-engineer agent on an ALREADY running Docker host.
# No VPS reinstallation, no auto-access to production or other running containers.
set -Eeuo pipefail
umask 077
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
command -v docker >/dev/null || { echo 'Docker Engine missing'; exit 2; }
docker compose version >/dev/null || { echo 'Docker Compose plugin missing'; exit 2; }
docker compose -f "$HERE/active-devops-agent.compose.yml" config --quiet
docker compose -f "$HERE/active-devops-agent.compose.yml" up -d
docker compose -f "$HERE/active-devops-agent.compose.yml" ps
echo 'Active AI interface is localhost:8000 ONLY. Reach via SSH tunnel.'
echo 'The agent requires choosing/configuring an LLM provider; no credentials are bundled.'
echo 'Give agent only review copies of projects, not live system credentials.'
