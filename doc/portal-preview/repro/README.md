# Independent engine bug reproductions

These Linux GPU tests use a generated flat map, a tiny game and the engine's bundled assets. No Zero-K, BAR or region feature is needed. All three region feature flags must be absent from the selected engine.

Requirements: Python 3, a C compiler (`cc`) for the temporary frame limiter, and a complete graphical engine runtime with `spring`, `base/` and `fonts/`. The process uses SDL's offscreen driver with desktop-display variables removed, two worker threads and a 30 FPS limit. Full native logs are retained and their paths are printed before launch.

Use upstream `bf2526610466f9d0329238cbe1c2065388ddb1d5` for the before runtime. The isolated fixes are [LuaUI layout #3578](https://github.com/beyond-all-reason/RecoilEngine/pull/3578) and [muzzle-flame culling #3579](https://github.com/beyond-all-reason/RecoilEngine/pull/3579). Build/install each normally or use its complete Linux CI runtime.

From this directory, with fresh output paths:

```sh
python3 run.py --engine-dir /path/upstream-runtime --case flame --expect-broken --output /tmp/flame-before
python3 run.py --engine-dir /path/flame-fixed-runtime --case flame --output /tmp/flame-after
python3 run.py --engine-dir /path/upstream-runtime --case growth --expect-broken --output /tmp/growth-before
python3 run.py --engine-dir /path/flame-fixed-runtime --case growth --output /tmp/growth-after
python3 run.py --engine-dir /path/upstream-runtime --case layout --expect-broken --output /tmp/layout-before
python3 run.py --engine-dir /path/layout-fixed-runtime --case layout --output /tmp/layout-after
```

`--expect-broken` requires the known upstream regression. Exit status zero means the requested expectation was observed, including a clean native exit; it does not mean the before engine is fixed. `result.json` records this distinction, the binary hash and source-file hashes.

The `flame` case spawns a native `CBitmapMuzzleFlame` with size −140, length −60, zero growth and its origin just beyond the right frustum edge. It saves four complete native screenshots and camera states. Unmodified upstream has zero bright cyan pixels in the sampled edge area; the fixed build must show the effect in all four views.

The `growth` case uses positive size 25, length 20, TTL 120 and growth 30, with its origin farther outside the frustum. It must initially be invisible. After 45 simulation frames it has grown into view; unmodified upstream still drops it because its cached bound was never refreshed by drawing. The test saves early/late screenshots and records the sampled ages. It does not measure frame-rate performance.

The `layout` case requests `Spring.LoadCtrlPanelConfig` from an existing Lua call while a unit is selected. Both runs must exercise the nested callback; only the upstream runtime must produce the invalid-result warning. Its proof is in the native log.

The flame captures hide the console overlay for readability; `console.log` retains every native diagnostic. Temporary game/map content is removed after each run. Screenshots, configuration, camera states, results and logs remain in the selected output directory.

OpenAI Codex assisted with the implementation, documentation and automated testing. These remain WIP fixes pending human review and playtesting.
