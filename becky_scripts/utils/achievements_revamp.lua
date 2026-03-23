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
    ACHIEVEMENT_CHALICE = Isaac.GetAchievementIdByName("Defiled Chalice"),
    ACHIEVEMENT_COXINHA = Isaac.GetAchievementIdByName("Coxinha"),
    ACHIEVEMENT_CORPSE_TAG = Isaac.GetAchievementIdByName("Corpse Tag"),
    ACHIEVEMENT_SCARECROW = Isaac.GetAchievementIdByName("Scarecrow"),
    ACHIEVEMENT_NULL_BOMBS = Isaac.GetAchievementIdByName("Null Bombs"),
    ACHIEVEMENT_GHOST_AMULET = Isaac.GetAchievementIdByName("Ghost Amulet"),
    ACHIEVEMENT_DEAD_SOCKET = Isaac.GetAchievementIdByName("Dead Socket"),
    ACHIEVEMENT_DEAD_BATTERY = Isaac.GetAchievementIdByName("Dead Battery"),
    ACHIEVEMENT_BUTCHERS_COOKBOOK = Isaac.GetAchievementIdByName("Butcher's Cookbook"),
    ACHIEVEMENT_TAINTED_BECKY = Isaac.GetAchievementIdByName("Tainted Becky"), -- Currently unused
}

local items = {
    --- Actives ---
    BUTCHERS_COOKBOOK = Isaac.GetItemIdByName("Butcher's Cookbook"),
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
    CORPSE_TAG = Isaac.GetTrinketIdByName("Corpse Tag"),
    DEVILZON_PRIME = Isaac.GetTrinketIdByName("Devilzon Prime"),
    HOLY_BOOKMARK = Isaac.GetTrinketIdByName("Holy Bookmark"),
}
local pickup = {
	DEAD_BATTERY = Isaac.GetEntityVariantByName("Dead Battery")
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
            Unlock = achievements.ACHIEVEMENT_NIGHT_OF_THE_SLASHER,
            Difficulty = Difficulty.DIFFICULTY_HARD,
            Trinket = trinkets.NIGHT_OF_THE_SLASHER
        },
        [CompletionType.BLUE_BABY] = {
            Unlock = achievements.ACHIEVEMENT_HOLY_BOOKMARK,
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

---@return table<TrinketType, Achievement>
local function GetModdedTrinketsUnlocks()
    local tab = {}

    for _, stuff in pairs(UnlockTable.Becky) do
        if stuff.Trinket then
            tab[stuff.Trinket] = stuff.Unlock
        end
    end

    return tab
end

---@param pickup EntityPickup
function unlocks:OnPickupInit(pickup)
    local pgd = Isaac.GetPersistentGameData()

    if not pickup then return end

    if pickup.Variant == PickupVariant.PICKUP_TRINKET then
        local unlocks = GetModdedTrinketsUnlocks()[pickup.SubType]
        if unlocks then
            if not pgd:Unlocked(unlocks) then
                pickup:Morph(pickup.Type, pickup.Variant, 0)
            end
        end
    end

    if pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY and pickup.SubType == Isaac.GetEntitySubTypeByName("Dead Battery") then
        if not pgd:Unlocked(achievements.ACHIEVEMENT_DEAD_BATTERY) then
            pickup:Morph(pickup.Type, 50, 1, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, unlocks.OnPickupInit)

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
        pgd:TryUnlock(achievements.ACHIEVEMENT_GHOST_AMULET)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_MARK_GET, unlocks.OnTriggerCompletion)



function mod:SlotUpdate(slot)
    if Isaac.GetPlayer(0):GetPlayerType() ~= mod.Character.BECKY.PLAYERTYPE or Isaac.GetPersistentGameData():Unlocked(achievements.ACHIEVEMENT_TAINTED_BECKY) then return end
    if not slot:GetSprite():IsFinished("PayPrize") then return end
    Isaac.GetPersistentGameData():TryUnlock(achievements.ACHIEVEMENT_TAINTED_BECKY)
end
mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, mod.SlotUpdate, SlotVariant.HOME_CLOSET_PLAYER)

function mod:SpawnClosetSlot(_, t, v, s)
    if game:AchievementUnlocksDisallowed() then return end
    if t ~= 6 or v ~= SlotVariant.HOME_CLOSET_PLAYER then return end
    local level = mod.Level()
    if level:GetStage() == LevelStage.STAGE8 and level:GetCurrentRoomIndex() == 94 then
        if Isaac.GetPlayer(0):GetPlayerType() ~= mod.Character.BECKY.PLAYERTYPE or Isaac.GetPersistentGameData():Unlocked(achievements.ACHIEVEMENT_TAINTED_BECKY) then return end
        return {t, v, s}
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, mod.SpawnClosetSlot)

function mod:OnClosetIsaacInit(slot)
    if game:AchievementUnlocksDisallowed() then return end
    if Isaac.GetPlayer(0):GetPlayerType() ~= mod.Character.BECKY.PLAYERTYPE or Isaac.GetPersistentGameData():Unlocked(achievements.ACHIEVEMENT_TAINTED_BECKY) then return end
    local sp = slot:GetSprite()
    sp:ReplaceSpritesheet(0, "gfx/characters/costumes/character_beckyb.png", true)
end
mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, mod.OnClosetIsaacInit, SlotVariant.HOME_CLOSET_PLAYER)