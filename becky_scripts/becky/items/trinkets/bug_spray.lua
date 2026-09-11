local BUG_SPRAY = {}

BeckyMod.Trinket.BUG_SPRAY = BUG_SPRAY

BUG_SPRAY.ID = Isaac.GetTrinketIdByName("Bug Spray")

local NotTaggedFlySpiderEntities = {
    [EntityType.ENTITY_DUKE] = {
        [0] = true,--duke of flies
        [1] = true,--husk
    },
    [EntityType.ENTITY_WIDOW] = {
        [0] = true,--widow
        [1] = true,--wretched
    }, 
    [EntityType.ENTITY_DADDYLONGLEGS] = {
        [0] = true,--daddy long legs
        [1] = true,--triachnid
    }, 
    [EntityType.ENTITY_BABY_PLUM] = { [0] = true, },
    [EntityType.ENTITY_REAP_CREEP] = { [0] = true, },
    [EntityType.ENTITY_TWITCHY] = { [0] = true, },
    [EntityType.ENTITY_SWARMER] = { [0] = true, },
}

function BUG_SPRAY:AddFlySpiderEntity(t,v)
    NotTaggedFlySpiderEntities[t]= NotTaggedFlySpiderEntities[t] or {}
    NotTaggedFlySpiderEntities[t][v] = true
end

function BUG_SPRAY:IsFlySpider(ent)
    local t = ent.Type
    local v = ent.Variant
    local s = ent.SubType
    if NotTaggedFlySpiderEntities[t] and NotTaggedFlySpiderEntities[t][v] then return true end
    return ent:GetEntityConfigEntity():GetEntityTags() & (EntityTag.FLY | EntityTag.SPIDER) > 0
end


function BUG_SPRAY:PreDamageEntity(ent, amount)
    if not BUG_SPRAY:IsFlySpider(ent) then return end

    local mult = PlayerManager.GetTotalTrinketMultiplier(BUG_SPRAY.ID)
    if mult == 0 then return end

    return { Damage = amount * (1 + 0.36 *mult) }
end
BeckyMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BUG_SPRAY.PreDamageEntity)
