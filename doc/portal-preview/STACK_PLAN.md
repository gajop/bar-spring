# Engine review organisation

The current arrangement is three engine PRs, all based on upstream `bf2526610466f9d0329238cbe1c2065388ddb1d5`:

| PR | Scope | Commits |
| --- | --- | --- |
| [#3578](https://github.com/beyond-all-reason/RecoilEngine/pull/3578) | Nested LuaUI layout result indices | One independent fix |
| [#3579](https://github.com/beyond-all-reason/RecoilEngine/pull/3579) | Native muzzle-flame culling bounds | One independent fix |
| [#3571](https://github.com/beyond-all-reason/RecoilEngine/pull/3571) | Map-region APIs and example game | Four feature commits |

Following review, the first two fixes were removed from #3571 and published separately. Both reproduce on unmodified upstream without region APIs; [screenshots, logs, reproduction commands and performance implications](BUGFIXES.md) are available. The feature PR contains neither fix, and its example labels the two companion regression cases as optional.

The four commits retained in #3571 are [sensor partitions](https://github.com/gajop/bar-spring/commit/0217a48b1b96e91f60949fe80b3002c179ea10bf), [crater partitions](https://github.com/gajop/bar-spring/commit/7e5eecf04c3cd02a7a4bd16a4aeda799acdb477d), [world/camera/minimap bounds](https://github.com/gajop/bar-spring/commit/9b3405e316c8d12128f48fc0504659bbd7e0caa0), and [example game/regressions](https://github.com/gajop/bar-spring/commit/73f41ea8fa4a87f48458256e528e1bbcdbaa1fb7). The three feature APIs also have independent local preparation branches; all six merge orders of sensors, craters and rendering produce the same source tree without conflicts.

Linux validation of the independent and combined feature builds passed 14 native fixture runs and four unit-test runs, including two clients with different cropped views and both GL4 nano paths. Historical receipts and independent-review patches remain in the [evidence archive](https://github.com/gajop/bar-spring/releases/download/portal-preview-20261020/portal-review-evidence.zip); that archive predates the final PR extraction. Current public commit lists and CI are on the linked PRs.

The downloadable preview remains frozen at integration commit `17512b8afc63da04bc36f553b18260c92d6a0af3`, with its tested runtime, source patches and recordings. Restructuring review does not replace that binary. [Zero-K #5974](https://github.com/ZeroK-RTS/Zero-K/pull/5974) and [BAR #9779](https://github.com/beyond-all-reason/Beyond-All-Reason/pull/9779) remain separate game PRs. The merged SDL cursor fix and separate save PR are outside this feature review.

OpenAI Codex assisted with implementation, documentation and automated testing. This remains WIP; human review and further playtesting are pending.
