# Agent notes

This workspace is not fully hermetic.

The compiler is a Bazel-fetched LLVM. Native links still use the host
sysroot. Do not write "hermetic" as a claim.

The host Godot editor is a known leak.

Author never merges. Joe (joemosby) is off the review path. Architect
stamps claims.

---

## Live stamps

- **Bazel:** not fully hermetic. Fetched LLVM + host sysroot. Do not write
  hermetic. Host Godot editor is a known leak. (Architect)
- **Bzlmod consumer:** portable as a third-party Bzlmod module. Name
  `low_tide`. Public `@low_tide//clock` and `@low_tide//journal` only.
  Consumer brings the toolchain. Cove scenes in `place/` are Godot assets,
  not a public Bazel dep. No WORKSPACE. No rules_godot. (Architect)
- **Phase 0:** one cove. Engine is Godot 4. Next cut is a playable cove,
  not more paper. Do not grow the cove. (Architect)
- **Buildkite:** tests `//clock` and `//journal`.
