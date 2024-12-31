AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName		= "Wire Punchcard"
ENT.WireDebugName 	= "WPunchcard"

if CLIENT then return end -- No more client

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetOverlayText("unknown")
end

local Models = {
	ibm5081 = {Columns = 80, Rows = 10}
}

util.AddNetworkString("wire_punchcard_request_data")
util.AddNetworkString("wire_punchcard_data")

net.Receive("wire_punchcard_request_data",function(len,ply)

end)


function ENT:Setup(model)
	self.Patches = {} -- Patched areas, once patched the patch will remain, even if punched again. For flavor
	self.Data = {} -- Packed data, 1 number per row, unpack using bit lib
	model = model or "ibm5081"
	self.Columns = Models[model].Columns
	self.Rows = Models[model].Rows
	for i=1,self.Rows,1 do
		self.Data[i] = 0
	end
end

function ENT:ReadRow(row)
	return self.Data[row]
end

function ENT:ReadPatches(row)
	return self.Patches[row]
end

function ENT:GetPunchLayout()
	local ret = {}
	-- quickly make a mask table
	local masks = {}
	for i=1,self.Columns,1 do
		masks[i] = math.ldexp(1,self.Columns-1)
	end
	for i=1,self.Rows,1 do
		local r,p,t = self:ReadRow(i),self:ReadPatches(i),{}
		ret[i] = t
		for j=1,self.Columns,1 do
			t[1] = bit.band(r,masks[j]) > 0 -- Bit is punched
			t[2] = bit.band(p,masks[j]) > 0 -- Bit is patched (can be patched AND punched)
		end
	end
	return ret
end

function ENT:Punch(row,column,silent)
	if self.Data[row] then
		self.Data[row] = bit.bor(self.Data[row],math.ldexp(1,column-1))
		if not silent then
			self:EmitSound(string.format("paper-punch-0%d.wav",math.floor(math.random()*7)+1))
		end
	end
end

function ENT:Patch(row,column,silent)
	if self.Data[row] then
		self.Patches[row] = bit.bor(self.Data[row],math.ldexp(1,column))
		self.Data[row] = bit.bxor(self.Data[row],math.ldexp(1,column)-1)
		if not silent then
			-- no sfx yet
		end
	end
end

duplicator.RegisterEntityClass("gmod_wire_punchcard", WireLib.MakeWireEnt, "Model")
