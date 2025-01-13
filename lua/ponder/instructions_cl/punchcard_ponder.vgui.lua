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
