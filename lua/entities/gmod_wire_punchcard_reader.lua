AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName		= "Wire Punchcard Reader"
ENT.WireDebugName 	= "PunchcardReader"

if CLIENT then return end -- No more client

AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName		= "Wire Punchcard Reader"
ENT.WireDebugName 	= "PunchcardReader"

if CLIENT then return end -- No more client

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self.Inputs = Wire_CreateInputs(self, {"CLK", "Data", "Next Row"})
	self.Outputs = Wire_CreateOutputs(self, {"Data","Punchcard Inserted"})
	self.HasCard = false
end

function ENT:Setup(Option)
end

function ENT:Think()
	BaseClass.Think(self)

	self.DataRate = self.DataBytes
	self.DataBytes = 0

	-- Wire_TriggerOutput(self, "Memory", self.DataRate)
	-- self:SetOverlayText("Data rate: "..math.floor(self.DataRate*2).." bps")
	-- self:NextThink(CurTime()+0.5)
	return true
end

function ENT:ReadCell(Address)
	if Address < 0 or Address > 5 then return end

end

function ENT:WriteCell(Address, value)

end

function ENT:TriggerInput(iname, value)
	
end

duplicator.RegisterEntityClass("gmod_wire_punchcard_reader", WireLib.MakeWireEnt, "Data")
