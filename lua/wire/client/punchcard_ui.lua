
Wire_PunchCardUI = Wire_PunchCardUI or vgui.Create("DFrame",nil,"PunchCardUI")
Wire_PunchCardUI:SetDeleteOnClose(false)
Wire_PunchCardUI:Hide()
Wire_PunchCardUI.SetNameButton = Wire_PunchCardUI.SetNameButton or vgui.Create("DButton",Wire_PunchCardUI)
Wire_PunchCardUI.Renderers = Wire_PunchCardUI.Renderers or {}
Wire_PunchCardUI.SetNameButton:SetText("Edit Punchcard Name")
Wire_PunchCardUI.SetNameButton:SizeToContents()
function Wire_PunchCardUI.SetNameButton:DoClick()
	Derma_StringRequest(
		"Write Punchcard Name",
		"",
		Wire_PunchCardUI.UserText or "",
		function(str)
			local limited = str:sub(1,48)
			net.Start("wire_punchcard_write")
				net.WriteEntity(Wire_PunchCardUI.CardEntity)
				net.WriteUInt(0,16)
				net.WriteUInt(0,16)
				net.WriteUInt(0,2)
				net.WriteString(limited)
			net.SendToServer()
			Wire_PunchCardUI:UpdateUserText(limited)
		end
	)
end
if not Wire_PunchCardUI.UserFont then
	Wire_PunchCardUI.UserFont = "PunchCard_Handwritten"
	surface.CreateFont(
		"PunchCard_Handwritten",
		{
			font = "Akbar",
			size=60
		}
	)
end

function Wire_PunchCardUI:UpdateUserText(str)
	self.UserText = str
	if self.Card.UpdateUserText then
		self.Card:UpdateUserText(str)
	end
end

-- Interprets punch card data and then opens the UI
function Wire_PunchCardUI:LoadCard(Entity,Model,Writable,Columns,Rows,Data,Patches,UserText)
	if self.Card then
		self.Card:Remove()
	end
	self.Card = vgui.Create("DPanel",Wire_PunchCardUI)
	-- since they don't allow clicking on shapes lets just quickly write our own handler
	local mx,my = 0,0
	function self.Card:OnCursorMoved(x,y)
		mx,my = x,y
	end
	function self.Card:OnMouseReleased(mkey)
		local elem = self:GetChildrenInRect(mx-1,my-1,2,2)[1]
		if not elem then return end
		if mkey == MOUSE_LEFT then
			if elem.DoClick then
				elem:DoClick()
			end
		end
		if mkey == MOUSE_RIGHT then
			if elem.DoRightClick then
				elem:DoRightClick()
			end
		end
	end
	if Writable then
		function self.Card.Punch(row,col)
			net.Start("wire_punchcard_write")
				net.WriteEntity(Entity)
				net.WriteUInt(col+1,16)
				net.WriteUInt(row+1,16)
				net.WriteUInt(1,2)
			net.SendToServer()
		end
		function self.Card.Patch(col,row)
			net.Start("wire_punchcard_write")
				net.WriteEntity(Entity)
				net.WriteUInt(col+1,16)
				net.WriteUInt(row+1,16)
				net.WriteUInt(2,2)
			net.SendToServer()
		end
	else
		-- noop these
		function self.Card.Punch()
		end
		function self.Card.Patch()
		end
	end
	local renderer = self.Renderers[Model] or self.Renderers["ibm5081"]
	renderer(Columns,Rows,Data,Patches,self.Card,Writable)
	self.Card:SetSize(0,0)
	self.Card:SizeToChildren(true,true)
	self.Card:SetPos(2,30)
	self.Card:SetMouseInputEnabled(true)
	self.CardEntity = Entity
	self:SetSize(0,0)
	self:SizeToChildren(true,true)
	self:Center()
	self:SetTitle(Model.." "..(Writable and "(Write Allowed)" or "(Write Disallowed)"))
	self:UpdateUserText(UserText)
	local ctrlx,ctrly = self.btnMinim:GetPos()
	local snx,sny = self.SetNameButton:GetSize()
	self.SetNameButton:SetPos(ctrlx-snx,ctrly)
	self:Show()
	self:MakePopup()
end

net.Receive("wire_punchcard_data",function (len,ply)
	local Entity = net.ReadEntity()
	local Columns = net.ReadUInt(16)
	local Rows = net.ReadUInt(16)
	local Writable = net.ReadBool()
	local Model = net.ReadString()
	local UserText = net.ReadString()
	local Data = {}
	local Patches = {}
	for i=1,Rows,1 do
		table.insert(Data,net.ReadUInt(Columns))
	end
	for i=1,Rows,1 do
		table.insert(Patches,net.ReadUInt(Columns))
	end
	Wire_PunchCardUI:LoadCard(Entity,Model,Writable,Columns,Rows,Data,Patches,UserText)
end)
