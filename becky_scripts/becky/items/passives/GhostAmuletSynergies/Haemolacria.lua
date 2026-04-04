local mod = BeckyMod
local baseRange = 6.5
local baseHeight = -5.45
local baseMultiplier = -70 / baseRange

---Helper function for a better management of random floats, allowing to use min and max values, like `math.random()` and `RNG:RandomInt()`
---@param rng? RNG if `nil`, the function will use Mod's `RNG` object instead
---@param min number
---@param max? number if `nil`, returned number will be one between 0 and `min`
local function RandomFloat(rng, min, max)
	if not max then
		max = min
		min = 0
	end

	min = min * 1000
	max = max * 1000

	return (rng or RNG()):RandomInt(min, max) / 1000
end

---comment
---@param ent Entity
---@param rng RNG
---@param tearParams TearParams
local function ShootHaemolacriaTear(ent, rng, tearParams)
	local tear
	local fallSpeedVar

        tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BALLOON, 0, ent.Position, rng:RandomVector():Resized(20), ent):ToTear()

        if not tear then return end

        fallSpeedVar = RandomFloat(rng, 1.2, 1.4)
        tear.Color = tearParams.TearColor
		tear.Height = baseHeight * 4
        tear.Velocity = tear.Velocity * RandomFloat(rng, 0.1, 0.6)
        tear.FallingAcceleration = (RandomFloat(rng, 0.7, 1.2)) 
        tear.FallingSpeed = (baseMultiplier * (fallSpeedVar)) 
        tear.CollisionDamage = tearParams.TearDamage/2 * RandomFloat(rng, 1, 1.2) 
        tear:AddTearFlags(TearFlags.TEAR_BURSTSPLIT | tearParams.TearFlags | TearFlags.TEAR_PIERCING)
        tear:AddToHitList(ent)
		tear.Scale = tear.CollisionDamage/3.5
    -- end
end

---@param fam EntityFamiliar
---@param enemy EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams)
    local player = fam.Player

    if not player then return end
    if not (tearParams.TearFlags & TearFlags.TEAR_BURSTSPLIT == TearFlags.TEAR_BURSTSPLIT) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HAEMOLACRIA)

    if rng:RandomFloat() > 0.5 then return end

    ShootHaemolacriaTear(fam, rng, tearParams)
end)