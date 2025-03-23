local DEAD_BATTERY = {}

BeckyMod.Item.DEAD_BATTERY = DEAD_BATTERY

DEAD_BATTERY.ID = Isaac.GetItemIdByName("Dead Battery")
DEAD_BATTERY.GHOST_CHARGE = 6
DEAD_BATTERY.ACTIVE_CHARGE = 6

---@param new boolean
---@param player EntityPlayer
function DEAD_BATTERY:OnAdd(_, _, new, _, _, player)
    if not new then return end

    player:GetEffects():AddCollectibleEffect(BeckyMod.Item.DEAD_SOCKET.ID, nil, DEAD_BATTERY.GHOST_CHARGE)

    local config = Isaac.GetItemConfig()

    for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do
        local id = player:GetActiveItem(slot)
        local item = config:GetCollectible(id)

        if item and item.MaxCharges > 0 and item.ChargeType ~= 2 then
            player:AddActiveCharge(
                item.ChargeType == 1 and item.MaxCharges or DEAD_BATTERY.ACTIVE_CHARGE,
                slot,
                true,
                true,
                true
            )
            break
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, DEAD_BATTERY.OnAdd, BeckyMod.Item.DEAD_BATTERY.ID)