-- This file is part of the Spring engine (GPL v2 or later), see LICENSE.html
for _, name in ipairs({"sensorRegions", "mapDamageRegions", "mapRegionViews"}) do
	assert(Engine.FeatureSupport[name] ~= true, "unexpected region API: " .. name)
end
Spring.Echo("GROWTH_CAPTURE_NO_REGION_APIS")
Spring.SendCommands("console 0", "resbar 0", "tooltip 0", "minimap minimize 1")
local phase, frames, changedFrame = 0, 0, 0
local early, earlyAge
local function CountPixels(w, h)
	local count = 0
	for _, row in ipairs(gl.ReadPixels(w - 200, h / 2 - 200, 200, 400)) do
		for _, c in ipairs(row) do
			if c[2] > 0.8 and c[3] > 0.8 and c[1] < 0.3 then count = count + 1 end
		end
	end
	return count
end
function DrawScreen()
	local w, h = Spring.GetViewGeometry()
	gl.Color(1, 1, 1, 1)
	gl.Text("Growing muzzle-flame: " .. BUILD_LABEL, 24, h - 40, 24, "o")
	gl.Text("Positive dimensions; origin stays outside the frustum while the effect grows", 24, h - 70, 16, "o")
	if Spring.GetGameFrame() < 30 or phase > 2 then return end
	frames = frames + 1
	if phase == 0 then
		Spring.SetCameraState({mode=1, px=2048, py=96, pz=1200, height=1400, angle=0.8, flipped=0}, 0)
		phase, frames, changedFrame = 1, 0, Spring.GetGameFrame()
	elseif phase == 1 and frames > 15 and Spring.GetGameFrame() > changedFrame + 1 then
		local x, y, z = Spring.GetCameraPosition()
		local dx, dy, dz = Spring.GetPixelDir(w + 180, h / 2)
		local distance = -400 / dy
		local message = string.format("grow %.4f %.4f %.4f", x + dx * distance, y - 400, z + dz * distance)
		Spring.Echo("GROWTH_SEND " .. message)
		Spring.SendLuaRulesMsg(message)
		phase = 2
	elseif phase == 2 then
		local spawned = Spring.GetGameRulesParam("growth_frame")
		if not spawned then
			if frames % 60 == 0 then Spring.Echo("GROWTH_WAIT frame=" .. Spring.GetGameFrame()) end
			return
		end
		local age = Spring.GetGameFrame() - spawned
		if not early and age >= 2 then
			early, earlyAge = CountPixels(w, h), age
			gl.SaveImage(0, 0, w, h, "growth-early.png")
		end
		if early and age >= 45 then
			local late = CountPixels(w, h)
			gl.SaveImage(0, 0, w, h, "growth-late.png")
			Spring.Echo("GROWTH_BOUNDS_CASE early=" .. early .. " late=" .. late .. " early_age=" .. earlyAge .. " late_age=" .. age)
			Spring.Echo(early == 0 and late > 20 and "GROWTH_BOUNDS_PASS" or "GROWTH_BOUNDS_FAIL")
			phase = 3
			Spring.SendCommands("quitforce")
		end
	end
end
