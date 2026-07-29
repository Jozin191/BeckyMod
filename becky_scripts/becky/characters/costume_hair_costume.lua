

local CostumesHair = {
    [CollectibleType.COLLECTIBLE_OUIJA_BOARD] = Isaac.GetNullItemIdByName("Ouijaboard_Costume handler"),
    [CollectibleType.COLLECTIBLE_DEAD_DOVE] = Isaac.GetNullItemIdByName("Dead Dove_Costume handler"),
    [CollectibleType.COLLECTIBLE_INFESTATION_2] = Isaac.GetNullItemIdByName("Infestation2_Costume handler"),
}


BeckyMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, itemID, charge, firstTime, slot, varData, player)
    local pType = player:GetPlayerType()
    if (pType == BeckyMod.Character.BECKY.PLAYERTYPE or pType == BeckyMod.Character.BECKY_B.PLAYERTYPE) and CostumesHair[itemID] then
        player:AddNullItemEffect(CostumesHair[itemID], true)
    end
end)



BeckyMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function(_, player, itemID, removePlayerForm, wispOrInnate)
    local pType = player:GetPlayerType()
    if (pType == BeckyMod.Character.BECKY.PLAYERTYPE or pType == BeckyMod.Character.BECKY_B.PLAYERTYPE) and CostumesHair[itemID] then
        player:GetEffects():RemoveNullEffect(CostumesHair[itemID], 1)
    end
end)