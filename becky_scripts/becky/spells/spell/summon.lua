local SPELL_COST = 30
local CanPickupGridList = {}

local game = BeckyMod.Game

local SPEED = Vector(10,0)
local COOLDOWN = 90
local ATTACKING_COOLDOWN = 7
local PROJ_SPEED = Vector(15,0)

local NULL_ITEM_ID = Isaac.GetNullItemIdByName("SPELL_Summon_BroberBobby")
BeckyMod.Spells.NULL_ITEMS.SUMMON = NULL_ITEM_ID

BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
    player:CheckFamiliar(
        FamiliarVariant.BROTHER_BOBBY,
        player:GetEffects():GetNullEffectNum(NULL_ITEM_ID),
        player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BROTHER_BOBBY),
        nil,
        120
    )
end, CacheFlag.CACHE_FAMILIARS)

BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
    if fam.SubType ~= 120 then return end
    local color = fam:GetSprite().Color
    color:SetColorize(1, 1, 1, 1)
    color.A = 0.85
    fam:GetSprite().Color = color
end, FamiliarVariant.BROTHER_BOBBY)


local function fun(player)
    local data = BeckyMod.GetEntData(player)
    if data.MagicStaff_SelectSpellDir == nil then
        data.MagicStaff_SelectSpellDir = { Type = BeckyMod.Spells.SpellType.SUMMON, Choices = {
            [Direction.LEFT] = 2, --Shooting familiar
            [Direction.RIGHT] = 3,--Mr Me
        } }
        return
    end

    if data.MagicStaff_SelectSpellDir.Dir == Direction.RIGHT then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_MR_ME, UseFlag.USE_MIMIC)
    else
        player:AddNullItemEffect(NULL_ITEM_ID)
    end

    data.MagicStaff_SelectSpellDir = nil
end

local function canSelectFun(player, manaLeft)
    --local data = BeckyMod.GetEntData(player)
    --return (data.SpellsData and data.SpellsData.SummonActive) or 100 - (data.MaxManaOffset or 0) > SPELL_COST
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.SUMMON,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = 0
}



--[[
tint : 1 | 1 | 1 | 1
colorize : 1.8 | 0.9 | 0.3 | 1
offset : 0.3 | 0 | 0
]]