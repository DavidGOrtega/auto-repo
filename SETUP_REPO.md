## Apply to an Existing Repository

Start with the remote bootstrap command so you can install this into an existing repository without cloning this one first:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash -s -- /path/to/target-repo
```

After that, the rest of this document is the manual repository setup checklist.

If you already have this repository cloned locally, you can run:

```bash
./oc-init /path/to/target-repo
```

By default the script copies these files into the target repository:

- `AGENTS.md`
- `.gitignore`
- `.github/workflows/opencode.yml`
- `.github/workflows/issues-triage.yml`
- `SETUP_REPO.md`

If you also want scheduled repository reviews, run `./oc-init /path/to/target-repo --with-scheduled` or add `--with-scheduled` to the remote command to include `.github/workflows/opencode-scheduled.yml`.

If the target repository already has any of these files, the script keeps the current file in place and writes a `*.oc-init-new` copy beside it. Merge the relevant changes instead of overwriting them blindly.

If you want to replace the bootstrap-managed files directly, add `--force`.

If you need to install from a fork or branch instead of the default remote source, add `--source-base-url https://raw.githubusercontent.com/<owner>/<repo>/<ref>`.

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

## Repository Files

- `AGENTS.md` defines the working agreement OpenCode should follow inside the repository.
- `.github/workflows/opencode.yml` handles interactive `/oc` and `/opencode` requests.
- `.github/workflows/opencode-scheduled.yml` runs a scheduled review every 12 hours.
- `.github/workflows/issues-triage.yml` labels new issues with `triage`.
- `.gitignore` ignores the local `.worktrees` directory used by the branching workflow.
- `oc-init` is the bootstrap entrypoint that copies these files into an existing repository.

## Labels

- Create the labels `triage` and `bug`.
- New issues are automatically labeled with `triage` by `.github/workflows/issues-triage.yml`.

```bash
gh label create triage --color FBCA04 --description "Needs initial triage"
gh label create bug --color D73A4A --description "Something isn't working"
```

## Optional Repository Settings

- If the target repository already has its own label taxonomy, keep the existing labels and only add the missing ones required by the workflows.
- If the target repository does not want scheduled reviews, omit `.github/workflows/opencode-scheduled.yml`.

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

## Verification

- Confirm `./oc-init` copied or replaced the expected files and that any `*.oc-init-new` files were merged intentionally when `--force` was not used.
- Confirm GitHub Actions is enabled in the target repository.
- Confirm the `OPENCODE_AUTH_JSON` secret exists.
- Confirm the `triage` and `bug` labels exist.
- Open a test issue and add a comment containing `/oc` or `/opencode`.
- Verify the `opencode` workflow starts and posts back to the thread.
