#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TEMP_DIR=$(mktemp -d)

cleanup() {
  rm -rf -- "$TEMP_DIR"
}

trap cleanup EXIT

BOOTSTRAP_DIR="$TEMP_DIR/bootstrap"
TARGET_REPO="$TEMP_DIR/target"
TEST_BIN="$TEMP_DIR/bin"
TEST_HOME="$TEMP_DIR/home"

mkdir -p -- "$BOOTSTRAP_DIR/.github/workflows" "$TARGET_REPO" "$TEST_BIN" "$TEST_HOME/.config/opencode"

cat > "$BOOTSTRAP_DIR/AGENTS.md" <<'EOF'
# Bootstrap AGENTS

## Repo Guidance
Repo-specific guidance lives here.

## Bootstrap Marker
Bootstrap-only guidance should appear in the reconciled result.

### Superpowers Agent Rules

This repository uses Superpowers for agent-driven work.

- Agents must use the relevant Superpowers skill flow.
- Reviewer approvals must start with `# REVIEW <sha>`.
- Approval reviews end with `LGTM`.
- Requested-change reviews end with `/coder fix this`.
EOF

cat > "$BOOTSTRAP_DIR/opencode.json" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "superpowers@git+https://github.com/obra/superpowers.git"
  ]
}
EOF

cat > "$BOOTSTRAP_DIR/.github/workflows/opencode.yml" <<'EOF'
name: opencode
EOF

cat > "$BOOTSTRAP_DIR/.github/workflows/opencode-review.yml" <<'EOF'
name: opencode-review
EOF

mkdir -p -- "$BOOTSTRAP_DIR/.github/scripts"
cat > "$BOOTSTRAP_DIR/.github/scripts/restore-opencode-config.sh" <<'EOF'
#!/bin/sh
exit 0
EOF

git init "$TARGET_REPO" >/dev/null
git -C "$TARGET_REPO" remote add origin https://github.com/example/target.git

cat > "$TARGET_REPO/AGENTS.md" <<'EOF'
# Target AGENTS

## Local Rules
Keep this repo-specific guidance.

### Superpowers Agent Rules

This repository uses Superpowers for agent-driven work.

- Agents must use the relevant Superpowers skill flow.
- Reviewer approvals must start with `# REVIEW <sha>`.
- Approval reviews end with `LGTM`.
- Requested-change reviews end with `/coder fix this`.
EOF

mkdir -p -- "$TARGET_REPO/.github/workflows"
cat > "$TARGET_REPO/.github/workflows/opencode.yml" <<'EOF'
name: existing-opencode
EOF

cat > "$TARGET_REPO/opencode.json" <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "drachtio": {
      "url": "https://gitmcp.io/drachtio/drachtio-server",
      "enabled": true,
      "type": "remote"
    }
  }
}
EOF

cat > "$TEST_HOME/.config/opencode/opencode.json" <<'EOF'
{
  "provider": {
    "ZCode": {
      "options": {
        "apiKey": "test-key"
      }
    }
  }
}
EOF
cp -- "$REPO_ROOT/oc-init" "$TARGET_REPO/oc-init"

cat > "$TEST_BIN/gh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$TEST_BIN/gh"

cat > "$TEST_BIN/opencode" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

prompt=''
target_dir=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    run)
      ;;
    --format)
      shift
      ;;
    --dir)
      shift
      target_dir=$1
      ;;
    *)
      if [ -z "$prompt" ]; then
        prompt=$1
      fi
      ;;
  esac
  shift
done

python3 - "$prompt" "$target_dir" <<'PY'
import json
import sys

prompt = sys.argv[1]
if 'Bootstrap-only guidance should appear in the reconciled result.' not in prompt:
    raise SystemExit('bootstrap AGENTS content was not passed to opencode')

print(json.dumps({"type": "text", "part": {"text": "# Reconciled AGENTS\n\n## Local Rules\nKeep this repo-specific guidance.\n\n## Bootstrap Marker\nBootstrap-only guidance should appear in the reconciled result.\n\n### Superpowers Agent Rules\n\nThis repository uses Superpowers for agent-driven work.\n\n- Agents must use the relevant Superpowers skill flow.\n- Reviewer approvals must start with `# REVIEW <sha>`.\n- Approval reviews end with `LGTM`.\n- Requested-change reviews end with `/coder fix this`.\n"}}))
PY
EOF
chmod +x "$TEST_BIN/opencode"

PATH="$TEST_BIN:$PATH" HOME="$TEST_HOME" bash "$TARGET_REPO/oc-init" --source-base-url "file://$BOOTSTRAP_DIR" "$TARGET_REPO" >/dev/null

python3 - "$TARGET_REPO/AGENTS.md" <<'PY'
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text()
if 'Bootstrap-only guidance should appear in the reconciled result.' not in text:
    raise SystemExit('expected reconciled AGENTS.md to include bootstrap-only guidance')
if 'Keep this repo-specific guidance.' not in text:
    raise SystemExit('expected reconciled AGENTS.md to keep repo-specific guidance')
PY

python3 - "$TARGET_REPO/.github/workflows/opencode.yml.oc-init-new" <<'PY'
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text().strip()
if text != 'name: opencode':
    raise SystemExit(f'expected workflow side file to come from bootstrap template, got: {text!r}')
PY
