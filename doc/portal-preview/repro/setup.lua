-- This file is part of the Spring engine (GPL v2 or later), see LICENSE.html
function gadget:GetInfo()
	return { name = "Flame bounds regression", layer = 0, enabled = true }
end
if not gadgetHandler:IsSyncedCode() then
	return
end
function gadget:Initialize()
	local unit = assert(Spring.CreateUnit("region_test_unit", 1500, 96, 1500, 0, 0))
	Spring.SetGameRulesParam("view_home", unit, {public = true})
end
function gadget:RecvLuaMsg(message)
	local gx, gy, gz = message:match("^grow ([%d.-]+) ([%d.-]+) ([%d.-]+)$")
	if gx then
		Spring.SpawnCEG("region_growth", tonumber(gx), tonumber(gy), tonumber(gz), 0, 1, 0)
		Spring.Echo("GROWTH_SPAWN_FRAME " .. Spring.GetGameFrame())
		Spring.SetGameRulesParam("growth_frame", Spring.GetGameFrame(), {public = true})
		return
	end
	local n, x, y, z = message:match("^flare (%d+) ([%d.-]+) ([%d.-]+) ([%d.-]+)$")
	if not n then
		return
	end
	Spring.SpawnCEG("region_flame", tonumber(x), tonumber(y), tonumber(z), 0, 1, 0)
	Spring.SetGameRulesParam("flare_ready", tonumber(n), {public = true})
end
