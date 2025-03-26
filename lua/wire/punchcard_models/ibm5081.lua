Wire_PunchCardModels["ibm5081"] = {
	Columns = 10,
	Rows = 80,
	FriendlyName = "IBM 5081",
	Description = "A generic 80 row wide 10 column card introduced between 1960 and 1970.\nUses rectangular holes, has no field divisions."
}
Wire_PunchCardModels["ibm5081op"] = {
	Columns = 12,
	Rows = 80,
	FriendlyName = "IBM 5081 (Overpunch)",
	Description = Wire_PunchCardModels.ibm5081.Description .. "\n\nThis version allows the empty space above the regular columns to be punched.\nActing as the 11th and 12th columns.\nOtherwise known as Zone Punching or the X,Y rows."
}

if CLIENT then
	local function load()
		local white = Color(255,255,255,255)
		local gray = Color(128,128,128,255)
		local black = Color(0,0,0,255)
		local hidden = Color(0,0,0,1) -- ??? I need at least 1 in alpha for it to be allowed to render after changing color
		local card = Color(233,215,193,255)

		local function renderer(Overpunch,Columns,Rows,Data,Patches,Panel,Writable,UserColor)
			local CardColor = UserColor or card
			local tempColor = Color(0,0,0,0)
			tempColor:SetUnpacked(math.min(CardColor.r*1.1,255),math.min(CardColor.g*1.1,255),math.min(CardColor.b*1.1,255),CardColor.a)
			local cornerSize = 50
			function Panel:Paint(w, h)
				self:DrawCard(w, h, CardColor, cornerSize, -- Width, Height, Color, Corner Size
				-- Enable corner?, Cut corner or round?
					true, false,  -- Top left
					false, false,  -- Top right
					false, false, -- Bottom right
					false, false  -- Bottom left
				)
			end
			function holder:SetPunched()
				if t then
					t:SetColor(hidden)
				end
				self:SetColor(black)
				self.CustomMaterial = Panel.TransparentMaterial
				self.Punched = true
			end
			function holder:SetPatched()
				if t then
					t:SetColor(gray)
				end
				self:SetColor(gray)
				self.Patched = true
				self.Punched = false
				self.CustomMaterial = nil
			end
			if Writable then
				function holder:DoClick()
					self:SetPunched()
					Panel.Punch(digit,row)
				end
				function holder:DoRightClick()
					self:SetPatched()
					Panel.Patch(digit,row)
				end
			end
			if not overpunch then
				t:SetText(tostring(digit))
				t:SetColor(black)
				t:SizeToContents()
				t:Center()
				local tx,ty = t:GetPos()
				t:SetPos(tx+1,ty)
			end
			holder.Paint = Panel.ColumnPaint
			return holder
		end
		local masks = {}
		for i=1,Columns,1 do
			masks[i] = math.ldexp(1,i-1)
		end
		local startx,starty = cornerSize,((ysize+ypad)*2)+5
		Panel:SetWidth( Rows*(xsize+xpad) + cornerSize*2 )

		local x,y = startx,starty
		if Overpunch then
			Columns = Columns-2
		end
		
		local function createRows(startx,starty,xpad,ypad,columns,digitoffset,overpunch)
			digitoffset = digitoffset or 0
			overpunch = overpunch or false
			for row=0,Rows-1,1 do
				local r,p = Data[row+1],Patches[row+1]
				for digit=0,columns-1,1 do
					local punchable = createPunchable(digit+digitoffset,row,overpunch)
					punchable:SetPos(x,y)
					y = y + ysize + ypad
					if bit.band(p,masks[digit+digitoffset+1]) > 0 then
						punchable:SetPatched() -- Bit is patched (can be patched AND punched)
					end
					if bit.band(r,masks[digit+digitoffset+1]) > 0 then
						punchable:SetPunched() -- Bit is punched
					end
				end
				--x = startx
				y = starty
				x = x + xsize + xpad
				--y = y + ysize + ypad
			end
		end
		createRows(startx,starty,xpad,ypad,Columns,0,false)
		local textx = x
		function Panel:UpdateUserText(str)
			usertextLabel:SetText(str or "")
			usertextLabel:SizeToContents()
			local ux,_ = usertextLabel:GetSize()
			usertextLabel:SetPos((textx/2)-(ux/2))
		end
		local function createRowIdentifier(startx,starty)
			-- not zero indexed
			local x,y = startx,starty
			for row=1,Rows,1 do
				local label = vgui.Create("DLabel",Panel)
				local rstr = tostring(row)
				label:SetText(rstr)
				label:SizeToContents()
				local lx = label:GetSize()
				label:SetPos(((3-#rstr)+x)-(lx/4),y)
				label:SetColor(black)
				x = x + xsize + xpad
			end
		end
		createRowIdentifier(startx+5,starty+(ysize)) -- Start inbetween column 1 & 2
		createRowIdentifier(startx+5,starty+((ysize+ypad)*(Columns-0.3))) -- Start just after last column
		local nameLabel = vgui.Create("DLabel",Panel)
		nameLabel:SetPos(startx+5+((xsize+xpad)*10),starty+(ysize+ypad)*(Columns))
		nameLabel:SetText("IBM [5081]")
		nameLabel:SetColor(black)
		if Overpunch then
			x, y = startx, 5
			starty = y
			createRows(startx,starty,xpad,ypad,2,Columns,true)
		end
	end

	local function ibm5081(...)
		return renderer(false,...)
	end

	local function ibm5081op(...)
		return renderer(true,...)
	end
	Wire_PunchCardUI.Renderers["ibm5081"] = ibm5081
	Wire_PunchCardUI.Renderers["ibm5081op"] = ibm5081op
end