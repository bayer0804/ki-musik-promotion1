# BAYERKLANG private server-to-server network (Tailscale)

**Prepared, not deployed.** Install Tailscale directly on each Linux host, not in n8n. A private tailnet connects Contabo (n8n + Portainer + OpenHands) and a separate GPU server (ACE-Step); an authorized phone or laptop can also connect.

## Installation once the servers are accessible

Contabo:
```bash
sudo bash deployment/services/install-tailscale.sh contabo
sudo tailscale up --hostname=bayerklang-contabo --accept-routes=false
```
GPU server:
```bash
sudo bash deployment/services/install-tailscale.sh gpu
sudo tailscale up --hostname=bayerklang-gpu --accept-routes=false
```
Each `tailscale up` displays a device approval URL. Authorize the TWO machines under the **same** tailnet. No auth keys are included in GitHub.

Check `tailscale status` on both hosts and `tailscale ping <peer-hostname>`; then check Tailscale policy/Grants to restrict which machines can reach which ports. Do not assume any Tailscale host is a trusted production agent.

## Access apps without public admin ports
- The prepared Compose setups bind n8n (5678), Portainer (9443), OpenHands (8000), and ACE-Step (8001) to **127.0.0.1**. A remote Tailscale peer CANNOT directly connect to those localhost-only ports using the host's 100.x.y.z Tailscale IP.
- **Option A (initial, simplest):** SSH tunnel over Tailscale to the Contabo machine:
```bash
ssh -L 5678:127.0.0.1:5678 -L 9443:127.0.0.1:9443 -L 8000:127.0.0.1:8000 USER@BAYERKLANG_CONTABO_TAILSCALE_IP
```
  On your own computer open http://localhost:5678, https://localhost:9443, and http://localhost:8000.
- **Option B (later, optional):** Tailscale Serve for private, authenticated HTTPS service exposure to specific tailnet users. Configure it separately and verify policies. NEVER use Tailscale Funnel for admin services.
- GPU music API: allow n8n to reach ACE-Step **only after** configuring a limited private service proxy or an authenticated internal endpoint on the GPU host. Localhost port mapping alone is insufficient. Do not open 8001 publicly.
- Keep emergency SSH access until VPN connectivity has been independently verified; do not change firewall rules while testing.

Security: least-privilege Tailscale Grants/ACL, MFA on identity provider, independently managed service logins, approved device enrollment, no credentials in repository. Avoid accepting routes / exit-node role by default.

References:
- https://tailscale.com/docs/install/linux
- https://tailscale.com/docs/features/access-control
- https://tailscale.com/docs/features/tailscale-ssh

**Current state:** Only shell scripts and documentation committed. No Tailscale daemon or tailnet registration has been executed on Contabo or GPU hosts.
