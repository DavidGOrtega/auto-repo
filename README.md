# OpenCode Repository Bootstrap

Install OpenCode automation into the repo you are currently in with one command, without cloning this repository first.

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash
```

This repository is the bootstrap source for that command.

`oc-init` is not just a file copier. It resolves the target repository root, reconciles the repo-defining OpenCode bootstrap files, preserves other existing managed files by default, and configures the GitHub repository settings the workflows need.

## What `oc-init` does

When you run `oc-init`, it:

- resolves the target repo to the git root, even if you launch it from a nested folder
- reconciles `AGENTS.md` and copies `.github/workflows/opencode.yml` plus `.github/workflows/opencode-review.yml`
- optionally copies `.github/workflows/opencode-scheduled.yml` when you pass `--with-scheduled`
- updates `.gitignore` by appending `.worktrees` only when that entry is missing
- writes `*.oc-init-new` files for existing managed files other than `AGENTS.md`, unless you pass `--force`
- creates or updates the `bug` label through `gh`
- uploads the `ZAI_API_KEY` secret extracted from `~/.config/opencode/opencode.json`
- enables GitHub Actions workflow write permissions and pull request approval permissions
- configures repository merge settings for squash-merge flow and branch cleanup

By default, existing repository content stays in place. `AGENTS.md` is reconciled and overwritten, and `--force` only replaces the other files managed by `oc-init`; it does not touch unrelated files.

## What it includes

- `AGENTS.md` reconciled with repository workflow and contribution guidance for OpenCode sessions.
- `.github/workflows/opencode.yml` to run OpenCode from issue comments.
- `.github/workflows/opencode-review.yml` to run reviewer automation on pull requests.
- `.github/workflows/opencode-scheduled.yml` to perform scheduled repository reviews.
- `.gitignore` updated to include the local `.worktrees` convention used by the branching guide.
- GitHub labels, secrets, workflow permissions, PR approval permissions, and merge settings configured through `gh`.

## Quick start

Remote install from inside your target repo is the default path:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash
```

That command assumes:

- you run it inside the target git repository, even from a nested folder
- `gh` is already authenticated for that repository
- `opencode` is installed locally
- `~/.config/opencode/opencode.json` exists with the ZCode provider API key

Include the scheduled review workflow when you want it:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash -s -- --with-scheduled
```

Replace existing managed files that still use copy semantics instead of emitting `*.oc-init-new` merge copies:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash -s -- --force
```

If you are outside the target repo, pass a path explicitly:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash -s -- ../target-repo
```

If you prefer to run it from a local clone, `./oc-init` also defaults to the current repo and still resolves to the repository root when you launch it from a nested folder:

```bash
./oc-init
```

Pass a target path when you want to install into a different git repository:

```bash
./oc-init ../target-repo
```

Local clone with the optional scheduled workflow:

```bash
./oc-init ../target-repo --with-scheduled
```

Local clone with direct replacement of managed files:

```bash
./oc-init ../target-repo --force
```

`AGENTS.md` is always reconciled through local OpenCode and overwritten directly. The OpenCode provider configuration is stored in the global config (`~/.config/opencode/opencode.json`) and is not placed in the target repository. For the managed workflow files, `oc-init` preserves existing content and writes a `*.oc-init-new` file beside it so you can merge intentionally. Pass `--force` when you want those copy-managed files to be replaced directly. `.gitignore` is handled differently: `oc-init` appends `.worktrees` when needed instead of replacing the file.

If you want to install from a fork or a non-default ref, pass `--source-base-url https://raw.githubusercontent.com/<owner>/<repo>/<ref>`.

## Use this bootstrap in an existing repository

1. From inside the target repo, run the remote `curl ... | bash` command, or use `./oc-init` from a local clone if you already have this repository checked out.
2. Review the reconciled `AGENTS.md` in git diff, and review any generated `*.oc-init-new` files for the remaining managed files.
3. Adjust branch naming, review conventions, or plugin configuration if your team uses different defaults.
4. Commit the resulting files in the target repository.
5. Open an issue or PR comment with `/coder` to verify the workflow is active.

## `/coder` usage

Invoke `/coder` in an issue or PR comment to trigger the workflow:

```
/coder                        # default 20-minute timeout
/coder timeout=60             # 60-minute timeout for this run
/coder timeout 60             # same, alternative syntax
/coder fix this timeout=45    # timeout works anywhere in the comment body
```

The timeout is per-invocation. Add `timeout=N` (or `timeout N`) anywhere in the comment body to override the default 20 minutes for that run only.

## Notes

- The workflows use repository-scoped defaults and do not depend on a hardcoded repository name.
- OpenCode reads the global config (`~/.config/opencode/opencode.json`) for provider and plugin settings. The workflows write this config at runtime.
- `oc-init` now requires the local `opencode` CLI so it can reconcile `AGENTS.md` before applying repository-side GitHub configuration.
- `oc-init` uploads the ZCode API key as the `ZAI_API_KEY` GitHub secret. The workflow config uses `{env:ZAI_API_KEY}` so the key is never committed to the repository.
- Git author configuration is handled inside the workflows so automation can create commits when needed.
- Commits created by the `/coder` workflow are tagged with the commit trailer `By: coder` so reviewer automation can tell when a follow-up `/coder fix this` is valid.
- `oc-init` configures the repository so GitHub Actions can create and approve pull requests.
- OpenCode uses the default `GITHUB_TOKEN` by default, but if you need workflow-triggered PR creation or chained automation between workflows, a dedicated higher-privilege token may still be required.
- The scheduled workflow is optional; add it with `./oc-init --with-scheduled` or `bash -s -- --with-scheduled` if you want automated periodic repository reviews.
- `--force` only affects files managed by `oc-init`; it does not touch unrelated repository content.
