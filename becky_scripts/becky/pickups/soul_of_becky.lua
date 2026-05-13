local SOUL_OF_BECKY = {}
    
BeckyMod.Pickup.SOUL_OF_BECKY = SOUL_OF_BECKY

SOUL_OF_BECKY.ID = Isaac.GetCardIdByName("Soul of Becky_BeckyMod")
SOUL_OF_BECKY.NULL_ITEM_ID = Isaac.GetNullItemIdByName("SOUL_OF_BECKY_SELECT_STATE")

function SOUL_OF_BECKY:PreUseCard(CardId, player, useFlags)
    if BeckyMod.Spells:IsPlayerSelectingSpell(player) then return true end
end
function SOUL_OF_BECKY:UseCard(CardId, player, useFlags)
    player:AddNullItemEffect(SOUL_OF_BECKY.NULL_ITEM_ID)
end

function SOUL_OF_BECKY:PlayerAddEffect(player, itemConfig, addCostume, count)
    if itemConfig:IsNull() and itemConfig.ID == SOUL_OF_BECKY.NULL_ITEM_ID then
        BeckyMod.Spells:SetPlayerSelectSpell(player, BeckyMod.Spells.SpellSelectType.RANDOM_NO_UNSELECT)
        player:AnimateCard(SOUL_OF_BECKY.ID, "LiftItem")
    end
end
function SOUL_OF_BECKY:PlayerRemoveEffect(player, itemConfig, count)
    if itemConfig:IsNull() and itemConfig.ID == SOUL_OF_BECKY.NULL_ITEM_ID and not player:GetEffects():HasNullEffect(SOUL_OF_BECKY.NULL_ITEM_ID) then
        player:AnimateCard(SOUL_OF_BECKY.ID, "HideItem")
        BeckyMod.Spells:SetPlayerSelectSpell(player, BeckyMod.Spells.SpellSelectType.NONE)
    end
end


BeckyMod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, SOUL_OF_BECKY.PreUseCard, SOUL_OF_BECKY.ID)
BeckyMod:AddCallback(ModCallbacks.MC_USE_CARD, SOUL_OF_BECKY.UseCard, SOUL_OF_BECKY.ID)
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_EFFECT, SOUL_OF_BECKY.PlayerAddEffect)
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, SOUL_OF_BECKY.PlayerRemoveEffect)