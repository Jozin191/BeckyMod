local PATH_OF_PAIN = Isaac.GetChallengeIdByName("Path of pain")

local function addGulpedShit(_, IsContinued)
    if Isaac.GetChallenge() ~= PATH_OF_PAIN or IsContinued then return end

    for _, player in ipairs(PlayerManager:GetPlayers()) do
        player:AddSmeltedTrinket(BeckyMod.Trinket.SANGUINE_FEATHER.ID)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, addGulpedShit)