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
---@param pos? Vector
---@param velocity Vector
---@param amount? integer
---@param spread? number
local function FireMonstroBurst(player, rng, pos, velocity, amount, spread)
    local amount = amount or 14
    local spread = spread or 20
    for i =  1, amount do
        local velo = (velocity*((rng:RandomFloat()*7)+7)):Rotated((rng:RandomFloat()*spread*2)-spread)
        local tear = player:FireTear(pos or player.Position, velo, true, false, false, player, 1)
        tryChangeTearToBloodVariant(tear)

        tear.Scale = tear.Scale*(.9+(rng:RandomFloat()*.45))
        tear.FallingSpeed = (rng:RandomFloat()*16)-8
        tear.FallingAcceleration = .5
        if rng:RandomFloat()> .5 and i < 5  then
            tear:AddTearFlags(TearFlags.TEAR_PIERCING)
        end
    end
end

---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function (_, fam)
    local player = fam.Player
    local data = BeckyMod.GetEntData(fam)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then return end
    local sprite = fam:GetSprite()
    local lungcharge = data.LUNGCHARGE or 0
    lungcharge = math.min(lungcharge+BeckyMod:toTearsPerSecond(player.MaxFireDelay)/40, 1)
    if lungcharge == 0 then
        SFXManager():Play(SoundEffect.SOUND_MONSTROS_LUG_CHARGE, 1.5)
    end
    if lungcharge < 1 then
        sprite:SetAnimation("Charge", true)
        sprite:SetFrame(math.ceil((lungcharge*4)-.5))
    elseif lungcharge >= 1 then
        sprite:Play("ChargeFull")
    end
    data.LUNGCHARGE = lungcharge
end)

---@param fam EntityFamiliar
---@param npc EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, fam, npc)
    local player = fam.Player
    local data = BeckyMod.GetEntData(fam)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then 
        if data.LUNGCHARGE >= 1 then
            FireMonstroBurst(player, player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MONSTROS_LUNG), fam.Position, (npc.Position-fam.Position):Normalized(), 14, 35)
            SFXManager():Play(SoundEffect.SOUND_MONSTROS_LUNG_BARF, 1.5)
            data.LUNGCHARGE = 0
        else
            data.LUNGCHARGE = math.max(data.LUNGCHARGE-.075, 0)
        end
    end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LEAD_PENCIL) then return end
    
    local pencilCharge = data.GHOSTLEADBURST or 0
    pencilCharge = pencilCharge + 1
    if pencilCharge >= 15 then
        pencilCharge = 0
        local velo = (fam.Position-player.Position):Normalized()*player.ShotSpeed

        FireMonstroBurst(player, player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LEAD_PENCIL), nil, velo, 12)
        
    end
    data.GHOSTLEADBURST = pencilCharge
end)

---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_RENDER_HELPER, function (_, fam, offset)
    local player = fam.Player
    local data = BeckyMod.GetEntData(fam)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then return end
    local lungcharge = data.LUNGCHARGE or 0
    if not data.MONSTROCHARGEBARSPRITE then
        data.MONSTROCHARGEBARSPRITE = Sprite()
        data.MONSTROCHARGEBARSPRITE:Load("gfx/chargebar.anm2", true)
    end
    local renderPos = Isaac.WorldToRenderPosition(fam.Position+fam.PositionOffset) + offset + Vector(15,-15)
    HudHelper.RenderChargeBar(data.MONSTROCHARGEBARSPRITE, lungcharge, 1, renderPos)
end)