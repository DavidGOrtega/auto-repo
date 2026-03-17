## Apply to an Existing Repository

Run `./oc-init /path/to/target-repo` from this repository before running the setup commands.

By default the script copies these files into the target repository:

- `AGENTS.md`
- `.gitignore`
- `.github/workflows/opencode.yml`
- `.github/workflows/issues-triage.yml`
- `SETUP_REPO.md`

If you also want scheduled repository reviews, run `./oc-init /path/to/target-repo --with-scheduled` to include `.github/workflows/opencode-scheduled.yml`.

If the target repository already has any of these files, the script keeps the current file in place and writes a `*.oc-init-new` copy beside it. Merge the relevant changes instead of overwriting them blindly.

## Setup Secrets

- Add a repository secret named `OPENCODE_AUTH_JSON`.
- Set its value to the full contents of `~/.local/share/opencode/auth.json` from the machine where OpenCode is already authenticated.
- This lets the GitHub Actions runner restore OpenCode provider credentials before running the workflow.
- The workflow also configures a local git author in the runner so commits can be created when using `GITHUB_TOKEN` without the OpenCode GitHub app.
- The workflow requires `/oc` or `/opencode` in regular issue comments, but pull request comments, pull request review comments, and pull request reviews from `OWNER`, `MEMBER`, or `COLLABORATOR` users trigger OpenCode implicitly.
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

- Confirm `./oc-init` copied the expected files and that any `*.oc-init-new` files were merged intentionally.
- Confirm GitHub Actions is enabled in the target repository.
- Confirm the `OPENCODE_AUTH_JSON` secret exists.
- Confirm the `triage` and `bug` labels exist.
- Open a test issue and add a comment containing `/oc` or `/opencode`.
- Verify the `opencode` workflow starts and posts back to the thread.
