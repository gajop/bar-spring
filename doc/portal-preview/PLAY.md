# Portal worlds preview: Linux AMD64

This WIP preview includes published game branches, a packaged engine and the composed example map. BAR uses `gajop/Beyond-All-Reason`; ZK uses `gajop/Zero-K`. The download recipe below needs no files from the author's PC.

The preview runs four genuine 8×8 maps in one simulation, connected by portals. It includes the engine's region APIs and both companion native AIs. No engine compilation, existing game installation or files from the author's PC are needed. Only Linux AMD64 has been packaged and tested here.

[Known limitations and validation](REVIEW.md) · [Related PRs and commit layout](STACK_PLAN.md)

## Install

On Ubuntu 24.04 or a compatible distribution:

```sh
sudo apt-get update
sudo apt-get install python3 git lua5.1 libsdl2-2.0-0 libopenal1 \
  libxcursor1 libx11-6 libfontconfig1 libfreetype6 libgl1 libegl1 \
  libgl1-mesa-dri libegl-mesa0
mkdir portal-preview
cd portal-preview
```

Download these two release assets and `SHA256SUMS` into this directory:

- `recoil-portal-preview-20261020-linux-amd64.tar.gz`
- `portal-worlds-v3-map.tar.gz`

The preview release location is `https://github.com/gajop/bar-spring/releases/tag/portal-preview-20261020`. Use its asset links, or download with GitHub CLI:

```sh
gh release download portal-preview-20261020 --repo gajop/bar-spring \
  --pattern '*linux-amd64.tar.gz' --pattern 'portal-worlds-v3-map.tar.gz' \
  --pattern 'SHA256SUMS'
sha256sum --check --ignore-missing SHA256SUMS
tar -xzf recoil-portal-preview-20261020-linux-amd64.tar.gz
tar -xzf portal-worlds-v3-map.tar.gz
```

`engine/preview-manifest.json` identifies every runtime file and the exact engine and AI source revisions, with separate as-built and stripped runtime library hashes. `engine/source-patches/` includes the engine, BARb and CircuitAI changes against their stated upstream bases. The two AI changes are independent of the engine API change. Keep each AI's complete bundled data folder together with its library.

## Play BAR

Use the preview branch:

```sh
git clone --depth 1 --recurse-submodules --branch codex/portal-worlds-wip \
  https://github.com/gajop/Beyond-All-Reason.git bar-game
python3 bar-game/tools/portal_worlds/play_portals.py bar-play \
  --engine-dir "$PWD/engine" --map-dir "$PWD/portal_worlds_v3.sdd" \
  --workspace "$PWD/bar-data" --play
```

## Play Zero-K

Use the preview branch:

```sh
git clone --depth 1 --branch codex/portal-worlds-wip \
  https://github.com/gajop/Zero-K.git zk-game
mkdir -p zk-data/content/maps
ln -s ../../../portal_worlds_v3.sdd zk-data/content/maps/worlds.sdd
ZK_PORTAL_WORKSPACE="$PWD/zk-data" \
  python3 zk-game/tools/portal_worlds/play_duels.py zk-play \
  --engine-dir "$PWD/engine" --play
```

Choose an unused run name each time. `--play` opens the actual game and runs until you close it. You begin in one world. A commander loss opens its portal at the death position, with the invading mouth near the neighboring world's centre. The world selector becomes available when a connection opens. Right-click a portal with mobile units to travel, or give move/fight/attack orders in another reachable world. Merely approaching a portal does not activate it.

## Record AI gameplay without opening a window

These give the first team in the four worlds respectively 2×, 4×, 8× and 16× native income. Their opening opponents retain normal income. The recorder and observers never order the units, destroy commanders or force victory. The AIs still decide how to play.

```sh
python3 bar-game/tools/portal_worlds/play_portals.py bar-ai \
  --engine-dir "$PWD/engine" --map-dir "$PWD/portal_worlds_v3.sdd" \
  --workspace "$PWD/bar-data" --headless --record --test ai_match \
  --region-income-multipliers 2,4,8,16 --ai-seed 20261020 \
  --frames 108000 --speed 20 --seconds 7200
ZK_PORTAL_WORKSPACE="$PWD/zk-data" \
  python3 zk-game/tools/portal_worlds/play_duels.py zk-ai \
  --engine-dir "$PWD/engine" --headless --record \
  --region-income-multipliers 2,4,8,16 --frames 108000 --speed 20 --seconds 7200
```

Launchers print the run, logs and recording paths. Frame caps are simulation time; `--seconds` is wall time. A timed recording is labelled as such and is not a victory. See the accompanying review for the actual outcomes of the supplied recordings. Full-view spectator recording is intentionally separate from human play. Use `--watch` instead of `--headless` to watch the real game window.

```sh
python3 bar-game/tools/portal_worlds/dots.py pack \
  bar-data/runs/bar-ai/write/recordings/portal-dots-TIMESTAMP.jsonl \
  --run bar-data/runs/bar-ai --out bar-ai.jsonl.gz
python3 bar-game/tools/portal_worlds/dots.py review bar-ai.jsonl.gz
python3 bar-game/tools/portal_worlds/dots.py bundle bar-ai.jsonl.gz \
  --map-dir portal_worlds_v3.sdd --out bar-ai.html
```

Use the equivalent ZK paths for its recording. Background thumbnails need Pillow (`python3 -m pip install Pillow` in a virtual environment); recording and basic playback do not. Open the resulting HTML directly in a current browser. It has play/pause, seeking, speed, unit inspection and four simultaneous world views. Share the single HTML with map attribution. It is a recording, not a live client.

## Maps and rebuilding

The example contains Living Lands 4.1, Barren 2, FrozenPlanetV3 and Calayo2, preserving native terrain size and using 512-elmo cubicle barriers. Keep the included `ATTRIBUTION.txt` with redistributed map media and backgrounds. `tools/portal_worlds/portal_maps.json` contains the original map links and pinned checksums. The original mirror timed out during this preparation, so the prepared composed-map asset is the reliable default setup path; no claim is made that the original mirror is currently reachable.

Both game branches include the packer, templates, metadata and verifier. To make a different layout, install `requirements.txt`, Lua 5.1 and 7z, fetch the manifest's source maps and run `build_portal_worlds.py --engine-dir /path/engine`, then `verify_four_worlds.py`. BAR includes the small attributed metadata overrides it needs; it does not need a ZK checkout or an engine source tree to pack maps.

The regions share one engine simulation and global resources such as water height, gravity and unit limits. The game handles interaction isolation; engine view bounds alone do not do that. The native AIs have an experimental invasion policy, not coordinated multi-world strategy. Read the review's open findings.

OpenAI Codex assisted with implementation, documentation and automated testing. This is still being worked on and is not ready for review. Human review and playtesting remain pending.
