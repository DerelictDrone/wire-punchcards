local function load()
	local storyboard = Ponder.API.NewStoryboard("Wire_PunchCard", "Punchcards", "punchcard-reading")
	storyboard:WithMenuName("wire_punchcard.ponder.card.reading.menuname")
	storyboard:WithPlaybackName("wire_punchcard.ponder.card.reading.playname")
	storyboard:WithModelIcon("models/punch_card/punch_card.mdl")
	storyboard:WithDescription("wire_punchcard.ponder.card.reading.description")
	storyboard:WithIndexOrder(3)
	local chapter1 = storyboard:Chapter()
	chapter1:AddInstruction("PlaceModel", {
		Name  = "Punchcard",
		IdentifyAs = "wire_punchcard.ponder.card.reading.punchcard_inspect",
		Model = "models/punch_card/punch_card.mdl",
		Position = Vector(0, 0, 10),
		ComeFrom = Vector(0, 0, 32),
		RotateFrom = Angle(0,0,0),
		Angles = Angle(90,45,0),
		LocalTransform = false
	})
	chapter1:AddInstruction("MoveCameraLookAt", {Time = 0, Length = 0.8, Target = Vector(0, 0, 10), Angle = 20, Distance = 100, Height = 50})
	
	local chapter2 = storyboard:Chapter()
	chapter2:AddInstruction("ShowText", {
		Name = "punchcard_txt",
		Text = "wire_punchcard.ponder.card.reading.punchcard_text_1",
		Time = 0,
		Position = Vector(0, 0, 12.5),
	})
	chapter2:AddInstruction("Delay", {Time = 0, Length = 4})
	chapter2:AddInstruction("ChangeText", {
		Name = "punchcard_txt",
		Text = string.format(language.GetPhrase("wire_punchcard.ponder.card.reading.punchcard_text_2"),string.upper(input.LookupBinding("+walk")),string.upper(input.LookupBinding("+use"))),
	})
	chapter2:AddInstruction("Delay", {Time = 0, Length = 4})
	-- Punchcard entities just need a color
	local fakeEnt = {
		Color = Color(255,255,255,255)
	}
	function fakeEnt:GetColor()
		return self.Color
	end
	chapter2:AddInstruction("ClickToolgun",{})
	chapter2:AddInstruction("PlacePanel", {
		Name = "punchcard_ui",
		Type = "DPanel",
	})
	chapter2:AddInstruction("punchcard_RunOnVGUI", {
		Target = "punchcard_ui",
		Function = Wire_PunchCardUI.SetupCard,
		Arguments = {
			Wire_PunchCardUI,
			fakeEnt,
			"ibm5081",
			false,
			4,
			16,
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			"Ponder Card"
		},
		PassTargetAsArgument = 2,
	})
	chapter2:AddInstruction("punchcard_RunOnVGUI", {
		Target = "punchcard_ui",
		Function = "SizeToChildren",
		Arguments = {
			true,true
		},
		PassTargetAsArgument = 1,
	})
	chapter2:AddInstruction("punchcard_RunOnVGUI", {
		Target = "punchcard_ui",
		Function = "Center",
		Arguments = {},
		PassTargetAsArgument = 1,
	})
	chapter2:AddInstruction("punchcard_RunOnVGUI", {
		Target = "punchcard_ui",
		Function = function(card)
			card.TransparentMaterial = nil
		end,
		Arguments = {},
		PassTargetAsArgument = 1,
	})
	chapter2:AddInstruction("Delay", {Time = 0, Length = 3})
	chapter2:AddInstruction("HideToolgun",{})
	local chapter3 = storyboard:Chapter()
	chapter3:AddInstruction("HideText", {
		Name = "punchcard_txt",
	})
	chapter3:AddInstruction("ShowText", {
		Name = "punchcard_txt2",
		Text = "wire_punchcard.ponder.card.reading.punchcard_text_3",
		Dimension = "2D",
		Position = Vector((ScrW()/3),(ScrH()/2)-200)
	})
	chapter3:AddInstruction("Delay", {Time = 0, Length = 7})
	chapter3:AddInstruction("ChangeText", {
		Name = "punchcard_txt2",
		Text = string.format(language.GetPhrase("wire_punchcard.ponder.card.reading.punchcard_text_4")),
	})
	chapter3:AddInstruction("Delay", {Time = 0, Length = 4})
	chapter3:AddInstruction("punchcard_Pow2Gen",
		{
			Name = "Punchcard_Column",
			Length = 4,
			Powers = 4,
			StartPower = 0,
			Position = Vector((ScrW()/3)+40,(ScrH()/2)-50),
			SpaceBetween = Vector(0,50,0)
		}
	)
	-- chapter3:AddInstruction("punchcard_PunchMany", {
	-- 	Target = "punchcard_ui",
	-- 	Mode = "SetPatched",
	-- 	Rows = {
	-- 		{8,3}
	-- 	},
	-- 	Length = 0.5,
	-- })
	-- chapter3:AddInstruction("Delay", {Time = 0, Length = 4})
	chapter3:AddInstruction("Delay", {Time = 0, Length = 4})
	local chapter4 = storyboard:Chapter()
	chapter4:AddInstruction("Delay", {Time = 0, Length = 3})
	chapter4:AddInstruction("ChangeText", {
		Name = "punchcard_txt2",
		Text = string.format(language.GetPhrase("wire_punchcard.ponder.card.reading.punchcard_text_5")),
	})
	chapter4:AddInstruction("punchcard_PunchMany", {
		Target = "punchcard_ui",
		Mode = "SetPunched",
		Rows = {
			{1,1},
			{2,2},
			{3,1},
			{3,2},
			{4,3},
			{5,1},
			{5,2},
			{5,3},
			{5,4},
		},
		Length = 5,
	})
	chapter4:AddInstruction("Delay", {Time = 0, Length = 7})
	chapter4:AddInstruction("ShowText", {
		Name = "punchcard_spoiler_warning",
		Text = "wire_punchcard.ponder.card.reading.punchcard_text_6",
		Dimension = "2D",
		Position = Vector((ScrW()/1.6),(ScrH()/2)-160)
	})
	chapter4:AddInstruction("punchcard_Countdown",{
		Length = 10,
		Position = Vector((ScrW()/1.6),(ScrH()/2)-80)
	})
	local chapter5 = storyboard:Chapter()
	chapter5:AddInstruction("Delay", {Time = 0, Length = 1})
	chapter5:AddInstruction("HideText",{
		Name = "punchcard_spoiler_warning"
	})
	chapter5:AddInstruction("ShowText",{
		Name = "punchcard_value",
		Text = "1",
		Dimension = "2D",
		Position = Vector((ScrW()/2)-135,(ScrH()/2)+150),
	})
	chapter5:AddInstruction("Delay", {Time = 0, Length = 1})
	chapter5:AddInstruction("ChangeText",{
		Name = "punchcard_value",
		Text = "1,2",
	})
	chapter5:AddInstruction("Delay", {Time = 0, Length = 1})
	chapter5:AddInstruction("ChangeText",{
		Name = "punchcard_value",
		Text = "1,2,3",
	})
	chapter5:AddInstruction("Delay", {Time = 0, Length = 1})
	chapter5:AddInstruction("ChangeText",{
		Name = "punchcard_value",
		Text = "1,2,3,4",
	})
	chapter5:AddInstruction("Delay", {Time = 0, Length = 1})
	chapter5:AddInstruction("ChangeText",{
		Name = "punchcard_value",
		Text = "1,2,3,4,15",
	})
	chapter5:AddInstruction("Delay", {Time = 0, Length = 1})
	chapter5:AddInstruction("ChangeText",{
		Name = "punchcard_value",
		Text = "1,2,3,4,15, "..language.GetPhrase("wire_punchcard.ponder.card.reading.punchcard_text_7"),
	})
	chapter5:AddInstruction("Delay", {Time = 0, Length = 4})
	chapter5:AddInstruction("ShowText", {
		Name = "punchcard_bye",
		Text = "wire_punchcard.ponder.continuenext",
		Dimension = "2D",
		Position = Vector((ScrW()/2)+200,(ScrH()/2)-80)
	})
	chapter5:AddInstruction("Delay", {Time = 0, Length = 1})
end

Wire_PunchCardUI_LoadHook(load)
