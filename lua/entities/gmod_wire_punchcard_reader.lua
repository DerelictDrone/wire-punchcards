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
	self.Outputs = Wire_CreateOutputs(self, {"Memory"})
	self.Inputs = {}
	self.DataRate = 0
	self.DataBytes = 0

	self.Memory = {}
	self.MemStart = {}
	self.MemEnd = {}
	self.MemOffsets = {}
	for i = 1,4 do
		self.Memory[i] = nil
		self.MemStart[i] = 0
		self.MemEnd[i] = 0
		self.MemOffsets[i] = 0
	end
	self:SetOverlayText("Name")
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
end

function ENT:WriteCell(Address, value)
end

function ENT:TriggerInput(iname, value)
	for i = 1,4 do
		if iname == "Memory"..i then
			self.Memory[i] = self.Inputs["Memory"..i].Src
		end
	end
end

duplicator.RegisterEntityClass("gmod_wire_addressbus", WireLib.MakeWireEnt, "Data", "Mem1st", "Mem2st", "Mem3st", "Mem4st", "Mem1sz", "Mem2sz", "Mem3sz", "Mem4sz", "Mem1rw", "Mem2rw", "Mem3rw", "Mem4rw")
