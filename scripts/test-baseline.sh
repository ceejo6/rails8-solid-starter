#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

run_check() {
  local desc="$1"
  shift
  local err_file
  err_file="$(mktemp)"
  if ! "$@" > "$err_file" 2>&1; then
    echo "FAILED: $desc"
    echo "--- Error Details ---"
    cat "$err_file"
    rm -f "$err_file"
    exit 1
  fi
  rm -f "$err_file"
}

run_check "Environment file exists (.env)" test -f .env
run_check "Compose file exists (compose.yaml)" test -f compose.yaml
run_check "Build and start stack" docker compose up -d --build

check_puma() {
  for _ in {1..25}; do
    if curl -fsS "http://localhost:${APP_PORT}/up" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

source .env
run_check "Puma responds HTTP 200 on /up" check_puma

verify_sqlite_persistence() {
  test -f "data/storage/production.sqlite3" || return 1
  return 0
}
run_check "SQLite primary DB initialized in data/storage" verify_sqlite_persistence

echo "PASS"
exit 0
