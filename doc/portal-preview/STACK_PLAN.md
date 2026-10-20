# Engine review organisation

[Engine PR](https://github.com/beyond-all-reason/RecoilEngine/pull/3571) · [Zero-K PR](https://github.com/ZeroK-RTS/Zero-K/pull/5974) · [BAR PR](https://github.com/beyond-all-reason/Beyond-All-Reason/pull/9779)

The current public review is [#3571](https://github.com/beyond-all-reason/RecoilEngine/pull/3571), now organised as six linear commits: LuaUI layout fix, muzzle-flame culling fix, sensor partitions, crater partitions, local rendering/camera/minimap bounds, and the example/regression game. The feature changes are preserved on the current upstream base; the only manual merge resolution keeps both upstream and new feature flags. No additional engine PRs have been opened. See `evidence/engine-pr-commit-split.json` for exact commit IDs and the tree check.

The independent branches below remain local preparation for a possible later PR split. Their upstream base is newer than the existing PR's base, so their commit IDs differ from the published linear sequence.

GitHub's native stacks require all branches in the same repository; they cannot span a contributor fork and upstream. That limitation does not prevent ordinary upstream PRs from being independently mergeable. The local preparation uses six branches based directly on upstream `bf25266104`, without a dependency chain:

| Review | Local branch | Scope |
| --- | --- | --- |
| Nested LuaUI layout fix | `codex/fix-nested-layout` | Interpret callback results relative to the current Lua stack top |
| Muzzle-flame bounds fix | `codex/fix-muzzle-flame-bounds` | Compute conservative bounds before culling, including negative sizes |
| Sensor regions | `codex/region-review-sensors` | Initialization-only synced sensor partitions, native detection, docs and geometry tests |
| Crater regions | `codex/region-review-craters` | Initialization-only synced native deformation partitions, docs and geometry tests |
| Rendering | `codex/region-review-rendering` | Independent world, camera and minimap views, docs and rectangle tests; intended replacement scope for #3571 |
| Example/regressions | `codex/region-review-example` | Self-contained demo game and graphical fixtures; requires the relevant feature when run |

The small partition validator, Lua parser and geometry test are identical in the sensor and crater branches. Their distinct API registrations, declarations and feature flags occupy separate locations. Git merges the identical helper once; neither API depends on the other. The rendering API has no simulation-policy dependency. Both bug fixes reproduce without any region API.

All six orders of merging sensors, craters and rendering have been checked with Git's three-way merge. Each merges cleanly and produces the same source tree. `evidence/independent-engine-parts.json` records the exact local commits and combined tree. Build/runtime checks are recorded separately; a clean merge is not a claim that those checks passed.

Linux validation after the split passes: 14 native fixture runs and four unit-test runs, covering each feature independently and their combined build. Two clients agree on simulation witnesses, with different cropped views in the combined tests. Both GL4 nano paths pass. See `evidence/independent-engine-validation.json`. These independent local branches do not have public CI runs. The previous #3571 head passed Linux, ARM64, Windows and Lua checks; the feature is now published as six commits on current upstream and the current checks are linked from the PR.

`codex/region-review-combined` merges the six local branches for validation. The published preview continues to use its frozen, already-tested integration commit and binary; these local review branches do not replace that release source. The game PRs remain in their own repositories. The already merged SDL cursor fix and separate save PR are excluded from the six feature reviews.

The workflow has one inventory and one combined validation branch. Source updates, merge checks, testing and eventual branch pushes are handled together; the user does not need to manually restack six branches. No additional split PR has been opened. The six commits are published in #3571; the current publication state is visible on the linked PR.

The preview's evidence archive includes `patches/engine-split/` for reviewing the six diffs together. Those patches share the base listed in their JSON receipts. They describe local review preparation; the downloadable runtime remains the separately identified frozen preview build.

[GitHub stack requirements](https://docs.github.com/en/pull-requests/reference/stacked-pull-requests).

## Independent bugfix verification

Both tests fail on upstream `bf25266104` with all three region APIs absent. The layout case reports invalid x/y button return values. The muzzle-flame case has zero cyan pixels at the tested view. Each passes with only its own fix, and the two fixes pass together with region APIs still absent. Four positive flame views contain 1,216 / 481 / 1,193 / 445 cyan pixels. See `evidence/independent-bug-reproductions.json` and the corresponding logs. The native processes exit cleanly in the negative tests; the expected failures are regression assertions, not native crashes. The standalone production flame branch has the same source tree as its tested flame-only control.

OpenAI Codex assisted with the split, documentation and automated checks. This remains WIP; human source review and further playtesting are pending.

The historical validation evidence and independent-review patches referenced here are in the [preview evidence archive](https://github.com/gajop/bar-spring/releases/download/portal-preview-20261020/portal-review-evidence.zip). The newer six-commit layout is visible directly in [the engine PR commits](https://github.com/beyond-all-reason/RecoilEngine/pull/3571/commits).
