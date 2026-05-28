local SPELL_COST = 30
local CanPickupGridList = {}

local game = BeckyMod.Game

local SPEED = Vector(10,0)
local COOLDOWN = 90
local ATTACKING_COOLDOWN = 7
local PROJ_SPEED = Vector(15,0)

local NULL_ITEM_ID = Isaac.GetNullItemIdByName("SPELL_Summon_BroberBobby")
local NULL_ITEM_ID2 = Isaac.GetNullItemIdByName("SPELL_Summon_2")
local NULL_ITEM_ID3 = Isaac.GetNullItemIdByName("SPELL_Summon_3")
local NULL_ITEM_ID4 = Isaac.GetNullItemIdByName("SPELL_Summon_4")
BeckyMod.Spells.NULL_ITEMS.SUMMON = NULL_ITEM_ID
BeckyMod.Spells.NULL_ITEMS.SUMMON2 = NULL_ITEM_ID2
BeckyMod.Spells.NULL_ITEMS.SUMMON3 = NULL_ITEM_ID3
BeckyMod.Spells.NULL_ITEMS.SUMMON4 = NULL_ITEM_ID4

local VALID_FAMS = {
    [FamiliarVariant.BROTHER_BOBBY] = true,
    [FamiliarVariant.LIL_HAUNT] = true,
    [FamiliarVariant.PUNCHING_BAG] = true,
    [FamiliarVariant.MULTIDIMENSIONAL_BABY] = true,
}

BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
    player:CheckFamiliar(
        FamiliarVariant.BROTHER_BOBBY,
        player:GetEffects():GetNullEffectNum(NULL_ITEM_ID),
        player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BROTHER_BOBBY),
        nil,
        120
    )
    player:CheckFamiliar(
        FamiliarVariant.LIL_HAUNT,
        player:GetEffects():GetNullEffectNum(NULL_ITEM_ID2),
        player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LIL_HAUNT),
        nil,
        120
    )
    player:CheckFamiliar(
        FamiliarVariant.PUNCHING_BAG,
        player:GetEffects():GetNullEffectNum(NULL_ITEM_ID3),
        player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PUNCHING_BAG),
        nil,
        120
    )
    player:CheckFamiliar(
        FamiliarVariant.MULTIDIMENSIONAL_BABY,
        player:GetEffects():GetNullEffectNum(NULL_ITEM_ID4),
        player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MULTIDIMENSIONAL_BABY),
        nil,
        120
    )
end, CacheFlag.CACHE_FAMILIARS)

BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
    if fam.SubType ~= 120 then return end
    if VALID_FAMS[fam.Variant] then
        local color = fam:GetSprite().Color
        color:SetColorize(1, 1, 1, 1)
        color.A = 0.85
        fam:GetSprite().Color = color
        BeckyMod.GetEntData(fam).NoGrantMana = true
    end
end)


local function fun(player)
    local data = BeckyMod.GetEntData(player)
    if data.MagicStaff_SelectSpellDir == nil then
        data.MagicStaff_SelectSpellDir = { Type = BeckyMod.Spells.SpellType.SUMMON }
        return
    end
    --if data.MagicStaff_SelectSpellDir == nil then
    --    data.MagicStaff_SelectSpellDir = { Type = BeckyMod.Spells.SpellType.SUMMON, Choices = {
    --        [Direction.LEFT] = 2, --Shooting familiar
    --        [Direction.RIGHT] = 3,--Mr Me
    --    } }
    --    return
    --end
    local effects = player:GetEffects()

    if effects:HasNullEffect(NULL_ITEM_ID) then
        effects:RemoveNullEffect(NULL_ITEM_ID, -1)
    elseif effects:HasNullEffect(NULL_ITEM_ID2) then
        effects:RemoveNullEffect(NULL_ITEM_ID2, -1)
    elseif effects:HasNullEffect(NULL_ITEM_ID3) then
        effects:RemoveNullEffect(NULL_ITEM_ID3, -1)
    elseif effects:HasNullEffect(NULL_ITEM_ID4) then
        effects:RemoveNullEffect(NULL_ITEM_ID4, -1)
    end


    if data.MagicStaff_SelectSpellDir.Dir == Direction.RIGHT then
        player:AddNullItemEffect(NULL_ITEM_ID2)
        --player:UseActiveItem(CollectibleType.COLLECTIBLE_MR_ME, UseFlag.USE_MIMIC)
    elseif data.MagicStaff_SelectSpellDir.Dir == Direction.UP then
        player:AddNullItemEffect(NULL_ITEM_ID3)
    elseif data.MagicStaff_SelectSpellDir.Dir == Direction.DOWN then
        player:AddNullItemEffect(NULL_ITEM_ID4)
    else
        player:AddNullItemEffect(NULL_ITEM_ID)
    end
    --local save = BeckyMod:RunSave(player)
    --save.ManaCharge = save.ManaCharge - SPELL_COST


    data.MagicStaff_SelectSpellDir = nil
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.SUMMON,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST
}



--[[
tint : 1 | 1 | 1 | 1
colorize : 1.8 | 0.9 | 0.3 | 1
offset : 0.3 | 0 | 0
]]