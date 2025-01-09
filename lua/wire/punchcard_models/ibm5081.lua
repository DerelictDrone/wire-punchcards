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
	local white = Color(255,255,255,255)
	local gray = Color(128,128,128,255)
	local black = Color(0,0,0,255)
	local hidden = Color(0,0,0,0)

	local function renderer(Overpunch,Columns,Rows,Data,Patches,Panel,Writable)
		local usertextLabel = vgui.Create("DLabel",Panel)
		usertextLabel:SetText(Panel.UserText or "")
		usertextLabel:SetFont("PunchCard_Handwritten")
		usertextLabel:SizeToContents()
		usertextLabel:SetColor(black)
		local xsize,ysize = 15,30
		local xpad,ypad = 5,15
		local function createPunchable(digit,row,overpunch)
			local holder = vgui.Create("DShape",Panel)
			holder:SetType("Rect")
			holder:SetSize(xsize,ysize)
			holder:SetColor(overpunch and hidden or white)
			holder.m_bSelectable = true -- Allow selection by GetChildrenInRect
			local t
			if not overpunch then
				t = vgui.Create("DLabel",holder)
			end
			function holder:SetPunched()
				if t then
					t:SetColor(black)
				end
				self:SetColor(black)
				holder.Punched = true
			end
			function holder:SetPatched()
				if t then
					t:SetColor(gray)
				end
				self:SetColor(gray)
				holder.Patched = true
				holder.Punched = false
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
			return holder
		end
		local masks = {}
		for i=1,Columns,1 do
			masks[i] = math.ldexp(1,i-1)
		end
		local startx,starty = 0,((ysize+ypad)*2)+5
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
			x,y = 0,5
			startx,starty = x,y
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