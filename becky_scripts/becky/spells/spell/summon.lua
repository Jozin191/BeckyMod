local SPELL_COST = 50
local CanPickupGridList = {}

local game = BeckyMod.Game

local SPEED = Vector(10,0)
local COOLDOWN = 90
local ATTACKING_COOLDOWN = 7
local PROJ_SPEED = Vector(15,0)


local function fun(player)
    local data = player:GetData()
    data.SpellsData = data.SpellsData or {}

    data.SpellsData.SummonActive = (not data.SpellsData.SummonActive)
    if data.SpellsData.SummonActive then
        --player:CheckFamiliar(BeckyMod.Spells.ENTITIES.POLTY_FAM.Variant, 1, player:GetCollectibleRNG(BeckyMod.Item.MAGIC_STAFF.ID))
        data.MaxManaOffset = (data.MaxManaOffset or 0) + SPELL_COST
    else
        --player:CheckFamiliar(BeckyMod.Spells.ENTITIES.POLTY_FAM.Variant, 0, player:GetCollectibleRNG(BeckyMod.Item.MAGIC_STAFF.ID))
        data.MaxManaOffset = data.MaxManaOffset -SPELL_COST
    end
end

local function canSelectFun(player)
    local data = player:GetData()
    return (data.SpellsData and data.SpellsData.SummonActive) or 100 - (data.MaxManaOffset or 0) > SPELL_COST
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