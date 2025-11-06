local game = Game()

BeckyMod.Enums = {
    Utils = {
        Game = game,
        SFX = SFXManager(),
        Level = game:GetLevel()
    },
    PlayerType = {
        BECKY = Isaac.GetPlayerTypeByName("Becky"),
        BECKY_B = Isaac.GetPlayerTypeByName("Becky", true)
    },
    NullItemID = {
        BECKY_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/becky_hair.anm2"),
        BECKY_BODY = Isaac.GetCostumeIdByPath("gfx/characters/becky_body.anm2"),
        NIGHT_OF_THE_SLASHER = Isaac.GetCostumeIdByPath("gfx/characters/night_of_the_slasher.anm2"),
    },
    CollectibleType = {
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
    },
    TrinketType = {
        BURNING_FEATHER = Isaac.GetTrinketIdByName("Burning Feather"),
        CORPSE_TAG = Isaac.GetTrinketIdByName("Corpse Tag"),
        DEVILZON_PRIME = Isaac.GetTrinketIdByName("Devilzon Prime"),
        HOLY_BOOKMARK = Isaac.GetTrinketIdByName("Holy Bookmark"),
    },
    Variants = {
        SAWBLADE = Isaac.GetEntityVariantByName("Butcher's Cookbook Sawblade"),
        GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball"),
        NULL_BOMB = Isaac.GetEntityVariantByName("Null Bomb"),
        SINNER = Isaac.GetEntityVariantByName("Becky Sinner"),
    },
    Achievements = {
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
    },
    Callbacks = {
        --- Called every time the ghost hits an enemy
        --- * Familiar: The ghost entity
        --- * Entity: The entity hit by the ghost
        ON_GHOST_HIT_ENEMY = "BeckyMod_ON_GHOST_HIT_ENEMY",
    }
}