# OpenCode Repository Bootstrap

Install OpenCode automation into the repo you are currently in with one command, without cloning this repository first.

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash
```

This repository is the bootstrap source for that command. It adds OpenCode workflow conventions to a repository that already exists.

## What it includes

- `AGENTS.md` with repository workflow and contribution guidance for OpenCode sessions.
- `.github/workflows/opencode.yml` to run OpenCode from issue comments and PR review activity.
- `.github/workflows/opencode-scheduled.yml` to perform scheduled repository reviews.
- `.github/workflows/issues-triage.yml` to label newly opened issues with `triage`.
- `.gitignore` with the local `.worktrees` convention used by the branching guide.
- `SETUP_REPO.md` with the repository configuration steps needed after copying these files.

## Quick start

Remote install from inside your target repo is the default path:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash
```

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

If you prefer to run it from a local clone, `./oc-init` also defaults to the current repo:

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

If a target file already exists, `oc-init` preserves it and writes a `*.oc-init-new` file beside it so you can merge intentionally. Pass `--force` when you want the bootstrap-managed files to be replaced directly.

If you want to install from a fork or a non-default ref, pass `--source-base-url https://raw.githubusercontent.com/<owner>/<repo>/<ref>`.

## Use this bootstrap in an existing repository

1. From inside the target repo, run the remote `curl ... | bash` command, or use `./oc-init` from a local clone if you already have this repository checked out.
2. Review any generated `*.oc-init-new` files and merge them with the target repository's existing files, or use `--force` when you explicitly want bootstrap-managed files replaced.
3. Review `AGENTS.md` and adjust branch naming or review conventions if your team uses different defaults.
4. Complete the repository configuration in `SETUP_REPO.md`.
5. Commit the copied files in the target repository.
6. Open an issue or PR comment with `/oc` or `/opencode` to verify the workflow is active.

## Notes

- The workflows use repository-scoped defaults and do not depend on a hardcoded repository name.
- Git author configuration is handled inside the workflows so automation can create commits when needed.
- The scheduled workflow is optional; add it with `./oc-init --with-scheduled` or `bash -s -- --with-scheduled` if you want automated periodic repository reviews.
- `--force` only affects files managed by `oc-init`; it does not touch unrelated repository content.
