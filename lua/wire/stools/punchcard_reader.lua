WireToolSetup.setCategory( "Memory" )
WireToolSetup.open( "punchcard_reader", "Punchcard Reader", "gmod_wire_punchcard_reader", nil, "Punchcard Readers" )

if ( CLIENT ) then
	TOOL.Information = {
		{ name = "left", text = "Create a Punchcard Reader" },
	}
end
WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 20 )

TOOL.ClientConVar[ "model" ] = "models/props_lab/reciever01b.mdl"
TOOL.ClientConVar[ "mediareversible" ] = "0"

if SERVER then
	function TOOL:GetConVars()
		return self:GetClientBool("mediareversible")
	end
end

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
	panel:CheckBox(language.GetPhrase("wire_punchcard.reversable"),"wire_punchcard_reader_mediareversible")
end
