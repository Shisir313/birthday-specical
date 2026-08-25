#!/usr/bin/env bash

set -euo pipefail

if [[ "${1:-}" == "-c" && "${2:-}" == "log.showSignature=false" ]]; then
  shift 2
fi

exec "${NETLIFY_SYSTEM_GIT:?}" "$@"
