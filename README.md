# OpenCode Repository Bootstrap

This repository is a reusable bootstrap for adding OpenCode automation and GitHub workflow conventions to a repository that already exists.

Use `./oc-init` to copy the bootstrap into another git repository instead of manually collecting files.

The same script also works as a remote installer, so you can pipe it straight into `bash` without cloning this repository first.

## What it includes

- `AGENTS.md` with repository workflow and contribution guidance for OpenCode sessions.
- `.github/workflows/opencode.yml` to run OpenCode from issue comments and PR review activity.
- `.github/workflows/opencode-scheduled.yml` to perform scheduled repository reviews.
- `.github/workflows/issues-triage.yml` to label newly opened issues with `triage`.
- `.gitignore` with the local `.worktrees` convention used by the branching guide.
- `SETUP_REPO.md` with the repository configuration steps needed after copying these files.

## Quick start

Run the bootstrap script from this repository and point it at an existing git repository:

```bash
./oc-init ../target-repo
```

Include the scheduled review workflow only when you want it:

```bash
./oc-init ../target-repo --with-scheduled
```

Run it remotely without cloning this repository first:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash -s -- ../target-repo
```

Remote installs can also include the scheduled workflow:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash -s -- ../target-repo --with-scheduled
```

If a target file already exists, `oc-init` preserves it and writes a `*.oc-init-new` file beside it so you can merge intentionally.

If you want to install from a fork or a non-default ref, pass `--source-base-url https://raw.githubusercontent.com/<owner>/<repo>/<ref>`.

## Use this bootstrap in an existing repository

1. Run `./oc-init /path/to/target-repo` from this repository, or use the remote `curl ... | bash` form.
2. Review any generated `*.oc-init-new` files and merge them with the target repository's existing files.
3. Review `AGENTS.md` and adjust branch naming or review conventions if your team uses different defaults.
4. Complete the repository configuration in `SETUP_REPO.md`.
5. Commit the copied files in the target repository.
6. Open an issue or PR comment with `/oc` or `/opencode` to verify the workflow is active.

## Notes

- The workflows use repository-scoped defaults and do not depend on a hardcoded repository name.
- Git author configuration is handled inside the workflows so automation can create commits when needed.
- The scheduled workflow is optional; add it with `./oc-init --with-scheduled` if you want automated periodic repository reviews.
