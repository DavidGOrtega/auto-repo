# OpenCode Repository Bootstrap

This repository is a reusable bootstrap for adding OpenCode automation and GitHub workflow conventions to a repository that already exists.

## What it includes

- `AGENTS.md` with repository workflow and contribution guidance for OpenCode sessions.
- `.github/workflows/opencode.yml` to run OpenCode from issue comments and PR review activity.
- `.github/workflows/opencode-scheduled.yml` to perform scheduled repository reviews.
- `.github/workflows/issues-triage.yml` to label newly opened issues with `triage`.
- `.gitignore` with the local `.worktrees` convention used by the branching guide.
- `SETUP_REPO.md` with the repository configuration steps needed after copying these files.

## Use this bootstrap in an existing repository

1. Copy these files into the target repository:
   - `AGENTS.md`
   - `.gitignore`
   - `.github/workflows/opencode.yml`
   - `.github/workflows/opencode-scheduled.yml`
   - `.github/workflows/issues-triage.yml`
   - `SETUP_REPO.md`
2. Review `AGENTS.md` and adjust branch naming or review conventions if your team uses different defaults.
3. Complete the repository configuration in `SETUP_REPO.md`.
4. Commit the copied files in the target repository.
5. Open an issue or PR comment with `/oc` or `/opencode` to verify the workflow is active.

## Notes

- The workflows use repository-scoped defaults and do not depend on a hardcoded repository name.
- Git author configuration is handled inside the workflows so automation can create commits when needed.
- The scheduled workflow is optional; copy it only if you want automated periodic repository reviews.
