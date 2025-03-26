include("wire/client/punchcard_models.lua")

Wire_PunchCardModels = Wire_PunchCardModels or {}

AddCSLuaFile("wire/client/punchcard_ui.lua")
if CLIENT then
	include("wire/client/punchcard_ui.lua")
end
if SERVER then
	include("wire/server/punchcard_helpers.lua")
end

local models = file.Find("wire/punchcard_models/*.lua","LUA")
for _,model in ipairs(models) do
	AddCSLuaFile("wire/punchcard_models/"..model)
	include("wire/punchcard_models/"..model)
end
