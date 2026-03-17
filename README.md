# auto-repo

Reusable bootstrap for repositories that want OpenCode-driven issue and PR automation without starting from a template.

## What this repository provides

- `.github/workflows/opencode.yml` to run OpenCode from issue and PR activity
- `.github/workflows/opencode-scheduled.yml` to run recurring repository reviews
- `.github/workflows/issues-triage.yml` to apply a default `triage` label to new issues
- `AGENTS.md` with repository workflow and pull request conventions for coding agents
- `SETUP_REPO.md` with the steps needed to apply this setup to an existing repository

## Use it with an existing repository

Copy the bootstrap files into an already initialized repository, then follow `SETUP_REPO.md`.

```bash
cp AGENTS.md /path/to/target-repo/
cp SETUP_REPO.md /path/to/target-repo/
mkdir -p /path/to/target-repo/.github/workflows
cp .github/workflows/opencode.yml /path/to/target-repo/.github/workflows/
cp .github/workflows/opencode-scheduled.yml /path/to/target-repo/.github/workflows/
cp .github/workflows/issues-triage.yml /path/to/target-repo/.github/workflows/
```

After copying the files:

1. Configure the repository secret described in `SETUP_REPO.md`
2. Create the required labels
3. Apply the recommended merge settings
4. Trigger `/oc` or `/opencode` in an issue comment to verify the workflow
