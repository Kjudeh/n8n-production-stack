#!/usr/bin/env bash
# Bumps the pinned n8n tag+digest to the latest stable release.
set -euo pipefail

hub="https://hub.docker.com/v2/repositories/n8nio/n8n"
tag=$(curl -fsSL "$hub/tags?page_size=100" | jq -r '.results[].name' \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
digest=$(curl -fsSL "$hub/tags/$tag" | jq -r '.digest')
sed -i -E "s|^FROM n8nio/n8n:.*|FROM n8nio/n8n:${tag}@${digest}|" services/n8n/Dockerfile
echo "n8n: ${tag}@${digest}"
