# BAYERKLANG KI Desktop (Test-Build)
This isolated branch is only a build test for a Contabo-compatible Ubuntu 24.04 QCOW2. It does NOT change the existing Contabo VPS, website or main GitHub branch.

Target after optional installation: Ubuntu 24.04 + XFCE / XRDP + Docker + SSH.
The provided ED25519 public key is TEMPORARY. The private key was previously exported through a chat attachment. Generate a new private/public key locally before production and replace the public key before rebuilding.

Trigger: push to branch `bayerklang-image-setup-20261104` activates `.github/workflows/bayerklang-image.yml`. The GitHub Action generates an authenticated downloadable **artifact**, NOT a direct public URL. Its QCOW2 must be test-booted and then hosted on a public direct HTTPS .qcow2 URL before import by Contabo. No server reinstall or purchase happens automatically.
