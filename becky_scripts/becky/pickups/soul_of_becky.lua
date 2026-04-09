local SOUL_OF_BECKY = {}
    
BeckyMod.Pickup.SOUL_OF_BECKY = SOUL_OF_BECKY

SOUL_OF_BECKY.ID = Isaac.GetCardIdByName("Soul of Becky_BeckyMod")

function SOUL_OF_BECKY:UseCard(CardId, player, useFlags)
end

BeckyMod:AddCallback(ModCallbacks.MC_USE_CARD, SOUL_OF_BECKY.UseCard, SOUL_OF_BECKY.ID)