local GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball")
local Game = Game()
---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam, tearParams)
    local player = fam.Player
    if tearParams.TearFlags & TearFlags.TEAR_ATTRACTOR == TearFlags.TEAR_ATTRACTOR then
        local power = 15
        if fam.State > 0 then
            power = 20
        end
        Game:UpdateStrangeAttractor(fam.Position, power, 250) -- w nicalis
    end
end)