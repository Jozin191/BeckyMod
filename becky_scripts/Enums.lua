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
    Callbacks = {
        --- Called every time the ghost hits an enemy
        --- * Familiar: The ghost entity
        --- * Entity: The entity hit by the ghost
        ON_GHOST_HIT_ENEMY = "BeckyMod_ON_GHOST_HIT_ENEMY",
    }
}