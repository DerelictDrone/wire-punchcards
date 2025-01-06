
Wire_PunchCardUI = Wire_PunchCardUI or vgui.Create("DFrame",nil,"PunchCardUI")
Wire_PunchCardUI:SetDeleteOnClose(false)
Wire_PunchCardUI:Hide()
Wire_PunchCardUI.Renderers = {}

-- Interprets punch card data and then opens the UI
function Wire_PunchCardUI:LoadCard(Entity,Model,Writable,Columns,Rows,Data,Patches)
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
	print(Model)
	local renderer = self.Renderers[Model] or self.Renderers["ibm5081"]
	renderer(Columns,Rows,Data,Patches,self.Card,Writable)
	self.Card:SetSize(0,0)
	self.Card:SizeToChildren(true,true)
	self.Card:SetPos(2,30)
	self.Card:SetMouseInputEnabled(true)
	self:SetSize(0,0)
	self:SizeToChildren(true,true)
	self:Center()
	self:SetTitle(Model.." "..(Writable and "(Write Allowed)" or "(Write Disallowed)"))
	self:Show()
	self:MakePopup()
end

Wire_PunchCardUI.Renderers = Wire_PunchCardUI.Renderers or {}

net.Receive("wire_punchcard_data",function (len,ply)
	local Entity = net.ReadEntity()
	local Columns = net.ReadUInt(16)
	local Rows = net.ReadUInt(16)
	local Writable = net.ReadBool()
	local Model = net.ReadString()
	local Name = net.ReadString()
	local Data = {}
	local Patches = {}
	for i=1,Rows,1 do
		table.insert(Data,net.ReadUInt(Columns))
	end
	for i=1,Rows,1 do
		table.insert(Patches,net.ReadUInt(Columns))
	end
	Wire_PunchCardUI:LoadCard(Entity,Model,Writable,Columns,Rows,Data,Patches)
end)
