local BUTCHERS_ID = Isaac.GetItemIdByName("Butcher's Cookbook")
local SAW_VARIANT = Isaac.GetEntityVariantByName("Butcher's Cookbook Sawblade")
local SAW_LIFETIME = 20 --in seconds

---@param player EntityPlayer
local function butchersUse(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
    local room = BeckyMod.Game:GetRoom()
    local gridIndex = room:GetGridIndex(player.Position)
    local pos = room:GetGridPosition(gridIndex)

    local saw = BeckyMod.Game:Spawn(EntityType.ENTITY_EFFECT, SAW_VARIANT, pos, Vector.Zero, player, 0, 1)
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
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, sawUpdate, SAW_VARIANT)