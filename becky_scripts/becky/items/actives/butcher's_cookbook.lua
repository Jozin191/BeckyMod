local mod = BeckyMod
local enums = mod.Enums
local items = enums.CollectibleType
local game = enums.Utils.Game
local variants = enums.Variants
local SAW_LIFETIME = 20 --in seconds
local SAW_DPS = 20


---@param rngObj RNG
---@param player EntityPlayer
local function butchersUse(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
    local room = game:GetRoom()
    local gridIndex = room:GetGridIndex(player.Position)
    local pos = room:GetGridPosition(gridIndex)
    local saw = game:Spawn(EntityType.ENTITY_EFFECT, variants.SAWBLADE, pos, Vector.Zero, player, 0, rngObj:GetSeed())

    Isaac.CreateTimer(function ()
        saw:Remove()
    end, SAW_LIFETIME * 30, 0, false)
end
BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, butchersUse, items.BUTCHERS_COOKBOOK)

---@param effect EntityEffect
local function sawInit(_, effect)
    local sprite = effect:GetSprite()
    sprite:Play("Spawn")

end
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, sawInit, variants.SAWBLADE)

---@param effect EntityEffect
local function sawUpdate(_, effect)
    local sprite = effect:GetSprite()

    if sprite:IsFinished("Spawn") then
        sprite:Play("Idle")
    end

    local player = effect.SpawnerEntity:ToPlayer()

    if not player then return end

    for _, entity in ipairs(Isaac.FindInRadius(effect.Position, 40, EntityPartition.ENEMY)) do
        if not mod:IsEnemy(entity) then goto continue end
        entity:TakeDamage(SAW_DPS/30, DamageFlag.DAMAGE_CLONES, EntityRef(player), 0)      
        ::continue::
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, sawUpdate, variants.SAWBLADE)