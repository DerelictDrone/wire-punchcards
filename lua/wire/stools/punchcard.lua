WireToolSetup.setCategory( "Memory" )
WireToolSetup.open( "punchcard", "Punchcard", "gmod_wire_punchcard", nil, "Punchcards" )

if ( CLIENT ) then
	language.Add( "Tool.wire_punchcard.name", "Punchcard(Wire)" )
	language.Add( "Tool.wire_punchcard.desc", "Spawns a Punchcard!" )
	TOOL.Information = { { name = "left", text = "Create a Punchcard" } }
end
WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 20 )

TOOL.ClientConVar[ "model" ] = "models/jaanus/wiretool/wiretool_gate.mdl"
TOOL.ClientConVar[ "pc_model" ] = "ibm5081"
if SERVER then
	function TOOL:GetConVars()
		-- return self:GetClientString( "type" )
	end

	-- Uses default WireToolObj:MakeEnt's WireLib.MakeWireEnt function
end


if CLIENT then
	Wire_PunchCardUI = Wire_PunchCardUI or vgui.Create("DFrame",nil,"PunchCardUI")
	Wire_PunchCardUI:Hide()
	-- Interprets punch card data and then opens the UI
	function Wire_PunchCardUI:LoadCard(Data)
		
	end
end

local PunchCardUI = Wire_PunchCardUI

function TOOL:RightClick( trace )
	if trace.Entity:IsPlayer() then return false end
	if (CLIENT) then return true end

	local ply = self:GetOwner()
	return true
end

function TOOL.BuildCPanel(panel)
	WireToolHelpers.MakePresetControl(panel, "wire_punchcard")
	ModelPlug_AddToCPanel(panel, "gate", "wire_punchcard", nil, 4)
end
