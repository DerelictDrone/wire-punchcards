WireToolSetup.setCategory( "Memory" )
WireToolSetup.open( "punchcard", "Punchcard", "gmod_wire_punchcard", nil, "Punchcards" )

if ( CLIENT ) then
	language.Add( "Tool.wire_punchcard.name", "Punchcard(Wire)" )
	language.Add( "Tool.wire_punchcard.desc", "Spawns a Punchcard!" )
	TOOL.Information = {
		{ name = "left", text = "Create a Punchcard" },
		{ name = "right", text = "Edit Punchcard" }
	}
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

function TOOL:RightClick( trace )
	if trace.Entity:IsPlayer() then return false end
	if trace.Entity:GetClass() ~= "gmod_wire_punchcard" then
		return false
	end
	if CLIENT then return true end
	local ent = trace.Entity
	local Columns = ent.Columns -- aka bits
	local Rows = ent.Rows
	local Data,Patches = ent.Data,ent.Patches
	net.Start("wire_punchcard_data")
		net.WriteEntity(ent)
		net.WriteUInt(Columns,16)
		net.WriteUInt(Rows,16)
		net.WriteString(ent.pc_model)
		for _,i in ipairs(Data) do
			net.WriteUInt(i,Columns)
		end
		for _,i in ipairs(Patches) do
			net.WriteUInt(i,Columns)
		end
	net.Send(self:GetOwner())
	return true
end

function TOOL.BuildCPanel(panel)
	WireToolHelpers.MakePresetControl(panel, "wire_punchcard")
	ModelPlug_AddToCPanel(panel, "gate", "wire_punchcard", nil, 4)
end
