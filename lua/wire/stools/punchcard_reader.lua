WireToolSetup.setCategory( "Memory" )
WireToolSetup.open( "punchcard_reader", "Punchcard Reader", "gmod_wire_punchcard_reader", nil, "Punchcard Readers" )

if ( CLIENT ) then
	language.Add( "Tool.wire_punchcard_reader.name", "Punchcard Reader(Wire)" )
	language.Add( "Tool.wire_punchcard_reader.desc", "Spawns a Punchcard Reader!" )
	TOOL.Information = {
		{ name = "left", text = "Create a Punchcard Reader" },
	}
end
WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 20 )

TOOL.ClientConVar[ "model" ] = "models/props_lab/reciever01d.mdl"
-- if SERVER then
	-- function TOOL:GetConVars()
	-- 	-- return self:GetClientString( "type" )
	-- end
-- end

function TOOL:RightClick( trace )
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	return true
end

function TOOL.BuildCPanel(panel)
	WireToolHelpers.MakePresetControl(panel, "wire_punchcard_reader")
	ModelPlug_AddToCPanel(panel, "PunchcardInp", "wire_punchcard_reader", nil, 4)
end
