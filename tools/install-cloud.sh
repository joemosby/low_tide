#!/usr/bin/env bash
# Idempotent cloud-agent install: bazelisk on PATH, Godot 4.7.2 headless binary.
# Does not bake the editor project or export templates.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"

mkdir -p "${HOME}/.local/bin"
export PATH="${HOME}/.local/bin:${PATH}"

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
  curl -fsSL -o "${HOME}/.local/bin/bazelisk" \
    "https://github.com/bazelbuild/bazelisk/releases/download/v1.29.0/bazelisk-${os}-${arch}"
  chmod +x "${HOME}/.local/bin/bazelisk"
fi

godot_tag="4.7.2-stable"
godot_name="Godot_v${godot_tag}_linux.x86_64"
godot_url="https://github.com/godotengine/godot-builds/releases/download/${godot_tag}/${godot_name}.zip"
dest="${root}/tools/godot"

if [ ! -x "${dest}" ]; then
  tmp="$(mktemp -d)"
  cleanup() { rm -rf "${tmp}"; }
  trap cleanup EXIT
  curl -fsSL -o "${tmp}/godot.zip" "${godot_url}"
  unzip -qo "${tmp}/godot.zip" -d "${tmp}"
  mv "${tmp}/${godot_name}" "${dest}"
  chmod +x "${dest}"
fi
