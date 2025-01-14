
Wire_PunchCardUI = Wire_PunchCardUI or vgui.Create("DFrame",nil,"PunchCardUI")
Wire_PunchCardUI:SetDeleteOnClose(false)
Wire_PunchCardUI:Hide()
Wire_PunchCardUI.SetNameButton = Wire_PunchCardUI.SetNameButton or vgui.Create("DButton",Wire_PunchCardUI)
Wire_PunchCardUI.Renderers = Wire_PunchCardUI.Renderers or {}
Wire_PunchCardUI.SetNameButton:SetText("Edit Punchcard Name")
Wire_PunchCardUI.SetNameButton:SizeToContents()
Wire_PunchCardUI:SetTitle("")

local screenspace = Material("models/screenspace")
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

function Wire_PunchCardUI:Paint(w, h)
	surface.SetDrawColor(20, 20, 20, 64)
	surface.DrawRect(0, 0, w, h)

	draw.SimpleText(
		self.PCTitle,
		"DermaDefault",
		w / 2,
		15,
		color_white,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER
	)
end

local function ColumnPaint(self,w,h)
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

local function roundCorner(points, cx, cy, startAngle, endAngle, radius, steps)
	for i = 0, steps do
		local angle = math.rad(startAngle + (endAngle - startAngle) * (i / steps))
		local x = cx + math.cos(angle) * radius
		local y = cy + math.sin(angle) * radius
		table.insert(points, {x = x, y = y})
	end
end

local function DrawCard(self, w, h, color, size, hasCorner1, roundedCorner1, hasCorner2, roundedCorner2, hasCorner3, roundedCorner3, hasCorner4, roundedCorner4)
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

function Wire_PunchCardUI:SetupCard(Card,Entity,Model,Writable,Columns,Rows,Data,Patches,UserText)
	Card.DrawCard = DrawCard
	Card.ColumnPaint = ColumnPaint
		-- since they don't allow clicking on shapes lets just quickly write our own handler
		local mx,my = 0,0
		function Card:OnCursorMoved(x,y)
			mx,my = x,y
		end
		function Card:OnMouseReleased(mkey)
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
			function Card.Punch(row,col)
				net.Start("wire_punchcard_write")
					net.WriteEntity(Entity)
					net.WriteUInt(col+1,16)
					net.WriteUInt(row+1,16)
					net.WriteUInt(1,2)
				net.SendToServer()
			end
			function Card.Patch(col,row)
				net.Start("wire_punchcard_write")
					net.WriteEntity(Entity)
					net.WriteUInt(col+1,16)
					net.WriteUInt(row+1,16)
					net.WriteUInt(2,2)
				net.SendToServer()
			end
		else
			-- noop these
			function Card.Punch()
			end
			function Card.Patch()
			end
		end
		function Card:SetPunched_UI(col,row)
			if self.SetPunched then
				self:SetPunched(col,row)
			end
		end
		function Card:SetPatched_UI(col,row)
			if self.SetPatched then
				self:SetPatched(col,row)
			end
		end
		function Card:ResetPunchState_UI(col,row)
			if self.ResetPunchState then
				self:ResetPunchedState(col,row)
			end
		end
		-- Provide options for rendering transparently / with material.
		Card.TransparentMaterial = screenspace
		local renderer = self.Renderers[Model] or self.Renderers["ibm5081"]
		local Color = Entity:GetColor()
		if Color.r == 255 and Color.g == 255 and Color.b == 255 and Color.a == 255 then
			Color = nil
		end
		renderer(Columns,Rows,Data,Patches,Card,Writable,Color)
		if UserText and Card.UpdateUserText then
			Card:UpdateUserText(UserText)
		end
end

-- Interprets punch card data and then opens the UI
function Wire_PunchCardUI:LoadCard(Entity,Model,Writable,Columns,Rows,Data,Patches,UserText)
	if self.Card then
		self.Card:Remove()
	end
	self.Card = vgui.Create("DPanel",Wire_PunchCardUI)
	self:SetupCard(self.Card,Entity,Model,Writable,Columns,Rows,Data,Patches,UserText)
	self.CardEntity = Entity
	self.Card:SizeToChildren(false,true)
	self.Card:SetPos(2,30)
	self.Card:SetMouseInputEnabled(true)
	self:SetSize(0,0)
	self:SizeToChildren(true,true)
	self:Center()

	local pnx,pny = self:GetSize()
	local cdx,cdy = self.Card:GetSize()
	self.Card:SetPos((pnx-cdx)/2,30)

	local ctrlx,ctrly = self.btnMinim:GetPos()
	local snx,sny = self.SetNameButton:GetSize()
	self.SetNameButton:SetPos(ctrlx-snx*1.1,(30-sny)/2)
	self.PCTitle = Model.." "..(Writable and "(Write Allowed)" or "(Write Disallowed)")
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


if not Wire_PunchCardUI then
	Wire_PunchCardUI = {
		Renderers = {}
	}
	timer.Simple(0,function()
	end)
else
	if type(Wire_PunchCardUI) == "table" then
		return -- Loading is likely already queued, leave it to the timer.
	end
	Wire_PunchCardUI = createPunchCardUIElement(true)
	load()
end

if not Wire_PunchCardUI_LoadHook then
	local load_hooks = 0
	-- Runs the function when the UI is ready, or runs it immediately if it's already ready.
	function Wire_PunchCardUI_LoadHook(fn)
		if ispanel(Wire_PunchCardUI) then
			fn()
			return
		else
			hook.Add("Wire_PunchCardUI_Loaded","UILoad_"..load_hooks,fn)
			load_hooks = load_hooks + 1
		end
	end
end

hook.Add("OnGamemodeLoaded","Load_Wire_PunchCardUI",function()
	Wire_PunchCardUI = createPunchCardUIElement(false)
	load()
	hook.Run("Wire_PunchCardUI_Loaded",Wire_PunchCardUI)
end)
