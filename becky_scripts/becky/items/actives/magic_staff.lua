
local MAGIC_STAFF = {}

MAGIC_STAFF.ID = Isaac.GetItemIdByName("Magic Staff")
MAGIC_STAFF.TAINTED_BECKY_ID = MAGIC_STAFF.ID -1

BeckyMod.Item.MAGIC_STAFF = MAGIC_STAFF

function MAGIC_STAFF:UseItem(itemID, rng, player, useFlags, slot)

    if not BeckyMod.Spells:IsPlayerSelectingSpell(player) then
        BeckyMod.Spells:SetPlayerSelectSpell(player, true)
        player:AnimateCollectible(MAGIC_STAFF.ID, "LiftItem")
        player:SetItemState(MAGIC_STAFF.ID)
    else
        BeckyMod.Spells:SetPlayerSelectSpell(player, false)
        player:AnimateCollectible(MAGIC_STAFF.ID, "HideItem")
		player:ResetItemState()
    end

end

BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, MAGIC_STAFF.UseItem, MAGIC_STAFF.ID)
BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, MAGIC_STAFF.UseItem, MAGIC_STAFF.TAINTED_BECKY_ID)