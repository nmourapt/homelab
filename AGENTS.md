# Agent skills

### Deployment model

Everything under `docker/stacks/<svc>/` is a **Dockhand git stack**: folder
name = stack name = compose project. Pushing changes reconciles automatically
(create/update/delete) via `.github/workflows/deploy-dockhand.yml`; secrets
live in SOPS-encrypted `<svc>.env` files, decrypted by CI and pushed to
Dockhand's encrypted env store at deploy time. `portainer/` is the frozen
legacy copy pending retirement — do not deploy from it. Full semantics and
gotchas: `CONTEXT.md` + the `migrate-stack-to-dockhand` skill.

### Control planes (how to reach things)

- **Dockhand API** — `https://docker.nmoura.pt`, `Authorization: Bearer
  <DOCKHAND_API_TOKEN>` (decrypt from `secrets/reposecrets.sops.yml`)
- **Forgejo API** — `https://git.nmoura.pt/api/v1`, token via
  `git credential fill` (oauth; scopes `read/write:repository` only; expires
  ~hourly — re-extract after a user push)
- **Portainer API** (legacy, NAS container inspection) —
  `https://192.168.202.1:9443`, `X-API-Key: <PORTAINER_API_KEY>` from SOPS
- **NAS shell** — `cronus@192.168.202.1`, `sudo` for docker; no sops binary on
  the NAS (decrypt on the workstation, scp the result)
- **Cloudflare** — use the `cloudflare_*` MCP tools (account already
  authorized); Cloudflare config is Terraform-managed in `cloudflare/terraform/`
  — API edits drift, so prefer TF for anything CF-owned

### Current state (verify before assuming)

- Portainer→Dockhand migration: complete for all stacks; `portainer/` folder +
  TF state + CF artifacts still to purge (see issue tracker)
- `deploy-cloudflare.yml` and `deploy-stacks.yml` renamed `*.disabled`;
  cloudflare's backlog was applied locally — state is clean
- `sync-omni-templates` fails on the runner for a pre-existing, undiagnosed
  reason (worked locally with identical config)
- Issue access needs a `read:issue`/`write:issue`-scoped token — the git oauth
  token and the `forgejo_issue_*` MCP tools are both currently insufficient

### Issue tracker

Issues and PRDs live on the self-hosted Forgejo instance at
`https://git.nmoura.pt` under `nuno/homelab`. See `docs/agents/issue-tracker.md`
for the MCP tools and the REST fallback (token scopes matter — see above).

### Triage labels

Five canonical roles using default label strings (`needs-triage`, `needs-info`,
`ready-for-agent`, `ready-for-human`, `wontfix`). See
`docs/agents/triage-labels.md`.

### Domain docs

Single-context repo. `CONTEXT.md` exists (domain glossary). `docs/adr/` is
created lazily when the first decision is recorded. See
`docs/agents/domain.md`.
