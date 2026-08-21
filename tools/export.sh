#!/usr/bin/env bash
# Export place/ to a Linux x86_64 cove binary. Godot 4.7.2. Never Bazel.
#
# How-to (no editor GUI):
#   1. Godot 4.7.2: GODOT, tools/godot, or godot on PATH.
#      ./tools/install-cloud.sh fetches the official Linux binary (gitignored).
#   2. Official templates (this script fetches them into a gitignored dir):
#      https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz
#   3. ./tools/export.sh
#   4. ./dist/cove.x86_64
#
# --qa: skip honestly when Godot or templates are missing. Do not fetch.
#       Fail closed only when both are present and the export is broken.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"

qa=0
fetch=1
if [ "${1:-}" = "--qa" ]; then
  qa=1
  fetch=0
fi

godot_bin=""
if [ -n "${GODOT:-}" ]; then
  if [ -x "${GODOT}" ]; then
    godot_bin="${GODOT}"
  elif command -v "${GODOT}" >/dev/null 2>&1; then
    godot_bin="$(command -v "${GODOT}")"
  fi
fi
if [ -z "${godot_bin}" ] && [ -x "${root}/tools/godot" ]; then
  godot_bin="${root}/tools/godot"
fi
if [ -z "${godot_bin}" ] && command -v godot >/dev/null 2>&1; then
  godot_bin="$(command -v godot)"
fi

if [ -z "${godot_bin}" ]; then
  if [ "${qa}" -eq 1 ]; then
    echo "export QA: skipped (no GODOT on PATH and no tools/godot)"
    exit 0
  fi
  echo "export: need Godot 4.7.2 (GODOT, tools/godot, or godot on PATH)" >&2
  exit 1
fi

preset="${root}/place/export_presets.cfg"
if [ ! -f "${preset}" ]; then
  echo "export: missing place/export_presets.cfg" >&2
  exit 1
fi

godot_tag="4.7.2-stable"
template_ver="4.7.2.stable"
template_file="linux_release.x86_64"
official_dir="${HOME}/.local/share/godot/export_templates/${template_ver}"
cache_dir="${root}/tools/export-templates"
cache_inner="${cache_dir}/templates"
tpz_name="Godot_v${godot_tag}_export_templates.tpz"
tpz_url="https://github.com/godotengine/godot-builds/releases/download/${godot_tag}/${tpz_name}"

template_present() {
  local dir="$1"
  [ -f "${dir}/${template_file}" ]
}

ensure_official_link() {
  local src="$1"
  mkdir -p "$(dirname "${official_dir}")"
  if [ -e "${official_dir}" ] && [ ! -L "${official_dir}" ]; then
    return 0
  fi
  ln -sfn "${src}" "${official_dir}"
}

if template_present "${official_dir}"; then
  :
elif template_present "${cache_inner}"; then
  ensure_official_link "${cache_inner}"
elif [ "${fetch}" -eq 1 ]; then
  echo "export: fetching official ${godot_tag} templates (gitignored)"
  mkdir -p "${cache_dir}"
  curl -fsSL -o "${cache_dir}/${tpz_name}" "${tpz_url}"
  unzip -qo "${cache_dir}/${tpz_name}" -d "${cache_dir}"
  if ! template_present "${cache_inner}"; then
    echo "export: ${tpz_name} unpacked without ${template_file}" >&2
    exit 1
  fi
  ensure_official_link "${cache_inner}"
else
  echo "export QA: skipped (no ${template_ver} templates)"
  exit 0
fi

if ! template_present "${official_dir}"; then
  echo "export: templates not visible at ${official_dir}" >&2
  exit 1
fi

out_dir="${root}/dist"
out="${out_dir}/cove.x86_64"
mkdir -p "${out_dir}"
rm -f "${out}"

# --export-release must be last. Output stays in gitignored dist/.
set +e
"${godot_bin}" --headless --path "${root}/place" \
  --export-release Linux "${out}"
status=$?
set -e

if [ ! -f "${out}" ]; then
  echo "export: Godot exited ${status}; no ${out}" >&2
  exit 1
fi
chmod +x "${out}"

if ! file "${out}" | grep -q 'ELF 64-bit.*x86-64'; then
  echo "export: ${out} is not a Linux x86_64 ELF" >&2
  file "${out}" >&2 || true
  exit 1
fi

echo "export: ${out}"
exit 0
