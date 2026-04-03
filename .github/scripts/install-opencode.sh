#!/bin/sh
set -eu

curl -fsSL https://opencode.ai/install | bash

mkdir -p "$HOME/.config/opencode"
cat > "$HOME/.config/opencode/opencode.json" <<'CONFIG'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "superpowers@git+https://github.com/obra/superpowers.git"
  ],
  "provider": {
    "ZCode": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Z.ai coder plan",
      "options": {
        "baseURL": "https://api.z.ai/api/coding/paas/v4",
        "apiKey": "{env:ZAI_API_KEY}"
      },
      "models": {
        "glm-5.1": {
          "name": "GLM 5.1"
        }
      }
    }
  }
}
CONFIG
