# BAYERKLANG: System 1 + System 2 (prepared, NOT deployed)
This folder supports the original goal: Contabo VPS as control plane with Docker, Portainer and n8n; ACE-Step 1.5 music generation on a separate GPU instance.
Public GitHub branch contains NO SSH private keys, R2 credentials or n8n encryption keys.

## System 1: Contabo automation + management
**Preconditions:** A working Ubuntu VPS, administrator SSH access, and Docker Engine with docker compose plugin installed. A QCOW2 release exists but importing it can erase an existing server. Do not reinstall without an independent boot-test, backup and explicit approval.
On an existing Ubuntu server, copy `contabo-compose.yml` and `install-control.sh` to the same directory, then run:
```bash
sudo bash install-control.sh
```
The script is idempotent, preserves the n8n encryption key, and starts Portainer and n8n. Both bind only to 127.0.0.1 so their admin panels are NOT reachable over public IP.

Connect securely from a computer using SSH tunnel:
```bash
ssh -i /safe/path/to/private-key -L 5678:127.0.0.1:5678 -L 9443:127.0.0.1:9443 bayerki@YOUR_VPS_IP
```
In local browser: http://localhost:5678 (n8n), https://localhost:9443 (Portainer; initial self-signed certificate). Set the initial admin users in those applications. Do not expose the n8n HTTP interface directly. For mobile access use HTTPS with authenticated reverse proxy/Cloudflare Access after domain setup.

## System 2: ACE-Step 1.5 music generation
A real NVIDIA GPU server is required for practical performance. This is **not** to be run on the standard Contabo CPU-only VPS. Verify `nvidia-smi`, Docker and NVIDIA Container Toolkit on the GPU server. Copy `ace-step-gpu.compose.yml` to that machine, then:
```bash
docker compose -f ace-step-gpu.compose.yml config --quiet
docker compose -f ace-step-gpu.compose.yml up -d
```
The official ACE-Step container provides an API on port 8001. It is bound to 127.0.0.1 by default, and must be connected to the control plane by a secured tunnel or private VPN. Music checkpoints/downloads may require disk space and GPU VRAM. Do not publish an unauthenticated generation API to the open internet.

## Current implementation state (2026-11-05)
- Ubuntu 24.04 QCOW2 GitHub release uploaded: https://github.com/bayer0804/ki-musik-promotion1/releases/tag/bayerklang-contabo-20261105-safe
- SSH key replaced in offline QCOW2 and QCOW2 integrity checked.
- Boot on Contabo has NOT been verified; Contabo management blocked by human verification.
- This folder holds executable deployment templates. No live server deployment has been verified.
- The GPU instance, driver and ACE-Step live service have NOT been verified.

Docs: https://docs.n8n.io/hosting/installation/docker/ ; https://docs.portainer.io/start/install-ce/server/docker/linux ; https://github.com/ACE-Step/ACE-Step-1.5
