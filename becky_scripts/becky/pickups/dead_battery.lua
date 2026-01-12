local t = {}

local mod = BeckyMod
local enums = mod.Enums
local items = enums.CollectibleType
local utils = enums.Utils
local game = utils.Game

BeckyMod.Pickup.DEAD_BATTERY = t

t.SUBTYPE = Isaac.GetEntitySubTypeByName("Dead Battery")
t.REPLACE_CHANCE = 0.1

---@param pickup EntityPickup
---@param collider Entity
BeckyMod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, function (_, pickup, collider)
    local player = collider:ToPlayer()    
    local sprite = pickup:GetSprite()

    if not player then return end
    if player:GetEffects():GetCollectibleEffectNum(items.DEAD_SOCKET) >= player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) then return end
    if sprite:IsPlaying("Collect") then return end
    if pickup.SubType ~= t.SUBTYPE then return end
    if pickup:IsDead() then return end

    pickup:PlayPickupSound()
    player:GetEffects():AddCollectibleEffect(items.DEAD_SOCKET, nil, 6)

    sprite:Play("Collect", true)
end, PickupVariant.PICKUP_LIL_BATTERY)

---@param pickup EntityPickup
BeckyMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    local sprite = pickup:GetSprite()

    if sprite:GetAnimation() == "Collect" then
        pickup:SetShadowSize(0)
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end

    if not sprite:IsFinished("Collect") then return end    
    pickup:Kill()
end, PickupVariant.PICKUP_LIL_BATTERY)

---@param variant PickupVariant
---@param subtype BatterySubType
BeckyMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, function (_, _, variant, subtype)
    if not Isaac.GetPersistentGameData():Unlocked(Isaac.GetAchievementIdByName("Dead Battery")) then return end
    if variant ~= PickupVariant.PICKUP_LIL_BATTERY or subtype == t.SUBTYPE then return end
    local room = game:GetRoom() if not (room:IsFirstVisit() and room:GetFrameCount() == -1)
    or Isaac.GetPlayer():GetCollectibleRNG(items.DEAD_SOCKET):RandomFloat() > t.REPLACE_CHANCE then return end
    return {variant, t.SUBTYPE}
end)