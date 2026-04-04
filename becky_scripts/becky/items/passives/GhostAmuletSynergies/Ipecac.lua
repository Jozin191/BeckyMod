-- local mod = BeckyMod
-- local enums = mod.Enums
-- local Callbacks = enums.Callbacks
-- local game = enums.Utils.Game

---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams)
    local player = fam.Player

    if not player then return end
    if not (tearParams.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE) then return end
    BeckyMod.Game:BombExplosionEffects(fam.Position, tearParams.TearDamage, tearParams.TearFlags, tearParams.TearColor)
end)