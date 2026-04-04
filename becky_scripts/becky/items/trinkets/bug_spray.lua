local BUG_SPRAY = {}

BeckyMod.Trinket.BUG_SPRAY = BUG_SPRAY

BUG_SPRAY.ID = Isaac.GetTrinketIdByName("Bug Spray")


function BUG_SPRAY:PreDamageEntity(ent, amount)
    if ent:GetEntityConfigEntity():GetEntityTags() & (EntityTag.FLY | EntityTag.SPIDER) == 0 then return end

    local mult = PlayerManager.GetTotalTrinketMultiplier(BUG_SPRAY.ID)
    if mult == 0 then return end

    return { Damage = amount * (1 + 0.36 *mult) }
end
BeckyMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BUG_SPRAY.PreDamageEntity)
