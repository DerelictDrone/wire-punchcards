local function load()
	local storyboard = Ponder.API.NewStoryboard("Wire_PunchCard", "Punchcards", "punchcard-overpunch")
	storyboard:WithMenuName("wire_punchcard.ponder.card.overpunch.menuname")
	storyboard:WithPlaybackName("wire_punchcard.ponder.card.overpunch.playname")
	storyboard:WithModelIcon("models/punch_card/punch_card.mdl")
	storyboard:WithDescription("wire_punchcard.ponder.card.overpunch.description")
	storyboard:WithIndexOrder(2)
	local chapter1 = storyboard:Chapter()
	chapter1:AddInstruction("PlaceModel", {
		Name  = "Punchcard",
		IdentifyAs = "wire_punchcard.ponder.card.overpunch.punchcard_inspect",
		Model = "models/punch_card/punch_card.mdl",
		Position = Vector(0, 0, 10),
		ComeFrom = Vector(0, 0, 32),
		RotateFrom = Angle(0,0,0),
		Angles = Angle(90,45,0),
		LocalTransform = false
	})
	chapter1:AddInstruction("MoveCameraLookAt", {Time = 0, Length = 0.8, Target = Vector(0, 0, 10), Angle = 45, Distance = 100, Height = 50})
	
	local chapter2 = storyboard:Chapter()
	chapter2:AddInstruction("ShowText", {
		Name = "punchcard_txt",
		Text = "wire_punchcard.ponder.card.overpunch.punchcard_text_1",
		Time = 0,
		Position = Vector(0, 0, 12.5),
	})
	chapter2:AddInstruction("Delay", {Time = 0, Length = 4})
	chapter2:AddInstruction("ChangeText", {
		Name = "punchcard_txt",
		Text = "wire_punchcard.ponder.card.overpunch.punchcard_text_2",
	})
	chapter2:AddInstruction("Delay", {Time = 0, Length = 4})
	-- Punchcard entities just need a color
	local fakeEnt = {
		Color = Color(255,255,255,255)
	}
	function fakeEnt:GetColor()
		return self.Color
	end
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
			"ibm5081op",
			false,
			6,
			16,
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
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
	local chapter3 = storyboard:Chapter()
	chapter3:AddInstruction("HideText", {
		Name = "punchcard_txt",
	})
	chapter3:AddInstruction("ShowText", {
		Name = "punchcard_txt2",
		Text = "wire_punchcard.ponder.card.overpunch.punchcard_text_3",
		Dimension = "2D",
		Position = Vector((ScrW()/3),(ScrH()/2)-200)
	})
	chapter3:AddInstruction("Delay", {Time = 0, Length = 4})
	chapter3:AddInstruction("punchcard_Pow2Gen",
		{
			Name = "Punchcard_Column",
			Length = 4,
			Powers = 2,
			StartPower = 4,
			Position = Vector((ScrW()/3)+40,(ScrH()/2)-140),
			SpaceBetween = Vector(0,50,0)
		}
	)
	chapter3:AddInstruction("Delay", {Time = 0, Length = 8})
	local chapter4 = storyboard:Chapter()
	chapter4:AddInstruction("Delay", {Time = 0, Length = 3})
	chapter4:AddInstruction("ChangeText", {
		Name = "punchcard_txt2",
		Text = string.format(language.GetPhrase("wire_punchcard.ponder.card.overpunch.punchcard_text_4")),
	})
	chapter4:AddInstruction("punchcard_PunchMany", {
		Target = "punchcard_ui",
		Mode = "SetPunched",
		Rows = {
			{1,5},
			{2,6},
			{3,5},
			{4,6},
			{5,5},
			{6,6},
			{7,5},
			{8,6},
			{9,5},
			{10,6},
			{11,5},
			{12,6},
			{13,5},
			{14,6},
			{15,5},
			{16,6},
			{1,6},
			{2,5},
			{3,6},
			{4,5},
			{5,6},
			{6,5},
			{7,6},
			{8,5},
			{9,6},
			{10,5},
			{11,6},
			{12,5},
			{13,6},
			{14,5},
			{15,6},
			{16,5},
		},
		Length = 5,
	})
	chapter4:AddInstruction("punchcard_RunOnVGUI", {
		Time = 2,
		Target = "punchcard_ui",
		Function = "UpdateUserText",
		Arguments = {"Help!!"},
		PassTargetAsArgument = 1,
	})
	chapter4:AddInstruction("Delay", {Time = 0, Length = 7})
	chapter4:AddInstruction("ShowText", {
		Name = "punchcard_bye",
		Text = "wire_punchcard.ponder.continuenext",
		Dimension = "2D",
		Position = Vector((ScrW()/2)+200,(ScrH()/2)-80)
	})
	chapter4:AddInstruction("Delay", {Time = 0, Length = 1})
end

Wire_PunchCardUI_LoadHook(load)
