
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
	function self.Card:ColumnPaint(w,h)
		if self.CustomMaterial then
			surface.SetMaterial(self.CustomMaterial)
			local u,v = self:LocalToScreen(0,0)
			local sW,sH = ScrW(),ScrH()
			u = u/sW
			v = v/sH
			surface.DrawTexturedRectUV(0,0,w,h,u,v,u+(w/sW),v+(h/sH))
			draw.NoTexture()
			return
		else
			surface.SetDrawColor(self:GetColor())
			surface.DrawRect(0,0,w,h)
			return
		end
	end

	local renderer = self.Renderers[Model] or self.Renderers["ibm5081"]
	local Color = Entity:GetColor()
	if Color.r == 255 and Color.g == 255 and Color.b == 255 and Color.a == 255 then
		Color = nil
	end
	renderer(Columns,Rows,Data,Patches,self.Card,Writable,Color)

	self.Card:SizeToChildren(false,true)
	self.Card:SetPos(2,30)
	self.Card:SetMouseInputEnabled(true)
	self.CardEntity = Entity
	self:SetSize(0,0)
	self:SizeToChildren(true,true)
	self:Center()
	self:SetTitle("")
	self:UpdateUserText(UserText)

	local pnx,pny = self:GetSize()
	local cdx,cdy = self.Card:GetSize()
	self.Card:SetPos((pnx-cdx)/2,30)

	local ctrlx,ctrly = self.btnMinim:GetPos()
	local snx,sny = self.SetNameButton:GetSize()
	self.SetNameButton:SetPos(ctrlx-snx*1.1,(30-sny)/2)

	local function roundCorner(points, cx, cy, startAngle, endAngle, radius, steps)
		for i = 0, steps do
			local angle = math.rad(startAngle + (endAngle - startAngle) * (i / steps))
			local x = cx + math.cos(angle) * radius
			local y = cy + math.sin(angle) * radius
			table.insert(points, {x = x, y = y})
		end
	end

	function self.Card:DrawCard(w, h, color, size, hasCorner1, roundedCorner1, hasCorner2, roundedCorner2, hasCorner3, roundedCorner3, hasCorner4, roundedCorner4)
		local points = {}
	
		if hasCorner1 then
			if roundedCorner1 then
				roundCorner(points, size, size, 180, 270, size, 10)
			else
				table.insert(points, {x = size, y = 0})
				table.insert(points, {x = 0, y = size})
			end
		else
			table.insert(points, {x = 0, y = 0})
		end
	
		if hasCorner2 then
			if roundedCorner2 then
				roundCorner(points, w - size, size, 270, 360, size, 10)
			else
				table.insert(points, {x = w - size, y = 0})
				table.insert(points, {x = w, y = size})
			end
		else
			table.insert(points, {x = w, y = 0})
		end
	
		if hasCorner3 then
			if roundedCorner3 then
				roundCorner(points, w - size, h - size, 0, 90, size, 10)
			else
				table.insert(points, {x = w, y = h - size})
				table.insert(points, {x = w - size, y = h})
			end
		else
			table.insert(points, {x = w, y = h})
		end
	
		if hasCorner4 then
			if roundedCorner4 then
				roundCorner(points, size, h - size, 90, 180, size, 10)
			else
				table.insert(points, {x = size, y = h})
				table.insert(points, {x = 0, y = h - size})
			end
		else
			table.insert(points, {x = 0, y = h})
		end
	
		table.insert(points, {x = 0, y = size})
	
		surface.SetDrawColor(color)
		draw.NoTexture()
		surface.DrawPoly(points)
	end

	local title = Model.." "..(Writable and "(Write Allowed)" or "(Write Disallowed)")

	function self:Paint(w, h)
		surface.SetDrawColor(20, 20, 20, 64)
		surface.DrawRect(0, 0, w, h)

		draw.SimpleText(
			title,
			"DermaDefault",
			w / 2,
			15,
			color_white,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end

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
