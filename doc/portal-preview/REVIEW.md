# Gameplay and publication review

The new shareable recordings both end in native AI victories. **This is still WIP, not merge-ready.** BAR's 16× team won; ZK's 4× team defeated its more richly funded opponents. Native AI planning/lava avoidance and an intermittent native pathfinder crash remain limitations. The engine PR is now organised as six commits in the same review; see [the review arrangement](STACK_PLAN.md).

[Download the validation evidence and source patches](https://github.com/gajop/bar-spring/releases/download/portal-preview-20261020/portal-review-evidence.zip) to inspect the logs and receipts referenced below. The full recordings are separate release assets.

## The two recordings

These are direct live native AI recordings, with teams **0, 2, 4 and 6 at 2×, 4×, 8× and 16× income**, respectively. Their opening opponents (1, 3, 5 and 7) have normal income. All eight teams are separate enemies. A banner and colour legend show the advantages throughout playback. The observer never orders armies, kills commanders, grants resources or forces victory.

| | BAR | Zero-K |
| --- | --- | --- |
| Playback | [BAR](https://github.com/gajop/bar-spring/releases/download/portal-preview-20261020/bar-gameplay.html) | [Zero-K](https://github.com/gajop/bar-spring/releases/download/portal-preview-20261020/zk-gameplay.html) |
| Run | `dots-bar-graduated` | `dots-zk-graduated` |
| Native AI | BARb, source `29015a6cdb6c` | CircuitAI, source `6e4539012d62` |
| End | Native `GameOver`, frame 88,618: **49:13.9** | Native `GameOver`, frame 47,180: **26:12.7** |
| Winner | Team/ally-team **6**, **16× income** | Team/ally-team **2**, **4× income** |
| Observed transfers | **1,435**: 1,360 ground, 75 air | **1,110**: 1,065 ground, 45 air |
| Portal openings | 4 | 4 |
| Maximum sampled units | 816 | 1,075 |
| Foreign projectile samples / recorded foreign hits | 0 / 0 | 0 / 0 |
| Orders targeting cubicle gaps | 0 | 0 |
| Edge dwell candidates | 0 | 1 |
| Short return-trip candidates | 5, all aircraft | 13, ground units |
| Outside-region unit samples | 1, dying aircraft with negative HP | 4, one bomber executing rearm |

BAR's native campaign verifier passes and confirms the configured income multipliers and autonomous cross-world victory. Both winners have units observed in all four regions. The final recordings are not edited to make the 16× side win: ZK's 4× side won its actual match.

The BAR outside-region sample is a dead/dying `armkam` with negative HP. ZK's four samples are one full-health `bomberprec` briefly turning beyond Calayo2's outer edge while executing a rearm order (33410). It does not enter another world. These samples remain in the full recording and display data. The ZK edge candidate is `hoverarty` 15341 attacking unit 18296 near Calayo2's eastern edge; being stationary while attacking is not by itself proof of a movement stall.

BAR's five short returns involve EMP bombers and gunships. ZK retains thirteen short ground returns, including repeated region changes by a few hover units. Their orders, targets and health are retained for inspection; they are not all asserted to be correct retreats or pursuit. Native AI logistics and lava avoidance are left as limitations rather than expanded into an AI development project. An ordinary-map comparison has not established the origin of every observed AI behavior.

The previous uniform-10× recordings are retained as before-change controls in `review-controls/`, with their original receipts. That BAR run won at 21:30.1; the previous ZK run hit its one-hour cap. Those are not the new shared results.

## Regressions found and fixed

- **Actual ZK factory production:** its queue validates creation before a native spawn position exists. The portal gate previously rejected those nil-position checks. It now validates the producer's region while preserving nil arguments for unrelated gadgets; children inherit their producer's region. The regression uses actual ground/air factory queues and finished units, not direct spawning as a substitute for production.
- **Regional native combat:** ordinary fallback positions, candidate goals, squad merging and worker path costs now follow the current region. The earlier BAR control had hundreds of rapid returns, mostly support/artillery. The new BAR capture has five aircraft return candidates and no ground return candidates. The native planners remain separate companion changes, not engine code.
- **Fixed-wing multi-hop travel:** a completed approach could expose the original fight request before its tag was captured. Removing that mistaken "approach" deleted the remaining route. The router now distinguishes the two tags and uses a stopping radius inside the activation radius. The failing ZK three-hop fixture changed from 1/5 arrivals (gunship only) to 5/5. BAR's corresponding bomber/scout/fighter/gunship fixture passes 5/5 too.
- **ZK recording callback:** ZK's gadget handler passes damage arguments in its legacy order. The wrapper now normalizes them for the shared recorder. The earlier capture's attacker/projectile provenance is invalid and is quarantined as a before-change control. A corrected replay prefix matched all **3,001** unit/projectile/economy/portal samples exactly through frame 45,000 and removed the false foreign-hit warnings. The final supplied ZK recording is a fresh live capture using the corrected wrapper.
- **BAR UI fixture timing:** the original accelerated test checked arrival at frame 550, but the low-rate renderer issued the click at 558. The fixture now pauses simulation during camera/input and screenshot settling, then resumes before checking travel. Its 67 simulation and 28 UI assertions pass. This was a fixture correction, not a forced transit or gameplay change.

## Packaged runtime and clean-PC checks

The runtime is from **gajop/bar-spring**, integration commit `17512b8afc63da04bc36f553b18260c92d6a0af3`: `2026.07.01-122-g17512b8 codex/portal-integration`. It includes the isolated region feature plus independent cursor/save/metadata preview dependencies. The feature PR remains separate. Both native AI libraries and their full data folders are included, with source patches against pinned upstream bases.

All **146 runtime payload files** match the tested package manifest. The final manifest distinguishes as-built library hashes from stripped runtime hashes; clarifying those fields did not change the tested payload files. The reviewed native AI rebuilds are byte-identical to the libraries used by the campaigns. Both launchers record the bundled AI's provenance automatically when using this downloaded runtime.

A fresh Ubuntu 24.04 runtime container had no compiler, source/build directories, host cache or home directory mounted, and no network during the game tests. Fresh local shallow game clones, the extracted engine and the composed map were its inputs. BAR's submodule checkout completed at its pinned revision. Checks:

- BAR native economy/factory/portal smoke: **18 assertions**, clean exit. This smoke deliberately destroys a commander and is a **fixture**, not the autonomous campaign above.
- ZK actual production: **32 checks**, zero failures; normal-map production: **6 checks**, zero failures. Packaged ZK aircraft multi-hop: **5 checks**, zero failures.
- ZK order/cancellation regression after the route fix: **136 checks**, zero failures. Extended mechanics after the factory fix: **55 checks**, zero failures.
- Ordinary-map controls with the same native AI binaries reached native winners: BAR **9:21.9**, ZK **6:24.9**, with no portal missions. These are controls for basic operation, not a proof of unchanged AI strength.
- Offscreen hardware rendering from the packaged engine: ZK four-world terrain, materials/DNTS, lighting, selection, minimap input/events and travel checks pass. BAR's corrected four-world fixture passes **95 assertions**. Screenshots were inspected across grass, snow and volcanic regions. The [BAR logs (evidence archive)](https://github.com/gajop/bar-spring/releases/download/portal-preview-20261020/portal-review-evidence.zip) and [ZK logs (evidence archive)](https://github.com/gajop/bar-spring/releases/download/portal-preview-20261020/portal-review-evidence.zip) logs and native screenshots are retained. No desktop game window was opened. These checks do not exhaust camera angles, effects or optional graphics.
- The portable BAR packer rebuilt the composed map using its own bundled metadata and the downloaded engine's `bitmaps.sdz`, without an engine source or ZK checkout. Source terrain heights, diffuse tiles/mips, sizes and starts verify. The original Living Lands mirror timed out; that extraction reused retained source data. The other retained pinned archives were verified and freshly extracted. **A successful fresh network download is not claimed.**

## Current CI and follow-up verification

BAR's current source `c7b7c289defd` has all four upstream checks green: [formatting, type checking, unit tests and headless integration](https://github.com/beyond-all-reason/Beyond-All-Reason/pull/9779/checks). The final local source also passes 95 portal/UI assertions and 17 strategic-weapon assertions. The preceding cubicle-barrier run passes 58 assertions. A 900-frame native AI recorder smoke verifies the configured income labels and exits cleanly.

ZK's current source `6512de43f769` passes the new [portal tooling workflow in the fork](https://github.com/gajop/Zero-K/actions/runs/39418874829): 23 Python tests, geometry, recorder mode/adapter and map-template checks. Its upstream PR currently reports no checks; the passing fork run is identified explicitly rather than presented as an upstream check.

The engine feature is now published as six commits in [#3571](https://github.com/beyond-all-reason/RecoilEngine/pull/3571/commits), rebased onto current upstream with the feature changes preserved. Its previous head passed Linux AMD64, Linux ARM64, Windows AMD64 and Lua-library checks; [current checks](https://github.com/beyond-all-reason/RecoilEngine/pull/3571/checks) cover the rewritten head. The independent local branches retain separate Linux build/runtime evidence: 14 passing native fixture runs and four unit-test runs. No additional split PRs have been opened. `evidence/ci/final-status.json` and `evidence/independent-engine-validation.json` record the exact source revisions and results.

The completed AI recordings are unchanged. Their receipts retain their exact earlier capture commits; `sources.json` identifies the updated review branches. The CI cleanup also isolates standalone mock environments and fixes the map template's invalid-unit diagnostic. BAR still logs missing cactus feature definitions from the source map data, so decorative feature coverage is incomplete; no ordinary-map attribution is claimed for that finding.

## Independent upstream bug reproductions

The two small fixes proposed at the bottom of the engine split were checked against upstream `bf25266104`. All three region feature APIs are absent in these whole-map controls. Nested LuaUI layout fails with invalid x/y button results; the negative-size muzzle-flame control draws zero expected cyan pixels. Each passes with only its isolated fix, and both pass together. All four positive flame views contain visible effects. The native processes exit cleanly in both negative cases: these are expected assertion failures. This does **not** explain or clear the separate QTPFS crash below.

The exact sources, binary hashes and logs are indexed in `evidence/independent-bug-reproductions.json` in the [evidence archive](https://github.com/gajop/bar-spring/releases/download/portal-preview-20261020/portal-review-evidence.zip).

## Unresolved native crash

One repeated BAR offscreen fixture crashed at frame 271 in `QTPFS::PathSearch::IterateNodeNeighbors`, with native path-search worker frames in the stack. A later repeat of the same fixture completed all 95 assertions. The failed run is `package-offscreen-bar-checked`; its [launch metadata, start script and crash log (evidence archive)](https://github.com/gajop/bar-spring/releases/download/portal-preview-20261020/portal-review-evidence.zip) are retained. Baseline attribution has **not** been established: this report does not claim it predates the region changes or that it is fixed. It must be investigated before treating the preview as stable or merge-ready. No unrelated engine change was added to conceal or work around it.

## Player and evidence limits

The standalone HTML has no external service or engine dependency. Browser checks cover offline loading, all four panes, seeking, bookmarks, real unit selection, zoom/fit, playback/pause, restart at the end and embedded map credits. The schema and spatial/display regressions have **20 passing tests**, including ID reuse, missing references, absent versus zero command parameters, boundary membership and incomplete capture rejection. The ZK damage/income adapter has its own Lua regression. Three additional launcher tests cover distinct income advantages, arbitrary region order and invalid input. Native 300-frame recordings verify both games' income labels. ZK's compatibility API puts the income field at index 8; the wrapper now reads that field correctly. Older display copies can recover explicitly labelled income metadata from their matching launch scripts without changing full source recordings.

Full recordings retain half-second unit/projectile samples and exact-frame shot, damage, death and portal-open events. The shareable display copy uses one-second samples and labelled 0.1-unit position/health rounding; unchanged rows reuse the previous sample's state. Display transformations and source hashes are recorded in receipts. Original full recordings remain unchanged for analysis.

Sampling can miss short-lived projectiles or fast arrivals. Hits are post-damage call-in observations, and rejected damage is filtered by game rules before the recorder sees it; zero recorded foreign hits is not independent proof that every weapon is isolated. The native weapon/barrier fixtures supply additional checks. Dots do not reproduce particles, 3D occlusion, graphics buffer behavior, fog of war or the AI's knowledge. They do not establish multiplayer sync, cross-platform behavior, balanced strategy, complete optional-mechanic coverage or full-game persistence.

An older BAR replay export desynced and was rejected. Interrupted diagnostic captures and the old ZK callback data are not supplied as clean demonstrations. Use the final live recordings. Before-change controls and failure evidence are kept separately from the curated publication assets.

OpenAI Codex assisted with implementation, documentation and automated testing. Human source review and further playtesting remain pending.
