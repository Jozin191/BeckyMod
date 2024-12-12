local synergies = {}

local function getLaserVariant(player) -- move to a util script
    local techCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECHNOLOGY) + player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_TECHNOLOGY)
    local brimCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRIMSTONE) + player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BRIMSTONE)

    if techCount > 0 and brimCount > 1 then
        return LaserVariant.THICKER_BRIM_TECH
    elseif techCount > 0 and brimCount > 0 then
        return LaserVariant.BRIM_TECH
    elseif brimCount > 1 then
        return LaserVariant.THICKER_RED
    elseif brimCount > 0 then
        return LaserVariant.THICK_RED
    elseif techCount > 0 then
        return LaserVariant.THIN_RED
    end

    return 0
end

local function getSynergy(name, familiar)
    local player = familiar.Player
    -- laser/brimstone
    if name == "laser" then
        if getLaserVariant(player) ~= 0 then
            return true
        end
    end
    return false
end

-- runs the first frame of the initializing ghost or whenever the player gets an item
function synergies.GhostInit(familiar)
    -- laser/brimstone
    if getSynergy("laser", familiar) then
        familiar:GetData().BeckyGhostCostumeFlip = true
        familiar:GetData().BeckyGhostCostume = "gfx/familiar/BeckyGhostBrimstone.anm2"
    end
end

-- runs every frame of firing
function synergies.GhostFire(familiar)
    local player = familiar.Player

    -- laser/brimstone
    if getSynergy("laser", familiar) and not familiar:GetData().BeckyGhostLaser then
        local angle = (familiar.Velocity * -1):GetAngleDegrees()
        local offset = Vector(0, -19) + (familiar.Velocity * Vector(-2, -2))
        local laser = EntityLaser.ShootAngle(getLaserVariant(player), familiar.Position + offset, angle, 400, Vector.Zero, familiar)
        --local laser = player:FireBrimstone(familiar.Velocity * -1, familiar)
        laser:AddTearFlags(player.TearFlags)
        laser.Velocity = familiar.Velocity

        local brimCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRIMSTONE) + player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BRIMSTONE)
        local techCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECHNOLOGY) + player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_TECHNOLOGY)

        local finalDmg = (player.Damage * 0.75)

        if brimCount >= 2 then
            finalDmg = finalDmg * 1.2 + 1 --Is this the damage???
        elseif techCount > 0 then
            finalDmg = finalDmg * 1.5
        end

        laser.CollisionDamage = finalDmg

        familiar:GetData().BeckyGhostLaser = laser
    end
end

-- runs once when the ghost returns
function synergies.GhostReturn(familiar)
    -- laser/brimstone
    if familiar:GetData().BeckyGhostLaser then
        familiar:GetData().BeckyGhostLaser:SetTimeout(1)
        familiar:GetData().BeckyGhostLaser = nil
    end
end

return synergies