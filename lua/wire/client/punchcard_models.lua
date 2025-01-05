local function loadModels()
	ModelPlug.ListAddModels("Wire_PunchcardInp_Models",{
		"models/props_lab/reciever01a.mdl",
		"models/props_lab/reciever01b.mdl",
		"models/props_lab/reciever01c.mdl",
		"models/props_lab/reciever01d.mdl",
		"models/props_c17/consolebox05a.mdl",
		"models/props_c17/consolebox03a.mdl",
		"models/props_c17/consolebox01a.mdl",
		"models/hunter/plates/plate025x025.mdl",
		"models/squad/sf_plates/sf_plate1x1.mdl",
	})
end

hook.Add("ModelPlugLuaRefresh","PunchcardModels",function()
	loadModels()
end)

if ModelPlug then
	loadModels()
else
	timer.Simple(0,loadModels)
end