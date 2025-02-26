local CHALICE = {}

CHALICE.ID = Isaac.GetItemIdByName("Defiled Chalice")
BeckyMod.Item.DEFILED_CHALICE = CHALICE

CHALICE.TIMEOUT = 145
CHALICE.DAMAGE = 2.75

--EffectVariant.PLAYER_CREEP_RED

function CHALICE:EnemyDeath(Enemy)
    if not PlayerManager.AnyoneHasCollectible(CHALICE.ID) then return end

    if Enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
        return
    end

    local Creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, Enemy.Position, Vector.Zero, Enemy):ToEffect()
    Creep.Timeout = CHALICE.TIMEOUT
    Creep.CollisionDamage = CHALICE.DAMAGE
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, CHALICE.EnemyDeath)