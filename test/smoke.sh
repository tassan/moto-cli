#!/usr/bin/env bash
# End-to-end smoke test. Needs docker, curl and aws CLI v2.
# Uses its own container name and port so it never touches a running `moto`.
set -euo pipefail

cd "$(dirname "$0")/.."
export MOTO_NAME=moto-smoke MOTO_PORT=5599 MOTO_PROFILE=moto-smoke
MOTO=./moto

cleanup() {
  $MOTO stop >/dev/null 2>&1 || true
  # drop the throwaway aws profile
  sed -i.bak '/^\[moto-smoke\]/,/^$/d' ~/.aws/credentials 2>/dev/null || true
  sed -i.bak '/^\[profile moto-smoke\]/,/^$/d' ~/.aws/config 2>/dev/null || true
  rm -f ~/.aws/credentials.bak ~/.aws/config.bak
}
trap cleanup EXIT

step() { printf '== %s\n' "$*"; }
fail() { echo "FAIL: $*" >&2; exit 1; }

step "help"
$MOTO help | grep -q "usage: moto" || fail "help output"

step "start (idempotent)"
$MOTO start >/dev/null
$MOTO start >/dev/null
$MOTO status | grep -q running || fail "status after start"

step "doctor"
$MOTO doctor >/dev/null || fail "doctor"

step "s3 round trip"
$MOTO aws s3 mb s3://smoke-bucket >/dev/null
$MOTO aws s3 ls | grep -q smoke-bucket || fail "bucket missing"

step "reset"
$MOTO reset >/dev/null
$MOTO aws s3 ls | grep -q smoke-bucket && fail "bucket survived reset"

step "env"
$MOTO env | grep -q "AWS_ENDPOINT_URL=http://localhost:5599" || fail "env output"

step "stop"
$MOTO stop >/dev/null
$MOTO status | grep -q stopped || fail "status after stop"

echo "all passed"
