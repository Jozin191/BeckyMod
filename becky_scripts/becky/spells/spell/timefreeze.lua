local SPELL_COST = 60
local NONO_FLAGS = (EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN)
local function ValidNPC(ent)
    if ent:ToNPC() ~= nil and ent:GetEntityFlags() & NONO_FLAGS == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() then return true end
    return false
end

local function fun(player)
    local ref = EntityRef(player)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if ValidNPC(ent) then ent:AddFreeze(ref, 90) end
    end
end

local function canSelectFun(player, manaLeft)
    return manaLeft > SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.TIMEFREEZE,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST,
    Frame = 21
}