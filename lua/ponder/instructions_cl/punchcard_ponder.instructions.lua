local RunOnUI = Ponder.API.NewInstruction("punchcard_RunOnVGUI")
RunOnUI.Target = ""
RunOnUI.Function = function() end
RunOnUI.Arguments = {}
RunOnUI.PassTargetAsArgument = false

-- ??? unpack not defined unless I do this
local unpack = unpack
local function setupArgs(args,target,pass_as)
    local new = table.Pack(unpack(args))
    if pass_as then
        table.insert(new,pass_as,target)
    end
    return unpack(new)
end

function RunOnUI:First(playback)
    local env = playback.Environment
    -- local target = env:GetNamedModel(self.Target.."_vgui")
    local target = env:GetNamedObject("VGUIPanel", self.Target)
    if not IsValid(target) or not self.Function then return end
    if type(self.Function) == "string" then
        target[self.Function](setupArgs(self.Arguments,target,self.PassTargetAsArgument))
    else
        self.Function(setupArgs(self.Arguments,target,self.PassTargetAsArgument))
    end
end

local GetEntColor = Ponder.API.NewInstruction("punchcard_GetEntColor")
GetEntColor.Target = ""

function GetEntColor:First(playback)
    local env = playback.Environment
    local target = env:GetNamedModel(self.Target)
    if not IsValid(target) then return end
    local color = target:GetColor()
    self.Color:SetUnpacked(color.r,color.g,color.b,color.a)
end

local SetIdentity = Ponder.API.NewInstruction("punchcard_SetIdentity")
SetIdentity.Target = ""
SetIdentity.IdentifyAs = ""
function SetIdentity:First(playback)
    local env = playback.Environment
    local target = env:GetNamedModel(self.Target)
    if not IsValid(target) then return end
    target.IdentifyAs = language.GetPhrase(self.IdentifyAs)
end

local CreateInput = Ponder.API.NewInstructionMacro("punchcard_CreateWireInput")
CreateInput.Target = ""
CreateInput.IdentifyAs = ""
function CreateInput:Run(chapter, parameters)
    chapter:AddInstruction("PlaceModel",{
        Name  = parameters.Name,
        IdentifyAs = "wire_punchcard.ponder.generic.wireinput",
        Model = parameters.Model or "models/fasteroid/led_mini.mdl",
        Position = parameters.Position,
        Parent = parameters.Parent,
        LocalTransform = true
    })
end

local CreateOutput = Ponder.API.NewInstructionMacro("punchcard_CreateWireOutput")
CreateOutput.Target = ""
CreateOutput.IdentifyAs = ""
function CreateOutput:Run(chapter, parameters)
    chapter:AddInstruction("PlaceModel",{
        Name  = parameters.Name,
        IdentifyAs = "wire_punchcard.ponder.generic.wireoutput",
        Model = parameters.Model or "models/fasteroid/led_mini.mdl",
        Position = parameters.Position,
        Parent = parameters.Parent,
        LocalTransform = true
    })
end

local SetInput = Ponder.API.NewInstructionMacro("punchcard_SetInput")
SetInput.Target = ""
SetInput.IdentifyAs = ""
function SetInput:Run(chapter, parameters)
    
end


local PunchMany = Ponder.API.NewInstructionMacro("punchcard_PunchMany")

local sfx = {
    SetPunched = {
        name = "paper-punch-%d.wav",
        count = 7,
    },
    SetPatched = {
        name = "paper-patch-%d.wav",
        count = 18
    }
}

function PunchMany:Run(chapter, parameters)
    local time = 0
    local punches = #parameters.Rows
    local mySfx = sfx[parameters.Mode]
    if (not parameters.Silent) and parameters.Length == 0 and mySfx then
        chapter:AddInstruction("PlaySound",{
            Time = 0,
            Sound = string.format(mySfx.name,1)
        })
    end
    for ind,i in ipairs(parameters.Rows) do
        time = time + (parameters.Length/punches)
        chapter:AddInstruction("punchcard_RunOnVGUI",
        {
            Time = time,
            Target=parameters.Target,
            Function=parameters.Mode.."_UI",
            Arguments = {
                i[2],i[1]
            },
            PassTargetAsArgument=1
        }
        )
        if mySfx and not (parameters.Silent or parameters.Length == 0) then
            chapter:AddInstruction("PlaySound",
            {
                Time = time,
                Sound = string.format(mySfx.name,(ind%mySfx.count)+1)
            }
        )
        end
    end
end

local Pow2Gen = Ponder.API.NewInstructionMacro("punchcard_Pow2Gen")
function Pow2Gen:Run(chapter, parameters)
    local time = 0
    local powers = parameters.Powers
    local startpower = parameters.StartPower
    local position = Vector(parameters.Position)
    local change = Vector(parameters.SpaceBetween)
    for pow=startpower,startpower+(powers-1),1 do
        time = time + (parameters.Length/powers)
        local curPos = Vector(position)
        position:Add(change)
        chapter:AddInstruction("ShowText",
        {
            Time = time,
            Name = parameters.Name.."_"..pow,
            Text = string.format(parameters.Format or "pow(%d,%d)=%d",2,pow,math.pow(2,pow)),
            Position = curPos,
            Dimension=parameters.Dimension or "2D"
        }
        )
    end
end

local Pow2GenCleanup = Ponder.API.NewInstructionMacro("punchcard_Pow2GenCleanup")
function Pow2GenCleanup:Run(chapter, parameters)
    local time = 0
    local powers = parameters.Powers
    local startpower = parameters.StartPower
    for pow=startpower,startpower+powers,1 do
        time = time + (parameters.Length/powers)
        chapter:AddInstruction("HideText",
        {
            Time = time,
            Name = parameters.Name.."_"..pow,
        }
        )
    end
end

local Countdown = Ponder.API.NewInstructionMacro("punchcard_Countdown")
function Countdown:Run(chapter, parameters)
    local seconds = parameters.Length
    local name = parameters.Name or "punchcard_Countdown"
    chapter:AddInstruction("ShowText",
    {
        Time = 0,
        Name = name,
        Text = tostring(seconds),
        Position = Vector(parameters.Position),
        Dimension=parameters.Dimension or "2D"
    })
    for t=seconds,1,-1 do
        chapter:AddInstruction("ChangeText",
        {
            Name = name,
            Text = tostring(t),
        }
        )
        chapter:AddInstruction("Delay",
        {
            Length = 1,
        }
        )
    end
    chapter:AddInstruction("HideText",{
        Name = name
    })
end

-- portmanteau of placemodel & changemodel, may gain additional functionality later
local PlaceModel = Ponder.API.NewInstructionMacro("punchcard_PlaceModel")
function PlaceModel:Run(chapter, parameters)
    local target = parameters.Name
    chapter:AddInstruction("PlaceModel", parameters)
    if parameters.Color then
        chapter:AddInstruction("ColorModel", {
            Target = parameters.Name,
            Color = parameters.Color
        })
    end
end

local OpenCardUI = Ponder.API.NewInstructionMacro("punchcard_OpenCardUI")
OpenCardUI.Name = "punchcard_ui"
OpenCardUI.CardModel = "ibm5081"
OpenCardUI.UserText = "Ponder Card"
OpenCardUI.CardColumns = 4
OpenCardUI.CardRows = 16
function OpenCardUI:Run(chapter, parameters)
    setmetatable(parameters,{__index=self})
    local color = Color(255,255,255,255)
    if not parameters.CardData then
        parameters.CardData = {}
    end
    if not parameters.CardPatches then
        parameters.CardPatches = {}
    end
    if #parameters.CardData ~= parameters.CardRows then
        for i=#parameters.CardData,parameters.CardRows-1,1 do
            table.insert(parameters.CardData,0)
        end
    end
    if #parameters.CardPatches ~= parameters.CardRows then
        for i=#parameters.CardPatches,parameters.CardRows-1,1 do
            table.insert(parameters.CardPatches,0)
        end
    end
    chapter:AddInstruction("PlacePanel", {
        Name = parameters.Name,
        Type = "DPanel",
    })
    chapter:AddInstruction("punchcard_GetEntColor", {
        Target = parameters.Target,
        Color = color
    })
    local fakeEnt = {Color = color}
    function fakeEnt:GetColor() return self.Color end
    chapter:AddInstruction("punchcard_RunOnVGUI", {
        Target = parameters.Name,
        Function = Wire_PunchCardUI.SetupCard,
        Arguments = {
            Wire_PunchCardUI,
            fakeEnt,
            parameters.CardModel,
            false,
            parameters.CardColumns,
            parameters.CardRows,
            parameters.CardData,
            parameters.CardPatches,
            parameters.UserText,
            true
        },
        PassTargetAsArgument = 2,
    })
    chapter:AddInstruction("punchcard_RunOnVGUI", {
        Target = parameters.Name,
        Function = "SizeToChildren",
        Arguments = {
            true,true
        },
        PassTargetAsArgument = 1,
    })
    if not parameters.Position then
        chapter:AddInstruction("punchcard_RunOnVGUI", {
            Target = parameters.Name,
            Function = "Center",
            Arguments = {},
            PassTargetAsArgument = 1,
        })
    else
        chapter:AddInstruction("punchcard_RunOnVGUI", {
            Target = parameters.Name,
            Function = "SetPos",
            Arguments = {
                parameters.Position.x,
                parameters.Position.y,
            },
            PassTargetAsArgument = 1,
        })
    end
end

