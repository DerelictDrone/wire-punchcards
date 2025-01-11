AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName		= "Wire Punchcard"
ENT.WireDebugName 	= "Punchcard"

if CLIENT then return end -- No more client

function ENT:Initialize()
	BaseClass.Initialize(self)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
end

Wire_PunchCardModels = Wire_PunchCardModels or {}
local Models = Wire_PunchCardModels

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
		if Action == 0 then
			ent.pc_usertext = net.ReadString() or ""
			ent.pc_usertext = ent.pc_usertext:sub(1,48)
			ent:UpdateOverlayText()
		end
	else
		return
	end
end
)

-- net.Receive("wire_punchcard_request_data",function(len,ply)
-- end)


function ENT:Setup(pc_model)
	self.Patches = {} -- Patched areas, once patched the patch will remain, even if punched again. For flavor
	self.Data = {} -- Packed data, 1 number per row, unpack using bit lib
	pc_model = pc_model or "ibm5081"
	self.pc_model = pc_model
	self.Columns = Models[pc_model].Columns
	self.Rows = Models[pc_model].Rows
	for i=1,self.Rows,1 do
		self.Data[i] = 0
		self.Patches[i] = 0
	end
	self:UpdateOverlayText()
	self.MaxValue = math.ldexp(1,self.Columns)-1
end

function ENT:Use(actv,call,type,data)
	if actv:IsPlayer() and actv:KeyDown(IN_WALK) then
		return SendPunchcard(self,actv,false)
	end
	if self:IsPlayerHolding() then return end
	if self.InDevice then
		-- alert the device rq that the user has just grabbed us
		if self.Device.MediaGrabbed then
			-- if grab returns true we're allowed to remove the device
			if not self.Device:MediaGrabbed(self) then return end
		end
	end
	actv:PickupObject(self)
end

function ENT:MediaConnected(device)
	if self:IsPlayerHolding() then
		self:ForcePlayerDrop()
	end
	self.InDevice = true
	self.Device = device
	return true
end

function ENT:MediaDisconnected(device)
	self.InDevice = false
	self.Device = nil
end

function ENT:ReadRow(row)
	return self.Data[row]
end

function ENT:ReadPatches(row)
	return self.Patches[row]
end

-- Just apply a number to a row outright, clamps first
function ENT:PunchRow(value,row,silent)
	value = math.floor(value)
	if value <= 0 then return end
	if self.Data[row] then
		local oldData = self.Data[row]
		self.Data[row] = bit.bor(self.Data[row],math.Clamp(value,0,self.MaxValue))
		if not silent and oldData ~= self.Data[row] then
			self:EmitSound(string.format("paper-punch-0%d.wav",math.floor(math.random()*7)+1))
		end
	end
end

function ENT:Punch(column,row,silent)
	if column <= 0 then return end
	if self.Data[row] then
		local oldData = self.Data[row]
		self.Data[row] = bit.bor(self.Data[row],math.ldexp(1,column-1))
		if not silent and oldData ~= self.Data[row] then
			self:EmitSound(string.format("paper-punch-%d.wav",math.floor(math.random()*7)+1))
		end
	end
end

function ENT:Patch(row,column,silent)
	if self.Data[row] then
		local oldPatch = self.Patches[row]
		local oldData = self.Data[row]
		self.Patches[row] = bit.bor(self.Patches[row],math.ldexp(1,column-1))
		self.Data[row] = bit.band(self.Data[row],bit.bnot(math.ldexp(1,column-1)))
		if not silent and (oldPatch ~= self.Patches[row] or oldData ~= self.Data[row]) then
			self:EmitSound(string.format("paper-patch-%d.wav",math.floor(math.random()*18)+1))
		end
	end
end

function ENT:UpdateOverlayText()
	local model = Wire_PunchCardModels[self.pc_model]
	self:SetOverlayText((model and model.FriendlyName or "Unknown Model")..(self.pc_usertext and "\n\n"..self.pc_usertext or ""))
end

function ENT:BuildDupeInfo()
	local info = BaseClass.BuildDupeInfo(self) or {}
	info.pc_model = self.pc_model
	info.pc_usertext = self.pc_usertext
	info.PCardData = self.Data
	info.PCardPatches = self.Patches
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID)
	ent.pc_model = info.pc_model or "ibm5081"
	ent.pc_usertext = info.pc_usertext
	ent.Patches = info.PCardPatches or ent.Patches or {}
	ent.Data = info.PCardData or ent.Data or {}
	ent:UpdateOverlayText()
end

duplicator.RegisterEntityClass("gmod_wire_punchcard", WireLib.MakeWireEnt, "Data", "pc_model")
