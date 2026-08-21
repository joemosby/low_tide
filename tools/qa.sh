#!/usr/bin/env bash
# Cloud-agent definition of done: C++ honesty, then cove honesty when present.
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

# Loop 1: C++ honesty. Reuses .buildkite/test.sh (Bazel 9 exit 4 is success).
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
if [ -f "${root}/place/project.godot" ]; then
  project_dir="${root}/place"
  script_res="res://qa/honesty.gd"
elif [ -f "${root}/project.godot" ]; then
  project_dir="${root}"
  script_res="res://place/qa/honesty.gd"
else
  echo "cove QA: scene is not on main"
  exit 0
fi

if [ ! -f "${root}/place/qa/honesty.gd" ]; then
  echo "cove QA: place/project.godot is present but place/qa/honesty.gd is missing" >&2
  exit 1
fi

"${godot_bin}" --headless --audio-driver Dummy --quit-after 15 \
  --path "${project_dir}" --script "${script_res}"

# Linux export when Godot and Linux templates are both present. Skip
# honestly otherwise. Fail closed only if they are present and the
# export is broken. Does not require Windows templates.
"${root}/tools/export.sh" --qa

# Windows export is a sibling path. Skip honestly when Windows templates
# are missing. Fail closed only when they are present and the export is
# broken. Does not gate Linux QA.
"${root}/tools/export.sh" --qa windows
