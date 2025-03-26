local function load()
    local storyboard = Ponder.API.NewStoryboard("Wire_PunchCard", "Punchcard Devices", "punchcard-device-basics")
    storyboard:WithMenuName("wire_punchcard.ponder.device.basics.menuname")
    storyboard:WithPlaybackName("wire_punchcard.ponder.device.basics.playname")
    storyboard:WithModelIcon("models/props_lab/reciever01c.mdl")
    storyboard:WithDescription(language.GetPhrase("wire_punchcard.ponder.device.basics.description"))
    storyboard:WithIndexOrder(5)
    local chapter1 = storyboard:Chapter()
    chapter1:AddInstruction("MoveCameraLookAt", {Time = 0, Length = 1.6, Target = Vector(0, 0, 10), Angle = 45, Distance = 100, Height = 50})
    chapter1:AddInstruction("PlaceModel", {
        Name  = "Punchcard Device",
        IdentifyAs = "wire_punchcard.ponder.device.basics.device_inspect",
        Model = "models/props_lab/reciever01d.mdl",
        Position = Vector(0, 0, 10),
        ComeFrom = Vector(0, 0, 32),
        RotateFrom = Angle(0,0,0),
        Angles = Angle(0,45,0),
        LocalTransform = false
    })
    chapter1:AddInstruction("Delay", {Time = 0, Length = 1.5})

    chapter1:AddInstruction("ShowText", {
        Name = "punchcard_txt",
        Text = "wire_punchcard.ponder.device.basics.punchcard_text_1",
        Time = 0,
        Position = Vector(0, 0, 12.5),
    })
    chapter1:AddInstruction("Delay", {Time = 0, Length = 4})
    chapter1:AddInstruction("ChangeText", {
        Name = "punchcard_txt",
        Text = "wire_punchcard.ponder.device.basics.punchcard_text_2",
    })
    chapter1:AddInstruction("PlaceModel", {
        Name  = "Punchcard",
        IdentifyAs = "wire_punchcard.ponder.device.basics.punchcard_inspect",
        Model = "models/punch_card/punch_card.mdl",
        Position = Vector(0, 0, 15),
        ComeFrom = Vector(0, 0, 32),
        RotateFrom = Angle(0,0,0),
        Angles = Angle(90,45,0),
        LocalTransform = false
    })
    chapter1:AddInstruction("PlaceModel", {
        Name  = "",
        IdentifyAs = "wire_punchcard.ponder.device.basics.punchcard_inspect",
        Model = "models/punch_card/punch_card.mdl",
        Position = Vector(0, 0, 15),
        ComeFrom = Vector(0, 0, 32),
        RotateFrom = Angle(0,0,0),
        Angles = Angle(90,45,0),
        LocalTransform = false
    })
    chapter1:AddInstruction("Delay", {Time = 0, Length = 3})

    local chapter2 = storyboard:Chapter()
    chapter2:AddInstruction("Delay", {Time = 0, Length = 2})

    chapter2:AddInstruction("ChangeText", {
        Name = "punchcard_txt",
        Text = string.format(language.GetPhrase("wire_punchcard.ponder.device.basics.punchcard_text_3"),string.upper(input.LookupBinding("+walk")),string.upper(input.LookupBinding("+use"))),
    })
    chapter2:AddInstruction("TransformModel", {
        Target = "Punchcard",
        Position = Vector(0, 0, 15),
        Rotation = Angle(0,135,90),
        Length = 0,
        LocalToParent = false,
    })
    chapter2:AddInstruction("Delay", {Time = 0, Length = 4})
    local chapter3 = storyboard:Chapter()
    chapter3:AddInstruction("HideText", {
        Name = "punchcard_txt",
        Text = "wire_punchcard.ponder.card.operation.punchcard_text_3",
    })
    chapter3:AddInstruction("ShowText", {
        Name = "punchcard_txt2",
        Text = "wire_punchcard.ponder.device.basics.punchcard_text_4",
        Dimension = "2D",
        Position = Vector((ScrW()/3),(ScrH()/2)-200)
    })

    chapter3:AddInstruction("PlacePanel", {
        Name = "punchcard_ui",
        Type = "DPanel",
    })
    chapter3:AddInstruction("Delay", {Time = 0, Length = 3})
    chapter3:AddInstruction("ChangeText", {
        Name = "punchcard_txt2",
        Text = "wire_punchcard.ponder.device.basics.punchcard_text_5",
    })
    chapter3:AddInstruction("Delay", {Time = 0, Length = 4})
    chapter3:AddInstruction("ShowText", {
        Name = "punchcard_column",
        Text = "wire_punchcard.ponder.device.basics.punchcard_text_6",
        Time = 0,
        Dimension = "2D",
        Position = Vector((ScrW()/2)-425, (ScrH()/2)+120, 0),
    })
    chapter3:AddInstruction("ShowText", {
        Name = "punchcard_row",
        Text = "wire_punchcard.ponder.device.basics.punchcard_text_7",
        Time = 0,
        Dimension = "2D",
        Position = Vector((ScrW()/2)+175, (ScrH()/2)+140, 0),
    })
    chapter3:AddInstruction("Delay", {Time = 0, Length = 4})
    chapter3:AddInstruction("ShowText", {
        Name = "punchcard_bye",
        Text = "wire_punchcard.ponder.continuenext",
        Time = 0,
        Dimension = "2D",
        Position = Vector((ScrW()/2)+200,(ScrH()/2)-80)
    })
end

Wire_PunchCardUI_LoadHook(load)
