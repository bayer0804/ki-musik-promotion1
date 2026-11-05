# BAYERKLANG second AI engineer — OpenHands Agent Canvas (prepared, not live)

OpenHands Agent Canvas is an agentic development environment, **not just a chat UI**. Once it has a configured LLM, tools and an intentionally granted project copy, it can inspect code, diagnose errors, propose patches, and run test commands inside its approved environment.

Official self-hosting: https://github.com/OpenHands/OpenHands/blob/main/README.md

## Deploy on an EXISTING Docker host (not a reinstall)
```bash
docker compose -f deployment/services/active-devops-agent.compose.yml config --quiet
bash deployment/services/install-active-agent.sh
```

Open SSH tunnel from your computer:
```bash
ssh -L 8000:127.0.0.1:8000 USER@CONTABO_HOST
```
Then open http://localhost:8000/canvas in your local browser.

## First-time operator actions
1. Set up a supported LLM provider in Agent Canvas. **ChatGPT subscription does not automatically provide an OpenAI API key or usage quota.** Some providers or local models may be available; verify requirements and costs first.
2. Import only a **copy** of the BAYERKLANG isolated GitHub branch into its dedicated projects volume. Allow read/test on the copy. Require review before allowing GitHub pushes/PRs or server changes.
3. Give it the task: 'Diagnose BAYERKLANG install-control.sh, Compose files and GitHub Actions run logs. Produce a minimal patch and evidence-backed test results. Never print secrets, never restart production, and never touch main.'
4. Connect to GitHub only through deliberately scoped permissions; if no token configured, it cannot autonomously publish GitHub changes.
5. To stop: `docker compose -f deployment/services/active-devops-agent.compose.yml down`. Persistent named volumes remain.

## Security and real-world status
- Loopback binding: admin web UI is not public.
- No host Docker socket, no mounted private SSH keys.
- OpenHands agent can execute code within its mounted projects; do not grant access to private production folders or credentials.
- A strong authentication barrier is required **before** any remote public hosting.
- Needs functional testing on the chosen host and a configured LLM. No server has been modified by committing these files.
- Prefer GitHub Copilot's cloud coding agent as an immediate alternative if enabled; it works through PR review without hosting a second server-side agent.
