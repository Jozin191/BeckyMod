local BUTCHERS_ID = Isaac.GetItemIdByName("Butcher's Cookbook")
local SAW_VARIANT = Isaac.GetEntityVariantByName("Butcher's Cookbook Sawblade")
local SAW_LIFETIME = 20 --in seconds
local SAW_DPS = 20

---@param player EntityPlayer
local function butchersUse(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
    local room = BeckyMod.Game:GetRoom()
    local gridIndex = room:GetGridIndex(player.Position)
    local pos = room:GetGridPosition(gridIndex)

    local saw = BeckyMod.Game:Spawn(EntityType.ENTITY_EFFECT, SAW_VARIANT, pos, Vector.Zero, player, 0, 1)
    saw:GetData().player = player

    Isaac.CreateTimer(function ()
        saw:Remove()
    end, SAW_LIFETIME * 30, 0, false)
end
BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, butchersUse, BUTCHERS_ID)

---@param effect EntityEffect
local function sawInit(_, effect)
    local sprite = effect:GetSprite()
    sprite:Play("Spawn")

end
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, sawInit, SAW_VARIANT)

---@param effect EntityEffect
local function sawUpdate(_, effect)
    local sprite = effect:GetSprite()

    if sprite:IsFinished("Spawn") then
        sprite:Play("Idle")
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:IsVulnerableEnemy() and entity.Position:Distance(effect.Position) < 40 then
            entity:TakeDamage(SAW_DPS/30, DamageFlag.DAMAGE_CLONES, EntityRef(effect:GetData(). player), 0)
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, sawUpdate, SAW_VARIANT)