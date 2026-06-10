
local MAGIC_STAFF = {}

MAGIC_STAFF.ID = Isaac.GetItemIdByName("Magic Staff")
MAGIC_STAFF.TAINTED_BECKY_ID = Isaac.GetItemIdByName("​Magic Staff")
MAGIC_STAFF.SPELLING_ID = Isaac.GetItemIdByName("Spelling")

BeckyMod.Item.MAGIC_STAFF = MAGIC_STAFF


function MAGIC_STAFF:UseItem(itemID, rng, player, useFlags, slot)
    local isSellecting, isRandomSpells = BeckyMod.Spells:IsPlayerSelectingSpell(player), BeckyMod.Spells:IsPlayerSelectingSpell(player, BeckyMod.Spells.SpellSelectType.RANDOM_SPELLS)
    if isSellecting and not isRandomSpells then return {Discharge = false} end
    if not isSellecting then
        BeckyMod.Spells:SetPlayerSelectSpell(player, BeckyMod.Spells.SpellSelectType.RANDOM_SPELLS)
        player:AnimateCollectible(MAGIC_STAFF.SPELLING_ID, "LiftItem")
        player:SetItemState(MAGIC_STAFF.ID)
    else
        BeckyMod.Spells:SetPlayerSelectSpell(player, BeckyMod.Spells.SpellSelectType.NONE)
        player:AnimateCollectible(MAGIC_STAFF.SPELLING_ID, "HideItem")
		player:ResetItemState()
    end
    return {Discharge = false}
end

function MAGIC_STAFF:TBeckyUseItem(itemID, rng, player, useFlags, slot)
    local isSellecting, isNormalSpells = BeckyMod.Spells:IsPlayerSelectingSpell(player), BeckyMod.Spells:IsPlayerSelectingSpell(player, BeckyMod.Spells.SpellSelectType.NORMAL)
    if isSellecting and not isNormalSpells then return {Discharge = false} end

    if not isSellecting then
        BeckyMod.Spells:SetPlayerSelectSpell(player, BeckyMod.Spells.SpellSelectType.NORMAL)
        player:AnimateCollectible(MAGIC_STAFF.SPELLING_ID, "LiftItem")
        player:SetItemState(MAGIC_STAFF.TAINTED_BECKY_ID)
    else
        BeckyMod.Spells:SetPlayerSelectSpell(player, BeckyMod.Spells.SpellSelectType.NONE)
        player:AnimateCollectible(MAGIC_STAFF.SPELLING_ID, "HideItem")
		player:ResetItemState()
    end
    return {Discharge = false}
end

BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, MAGIC_STAFF.UseItem, MAGIC_STAFF.ID)
BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, MAGIC_STAFF.TBeckyUseItem, MAGIC_STAFF.TAINTED_BECKY_ID)