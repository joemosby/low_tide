#!/usr/bin/env bash
# Cloud-agent definition of done: C++ honesty, then cove honesty,
# drop-floor, and glTF import when present.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "${root}"
export PATH="${HOME}/.local/bin:${PATH}"

# Optional Depot remote cache for cloud agents. Workspace .bazelrc stays
# token-free. Never commit DEPOT_TOKEN.
if [ -n "${DEPOT_TOKEN:-}" ]; then
  cat > "${HOME}/.bazelrc" <<EOF
build --remote_cache=https://cache.depot.dev
build --remote_header=authorization=${DEPOT_TOKEN}
EOF
fi

# Loop 1: C++ honesty. Allman + 80 first, then Bazel (exit 4 is success).
if ! command -v clang-format >/dev/null 2>&1; then
  echo "clang-format is required (Allman + 80). Install clang-format and retry." >&2
  exit 1
fi
mapfile -t cxx_files < <(find clock journal -type f \( \
  -name '*.h' -o -name '*.hh' -o -name '*.hpp' -o \
  -name '*.cc' -o -name '*.cpp' -o -name '*.cxx' \) | LC_ALL=C sort)
if [ "${#cxx_files[@]}" -eq 0 ]; then
  echo "clang-format: no C++ under clock/ or journal/" >&2
  exit 1
fi
clang-format --dry-run --Werror "${cxx_files[@]}"

"${root}/.buildkite/test.sh"

# Loop 2: cove honesty. Headless Godot only. Skip honestly when the scene
# or the binary is not here. Fail closed once Place lands a project.
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
  echo "cove QA: skipped (no GODOT on PATH and no tools/godot)"
  exit 0
fi

project_dir=""
script_res=""
drop_res=""
if [ -f "${root}/place/project.godot" ]; then
  project_dir="${root}/place"
  script_res="res://qa/honesty.gd"
  drop_res="res://qa/drop_floor.gd"
elif [ -f "${root}/project.godot" ]; then
  project_dir="${root}"
  script_res="res://place/qa/honesty.gd"
  drop_res="res://place/qa/drop_floor.gd"
else
  echo "cove QA: scene is not on main"
  exit 0
fi

if [ ! -f "${root}/place/qa/honesty.gd" ]; then
  echo "cove QA: place/project.godot is present but place/qa/honesty.gd is missing" >&2
  exit 1
fi
if [ ! -f "${root}/place/qa/drop_floor.gd" ]; then
  echo "cove QA: place/project.godot is present but place/qa/drop_floor.gd is missing" >&2
  exit 1
fi

"${godot_bin}" --headless --audio-driver Dummy --quit-after 15 \
  --path "${project_dir}" --script "${script_res}"

# Ride Water through Clock's WAIT_S + DROP_S. Script quits itself.
"${godot_bin}" --headless --audio-driver Dummy --quit-after 0 \
  --path "${project_dir}" --script "${drop_res}"

# glTF import. Fail closed when Godot is present and a glTF is
# missing or Godot cannot import it. Clock does not spawn geo.
if [ ! -f "${root}/place/qa/gltf_import.gd" ]; then
  echo "cove QA: place/project.godot is present but place/qa/gltf_import.gd is missing" >&2
  exit 1
fi
gltf_script=""
gltf_fix=""
gltf_cove=""
gltf_exp=""
if [ "${project_dir}" = "${root}/place" ]; then
  gltf_script="res://qa/gltf_import.gd"
  gltf_fix="res://art/qa_import.gltf"
  gltf_cove="res://art/cove.gltf"
  gltf_exp="res://art/.qa_export.gltf"
else
  gltf_script="res://place/qa/gltf_import.gd"
  gltf_fix="res://place/art/qa_import.gltf"
  gltf_cove="res://place/art/cove.gltf"
  gltf_exp="res://place/art/.qa_export.gltf"
fi
if [ ! -f "${root}/place/art/qa_import.gltf" ]; then
  echo "gltf import: missing place/art/qa_import.gltf" >&2
  exit 1
fi
if [ ! -f "${root}/place/art/cove.gltf" ]; then
  echo "gltf import: missing place/art/cove.gltf" >&2
  exit 1
fi
if [ ! -f "${root}/place/art/cove.bin" ]; then
  echo "gltf import: missing place/art/cove.bin" >&2
  exit 1
fi
"${godot_bin}" --headless --audio-driver Dummy --quit-after 15 \
  --path "${project_dir}" --script "${gltf_script}" -- "${gltf_fix}"
"${godot_bin}" --headless --audio-driver Dummy --quit-after 15 \
  --path "${project_dir}" --script "${gltf_script}" -- "${gltf_cove}"

# Blender --background export. Skip honestly when Blender is missing
# (same as export templates). Fail closed when Blender is present
# and the export is dirty. Then import the fresh export.
"${root}/tools/export-gltf.sh" --qa
if [ -f "${root}/place/art/.qa_export.gltf" ]; then
  "${godot_bin}" --headless --audio-driver Dummy --quit-after 15 \
    --path "${project_dir}" --script "${gltf_script}" -- "${gltf_exp}"
fi

# Linux export when Godot and Linux templates are both present. Skip
# honestly otherwise. Fail closed only if they are present and the
# export is broken. Does not require Windows templates.
"${root}/tools/export.sh" --qa

# Windows export is a sibling path. Skip honestly when Windows templates
# are missing. Fail closed only when they are present and the export is
# broken. Does not gate Linux QA.
"${root}/tools/export.sh" --qa windows
