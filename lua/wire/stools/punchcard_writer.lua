WireToolSetup.setCategory( "Memory" )
WireToolSetup.open( "punchcard_writer", "Punchcard Writer", "gmod_wire_punchcard_writer", nil, "Punchcard Writers" )

if ( CLIENT ) then
	TOOL.Information = {
		{ name = "left", text = language.GetPhrase("tool.wire_punchcard_writer.left") },
	}
end
WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 20 )

TOOL.ClientConVar[ "model" ] = "models/props_lab/reciever01d.mdl"
TOOL.ClientConVar[ "silent" ] = "0"
TOOL.ClientConVar[ "mediareversible" ] = "0"
-- if SERVER then
	function TOOL:GetConVars()
		return self:GetClientBool("silent"),self:GetClientBool("mediareversible")
	end

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
	panel:CheckBox(language.GetPhrase("wire_punchcard.reversable"),"wire_punchcard_writer_mediareversible")
	panel:CheckBox(language.GetPhrase("wire_punchcard.silentpunch"),"wire_punchcard_writer_silent")
end
