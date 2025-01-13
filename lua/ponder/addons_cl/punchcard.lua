Ponder.API.RegisterAddon("Wire_PunchCard", {
    Name = "Wire Punchcards",
    ModelIcon = "models/punch_card/punch_card",
    Description = "Punchcards and their related machinery"
})


-- Don't know where else to put renderers, so here it goes.

local renderer = Ponder.API.NewRenderer("Wire_PunchCardVGUI")

renderer.RegisteredPanels = {}

--Noop, we're required to have these two functions
function renderer:Initialize(env)
end

function renderer:Render3D(env)
end

function renderer:Render2D(env)
    for k,_ in pairs(self.RegisteredPanels) do
        local panel = env:GetNamedModel(k)
        if not IsValid(panel) then
            self.RegisteredPanels[k] = nil
        else
            panel.Element:PaintManual()
        end
    end
end

function renderer:RegisterPanel(name)
    self.RegisteredPanels[name] = true
end