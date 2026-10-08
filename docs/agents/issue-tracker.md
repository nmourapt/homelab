# Issue tracker: Forgejo (self-hosted)

Issues and PRDs for this repo live on the self-hosted Forgejo instance at
`https://git.nmoura.pt` under the `nuno/homelab` project.

## Conventions

- The agent creates and reads issues via the `forgejo_issue_*` MCP tools
  (`forgejo_issue_write` with `method: "create"`, `forgejo_issue_read` with
  `method: "get"`, `forgejo_list_issues`, `forgejo_search_issues`).
- Owner is `nuno`, repo is `homelab` unless specified otherwise.
- The PRD is published as an issue with the `ready-for-agent` triage label
  (or a `prd` label when available).
- Implementation issues are normal issues that reference the PRD issue number
  in their body.
- Triage state is recorded via Forgejo labels — see `triage-labels.md` for the
  role strings.

## When a skill says "publish to the issue tracker"

Call `forgejo_issue_write` with `method: "create"`, `owner: "nuno"`,
`repo: "homelab"`, plus the title and body.

## When a skill says "fetch the relevant ticket"

Call `forgejo_issue_read` with `method: "get"` and the issue number, or
`forgejo_search_issues` with a query.
