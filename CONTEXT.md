# CONTEXT.md

Domain vocabulary for the homelab repo. Single flat glossary; terms here are
the canonical names to use in issues, proposals, and code. Contradictions with
existing decisions belong in `docs/adr/` with an explicit callout.

## Vocabulary

### Stack

A unit of deployment on the NAS Docker host. A stack is a folder
`docker/stacks/<svc>/` containing a `docker-compose.yml` and an optional
SOPS-encrypted `<svc>.env`. The folder name is the stack's identity everywhere:
Dockhand stack name, compose project name, and workflow detection key. Renaming
happens in git, never in the Dockhand UI.

### Dockhand

The container management UI/API at `docker.nmoura.pt` (NAS Container Manager
project, port 3000, on `prod_net`). Owns deployment of every `docker/stacks/`
stack via git clones in `/volume2/docker/dockhand/volumes/data/stacks/`. API
auth is a Bearer token stored as `DOCKHAND_API_TOKEN` in the SOPS secrets file.

### Reconcile workflow

`.github/workflows/deploy-dockhand.yml`: on push, for each changed stack folder
it creates missing stacks, re-pushes env vars (decrypted SOPS values, stored as
secrets in Dockhand's encrypted env store), and deploys; deleted folders are
taken down (volumes preserved) and removed. Single-stack force-deploy via
`workflow_dispatch` with `service=<svc>`.

### Portainer (legacy)

The previous stack manager at `portainer.nmoura.pt` (via the ANSIBLE-lis_mgmt
tunnel). `portainer/` in the repo is its frozen legacy copy, kept until full
retirement. **Adoption trap**: Portainer binds stacks by
`com.docker.compose.project` label, so a same-named Portainer stack object left
alive will adopt and later delete Dockhand's containers. Full teardown always
precedes a Dockhand deploy.

### prod_net

The shared external Docker network on the NAS (172.x/`192.168.255.0/24` range)
that all stacks join. The cloudflared connectors run on it and reach
containers by name.

### SOPS env file

`<svc>.env` next to the compose file: dotenv format, age-encrypted (key at repo
root, recipient public key in `sops/.sops.yml`). Values are stored quoted
(`KEY="value"`); the reconcile workflow strips surrounding quotes when pushing
to Dockhand. Never name one plain `.env` — compose auto-reads it and would
interpolate ciphertext.

### Bootstrap secrets

Forgejo Actions secrets that cannot bootstrap themselves: `SOPS_AGE_KEY` (the
age private key) and `SECRETS_TOKEN` (a Forgejo API token with
`write:repository`). Everything else in `secrets/reposecrets.sops.yml` is
distributed to Forgejo by the push-secrets workflow.

### Tunnels

Cloudflare tunnels carrying public hostnames to the homelab:

- `TF-lis_prod` — NAS services. Explicit ingress rules for direct-to-container
  hostnames (`docker`, `warden`, `oidc`, `ha`, `kvm`), plus the
  `*.nmoura.pt` catch-all → Traefik for label-routed stacks.
- `ANSIBLE-lis_mgmt` — management plane (`nas`, `portainer`), IP-based rules.
- `TF-lis_k8s` — cluster-hosted apps.

### The CI loop

Forgejo (k8s, DB = `forgejo_pgsql` on the NAS at `192.168.202.1:10014`) →
k8s runner → reconcile workflow → Dockhand API → NAS containers. Corollary:
anything the loop depends on (Forgejo, its DB, Dockhand, the tunnel) cannot be
rescued by the loop; those stacks use the manual-cutover procedure in the
`migrate-stack-to-dockhand` skill.

### Runner

The self-hosted Forgejo act-runner in k8s (`ubuntu-latest` label). Its
`GITHUB_SERVER_URL` is an internal address, not `git.nmoura.pt` — API-bearing
workflows match resources by name for this reason. Expiry quirk: the git oauth
credential expires roughly hourly; agents re-extract it via
`git credential fill` (scopes: `read/write:repository` only — no issue scopes).
