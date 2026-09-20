#!/usr/bin/env bash
set -euo pipefail

: "${HCLOUD_TOKEN:?HCLOUD_TOKEN is required}"

endpoint=$(
  curl --fail --silent --show-error \
    --header "Authorization: Bearer $HCLOUD_TOKEN" \
    "https://api.hetzner.cloud/v1/servers?name=ivanpashkulev-production-1" \
  | jq --exit-status --raw-output '
      .servers
      | if length == 1
        then .[0].public_net.ipv4.ip
        else error("Expected exactly one deployment server")
        end
    '
)

printf 'endpoint=%s\n' "$endpoint" >> "$GITHUB_OUTPUT"
