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

TOOL.ClientConVar[ "model" ] = "models/punch_card/punch_card.mdl"
TOOL.ClientConVar[ "pc_model" ] = "ibm5081"
if SERVER then
	function TOOL:GetConVars()
		return self:GetClientInfo("pc_model")
	end

	-- Uses default WireToolObj:MakeEnt's WireLib.MakeWireEnt function
end

TOOL.NoLeftOnClass = true

if SERVER then
-- Copy of the function from wiretoolobj / wiretoollib but with the automatic weld+nocollide part removed.
	-- this function needs to return true if the tool beam should be "fired"
	function TOOL:LeftClick_PostMake( ent, ply, trace )
		if ent == true then return true end
		if ent == nil or ent == false or not ent:IsValid() then return false end

		-- Parenting
		local nocollide, const
		if self:GetClientNumber( "parent" ) == 1 then
			if (trace.Entity:IsValid()) then
				-- Nocollide the gate to the prop to make adv duplicator (and normal duplicator) find it
				if (not self.ClientConVar.noclip or self:GetClientNumber( "noclip" ) == 1) then
					nocollide = constraint.NoCollide( ent, trace.Entity, 0,trace.PhysicsBone )
				end

				ent:SetParent( trace.Entity )
			end
		end

		undo.Create( self.WireClass )
			undo.AddEntity( ent )
			if (const) then undo.AddEntity( const ) end
			if (nocollide) then undo.AddEntity( nocollide ) end
			undo.SetPlayer( self:GetOwner() )
		undo.Finish()

		ply:AddCleanup( self.WireClass, ent )

		if self.PostMake then self:PostMake(ent, ply, trace) end
		duplicator.ApplyEntityModifiers(ply, ent)

		return true
	end
end

function TOOL:RightClick(trace)
	if trace.Entity:IsPlayer() then return false end
	if trace.Entity:GetClass() ~= "gmod_wire_punchcard" then
		return false
	end
	if CLIENT then return true end
	SendPunchcard(trace.Entity,self:GetOwner(),true)
	return true
end

function TOOL.BuildCPanel(panel)
	WireToolHelpers.MakePresetControl(panel, "wire_punchcard")
	local list = panel:ComboBox("Punchcard Model","wire_punchcard_pc_model")
	local label = vgui.Create("DLabel")
	label:SetColor(Color(0,0,0,255))
	panel:AddItem(label)
	list:SetValue("Punchcard models")
	local function loadCards()
		list:Clear()
		local curmodel = GetConVar("wire_punchcard_pc_model"):GetString()
		for k,v in pairs(Wire_PunchCardModels) do
			list:AddChoice(v.FriendlyName or k,k,curmodel == k)
			if curmodel == k then
				label:SetText(Wire_PunchCardModels[k].Description or "No description for model.")
				label:InvalidateLayout(true)
				label:SizeToContents()
				label:InvalidateLayout(true)
			end
		end
	end
	hook.Add("Punchcard_UpdateModels","CreateSelector",loadCards)
	loadCards()
	local oldSelect = list.OnSelect
	function list:OnSelect(i,v,d)
		label:SetText(Wire_PunchCardModels[d].Description or "No description for model.")
		-- Double layout invalidation seems necessary to get it to properly update, dunno why
		label:SizeToContents()
		label:InvalidateLayout(true)
		label:SizeToContents()
		label:InvalidateLayout(true)
		return oldSelect(self,i,v,d)
	end
end
