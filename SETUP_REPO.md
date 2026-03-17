# Apply this bootstrap to an existing repository

Use this repository as a source of reusable workflow and agent configuration. The target repository should already exist and already be initialized with git.

## Copy the bootstrap files

Copy these files into the target repository:

- `AGENTS.md`
- `SETUP_REPO.md`
- `.github/workflows/opencode.yml`
- `.github/workflows/opencode-scheduled.yml`
- `.github/workflows/issues-triage.yml`

Example:

```bash
cp AGENTS.md /path/to/target-repo/
cp SETUP_REPO.md /path/to/target-repo/
mkdir -p /path/to/target-repo/.github/workflows
cp .github/workflows/opencode.yml /path/to/target-repo/.github/workflows/
cp .github/workflows/opencode-scheduled.yml /path/to/target-repo/.github/workflows/
cp .github/workflows/issues-triage.yml /path/to/target-repo/.github/workflows/
```

## What each file does

- `AGENTS.md` defines branch, PR, and documentation rules for coding agents
- `.github/workflows/opencode.yml` runs OpenCode from issue comments, PR comments, and PR reviews
- `.github/workflows/opencode-scheduled.yml` runs a scheduled repository review every 12 hours
- `.github/workflows/issues-triage.yml` adds the `triage` label to newly opened issues

## Configure secrets

- Add a repository secret named `OPENCODE_AUTH_JSON`
- Set its value to the full contents of `~/.local/share/opencode/auth.json` from a machine where OpenCode is already authenticated
- This lets the GitHub Actions runner restore OpenCode provider credentials before running the workflow
- The workflows already configure a local git author in the runner so commits can be created with `GITHUB_TOKEN`

```bash
gh secret set OPENCODE_AUTH_JSON < ~/.local/share/opencode/auth.json
```

## Configure labels

- Create the labels `triage` and `bug`
- New issues are automatically labeled with `triage` by `.github/workflows/issues-triage.yml`
- The scheduled OpenCode review uses `bug` for confirmed defects it files

```bash
gh label create triage --color FBCA04 --description "Needs initial triage"
gh label create bug --color D73A4A --description "Something isn't working"
```

## Configure repository settings

- Allow only `squash merge`
- Disable `merge commits`
- Disable `rebase merge`
- Enable automatic branch deletion after merge

```bash
gh api --method PATCH "repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)" \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f allow_squash_merge=true \
  -f delete_branch_on_merge=true
```

## Trigger behavior

- In regular issue comments, OpenCode runs only when the comment contains `/oc` or `/opencode`
- In pull requests, comments and reviews from `OWNER`, `MEMBER`, or `COLLABORATOR` users trigger OpenCode automatically
- The scheduled workflow reviews the repository every 12 hours and can open issues for bugs or follow-up work

## Verify the setup

1. Commit the copied files in the target repository
2. Confirm the `OPENCODE_AUTH_JSON` secret exists
3. Open an issue and add a comment with `/oc`
4. Confirm the `opencode` workflow starts successfully
5. Open a test issue and confirm the `triage` label is added automatically
