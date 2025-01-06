include("wire/client/punchcard_models.lua")

Wire_PunchCardModels = Wire_PunchCardModels or {}
local models = file.Find("wire/punchcard_models/*.lua","LUA")
for _,model in ipairs(models) do
	include("wire/punchcard_models/"..model)
end

if CLIENT then
	timer.Simple(0,function()
		include("wire/client/punchcard_ui.lua")
	end)
end
if SERVER then
	timer.Simple(0,function()
		include("wire/server/punchcard_helpers.lua")
	end)
end