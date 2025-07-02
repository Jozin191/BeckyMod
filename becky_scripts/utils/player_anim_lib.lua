--[[
    Player Animation Library by Kerkel
    Version 1.0.2
    TODO
    | RGON costume animation support akin to Hemoptysis
]]

local VERSION = 3

if PlayerAnimLib then
    if PlayerAnimLib.Internal.VERSION > VERSION then return end
    for _, v in ipairs(PlayerAnimLib.Internal.CallbackEntries) do
        PlayerAnimLib:RemoveCallback(v[1], v[3])
    end
end

PlayerAnimLib = RegisterMod("Player Animation Library", 1)
PlayerAnimLib.Internal = {}
PlayerAnimLib.Internal.VERSION = VERSION
PlayerAnimLib.Internal.CallbackEntries = {
    {
        ModCallbacks.MC_POST_PLAYER_UPDATE,
        CallbackPriority.IMPORTANT,
        ---@param player EntityPlayer
        function (_, player)
            local data = PlayerAnimLib:GetData(player)

            if data.Loaded and (not player:GetSprite():IsPlaying(data.Anim) or player:IsExtraAnimationFinished()) then
                data.Path = nil
                data.Anim = nil
                data.Loaded = nil
                PlayerAnimLib:Load(player, data.Default)
            end
        end,
    }
}

for _, v in ipairs(PlayerAnimLib.Internal.CallbackEntries) do
    PlayerAnimLib:AddPriorityCallback(v[1], v[2], v[3], v[4])
end

---@type table<SkinColor, string>
PlayerAnimLib.COLOR_TO_SUFFIX = {
    [SkinColor.SKIN_PINK] = ".png",
    [SkinColor.SKIN_WHITE] = "_white.png",
    [SkinColor.SKIN_BLACK] = "_black.png",
    [SkinColor.SKIN_BLUE] = "_blue.png",
    [SkinColor.SKIN_RED] = "_red.png",
    [SkinColor.SKIN_GREEN] = "_green.png",
    [SkinColor.SKIN_GREY] = "_grey.png",
    [SkinColor.SKIN_SHADOW] = "_shadow.png",
}

---@type table<PlayerType, string>
PlayerAnimLib.PLAYER_TO_SKIN = {
    [PlayerType.PLAYER_ISAAC] = "gfx/characters/costumes/character_001_isaac.png",
    [PlayerType.PLAYER_MAGDALENE] = "gfx/characters/costumes/character_002_magdalene.png",
    [PlayerType.PLAYER_CAIN] = "gfx/characters/costumes/character_003_cain.png",
    [PlayerType.PLAYER_JUDAS] = "gfx/characters/costumes/character_004_judas.png",
    [PlayerType.PLAYER_EVE] = "gfx/characters/costumes/character_005_eve.png",
    [PlayerType.PLAYER_BLUEBABY] = "gfx/characters/costumes/character_006_bluebaby.png",
    [PlayerType.PLAYER_SAMSON] = "gfx/characters/costumes/character_007_samson.png",
    [PlayerType.PLAYER_AZAZEL] = "gfx/characters/costumes/character_008_azazel.png",
    [PlayerType.PLAYER_EDEN] = "gfx/characters/costumes/character_009_eden.png",
    [PlayerType.PLAYER_LAZARUS] = "gfx/characters/costumes/character_009_lazarus.png",
    [PlayerType.PLAYER_LAZARUS2] = "gfx/characters/costumes/character_010_lazarus2.png",
    [PlayerType.PLAYER_THELOST] = "gfx/characters/costumes/character_012_lost.png",
    [PlayerType.PLAYER_BLACKJUDAS] = "gfx/characters/costumes/character_013_blackjudas.png",
    [PlayerType.PLAYER_LILITH] = "gfx/characters/costumes/character_014_lilith.png",
    [PlayerType.PLAYER_KEEPER] = "gfx/characters/costumes/character_015_keeper.png",
    [PlayerType.PLAYER_APOLLYON] = "gfx/characters/costumes/character_016_apollyon.png",
    [PlayerType.PLAYER_THEFORGOTTEN] = "gfx/characters/costumes/character_017_theforgotten.png",
    [PlayerType.PLAYER_THESOUL] = "gfx/characters/costumes/character_018_thesoul.png",
    [PlayerType.PLAYER_BETHANY] = "gfx/characters/costumes/character_001x_bethany.png",
    [PlayerType.PLAYER_JACOB] = "gfx/characters/costumes/character_002x_jacob.png",
    [PlayerType.PLAYER_ESAU] = "gfx/characters/costumes/character_003x_esau.png",
    [PlayerType.PLAYER_ISAAC_B] = "gfx/characters/costumes/character_001b_isaac.png",
    [PlayerType.PLAYER_MAGDALENE_B] = "gfx/characters/costumes/character_002b_magdalene.png",
    [PlayerType.PLAYER_CAIN_B] = "gfx/characters/costumes/character_003b_cain.png",
    [PlayerType.PLAYER_JUDAS_B] = "gfx/characters/costumes/character_004b_judas.png",
    [PlayerType.PLAYER_EVE_B] = "gfx/characters/costumes/character_005b_eve.png",
    [PlayerType.PLAYER_BLUEBABY_B] = "gfx/characters/costumes/character_006b_bluebaby.png",
    [PlayerType.PLAYER_SAMSON_B] = "gfx/characters/costumes/character_007b_samson.png",
    [PlayerType.PLAYER_AZAZEL_B] = "gfx/characters/costumes/character_008b_azazel.png",
    [PlayerType.PLAYER_EDEN_B] = "gfx/characters/costumes/character_009_eden.png",
    [PlayerType.PLAYER_LAZARUS_B] = "gfx/characters/costumes/character_009b_lazarus.png",
    [PlayerType.PLAYER_LAZARUS2_B] = "gfx/characters/costumes/character_009b_lazarus2.png",
    [PlayerType.PLAYER_THELOST_B] = "gfx/characters/costumes/character_012b_lost.png",
    [PlayerType.PLAYER_LILITH_B] = "gfx/characters/costumes/character_014b_lilith.png",
    [PlayerType.PLAYER_KEEPER_B] = "gfx/characters/costumes/character_015b_keeper.png",
    [PlayerType.PLAYER_APOLLYON_B] = "gfx/characters/costumes/character_016b_apollyon.png",
    [PlayerType.PLAYER_THEFORGOTTEN_B] = "gfx/characters/costumes/character_017b_theforgotten.png",
    [PlayerType.PLAYER_THESOUL_B] = "gfx/characters/costumes/character_018b_thesoul.png",
    [PlayerType.PLAYER_BETHANY_B] = "gfx/characters/costumes/character_018b_bethany.png",
    [PlayerType.PLAYER_JACOB_B] = "gfx/characters/costumes/character_019b_jacob.png",
    [PlayerType.PLAYER_JACOB2_B] = "gfx/characters/costumes/character_019b_jacob2.png",
}

---@type table<PlayerType, boolean>
PlayerAnimLib.NO_SKIN_ALT = {
    [PlayerType.PLAYER_BLUEBABY] = true,
    [PlayerType.PLAYER_AZAZEL] = true,
    [PlayerType.PLAYER_THELOST] = true,
    [PlayerType.PLAYER_BLACKJUDAS] = true,
    [PlayerType.PLAYER_LILITH] = true,
    [PlayerType.PLAYER_KEEPER] = true,
    [PlayerType.PLAYER_APOLLYON] = true,
    [PlayerType.PLAYER_THEFORGOTTEN] = true,
    [PlayerType.PLAYER_THESOUL] = true,
    [PlayerType.PLAYER_ESAU] = true,
    [PlayerType.PLAYER_JUDAS_B] = true,
    [PlayerType.PLAYER_BLUEBABY_B] = true,
    [PlayerType.PLAYER_AZAZEL_B] = true,
    [PlayerType.PLAYER_THELOST_B] = true,
    [PlayerType.PLAYER_LILITH_B] = true,
    [PlayerType.PLAYER_KEEPER_B] = true,
    [PlayerType.PLAYER_APOLLYON_B] = true,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = true,
    [PlayerType.PLAYER_THESOUL_B] = true,
    [PlayerType.PLAYER_LAZARUS2_B] = true,
    [PlayerType.PLAYER_JACOB2_B] = true,
}

if REPENTOGON then
    for i = PlayerType.NUM_PLAYER_TYPES, EntityConfig.GetMaxPlayerType() do
        local config = EntityConfig.GetPlayer(i)
        if config and config:GetSkinColor() ~= -1 then
            PlayerAnimLib.NO_SKIN_ALT[i] = true
        end
    end
end

---@param player EntityPlayer
function PlayerAnimLib:GetData(player)
    local data = player:GetData()

    data.__PAL = data.__PAL or {
        Default = "gfx/001.000_Player.anm2"
    }

    ---@class PALData
    ---@field Path string
    ---@field Anim string
    ---@field Loaded boolean
    ---@field Default string
    return data.__PAL
end

---@param player EntityPlayer
function PlayerAnimLib:GetSkinPath(player)
    local type = player:GetPlayerType()

    return PlayerAnimLib.NO_SKIN_ALT[type] and (
        REPENTOGON and EntityConfig.GetPlayer(type):GetSkinPath()
        or PlayerAnimLib.PLAYER_TO_SKIN[type]
        or PlayerAnimLib.PLAYER_TO_SKIN[PlayerType.PLAYER_ISAAC]
    ) or string.gsub(
        REPENTOGON and EntityConfig.GetPlayer(type):GetSkinPath()
        or PlayerAnimLib.PLAYER_TO_SKIN[type]
        or PlayerAnimLib.PLAYER_TO_SKIN[PlayerType.PLAYER_ISAAC],
        ".png",
        PlayerAnimLib.COLOR_TO_SUFFIX[player:GetBodyColor()]
    )
end

---@param player EntityPlayer
function PlayerAnimLib:GetDefaultAnm2(player)
    return PlayerAnimLib:GetData(player).Default
end

---@param player EntityPlayer
function PlayerAnimLib:Reload(player)
    local sprite = player:GetSprite()
    local path = PlayerAnimLib:GetSkinPath(player)

    for layer = PlayerSpriteLayer.SPRITE_GLOW, PlayerSpriteLayer.SPRITE_BACK do
        if layer ~= PlayerSpriteLayer.SPRITE_GHOST then
            sprite:ReplaceSpritesheet(layer, path)
        end
    end

    sprite:LoadGraphics()
end

---@param player EntityPlayer
---@param path string
---@param skip? boolean
function PlayerAnimLib:Load(player, path, skip)
    player:GetSprite():Load(path, true)
    if skip then return end
    PlayerAnimLib:Reload(player)
end

---@param player EntityPlayer
---@param path string
---@param anim string
---@param custom? boolean
function PlayerAnimLib:Play(player, path, anim, custom)
    local data = PlayerAnimLib:GetData(player)

    data.Path = anim
    data.Anim = anim
    data.Loaded = true

    PlayerAnimLib:Load(player, path, custom)

    player:PlayExtraAnimation(anim)
end

---@param player EntityPlayer
---@param path string
function PlayerAnimLib:SetDefaultAnm2(player, path)
    local data = PlayerAnimLib:GetData(player)

    data.Default = path

    if not data.Loaded then
        PlayerAnimLib:Load(player, path)
    end
end