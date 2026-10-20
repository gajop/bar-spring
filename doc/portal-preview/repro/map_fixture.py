# This file is part of the Spring engine (GPL v2 or later), see LICENSE.html
import struct

def make_map(target):
    """Native flat 10x8 SMF, one solid DXT1 tile. Test patterns are drawn in Lua."""
    target.mkdir(parents=True)
    maps = target / "maps"
    maps.mkdir()
    block = struct.pack("<HHI", 0x4BE8, 0x4BE8, 0)
    tile = b"".join(block * max(1, size // 4) ** 2 for size in (32, 16, 8, 4))
    (maps / "flat.smt").write_bytes(struct.pack("<16s4i", b"spring tilefile\0", 1, 1, 32, 1) + tile)
    data = bytearray(80)
    header = [b"spring map file\0", 1, 876543, 640, 512, 8, 8, 32, 0.0, 256.0, 0, 0, 0, 0, 0, 0, 0]
    header[10] = len(data)
    data.extend(struct.pack("<H", 24576) * (641 * 513))
    for index in (11, 14):
        header[index] = len(data)
        data.extend(bytes(320 * 256))
    header[12] = len(data)
    data.extend(struct.pack("<iii", 1, 1, 1) + b"flat.smt\0" + bytes(160 * 128 * 4))
    header[13] = len(data)
    data.extend(block * (699048 // 8))
    header[15] = len(data)
    data.extend(struct.pack("<ii", 0, 0))
    struct.pack_into("<16s7i2f7i", data, 0, *header)
    (maps / "flat.smf").write_bytes(data)
    (target / "mapinfo.lua").write_text(
        "return {name='Region View Fixture',version='1',mapfile='maps/flat.smf',"
        "lighting={sundir={1,1,1}},teams={[0]={startpos={x=1500,z=1250}}}}\n"
    )
