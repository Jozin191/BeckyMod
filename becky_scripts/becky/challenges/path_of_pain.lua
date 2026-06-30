local PATH_OF_PAIN = Isaac.GetChallengeIdByName("Path of pain")

local function addGulpedShit(_, player)
    if Isaac.GetChallenge() ~= PATH_OF_PAIN then return end
    
    --local list = player:GetSmeltedTrinketDesc(BeckyMod.Trinket.SANGUINE_FEATHER.ID)
    --if list and list.trinketAmount + list.goldenTrinketAmount > 0 then return end
    player:AddSmeltedTrinket(BeckyMod.Trinket.SANGUINE_FEATHER.ID)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, addGulpedShit)