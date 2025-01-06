WireToolSetup.setCategory( "Memory" )
WireToolSetup.open( "punchcard_writer", "Punchcard Writer", "gmod_wire_punchcard_writer", nil, "Punchcard Writers" )

if ( CLIENT ) then
	language.Add( "Tool.wire_punchcard_writer.name", "Punchcard Writer(Wire)" )
	language.Add( "Tool.wire_punchcard_writer.desc", "Spawns a Punchcard Writer!" )
	TOOL.Information = {
		{ name = "left", text = "Create a Punchcard Writer" },
	}
end
WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 20 )

TOOL.ClientConVar[ "model" ] = "models/props_c17/consolebox05a.mdl"
-- if SERVER then
-- 	function TOOL:GetConVars()
-- 	end

-- 	-- Uses default WireToolObj:MakeEnt's WireLib.MakeWireEnt function
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
	WireToolHelpers.MakePresetControl(panel, "wire_punchcard_writer")
	ModelPlug_AddToCPanel(panel, "PunchcardInp", "wire_punchcard_writer", nil, 4)
end
