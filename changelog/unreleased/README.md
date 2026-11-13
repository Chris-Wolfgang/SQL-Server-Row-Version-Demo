# Changelog fragments

`CHANGELOG.md` is not edited by hand. A pull request that makes a reader-visible change to an example (a
script or its ReadMe) adds **one fragment file** to this directory; when a batch of changes is collected the
fragments are assembled into a new section of `CHANGELOG.md` and deleted. This avoids merge conflicts on
`CHANGELOG.md` and keeps each entry next to the change that earned it.

This is the fleet-wide convention from
[repo-template](https://github.com/Chris-Wolfgang/repo-template/blob/main/changelog/unreleased/README.md),
applied to a repository of SQL examples.

## Writing a fragment

Create `changelog/unreleased/<short-change-name>.md` (kebab-case, named for the change, not the PR number):

```
type: fix

Propagate rows deleted from the source table to the destination table in example 1.
```

- **Line 1** is `type: <kind>` where `<kind>` is one of:

  | Kind | Use for | Assembles under |
  |------|---------|-----------------|
  | `breaking` | A change that makes an example behave differently for someone already following it (renamed scripts, a different database or schema) | Breaking changes |
  | `feature` | A new example, or a new step in an existing one | Added |
  | `fix` | A script or ReadMe correction | Fixed |
  | `docs` | Other reader-visible text changes | Documentation |
  | `internal` | CI, tooling or repository housekeeping with no visible effect | Internal |

- **The rest** is a one-sentence, reader-facing description.

## When a fragment is needed

The CI check (`scripts/changelog.ps1 check`, run by `.github/workflows/changelog.yaml`) is the
repo-template script unchanged. It requires a fragment only when a PR changes files under `src/`, and this
repository has no `src/` (the examples live under `example/`), so here a fragment is **encouraged, not
enforced**. The check still validates every fragment in this directory on every PR: a recognised `type:`
on line 1 and a non-empty description.

```powershell
pwsh ./scripts/changelog.ps1 check                     # against origin/main
```

## Assembling

```powershell
pwsh ./scripts/changelog.ps1 assemble -Version 2026.11.0
```

`assemble` inserts a `## [<version>] - <today>` section under `## [Unreleased]` in `CHANGELOG.md`, grouped
by kind, then deletes the fragments. The repository has no releases, so the version is just a label for
the batch (a date-style version as above is fine).
