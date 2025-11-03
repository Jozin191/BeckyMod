local mod = BeckyMod
local Callbacks = BeckyMod.Enums.Callbacks
local baseRange = 6.5
local baseHeight = -23.45
local baseMultiplier = -70 / baseRange

---comment
---@param ent Entity
---@param rng RNG
local function ShootHaemolacriaTear(ent, rng)
	local tear
	local fallSpeedVar

        tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BALLOON, 0, ent.Position, rng:RandomVector():Resized(20), ent):ToTear()

        if not tear then return end

        fallSpeedVar = mod.RandomFloat(rng, 1.2, 1.4)

		tear.Height = baseHeight * 4
        tear.Velocity = tear.Velocity * mod.RandomFloat(rng, 0.2, 0.6)
        tear.FallingAcceleration = (mod.RandomFloat(rng, 0.7, 1.2)) 
        tear.FallingSpeed = (baseMultiplier * (fallSpeedVar)) 
        tear.CollisionDamage = tear.CollisionDamage * mod.RandomFloat(rng, 1, 1.2) 
        tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_BURSTSPLIT)
		tear.Scale = tear.CollisionDamage/3.5
    -- end
end

---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HAEMOLACRIA)

    if not BeckyMod:RandomBoolean(rng) then return end

    ShootHaemolacriaTear(fam, rng)
end)