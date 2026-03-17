## Setup Secrets

- Add a repository secret named `OPENCODE_AUTH_JSON`.
- Set its value to the full contents of `~/.local/share/opencode/auth.json` from the machine where OpenCode is already authenticated.
- This lets the GitHub Actions runner restore OpenCode provider credentials before running the workflow.
- The workflow also configures a local git author in the runner so commits can be created when using `GITHUB_TOKEN` without the OpenCode GitHub app.
- GitHub Actions repository settings must allow `Read and write permissions` for `GITHUB_TOKEN` and enable `Allow GitHub Actions to create and approve pull requests`.
- The workflow requires `/oc` or `/opencode` in issue comments, pull request comments, pull request review comments, and pull request reviews, and only accepts them from `OWNER`, `MEMBER`, or `COLLABORATOR` users.
- `.github/workflows/opencode-scheduled.yml` reviews the repository every 12 hours and can open tracking issues for bugs or follow-up work.

```bash
gh secret set OPENCODE_AUTH_JSON < ~/.local/share/opencode/auth.json
```

## Labels

- Create the labels `triage` and `bug`.
- New issues are automatically labeled with `triage` by `.github/workflows/issues-triage.yml`.

```bash
gh label create triage --color FBCA04 --description "Needs initial triage"
gh label create bug --color D73A4A --description "Something isn't working"
```

## GitHub Actions Permissions

- Set the default `GITHUB_TOKEN` permission level to `Read and write`.
- Allow GitHub Actions to create and approve pull requests.

```bash
gh api \
  --method PUT \
  "repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/actions/permissions/workflow" \
  -f default_workflow_permissions=write \
  -F can_approve_pull_request_reviews=true
```

## Repository Merge Settings

- Allow only `squash merge`.
- Disable `merge commits`.
- Disable `rebase merge`.
- Enable automatic branch deletion after merge.

```bash
gh api --method PATCH "repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)" \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f allow_squash_merge=true \
  -f delete_branch_on_merge=true
```
