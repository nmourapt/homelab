# Domain Docs

How the engineering skills should consume this repo's domain documentation when
exploring the codebase.

This is a single-context repo (homelab infrastructure-as-code). Domain language
is one flat vocabulary covering Cloudflare, Portainer, Talos/Omni, Synology,
SOPS, and the CI/CD pipelines.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root — domain glossary (does not yet exist; will
  be created lazily by `grill-with-docs` when the first term is resolved).
- **`docs/adr/`** — architectural decisions (does not yet exist; will be created
  lazily by `grill-with-docs` when the first ADR-worthy decision lands).

If any of these files don't exist, **proceed silently**. Don't flag their
absence; don't suggest creating them upfront. They are created lazily when terms
or decisions actually get resolved.

## File structure

```
/
├── CONTEXT.md
├── docs/adr/
├── docs/agents/
└── (cloudflare/, portainer/, kubernetes/, synology/, secrets/, sops/)
```

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor
proposal, a hypothesis, a test name), use the term as defined in `CONTEXT.md`.
Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either
you're inventing language the project doesn't use (reconsider) or there's a
real gap (note it for `grill-with-docs`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than
silently overriding:

> _Contradicts ADR-0007 — but worth reopening because…_
