#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
OC_INIT="$REPO_ROOT/oc-init"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_exists() {
  local path=$1
  [ -f "$path" ] || fail "expected file to exist: $path"
}

assert_missing() {
  local path=$1
  [ ! -e "$path" ] || fail "expected path to be absent: $path"
}

make_stub_bin() {
  local bin_dir=$1

  mkdir -p -- "$bin_dir"

  cat <<'EOF' > "$bin_dir/gh"
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$bin_dir/gh"

  cat <<'EOF' > "$bin_dir/opencode"
#!/usr/bin/env bash
if [ "${1:-}" = 'run' ]; then
  printf '{"type":"text","part":{"text":"# Reconciled\n\n## Repo\n\nKeep repo guidance.\n"}}\n'
fi
exit 0
EOF
  chmod +x "$bin_dir/opencode"
}

make_target_repo() {
  local target_dir=$1

  mkdir -p -- "$target_dir"
  git init "$target_dir" >/dev/null
  git -C "$target_dir" remote add origin https://github.com/example/target.git
}

run_oc_init() {
  local temp_dir=$1
  shift

  PATH="$temp_dir/bin:$PATH" \
  HOME="$temp_dir/home" \
  "$OC_INIT" "$temp_dir/target" "$@" >/dev/null
}

test_installs_default_workflows() {
  local temp_dir
  temp_dir=$(mktemp -d)
  trap 'rm -rf -- "$temp_dir"' RETURN

  mkdir -p -- "$temp_dir/home/.local/share/opencode"
  printf '{}' > "$temp_dir/home/.local/share/opencode/auth.json"
  make_stub_bin "$temp_dir/bin"
  make_target_repo "$temp_dir/target"

  run_oc_init "$temp_dir"

  assert_exists "$temp_dir/target/.github/workflows/opencode.yml"
  assert_exists "$temp_dir/target/.github/workflows/opencode-review.yml"
  assert_missing "$temp_dir/target/.github/workflows/opencode-scheduled.yml"
}

test_installs_scheduled_workflow_only_with_flag() {
  local temp_dir
  temp_dir=$(mktemp -d)
  trap 'rm -rf -- "$temp_dir"' RETURN

  mkdir -p -- "$temp_dir/home/.local/share/opencode"
  printf '{}' > "$temp_dir/home/.local/share/opencode/auth.json"
  make_stub_bin "$temp_dir/bin"
  make_target_repo "$temp_dir/target"

  run_oc_init "$temp_dir" --with-scheduled

  assert_exists "$temp_dir/target/.github/workflows/opencode.yml"
  assert_exists "$temp_dir/target/.github/workflows/opencode-review.yml"
  assert_exists "$temp_dir/target/.github/workflows/opencode-scheduled.yml"
}

test_installs_default_workflows
test_installs_scheduled_workflow_only_with_flag

printf 'PASS: oc-init workflow installation\n'
