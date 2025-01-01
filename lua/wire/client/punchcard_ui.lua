
Wire_PunchCardUI = Wire_PunchCardUI or vgui.Create("DFrame",nil,"PunchCardUI")
Wire_PunchCardUI:SetDeleteOnClose(false)
Wire_PunchCardUI:Hide()
Wire_PunchCardUI.Renderers = {}

-- Interprets punch card data and then opens the UI
function Wire_PunchCardUI:LoadCard(Entity,Model,Columns,Rows,Data,Patches)
	if self.Card then
		self.Card:Remove()
	end
	self.Card = vgui.Create("DPanel",Wire_PunchCardUI)
	-- since they don't allow clicking on shapes lets just quickly write our own handler
	local mx,my = 0,0
	function self.Card:OnCursorMoved(x,y)
		-- print(mx,my)
		mx,my = x,y
	end
	function self.Card:OnMouseReleased(mkey)
		local elem = self:GetChildrenInRect(mx-1,my-1,2,2)[1]
		if not elem then return end
		if mkey == MOUSE_LEFT then
			elem:DoClick()
		end
		if mkey == MOUSE_RIGHT then
			elem:DoRightClick()
		end
	end
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
	local renderer = self.Renderers[Model] or self.Renderers["ibm5081"]
	renderer(Columns,Rows,Data,Patches,self.Card)
	self.Card:SetSize(0,0)
	self.Card:SizeToChildren(true,true)
	self.Card:SetPos(2,30)
	self.Card:SetMouseInputEnabled(true)
	self:SetSize(0,0)
	self:SizeToChildren(true,true)
	self:Center()
	self:Show()
	self:MakePopup()
end

Wire_PunchCardUI.Renderers = Wire_PunchCardUI.Renderers or {}

local white = Color(255,255,255,255)
local gray = Color(128,128,128,255)
local black = Color(0,0,0,255)

Wire_PunchCardUI.Renderers["ibm5081"] = function(Columns,Rows,Data,Patches,Panel)
	local xsize,ysize = 15,30
	local xpad,ypad = 5,15
	local function createPunchable(digit,row)
		local holder = vgui.Create("DShape",Panel)
		holder:SetType("Rect")
		holder:SetSize(xsize,ysize)
		holder:SetColor(white)
		holder.m_bSelectable = true -- Allow selection by GetChildrenInRect
		local t = vgui.Create("DLabel",holder)
		function holder:SetPunched()
			t:SetColor(black)
			self:SetColor(black)
			holder.Punched = true
		end
		function holder:SetPatched()
			t:SetColor(gray)
			self:SetColor(gray)
			holder.Patched = true
			holder.Punched = false
		end
		function holder:DoClick()
			self:SetPunched()
			Panel.Punch(digit,row)
		end
		function holder:DoRightClick()
			self:SetPatched()
			Panel.Patch(digit,row)
		end
		t:SetText(tostring(digit))
		t:SetColor(black)
		t:SizeToContents()
		t:Center()
		return holder
	end
	local masks = {}
	for i=1,Columns,1 do
		masks[i] = math.ldexp(1,i-1)
		print(masks[i])
	end
	local startx,starty = 0,((ysize+ypad)*2)+5
	local x,y = startx,starty
	for row=0,Rows-1,1 do
		local r,p = Data[row+1],Patches[row+1]
		for digit=0,Columns-1,1 do
			local punchable = createPunchable(digit,row)
			punchable:SetPos(x,y)
			y = y + ysize + ypad
			if bit.band(p,masks[digit+1]) > 0 then
				punchable:SetPatched() -- Bit is patched (can be patched AND punched)
			end
			if bit.band(r,masks[digit+1]) > 0 then
				punchable:SetPunched() -- Bit is punched
			end
		end
		--x = startx
		y = starty
		x = x + xsize + xpad
		--y = y + ysize + ypad
	end
	local function createRowIdentifier(startx,starty)
		-- not zero indexed
		local x,y = startx,starty
		for row=1,Rows,1 do
			local label = vgui.Create("DLabel",Panel)
			label:SetPos(x,y)
			label:SetText(tostring(row))
			label:SetColor(black)
			x = x + xsize + xpad
		end
	end
	createRowIdentifier(startx+5,starty+(ysize)-5) -- Start inbetween column 1 & 2
	createRowIdentifier(startx+5,starty+((ysize+ypad)*(Columns-0.35))) -- Start just after last column
end

net.Receive("wire_punchcard_data",function (len,ply)
	local Entity = net.ReadEntity()
	local Columns = net.ReadUInt(16)
	local Rows = net.ReadUInt(16)
	local Model = net.ReadString()
	local Data = {}
	local Patches = {}
	for i=1,Rows,1 do
		table.insert(Data,net.ReadUInt(Columns))
	end
	for i=1,Rows,1 do
		table.insert(Patches,net.ReadUInt(Columns))
	end
	Wire_PunchCardUI:LoadCard(Entity,Model,Columns,Rows,Data,Patches)
end)
