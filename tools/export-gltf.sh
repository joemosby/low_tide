#!/usr/bin/env bash
# Export a glTF into place/art/ via official Blender --background.
# Never Bazel. Never the Godot editor. Do not commit Blender.
# Host Blender is a known leak, like host Godot.
#
# How-to (no editor GUI):
#   1. Official Blender CLI: BLENDER, tools/blender, or blender on PATH.
#      ./tools/install-cloud.sh fetches the official Linux tarball
#      (gitignored).
#   2. A .blend: ./tools/export-gltf.sh cove.blend
#      writes place/art/cove.gltf
#   3. Explicit out (under place/): ./tools/export-gltf.sh in.blend \
#      place/art/cove.gltf
#   4. QA fixture (no .blend): ./tools/export-gltf.sh --qa
#      writes place/art/.qa_export.gltf (gitignored)
#
# --qa: skip honestly when Blender is missing. Do not fetch. Fail
#       closed only when Blender is present and the export is dirty.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"

qa=0
blend=""
out=""
for arg in "$@"; do
  case "${arg}" in
    --qa)
      qa=1
      ;;
    --help|-h)
      echo "usage: ./tools/export-gltf.sh [--qa] [in.blend] [out.gltf]" >&2
      exit 0
      ;;
    *)
      if [ -z "${blend}" ]; then
        blend="${arg}"
      elif [ -z "${out}" ]; then
        out="${arg}"
      else
        echo "export-gltf: unknown argument: ${arg}" >&2
        echo "usage: ./tools/export-gltf.sh [--qa] [in.blend] [out.gltf]" >&2
        exit 1
      fi
      ;;
  esac
done

blender_bin=""
if [ -n "${BLENDER:-}" ]; then
  if [ -x "${BLENDER}" ]; then
    blender_bin="${BLENDER}"
  elif command -v "${BLENDER}" >/dev/null 2>&1; then
    blender_bin="$(command -v "${BLENDER}")"
  fi
fi
if [ -z "${blender_bin}" ] && [ -x "${root}/tools/blender" ]; then
  blender_bin="${root}/tools/blender"
fi
if [ -z "${blender_bin}" ] && command -v blender >/dev/null 2>&1; then
  blender_bin="$(command -v blender)"
fi

if [ -z "${blender_bin}" ]; then
  if [ "${qa}" -eq 1 ]; then
    echo "gltf export QA: skipped (no BLENDER on PATH and no tools/blender)"
    exit 0
  fi
  echo "blender is required (headless glTF export). Install Blender and retry." >&2
  exit 1
fi

py="${root}/tools/export_gltf.py"
if [ ! -f "${py}" ]; then
  echo "export-gltf: missing ${py}" >&2
  exit 1
fi

art_dir="${root}/place/art"
mkdir -p "${art_dir}"

fixture=0
if [ "${qa}" -eq 1 ]; then
  fixture=1
  if [ -z "${out}" ]; then
    out="${art_dir}/.qa_export.gltf"
  fi
elif [ -n "${blend}" ]; then
  if [ ! -f "${blend}" ]; then
    echo "export-gltf: missing blend ${blend}" >&2
    exit 1
  fi
  if [ -z "${out}" ]; then
    base="$(basename "${blend}")"
    base="${base%.*}"
    out="${art_dir}/${base}.gltf"
  fi
else
  echo "usage: ./tools/export-gltf.sh [--qa] [in.blend] [out.gltf]" >&2
  exit 1
fi

case "${out}" in
  /*) ;;
  *) out="${root}/${out}" ;;
esac

rm -f "${out}"

set +e
if [ "${fixture}" -eq 1 ]; then
  "${blender_bin}" --background --python "${py}" -- --fixture "${out}"
  status=$?
else
  "${blender_bin}" --background "${blend}" --python "${py}" -- "${out}"
  status=$?
fi
set -e

if [ ! -f "${out}" ]; then
  echo "export-gltf: Blender exited ${status}; no ${out}" >&2
  exit 1
fi

if ! grep -q '"asset"' "${out}"; then
  echo "export-gltf: ${out} is not a glTF" >&2
  exit 1
fi
bin="${out%.gltf}.bin"
if [ "${out%.gltf}" != "${out}" ] && [ ! -f "${bin}" ]; then
  echo "export-gltf: missing sidecar ${bin}" >&2
  exit 1
fi

echo "export-gltf: ${out}"
exit 0
