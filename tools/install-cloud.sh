#!/usr/bin/env bash
# Idempotent cloud-agent install: bazelisk, clang-format, Godot 4.7.2
# headless binary, official Blender CLI. Does not bake the editor
# project or export templates. Does not commit Blender. Host Blender
# is a known leak, like host Godot.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"

mkdir -p "${HOME}/.local/bin"
export PATH="${HOME}/.local/bin:${PATH}"
if [ -f "${HOME}/.profile" ] && ! grep -qs '.local/bin' "${HOME}/.profile"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.profile"
fi

if [ ! -x "${HOME}/.local/bin/bazelisk" ]; then
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

if ! command -v clang-format >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1 && command -v sudo >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y clang-format
  else
    echo "clang-format is required (Allman + 80). Install clang-format and retry." >&2
    exit 1
  fi
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

# Official Linux x64 tarball. The binary needs its sibling libs; keep
# the extract and symlink tools/blender. Gitignored.
blender_ver="4.5.12"
blender_name="blender-${blender_ver}-linux-x64"
blender_url="https://download.blender.org/release/Blender4.5/${blender_name}.tar.xz"
blender_dir="${root}/tools/${blender_name}"
blender_bin="${root}/tools/blender"

if [ ! -x "${blender_bin}" ]; then
  tmp="$(mktemp -d)"
  cleanup_blender() { rm -rf "${tmp}"; }
  trap cleanup_blender EXIT
  curl -fsSL -o "${tmp}/blender.tar.xz" "${blender_url}"
  tar -xJf "${tmp}/blender.tar.xz" -C "${root}/tools"
  if [ ! -x "${blender_dir}/blender" ]; then
    echo "blender is required (headless glTF export). Install Blender and retry." >&2
    exit 1
  fi
  ln -sfn "${blender_dir}/blender" "${blender_bin}"
fi
