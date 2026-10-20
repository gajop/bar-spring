#!/usr/bin/env python3
# This file is part of the Spring engine (GPL v2 or later), see LICENSE.html
"""Independent native flame/layout reproductions; no game checkout or region APIs."""
import argparse
import hashlib
import html
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import tempfile

from map_fixture import make_map

HERE = Path(__file__).resolve().parent
LICENSE = '-- This file is part of the Spring engine (GPL v2 or later), see LICENSE.html\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--engine-dir', type=Path, required=True, help='Unpacked Linux engine runtime')
    parser.add_argument('--output', type=Path, required=True, help='New output directory')
    parser.add_argument('--case', choices=['flame', 'growth', 'layout'], default='flame')
    parser.add_argument('--expect-broken', action='store_true', help='Require the upstream regression instead of success')
    args = parser.parse_args()
    engine = args.engine_dir.resolve()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    for required in ['spring', 'base', 'fonts']:
        if not (engine / required).exists():
            parser.error(f'Incomplete engine runtime: missing {required}')
    with tempfile.TemporaryDirectory(prefix='engine-bug-repro-') as folder:
        data = Path(folder)
        game = data / 'games/bug_game.sdd'
        shutil.copytree(HERE / 'game', game)
        gadgets = game / 'LuaRules/Gadgets'
        gadgets.mkdir()
        (gadgets / 'unit_script.lua').write_text(LICENSE + 'VFS.Include("LuaGadgets/Gadgets/unit_script.lua", nil, VFS.BASE)\n')
        shutil.copy(HERE / 'setup.lua', gadgets / 'repro.lua')
        (game / 'LuaUI').mkdir()
        label = 'Unmodified upstream' if args.expect_broken else 'Isolated fix'
        ui = (HERE / (args.case + '.lua')).read_text().replace(LICENSE, '', 1)
        (game / 'LuaUI/main.lua').write_text(LICENSE + 'local BUILD_LABEL = ' + json.dumps(label) + '\n' + ui)
        shutil.copy(HERE / 'resources.lua', game / 'gamedata/resources.lua')
        shutil.copy(HERE / 'explosions.lua', game / 'gamedata/explosions.lua')
        make_map(data / 'maps/bug_map.sdd')
        for name in ['base', 'fonts']:
            (data / name).symlink_to(engine / name)
        script = output / 'start.txt'
        script.write_text('''[GAME]{IsHost=1;MyPlayerName=Repro;MyPlayerNum=0;OnlyLocal=1;
GameType=Region View Regression 1;MapName=Region View Fixture 1;
HostIP=localhost;HostPort=0;StartPosType=0;GameStartDelay=0;RecordDemo=0;
[MODOPTIONS]{LuaRules=1;LuaGaia=1;}
[PLAYER0]{Name=Repro;Team=0;Spectator=0;}
[TEAM0]{TeamLeader=0;AllyTeam=0;RGBColor=1 1 1;Side=Arm;}
[ALLYTEAM0]{NumAllies=0;}}
''')
        config = output / 'spring.conf'
        config.write_text('Fullscreen=0\nXResolutionWindowed=1280\nYResolutionWindowed=720\n'
                          'VSync=0\nSound=0\nWorkerThreadCount=2\nShadows=1\nShadowMapSize=1024\n'
                          'UnitIconsAsUI=0\nUnitIconDist=100000\nSoftParticles=0\n')
        fontconfig = output / 'fonts.conf'
        fontconfig.write_text('<fontconfig><dir>' + html.escape(str(engine / 'fonts')) + '</dir><cachedir>'
                              + html.escape(str(output / 'fontcache')) + '</cachedir></fontconfig>')
        limiter = data / 'limit-swap.so'
        subprocess.run(['cc', '-O2', '-shared', '-fPIC', str(HERE / 'limit_swap.c'), '-ldl', '-o', str(limiter)], check=True)
        env = os.environ.copy()
        env.pop('DISPLAY', None)
        env.pop('WAYLAND_DISPLAY', None)
        env.update(SDL_VIDEODRIVER='offscreen', FONTCONFIG_FILE=str(fontconfig), SPRING_TEST_FPS='30')
        env['LD_PRELOAD'] = str(limiter) + (':' + env['LD_PRELOAD'] if env.get('LD_PRELOAD') else '')
        command = ['nice', '-n', '10', str(engine / 'spring'), '--isolation', '--isolation-dir', str(data),
                   '--write-dir', str(output / 'write'), '--config', str(config), '--nocolor', str(script)]
        print('Full native log:', output / 'console.log', flush=True)
        with (output / 'console.log').open('w') as log:
            process = subprocess.Popen(command, cwd=output, env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
            try:
                code = process.wait(timeout=90)
            except subprocess.TimeoutExpired:
                code = -1
            finally:
                if process.poll() is None:
                    os.killpg(process.pid, signal.SIGTERM)
                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        os.killpg(process.pid, signal.SIGKILL)
                        process.wait()
    text = (output / 'console.log').read_text(errors='replace')
    cases = [int(value) for value in re.findall(r'FLAME_BOUNDS_CASE \d+ cyan=(\d+)', text)]
    nested = re.search(r'LAYOUT_STACK_PASS nested=(\d+)', text)
    if args.case == 'flame':
        observed = len(cases) == 4 and all((count == 0 if args.expect_broken else count > 20) for count in cases)
        observed &= len(list((output / 'write').glob('flame-view-*.png'))) == 4
        observed &= 'FLAME_CAPTURE_NO_REGION_APIS' in text
    elif args.case == 'growth':
        growth = re.search(r'GROWTH_BOUNDS_CASE early=(\d+) late=(\d+) early_age=(\d+) late_age=(\d+)', text)
        observed = bool(growth and int(growth[1]) == 0 and int(growth[3]) <= 6 and int(growth[4]) >= 45)
        if growth:
            observed &= int(growth[2]) == 0 if args.expect_broken else int(growth[2]) > 20
            cases = [int(growth[1]), int(growth[2])]
        observed &= 'GROWTH_CAPTURE_NO_REGION_APIS' in text
    else:
        warning = 'LayoutButtons() bad xButtons or yButtons values' in text
        observed = bool(nested and int(nested[1]) > 0) and warning == args.expect_broken
        observed &= 'LAYOUT_CAPTURE_NO_REGION_APIS' in text
    passed = code == 0 and observed and 'LuaError' not in text
    result = {'passed': passed, 'native_exit_code': code, 'expected_broken': args.expect_broken,
              'case': args.case, 'cyan_pixels': cases,
              'binary_sha256': hashlib.sha256((engine / 'spring').read_bytes()).hexdigest(),
              'fixture_sha256': {str(path.relative_to(HERE)): hashlib.sha256(path.read_bytes()).hexdigest()
                                 for path in sorted(HERE.rglob('*')) if path.is_file() and '__pycache__' not in path.parts}}
    (output / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: result[key] for key in ['passed', 'native_exit_code', 'expected_broken', 'case', 'cyan_pixels']}))
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
