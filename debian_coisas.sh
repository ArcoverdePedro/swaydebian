#!/usr/bin/env bash
# Nome historico mantido por compatibilidade.
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec "$ROOT/install.sh" "$@"
