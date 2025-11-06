local mod = BeckyMod
local game = mod.Game
local pool = game:GetItemPool()
local BeckyID = Isaac.GetPlayerTypeByName("Becky")

local achievements = {
    ACHIEVEMENT_DEVILZONE_PRIME = Isaac.GetAchievementIdByName("Devilzon Prime"),
    ACHIEVEMENT_NIGHT_OF_THE_SLASHER = Isaac.GetAchievementIdByName("Night of the Slasher"),
    ACHIEVEMENT_DREAM_BANISHER = Isaac.GetAchievementIdByName("Dream Banisher"),
    ACHIEVEMENT_SINNER = Isaac.GetAchievementIdByName("Sinner"),
    ACHIEVEMENT_HOLY_BOOKMARK = Isaac.GetAchievementIdByName("Holy Bookmark"),
    ACHIEVEMENT_CHALICE = Isaac.GetAchievementIdByName("Chalice"),
    ACHIEVEMENT_COXINHA = Isaac.GetAchievementIdByName("Coxinha"),
    ACHIEVEMENT_CORPSE_TAG = Isaac.GetAchievementIdByName("Corpse Tag"),
    ACHIEVEMENT_SCARECROW = Isaac.GetAchievementIdByName("Scarecrow"),
    ACHIEVEMENT_NULL_BOMBS = Isaac.GetAchievementIdByName("Null Bombs"),
    ACHIEVEMENT_GHOST_AMULET = Isaac.GetAchievementIdByName("Ghost Amulet"),
    ACHIEVEMENT_DEAD_SOCKET = Isaac.GetAchievementIdByName("Dead Socket"),
    ACHIEVEMENT_DEAD_BATTERY = Isaac.GetAchievementIdByName("Dead Battery"),
    ACHIEVEMENT_BUTCHERS_COOKBOOK = Isaac.GetAchievementIdByName("Butchers Cookbook"),
    ACHIEVEMENT_TAINTED_BECKY = Isaac.GetAchievementIdByName("Tainted Becky"), -- Currently unused
}

local items = {
    --- Actives ---
    BUTCHERS_COOKBOOK = Isaac.GetItemIdByName("Butcher's Cookbook"),
    HAND_MADE_BIBLE = Isaac.GetItemIdByName("Hand Made Bible"),
    NIGHT_OF_THE_SLASHER = Isaac.GetItemIdByName("Night of the Slasher"),

    --- Passives --- 
    COXINHA = Isaac.GetItemIdByName("Coxinha"),
    DEAD_SOCKET = Isaac.GetItemIdByName("Dead Socket"),
    DEFILED_CHALICE = Isaac.GetItemIdByName("Defiled Chalice"),
    DREAM_BANISHER = Isaac.GetItemIdByName("Dream Banisher"),
    GHOST_AMULET = Isaac.GetItemIdByName("Ghost Amulet"),
    NULL_BOMBS = Isaac.GetItemIdByName("Null Bombs"),
    SCARECROW = Isaac.GetItemIdByName("Scarecrow"),
    SINNER = Isaac.GetItemIdByName("Sinner"),
}
local trinkets = {
    BURNING_FEATHER = Isaac.GetTrinketIdByName("Burning Feather"),
    CORPSE_TAG = Isaac.GetTrinketIdByName("Corpse Tag"),
    DEVILZON_PRIME = Isaac.GetTrinketIdByName("Devilzon Prime"),
    HOLY_BOOKMARK = Isaac.GetTrinketIdByName("Holy Bookmark"),
}

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
    if player ~= BeckyID then return end

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

    if Isaac.AllMarksFilled(BeckyID) == 2 then 
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