local t = {}

t.SUBTYPE = Isaac.GetEntitySubTypeByName("Dead Battery")
t.REPLACE_CHANCE = 0.1

---@param pickup EntityPickup
---@param collider Entity
BeckyMod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, function (_, pickup, collider)
    if pickup.SubType ~= t.SUBTYPE or not pickup:IsDead() then return end
    local player = collider:ToPlayer() if not player then return end
    player:GetEffects():AddCollectibleEffect(BeckyMod.Item.DEAD_SOCKET.ID, nil, 6)
end, PickupVariant.PICKUP_LIL_BATTERY)

---@param variant PickupVariant
---@param subtype BatterySubType
BeckyMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, function (_, _, variant, subtype)
    if variant ~= PickupVariant.PICKUP_LIL_BATTERY or subtype == t.SUBTYPE then return end
    local room = BeckyMod.Game:GetRoom() if not room:IsFirstVisit() and room:GetFrameCount() == -1 then return end
    if Isaac.GetPlayer():GetCollectibleRNG(BeckyMod.Item.DEAD_SOCKET.ID):RandomFloat() > t.REPLACE_CHANCE then return end
    return {variant, t.SUBTYPE}
end)