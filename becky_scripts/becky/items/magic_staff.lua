
local MAGIC_STAFF = {}

MAGIC_STAFF.ID = Isaac.GetItemIdByName("Magic Staff")

BeckyMod.Item.MAGIC_STAFF = MAGIC_STAFF
local staffConfig = Isaac.GetItemConfig():GetCollectible(MAGIC_STAFF.ID)

BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, rng, player, useFlags, slot)

    if not BeckyMod.Spells:IsPlayerSelectingSpell(player) then
        BeckyMod.Spells:SetPlayerSelectSpell(player, true)
        player:AnimateCollectible(MAGIC_STAFF.ID, "LiftItem")
        player:SetItemState(MAGIC_STAFF.ID)
    else
        BeckyMod.Spells:SetPlayerSelectSpell(player, false)
        player:AnimateCollectible(MAGIC_STAFF.ID, "HideItem")
		player:ResetItemState()
    end

end, MAGIC_STAFF.ID)