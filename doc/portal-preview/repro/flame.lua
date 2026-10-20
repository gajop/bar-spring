-- This file is part of the Spring engine (GPL v2 or later), see LICENSE.html
for _, name in ipairs({"sensorRegions", "mapDamageRegions", "mapRegionViews"}) do assert(Engine.FeatureSupport[name] ~= true, "unexpected region API: " .. name) end
Spring.Echo("FLAME_CAPTURE_NO_REGION_APIS")
Spring.SendCommands("console 0", "resbar 0", "tooltip 0", "minimap minimize 1")
local stage, phase, frames, failed = 1, 0, 0, false
local changedFrame = 0
local missing = 0
local cameras = assert(io.open("flame-cameras.txt", "w"))
local buildLabel = BUILD_LABEL

function DrawScreen()
	local screenW, screenH = Spring.GetViewGeometry()
	gl.Color(1, 1, 1, 1)
	gl.Text("Muzzle-flame culling: " .. buildLabel, 24, screenH - 40, 24, "o")
	gl.Text("Same whole-map scene; negative-size effect extends into the right edge", 24, screenH - 70, 16, "o")
	gl.Text("Expected visible flare at the right edge  >", screenW - 375, screenH / 2 - 150, 16, "o")
	if failed or Spring.GetGameFrame() < 30 then
		return
	end
	local ok, err = pcall(function()
		if stage > 4 then
			cameras:close()
			Spring.Echo(missing == 0 and "FLAME_BOUNDS_PASS" or "FLAME_BOUNDS_FAIL missing=" .. missing)
			Spring.SendCommands("quitforce")
			return
		end
		frames = frames + 1
		if phase == 0 then
			Spring.SetCameraState(
				{
					mode = 1,
					px = 2048,
					py = 96,
					pz = stage <= 2 and 1200 or 3000,
					height = 1400,
					angle = stage % 2 == 1 and 0.05 or 0.8,
					flipped = 0,
				},
				0
			)
			phase = 1
			frames = 0
			changedFrame = Spring.GetGameFrame()
		elseif phase == 1 and frames > 15 and Spring.GetGameFrame() > changedFrame + 1 then
			local w, h = Spring.GetViewGeometry()
			local x, y, z = Spring.GetCameraPosition()
			local dx, dy, dz = Spring.GetPixelDir(w + 8, h / 2)
			local distance = -400 / dy
			Spring.SendLuaRulesMsg(
				string.format("flare %d %.4f %.4f %.4f", stage, x + dx * distance, y - 400, z + dz * distance)
			)
			phase = 2
			frames = 0
			changedFrame = Spring.GetGameFrame()
		elseif
			phase == 2
			and frames > 15
			and Spring.GetGameFrame() > changedFrame + 2
			and Spring.GetGameRulesParam("flare_ready") == stage
		then
			local w, h = Spring.GetViewGeometry()
			local count = 0
			for _, row in ipairs(gl.ReadPixels(w - 200, h / 2 - 180, 200, 360)) do
				for _, c in ipairs(row) do
					if c[2] > 0.8 and c[3] > 0.8 and c[1] < 0.3 then
						count = count + 1
					end
				end
			end
			if count <= 20 then missing = missing + 1 end
			local state = Spring.GetCameraState()
			local keys = {}
			for key in pairs(state) do keys[#keys + 1] = key end
			table.sort(keys)
			cameras:write("view " .. stage .. "\n")
			for _, key in ipairs(keys) do cameras:write(key .. "=" .. tostring(state[key]) .. "\n") end
			cameras:flush()
			gl.SaveImage(0, 0, w, h, "flame-view-" .. stage .. ".png")
			Spring.Echo("FLAME_BOUNDS_CASE " .. stage .. " cyan=" .. count)
			stage = stage + 1
			phase = 0
			frames = 0
		end
	end)
	if not ok then
		failed = true
		Spring.Echo("FLAME_BOUNDS_FAIL " .. tostring(err))
		Spring.SendCommands("quitforce")
	end
end
