# OpenCode Repository Bootstrap

Install OpenCode automation into the repo you are currently in with one command, without cloning this repository first.

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash
```

This repository is the bootstrap source for that command.

`oc-init` is not just a file copier. It resolves the target repository root, installs the OpenCode bootstrap files, preserves existing files by default, and configures the GitHub repository settings the workflows need.

## What `oc-init` does

When you run `oc-init`, it:

- resolves the target repo to the git root, even if you launch it from a nested folder
- copies `AGENTS.md`, `.github/workflows/opencode.yml`, and `.github/workflows/issues-triage.yml`
- optionally copies `.github/workflows/opencode-scheduled.yml` when you pass `--with-scheduled`
- updates `.gitignore` by appending `.worktrees` only when that entry is missing
- writes `*.oc-init-new` files instead of overwriting existing managed files, unless you pass `--force`
- creates or updates the `triage` and `bug` labels through `gh`
- uploads the `OPENCODE_AUTH_JSON` secret from `~/.local/share/opencode/auth.json`
- enables GitHub Actions workflow write permissions and pull request approval permissions
- configures repository merge settings for squash-merge flow and branch cleanup

By default, existing repository content stays in place. `--force` only replaces the files managed by `oc-init`; it does not touch unrelated files.

## What it includes

- `AGENTS.md` with repository workflow and contribution guidance for OpenCode sessions.
- `.github/workflows/opencode.yml` to run OpenCode from issue comments and PR review activity.
- `.github/workflows/opencode-scheduled.yml` to perform scheduled repository reviews.
- `.github/workflows/issues-triage.yml` to label newly opened issues with `triage`.
- `.gitignore` updated to include the local `.worktrees` convention used by the branching guide.
- GitHub labels, secret, workflow permissions, PR approval permissions, and merge settings configured through `gh`.

## Quick start

Remote install from inside your target repo is the default path:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash
```

That command assumes:

- you run it inside the target git repository, even from a nested folder
- `gh` is already authenticated for that repository
- `~/.local/share/opencode/auth.json` exists on your machine

Include the scheduled review workflow when you want it:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash -s -- --with-scheduled
```

Replace existing managed files instead of emitting `*.oc-init-new` merge copies:

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

If a target file already exists, `oc-init` preserves it and writes a `*.oc-init-new` file beside it so you can merge intentionally. Pass `--force` when you want the bootstrap-managed files to be replaced directly. `.gitignore` is handled differently: `oc-init` appends `.worktrees` when needed instead of replacing the file.

If you want to install from a fork or a non-default ref, pass `--source-base-url https://raw.githubusercontent.com/<owner>/<repo>/<ref>`.

## Use this bootstrap in an existing repository

1. From inside the target repo, run the remote `curl ... | bash` command, or use `./oc-init` from a local clone if you already have this repository checked out.
2. Review any generated `*.oc-init-new` files and merge them with the target repository's existing files, or use `--force` when you explicitly want bootstrap-managed files replaced.
3. Review `AGENTS.md` and adjust branch naming or review conventions if your team uses different defaults.
4. Commit the copied files in the target repository.
5. Open an issue or PR comment with `/oc` or `/opencode` to verify the workflow is active.

## Notes

- The workflows use repository-scoped defaults and do not depend on a hardcoded repository name.
- Git author configuration is handled inside the workflows so automation can create commits when needed.
- `oc-init` configures the repository so GitHub Actions can create and approve pull requests.
- Do not expect OpenCode automation to create or edit workflow files automatically. GitHub blocks workflow-file writes unless the token has explicit workflow permission, so workflow changes should be reviewed and applied manually.
- The scheduled workflow is optional; add it with `./oc-init --with-scheduled` or `bash -s -- --with-scheduled` if you want automated periodic repository reviews.
- `--force` only affects files managed by `oc-init`; it does not touch unrelated repository content.
