#!/usr/bin/env bash
# Test public packages only. Bazel version comes from .bazelversion via bazelisk.
set -euo pipefail

if ! command -v bazelisk >/dev/null 2>&1; then
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"
  case "${arch}" in
    x86_64) arch="amd64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
      echo "unsupported arch: ${arch}" >&2
      exit 1
      ;;
  esac
  mkdir -p "${HOME}/.local/bin"
  curl -fsSL -o "${HOME}/.local/bin/bazelisk" \
    "https://github.com/bazelbuild/bazelisk/releases/download/v1.29.0/bazelisk-${os}-${arch}"
  chmod +x "${HOME}/.local/bin/bazelisk"
  export PATH="${HOME}/.local/bin:${PATH}"
fi

# Optional Depot remote cache. Off unless DEPOT_TOKEN is set in the agent
# environment. Token is never written to the repo or to .bazelrc.
extra=()
if [ -n "${DEPOT_TOKEN:-}" ]; then
  if command -v buildkite-agent >/dev/null 2>&1; then
    printf '%s\n' "${DEPOT_TOKEN}" | buildkite-agent redactor add
  fi
  extra+=(--remote_cache=https://cache.depot.dev)
  extra+=(--remote_header="authorization=${DEPOT_TOKEN}")
fi

# Bazel 9 exit 4: analysis succeeded, no test targets. Header-only stubs
# have none yet. Real test failures are exit 3; build failures are exit 1.
# https://bazel.build/versions/9.2.0/run/scripts
set +e
bazelisk test "${extra[@]}" -- //clock/... //journal/...
status=$?
set -e
case "${status}" in
  0) exit 0 ;;
  4)
    echo "bazelisk test: no test targets under //clock or //journal yet (exit 4 is success)."
    exit 0
    ;;
  *) exit "${status}" ;;
esac
