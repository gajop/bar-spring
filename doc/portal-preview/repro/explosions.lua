-- This file is part of the Spring engine (GPL v2 or later), see LICENSE.html
return {
	region_growth = {
		usedefaultexplosions = false,
		flare = {
			class = "CBitmapMuzzleFlame", count = 1, air = true, ground = true, water = true,
			properties = {
				alwaysvisible = true, colormap = "0 1 1 0.01 0 1 1 0.01", dir = "dir",
				fronttexture = "flare", sidetexture = "flare", size = 25, length = 20,
				ttl = 120, sizegrowth = 30,
			},
		},
	},
	region_flame = {
		usedefaultexplosions = false,
		flare = {
			class = "CBitmapMuzzleFlame", count = 1, air = true, ground = true, water = true,
			properties = {
				alwaysvisible = true, colormap = "0 1 1 0.01 0 1 1 0.01", dir = "dir",
				fronttexture = "flare", sidetexture = "flare", size = -140, length = -60,
				ttl = 10000, sizegrowth = 0,
			},
		},
	},
}
