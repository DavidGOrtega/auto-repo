# oc-init Reconciliation Design

## Goal

Upgrade `oc-init` from a simple bootstrap file copier into a reconciler for `AGENTS.md` and `opencode.json`, using local OpenCode when needed and failing fast when OpenCode is unavailable.

The new flow should make installs deterministic enough for bootstrap needs while avoiding the current low-intelligence behavior of blindly copying or emitting `*.oc-init-new` files for the two most important configuration files.

## Current State

- `oc-init` currently copies `AGENTS.md` and `opencode.json` directly from the bootstrap source.
- If either target file already exists and `--force` is not used, `oc-init` writes `*.oc-init-new` side files instead of reconciling content.
- `oc-init` already requires:
  - `git`
  - `gh`
  - an authenticated GitHub CLI session
  - `~/.local/share/opencode/auth.json`
- `oc-init` does not currently require the `opencode` binary.
- `README.md` describes `oc-init` as preserving managed files by default with `*.oc-init-new` output.

## Proposed Behavior

`oc-init` should continue managing workflow files and `.gitignore` directly, but it should treat `AGENTS.md` and `opencode.json` as reconciliation targets instead of copy targets.

### OpenCode dependency

Before repository configuration starts, `oc-init` should require a working local `opencode` binary.

If `opencode` is missing, `oc-init` must fail immediately with a clear error. This is required because:

- the local machine already needs OpenCode credentials for bootstrap setup,
- `AGENTS.md` reconciliation will depend on OpenCode itself,
- partial installation without reconciliation would leave the repository in a misleading half-configured state.

## File-specific reconciliation rules

### `opencode.json`

`opencode.json` should be merged structurally as JSON.

Behavior:
- If the file does not exist, write the bootstrap version directly.
- If the file exists, parse both the target file and bootstrap file as JSON objects.
- Merge them so that required bootstrap configuration is present while preserving unrelated existing target configuration.
- Avoid duplicate plugin declarations or duplicate top-level values.
- Write the merged JSON back to `opencode.json`.

This merge should be deterministic and should not rely on OpenCode.

### `AGENTS.md`

`AGENTS.md` should be reconciled through a local non-interactive OpenCode invocation.

Behavior:
- If the file does not exist, write the bootstrap version directly.
- If the file exists, invoke `opencode` locally with:
  - the current target `AGENTS.md`,
  - the bootstrap `AGENTS.md`,
  - a reconciliation prompt that preserves repository-specific guidance while ensuring the bootstrap-required OpenCode and Superpowers rules are present.
- The reconciled output should overwrite `AGENTS.md` directly.

The reconciliation prompt must instruct OpenCode to:
- preserve repo-specific policy already present in the target file,
- incorporate missing bootstrap-required sections,
- update equivalent sections instead of duplicating them,
- keep Markdown readable and technically concise,
- avoid deleting unrelated repository guidance.

## Overwrite model

For these two files, `oc-init` should stop producing `*.oc-init-new` merge copies.

- `AGENTS.md` should be overwritten with reconciled output.
- `opencode.json` should be overwritten with merged output.

If reconciliation fails for either file, `oc-init` should abort instead of falling back to side files.

Other managed bootstrap files can keep the existing copy-or-`*.oc-init-new` behavior unless changed separately.

## Error handling

`oc-init` should fail clearly when any of the following happens:

- `opencode` is not installed,
- `opencode` exits non-zero during `AGENTS.md` reconciliation,
- existing `opencode.json` cannot be parsed as JSON,
- bootstrap `opencode.json` cannot be parsed as JSON,
- the merged JSON cannot be written back safely,
- the reconciled `AGENTS.md` output is empty or invalid for replacement.

The failure mode should be explicit and stop the bootstrap process before GitHub repository configuration proceeds further.

## README updates

`README.md` should be updated so it no longer describes `AGENTS.md` and `opencode.json` as files that default to `*.oc-init-new` output.

The documentation should instead explain that:
- local `opencode` is now required,
- `AGENTS.md` is reconciled through OpenCode and overwritten,
- `opencode.json` is merged structurally and overwritten,
- other managed files still use the existing `*.oc-init-new` behavior unless `--force` is used.

## Verification

Verify the change with scenarios that cover both fresh installs and repos with existing configuration:

- clean repository with no `AGENTS.md` or `opencode.json`: bootstrap writes both directly;
- repository with existing `opencode.json`: bootstrap preserves unrelated keys while ensuring required bootstrap configuration is present;
- repository with existing `AGENTS.md`: bootstrap produces a single reconciled file with both repo-specific rules and bootstrap-required rules;
- missing local `opencode` binary: `oc-init` fails immediately with a clear message;
- malformed existing `opencode.json`: `oc-init` fails clearly instead of overwriting blindly;
- reconciliation failure from local OpenCode: `oc-init` aborts and does not silently emit `*.oc-init-new` for these two files.

Success means `oc-init` becomes opinionated and reliable for the files that define repo behavior, rather than leaving manual merge debris for the most important bootstrap state.
