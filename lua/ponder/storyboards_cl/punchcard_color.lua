local function load()
	local storyboard = Ponder.API.NewStoryboard("Wire_PunchCard", "Punchcards", "punchcard-color")
	storyboard:WithMenuName("wire_punchcard.ponder.card.color.menuname")
	storyboard:WithPlaybackName("wire_punchcard.ponder.card.color.playname")
	storyboard:WithModelIcon("models/punch_card/punch_card.mdl")
	storyboard:WithDescription("wire_punchcard.ponder.card.color.description")
	storyboard:WithIndexOrder(2)

	local function makeColorIdentity(n)
		return language.GetPhrase("wire_punchcard.ponder.card.color.punchcard_inspect").." "..language.GetPhrase("wire_punchcard.ponder.card.color.punchcard_color"..n)
	end

	local chapter1 = storyboard:Chapter()
	chapter1:AddInstruction("PlaceModel", {
		Name  = "Punchcard",
		IdentifyAs = makeColorIdentity(1),
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
		Text = "wire_punchcard.ponder.card.color.punchcard_text_1",
		Time = 0,
		Position = Vector(0, 0, 12.5),
	})
	chapter2:AddInstruction("Delay", {Time = 0, Length = 4})
	chapter2:AddInstruction("ChangeText", {
		Name = "punchcard_txt",
		Text = "wire_punchcard.ponder.card.color.punchcard_text_2",
	})
	chapter2:AddInstruction("ShowToolgun", {
		ToolName = "Color",
		Position = Vector(0, 0, 12.5),
	})
	chapter2:AddInstruction("Delay", {Time = 0, Length = 4})
	-- Colors sampled from pictures of IBM 5081 cards sourced from the Smithsonian Institution (thanks)
	local salmon = Color(242,130,146)
	local verde = Color(132,160,148)
	local marble_blue = Color(107,167,201)
	-- "haze" color sourced from image of an ebay seller's IBM 5081 card listing, more specifically their carpet(? it might be clown-vomit tile idk)
	local haze = Color(156,80,119,168)
	-- Punchcard entities just need a color
	local function GetColor(self)
		return self.Color
	end
	local fakeEnt1 = {
		Color = verde,
		GetColor = GetColor
	}
	local fakeEnt2 = {
		Color = marble_blue,
		GetColor = GetColor
	}
	local fakeEnt3 = {
		Color = salmon,
		GetColor = GetColor
	}
	local fakeEnt4 = {
		Color = haze,
		GetColor = GetColor
	}
	local function packColorData(color)
		return {
			bit.band(color.r,15),bit.rshift(bit.band(color.r,240),4),
			bit.band(color.g,15),bit.rshift(bit.band(color.g,240),4),
			bit.band(color.b,15),bit.rshift(bit.band(color.b,240),4),
			bit.band(color.a,15),bit.rshift(bit.band(color.a,240),4)
	}
	end
	chapter2:AddInstruction("ClickToolgun",{})
	chapter2:AddInstruction("ColorModel",{
		Target = "Punchcard",
		Color = fakeEnt1.Color,
	})
	chapter2:AddInstruction("punchcard_SetIdentity",{
		Target = "Punchcard",
		IdentifyAs = makeColorIdentity(2),
	})
	chapter2:AddInstruction("HideToolgun",{})
	chapter2:AddInstruction("Delay", {Time = 0, Length = 2})
	chapter2:AddInstruction("punchcard_OpenCardUI", {
		Target = "Punchcard",
		Name = "ui1",
		UserText = language.GetPhrase("wire_punchcard.ponder.card.color.punchcard_color2"),
		CardData = packColorData(fakeEnt1.Color),
	})
	chapter2:AddInstruction("Delay", {Time = 0, Length = 3})
	local chapter3 = storyboard:Chapter()
	chapter3:AddInstruction("HideText", {
		Name = "punchcard_txt",
	})
	chapter3:AddInstruction("ShowText", {
		Name = "punchcard_txt2",
		Text = "wire_punchcard.ponder.card.color.punchcard_text_3",
		Dimension = "2D",
		Position = Vector((ScrW()/3),(ScrH()/2)-200)
	})
	chapter3:AddInstruction("Delay", {Time = 0, Length = 8})
	chapter3:AddInstruction("HideText", {
		Name = "punchcard_txt2",
	})
	local chapter4 = storyboard:Chapter()
	chapter4:AddInstruction("RemovePanel",{Name = "ui1"})
	chapter4:AddInstruction("Delay", {Time = 0, Length = 2})
	chapter4:AddInstruction("MoveCameraLookAt", {Time = 0, Length = 0.8, Target = Vector(0, 0, 10), Angle = 45, Distance = 200, Height = 50})
	chapter4:AddInstruction("TransformModel", {
		Target = "Punchcard",
		Position = Vector(0, 15, 10),
		LocalToParent = false,
	})
	chapter4:AddInstruction("punchcard_PlaceModel", {
		Name  = "Punchcard_2",
		IdentifyAs = makeColorIdentity(3),
		Model = "models/punch_card/punch_card.mdl",
		Position = Vector(15, 0, 10),
		ComeFrom = Vector(0, 0, -32),
		RotateFrom = Angle(0,0,0),
		Angles = Angle(90,45,0),
		Color = fakeEnt2.Color,
		LocalTransform = false
	})
	chapter4:AddInstruction("punchcard_PlaceModel", {
		Name  = "Punchcard_3",
		IdentifyAs = "wire_punchcard.ponder.card.color.punchcard_inspect",
		Model = "models/punch_card/punch_card.mdl",
		Position = Vector(0, 15, 20),
		ComeFrom = Vector(0, 0, 32),
		RotateFrom = Angle(0,0,0),
		Angles = Angle(90,45,0),
		Color = fakeEnt3.Color,
		LocalTransform = false
	})
	chapter4:AddInstruction("punchcard_PlaceModel", {
		Name  = "Punchcard_4",
		IdentifyAs = makeColorIdentity(4),
		Model = "models/punch_card/punch_card.mdl",
		Position = Vector(15, 0, 20),
		ComeFrom = Vector(0, 0, 32),
		RotateFrom = Angle(0,0,0),
		Angles = Angle(90,45,0),
		Color = fakeEnt4.Color,
		LocalTransform = false
	})
	chapter4:AddInstruction("Delay", {Time = 0, Length = 0.5})
	chapter4:AddInstruction("ShowText", {
		Name = "punchcard_txt3",
		Text = "wire_punchcard.ponder.card.color.punchcard_text_4",
		Dimension = "2D",
		Position = Vector((ScrW()/3),(ScrH()/16))
	})
	chapter4:AddInstruction("Delay", {Time = 0, Length = 3})
	chapter4:AddInstruction("punchcard_OpenCardUI", {
		Target = "Punchcard",
		Name = "ui1";
		UserText = language.GetPhrase("wire_punchcard.ponder.card.color.punchcard_color2"),
		CardData = packColorData(fakeEnt1.Color),
		Position = Vector(ScrW()/1.6,ScrH()/2.2)
	})
	chapter4:AddInstruction("punchcard_OpenCardUI", {
		Target = "Punchcard_2",
		Name = "ui2";
		UserText = language.GetPhrase("wire_punchcard.ponder.card.color.punchcard_color3"),
		CardData = packColorData(fakeEnt2.Color),
		Position = Vector(ScrW()/5,ScrH()/2.2)
	})
	chapter4:AddInstruction("punchcard_OpenCardUI", {
		Target = "Punchcard_3",
		Name = "ui3";
		UserText = language.GetPhrase("wire_punchcard.ponder.card.color.punchcard_color4"),
		CardData = packColorData(fakeEnt3.Color),
		Position = Vector(ScrW()/1.6,ScrH()/6.25)
	})
	chapter4:AddInstruction("punchcard_OpenCardUI", {
		Target = "Punchcard_4",
		Name = "ui4";
		UserText = language.GetPhrase("wire_punchcard.ponder.card.color.punchcard_color5"),
		CardData = packColorData(fakeEnt4.Color),
		Position = Vector(ScrW()/5,ScrH()/6.25)
	})
	chapter4:AddInstruction("punchcard_OpenCardUI", {
		UserText = language.GetPhrase("wire_punchcard.ponder.card.color.punchcard_color6"),
		CardData = packColorData(Color(255,255,255,255)),
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
