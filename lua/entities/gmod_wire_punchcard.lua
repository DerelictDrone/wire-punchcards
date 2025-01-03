AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName		= "Wire Punchcard"
ENT.WireDebugName 	= "Punchcard"

if CLIENT then return end -- No more client

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetOverlayText("IBM 5081 Punch Card")
end

local Models = {
	ibm5081 = {Columns = 10, Rows = 80}
}

util.AddNetworkString("wire_punchcard_data")
util.AddNetworkString("wire_punchcard_write")

net.Receive("wire_punchcard_write",function(len,ply)
	local ent = net.ReadEntity()
	if ent and ent:IsValid() and ent:GetClass() == "gmod_wire_punchcard" then
		local Column = net.ReadUInt(16)
		local Row = net.ReadUInt(16)
		local Action = net.ReadUInt(2)
		if Action == 1 then
			ent:Punch(Row,Column)
			return
		end
		if Action == 2 then
			ent:Patch(Row,Column)
			return
		end
	else
		return
	end
end
)

-- net.Receive("wire_punchcard_request_data",function(len,ply)
-- end)


function ENT:Setup(model)
	self.Patches = {} -- Patched areas, once patched the patch will remain, even if punched again. For flavor
	self.Data = {} -- Packed data, 1 number per row, unpack using bit lib
	model = model or "ibm5081"
	self.pc_model = model
	self.Columns = Models[model].Columns
	self.Rows = Models[model].Rows
	for i=1,self.Rows,1 do
		self.Data[i] = 0
		self.Patches[i] = 0
	end
end

function ENT:ReadRow(row)
	return self.Data[row]
end

function ENT:ReadPatches(row)
	return self.Patches[row]
end

function ENT:Punch(column,row,silent)
	if self.Data[row] then
		self.Data[row] = bit.bor(self.Data[row],math.ldexp(1,column-1))
		if not silent then
			self:EmitSound(string.format("paper-punch-0%d.wav",math.floor(math.random()*7)+1))
		end
	end
end

function ENT:Patch(row,column,silent)
	if self.Data[row] then
		self.Patches[row] = bit.bor(self.Patches[row],math.ldexp(1,column-1))
		self.Data[row] = bit.band(self.Data[row],bit.bnot(math.ldexp(1,column)-1))
		if not silent then
			-- no sfx yet
		end
	end
end

duplicator.RegisterEntityClass("gmod_wire_punchcard", WireLib.MakeWireEnt, "Model")
