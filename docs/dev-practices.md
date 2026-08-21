# Development practices

[`AGENTS.md`](../AGENTS.md) is the source of truth. Stamps there are
requirements.

## Review

Author never merges. Joe (`joemosby`) is off the review path. Architect
stamps claims. One written review from someone who did not write the
change.

## Repos

Cloud agents open GitHub PRs. Origin may mirror them. GitHub remains
source of truth. Do not create a second Origin-native repo.

## CI

Buildkite runs `bazel test` on `//clock` and `//journal`. Depot remote
cache is `https://cache.depot.dev`. The token is a secret. Never commit
it. Never put a literal Depot token in `.bazelrc`.
Roadmap lives at `docs/roadmap.md`. Do not grow it into a backlog.

## Leave alone unless Clock or Architect owns the change

`MODULE.bazel`, the fetched LLVM toolchain, and the clock/journal stubs.
No Godot scene, Next.js app, or tide logic in a docs change. No
`WORKSPACE`. No `rules_godot`. Do not write hermetic.
