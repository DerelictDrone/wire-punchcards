Wire_PunchCardModels = Wire_PunchCardModels or {}

AddCSLuaFile("wire/client/punchcard_ui.lua")
AddCSLuaFile("wire/client/punchcard_models.lua")
if CLIENT then
	include("wire/client/punchcard_ui.lua")
	include("wire/client/punchcard_models.lua")
end
if SERVER then
	include("wire/server/punchcard_helpers.lua")
end

timer.Simple(0,function()
	local models = file.Find("wire/punchcard_models/*.lua","LUA")
	for _,model in ipairs(models) do
		local filename = "wire/punchcard_models/"..model 
		AddCSLuaFile(filename)
		include(filename)
	end
end)