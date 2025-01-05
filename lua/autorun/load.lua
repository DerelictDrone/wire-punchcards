include("wire/client/punchcard_models.lua")

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