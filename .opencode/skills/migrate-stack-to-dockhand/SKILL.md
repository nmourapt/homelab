---
name: migrate-stack-to-dockhand
description: Use when migrating a NAS Docker stack from Portainer to Dockhand, when adding or removing stacks under docker/stacks/, or when a stack's containers need to move between compose projects. Covers the folder/naming conventions, the Portainer adoption trap, teardown ordering, stateful-stack cutovers (including stacks Forgejo itself depends on), and rollback paths.
---

# Migrate a stack to Dockhand

## The model (read first)

- A stack lives in `docker/stacks/<svc>/`: `docker-compose.yml` plus an optional
  SOPS-encrypted `<svc>.env` (dotenv format, age key at repo root, quoted
  values are fine — the workflow strips surrounding quotes).
- **Folder name = Dockhand stack name = compose project name.** Never rename a
  stack in the Dockhand UI; rename the folder in git instead.
- The `.github/workflows/deploy-dockhand.yml` workflow reconciles Dockhand
  against the repo on every push touching `docker/**`:
  - new folder → creates the git stack and deploys it
  - changed folder → re-pushes decrypted env vars as secrets, redeploys
  - deleted folder → `docker compose down` (volumes are **always kept**) then
    deletes the stack
- `workflow_dispatch` with `service=<svc>` force-deploys one stack; empty input
  deploys all. The dispatch API is
  `POST /api/v1/repos/nuno/homelab/actions/workflows/deploy-dockhand.yml/dispatches`
  (inputs must be JSON **strings**).

## The adoption trap (the one that bites)

Portainer binds stacks to containers via the `com.docker.compose.project`
label, not via which tool created them. If a Portainer stack and a Dockhand
stack share a project name, Portainer re-adopts Dockhand's container — and
deleting the Portainer stack later **deletes Dockhand's container**.

Rule: the Portainer stack (container **and** stack object) must be fully
deleted *before* Dockhand's first deploy. Never leave a same-named Portainer
stack object alive across a Dockhand deploy.

## Standard procedure (stateless stacks — traefik, plex style)

1. Copy the stack folder into `docker/stacks/<svc>/` verbatim. No version bumps
   mid-migration.
2. Portainer: stop + remove the container(s), then **delete the stack**.
3. Commit and push. The workflow creates + deploys.
4. Verify: container running, workflow run green, hostname(s) respond.

## Stateful / critical stacks (databases, anything backing Forgejo)

Extra rules when the stack holds data or the CI loop depends on it:

1. **Back up first**: `docker exec <svc> pg_dumpall -U <user> > <file>.sql` (or
   the engine's equivalent) before touching anything.
2. The reconcile workflow cannot operate while **Forgejo itself is down** —
   Dockhand's git stacks hard-fail `git pull`. Stacks Forgejo depends on (e.g.
   `forgejo_pgsql`) must be started out-of-band during the cutover window.
3. Manual cutover on the NAS (no sops there — decrypt on the workstation and
   scp the plaintext env over; delete it afterwards):
   ```
   # NAS, in a temp folder with docker-compose.yml + .env (decrypted):
   docker compose -p <svc> up -d
   ```
   The `-p` flag is **mandatory**: compose otherwise takes the project name
   from the folder basename, and a mismatched project label makes the
   reconcile push hit a container-name conflict.
4. After Forgejo recovers: push the commit. The workflow creates the git stack
   and either adopts the running container (no restart) or recreates it once
   (~10s blip).
5. Delete the plaintext env from the NAS once the reconcile run is green.

## Verification commands

```
# Dockhand stacks (Bearer token = DOCKHAND_API_TOKEN from secrets/reposecrets.sops.yml)
curl -sf -H "Authorization: Bearer $DH" https://docker.nmoura.pt/api/git/stacks | jq -c '[.[] | .stackName]'

# Container state via Portainer API (legacy path, X-API-Key = PORTAINER_API_KEY from sops)
curl -sk -H "X-API-Key: $PAK" "https://192.168.202.1:9443/api/endpoints/1/docker/containers/<name>/json"

# Workflow run status (token from: git credential fill)
curl -sf -H "Authorization: token $TOKEN" \
  "https://git.nmoura.pt/api/v1/repos/nuno/homelab/actions/tasks?limit=10" \
  | jq -r '.workflow_runs[] | "\(.workflow_id) run=\(.run_number) \(.status)"'
```

## Known gotchas

- Env values are quoted in the SOPS files (`KEY="value"`); the workflow strips
  quotes — do not "fix" the files.
- Never name a stack env file plain `.env` in the repo — compose auto-reads it
  and would interpolate ciphertext. The `<svc>.env` name is load-bearing.
- Dockhand's `down` on folder deletion keeps volumes (`removeVolumes: false`).
- The k8s runner's `GITHUB_SERVER_URL` is not the public git URL — the workflow
  matches Dockhand repositories by name, not URL, for this reason.
- `deploy-cloudflare.yml` and `deploy-stacks.yml` are renamed `*.disabled` —
  restore by renaming back (Gitea only runs `*.yml`).
