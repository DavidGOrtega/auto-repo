## Summary
The OpenCode config migration PR should stay focused on moving provider configuration to runtime config and wiring `ZAI_API_KEY`. Any change that narrows workflow triggers to only explicit `/oc` or `/opencode` commands is a separate behavior change and should be evaluated independently.

## Context
The review on PR #104 flagged a trigger-policy change in `.github/workflows/opencode.yml` as out of scope for the config migration.

## Proposed follow-up
- Compare the current `/coder` trigger behavior against a stricter explicit-command policy
- Decide which events should require command gating
- Update workflow tests or documentation together with any behavior change

## Verification
- Confirm the issue captures the trigger-policy scope separately from the config migration work
