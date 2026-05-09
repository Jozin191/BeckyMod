local bloodTearTable = {
    [TearVariant.BLUE] = TearVariant.BLOOD,
    [TearVariant.CUPID_BLUE] = TearVariant.CUPID_BLOOD,
    [TearVariant.NAIL] = TearVariant.NAIL_BLOOD,
    [TearVariant.PUPULA] = TearVariant.PUPULA_BLOOD,
    [TearVariant.GODS_FLESH] = TearVariant.GODS_FLESH_BLOOD,
    [TearVariant.GLAUCOMA] = TearVariant.GLAUCOMA_BLOOD,
    [TearVariant.EYE] = TearVariant.EYE_BLOOD,
}

---@param tear EntityTear
local function tryChangeTearToBloodVariant(tear)
    if bloodTearTable[tear.Variant] then
        tear:ChangeVariant(bloodTearTable[tear.Variant])
    end
end
--[[ measured a bunch of lead pencil bursts
--- -20, 20 angle spread
--- .5 falling accel
--- -8, 8 falling speed
--- 7, 14 velocity with 1 shotspeed
--- 0.9, 1.35 tear scale]]
---@param player EntityPlayer
---@param rng RNG
---@param velocity Vector
---@param amount? integer
local function FireMonstroBurst(player, rng, velocity, amount)
    local amount = amount or 14
    for i =  1, amount do
        local velo = (velocity*((rng:RandomFloat()*7)+7)):Rotated((rng:RandomFloat()*40)-20)
        local tear = player:FireTear(player.Position, velo, true, false, false, player, 1)
        tryChangeTearToBloodVariant(tear)

        tear.Scale = tear.Scale*(.9+(rng:RandomFloat()*.45))
        tear.FallingSpeed = (rng:RandomFloat()*16)-8
        tear.FallingAcceleration = .5
    end
end


---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, fam, npc)
    local player = fam.Player
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LEAD_PENCIL) then return end
    local data = fam:GetData()
    local pencilCharge = data.GHOSTLEADBURST or 0
    pencilCharge = pencilCharge + 1
    if pencilCharge >= 15 then
        pencilCharge = 0
        local velo = (fam.Position-player.Position):Normalized()*player.ShotSpeed
        FireMonstroBurst(player, player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LEAD_PENCIL), velo, 12)
        
    end
    data.GHOSTLEADBURST = pencilCharge
end)