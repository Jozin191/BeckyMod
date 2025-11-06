local mod = BeckyMod
local enums = mod.Enums
local utils = enums.Utils
local game = utils.Game
local achievements = enums.Achievements
local players = enums.PlayerType
local items = enums.CollectibleType
local trinkets = enums.TrinketType
local pool = game:GetItemPool()

local unlocks = {}
local UnlockTable = {
    Becky = {
        [CompletionType.MOMS_HEART] = {
            Unlock = achievements.ACHIEVEMENT_DEVILZONE_PRIME,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Trinket = trinkets.DEVILZON_PRIME
        },
        [CompletionType.ISAAC] = {
            Unlock = achievements.ACHIEVEMENT_SINNER,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Item = items.SINNER,
        },
        [CompletionType.SATAN] = {
            Unlock = achievements.ACHIEVEMENT_DREAM_BANISHER,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Item = items.DREAM_BANISHER,
        },
        [CompletionType.BOSS_RUSH] = {
            Unlock = achievements.NIGHT_OF_THE_SLASHER,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Trinket = trinkets.NIGHT_OF_THE_SLASHER
        },
        [CompletionType.BLUE_BABY] = {
            Unlock = achievements.HOLY_BOOKMARK,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Trinket = trinkets.HOLY_BOOKMARK
        },
        [CompletionType.LAMB] = {
            Unlock = achievements.ACHIEVEMENT_CHALICE,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Item = items.DEFILED_CHALICE
        },
        [CompletionType.MEGA_SATAN] = {
            Unlock = achievements.ACHIEVEMENT_DEAD_BATTERY,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            -- Pickup = , -- Temporarily on hold
        },
        [CompletionType.ULTRA_GREED] = {
            Unlock = achievements.ACHIEVEMENT_COXINHA,
            Difficulty = Difficulty.DIFFICULTY_GREED,
            Item = items.COXINHA,
        },
        [CompletionType.HUSH] = {
            Unlock = achievements.ACHIEVEMENT_DEAD_SOCKET,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Item = items.DEAD_SOCKET,
        },
        [CompletionType.ULTRA_GREEDIER] = {
            Unlock = achievements.ACHIEVEMENT_CORPSE_TAG,
            Difficulty = Difficulty.DIFFICULTY_GREEDIER,
            Trinket = trinkets.CORPSE_TAG,
        },
        [CompletionType.DELIRIUM] = {
            Unlock = achievements.ACHIEVEMENT_BUTCHERS_COOKBOOK,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Item = items.BUTCHERS_COOKBOOK,
        },
        [CompletionType.MOTHER] = {
            Unlock = achievements.ACHIEVEMENT_SCARECROW,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Item = items.SCARECROW,
        },
        [CompletionType.BEAST] = {
            Unlock = achievements.ACHIEVEMENT_NULL_BOMBS,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Item = items.NULL_BOMBS,
        },
    },
}

function unlocks:CheckStartUnlocks()
    for _, charTable in pairs(UnlockTable) do     
        for _, tab in pairs(charTable) do
            if Isaac.GetPersistentGameData():Unlocked(tab.Unlock) then goto continue end
            if tab.Item then
                pool:RemoveCollectible(tab.Item)
            end
            if tab.Trinket then
                pool:RemoveTrinket(tab.Trinket)
            end
            ::continue::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, unlocks.CheckStartUnlocks)

---@param mark CompletionType
---@param player PlayerType
function unlocks:OnTriggerCompletion(mark, player)
    if player ~= players.BECKY then return end

    local pgd = Isaac.GetPersistentGameData()
    local difficulty = game.Difficulty
    local unlock = UnlockTable.Becky[mark]

    if not unlock then return end

    if difficulty == Difficulty.DIFFICULTY_GREEDIER then
        pgd:TryUnlock(achievements.ACHIEVEMENT_COXINHA)
        pgd:TryUnlock(achievements.ACHIEVEMENT_CORPSE_TAG)
    end
        
    if difficulty ~= unlock.Difficulty then return end
    pgd:TryUnlock(unlock.Unlock)

    if Isaac.AllMarksFilled(players.BECKY) == 2 then 
        pgd:TryUnlock(achievements.ACHIEVEMENT_SALT_HEART)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_MARK_GET, unlocks.OnTriggerCompletion)

-- Tainted Becky isn't here so we comment this for a while

-- local taintedAchievement = {
--     [players.PLAYER_EDITH] = {unlock = achievements.ACHIEVEMENT_TAINTED_EDITH, gfx = "gfx/characters/costumes/characterTaintedEdith.png"}
-- }
-- function mod:SlotUpdate(slot)
--     if not slot:GetSprite():IsFinished("PayPrize") then return end
--     local d = slot:GetData().Tainted
--     if not d then return end
--     Isaac.GetPersistentGameData():TryUnlock(d.unlock)
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, mod.SlotUpdate, 14)

-- function mod:HiddenCloset()
--     if level:GetStage() ~= LevelStage.STAGE8 then return end
--     if level:GetCurrentRoomDesc().SafeGridIndex ~= 94 then return end
--     if game:AchievementUnlocksDisallowed() then return end

--     local p = Isaac.GetPlayer():GetPlayerType()
--     local d = taintedAchievement[p]
    
--     if not d then return end
--     if Isaac.GetPersistentGameData():Unlocked(d.unlock) then return end

--     if game:GetRoom():IsFirstVisit() then
--         for _, k in ipairs(Isaac.FindByType(17)) do
--             k:Remove()
--         end
--         for _, i in ipairs(Isaac.FindByType(5)) do
--             i:Remove()
--         end
--         local s = Isaac.Spawn(6, 14, 0, game:GetRoom():GetCenterPos(), Vector.Zero, nil)
--         s:GetSprite():ReplaceSpritesheet(0, d.gfx, true)
--         s:GetData().Tainted = d
--     else
--         for _, s in ipairs(Isaac.FindByType(6, 14)) do
--             s:GetSprite():ReplaceSpritesheet(0, d.gfx, true)
--             s:GetData().Tainted = d
--         end
--     end
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.HiddenCloset)