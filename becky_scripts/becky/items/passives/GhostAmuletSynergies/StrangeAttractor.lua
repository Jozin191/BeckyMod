-- noop
local GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball")
local Game = Game()
---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam, tearParams)
    local player = fam.Player
    if tearParams.TearFlags & TearFlags.TEAR_ATTRACTOR == TearFlags.TEAR_ATTRACTOR then
        Game:UpdateStrangeAttractor(fam.Position, 15, 250) -- w nicalis
    end
end)