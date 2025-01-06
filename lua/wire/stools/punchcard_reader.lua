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

if CLIENT then
	function TOOL:Holster()
		Punchcard_ShowHitboxes = false
	end
	function TOOL:Deploy()
		Punchcard_ShowHitboxes = true
	end
end

-- Ugly hack to get it to show in SP too
if game.SinglePlayer() then
	function TOOL:Holster()
		if SERVER then
			self:GetWeapon():CallOnClient("Holster","")
			return
		end
		Punchcard_ShowHitboxes = false
	end
	function TOOL:Deploy()
		if SERVER then
			self:GetWeapon():CallOnClient("Deploy","")
			return
		end
		Punchcard_ShowHitboxes = true
	end
end

function TOOL.BuildCPanel(panel)
	WireToolHelpers.MakePresetControl(panel, "wire_punchcard_reader")
	ModelPlug_AddToCPanel(panel, "PunchcardInp", "wire_punchcard_reader", nil, 4)
end
