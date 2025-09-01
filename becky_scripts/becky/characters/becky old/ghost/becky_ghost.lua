local BECKY_GHOST = {}

--[[
    Originally by Mocha
--]]

BECKY_GHOST.BECKY_GHOST_VARIANT = Isaac.GetEntityVariantByName("Becky Ghost")

BECKY_GHOST.CALLBACKS = include("becky_scripts.becky.characters.ghost.becky_ghost_callbacks")
local synergyCallbacks = BECKY_GHOST.CALLBACKS

BECKY_GHOST.CHARGEBAR = include("becky_scripts.becky.UI.chargebar")
BECKY_GHOST.GHOST_DAMAGE_COOLDOWN = 3
BECKY_GHOST.GHOST_FIRE_DELAY_MULT = 1
BECKY_GHOST.GHOST_SHOT_SPEED_MULT = 10
BECKY_GHOST.GHOST_OFFSET = 40
BECKY_GHOST.GHOST_SNAP_SMOOTHNESS = 0.3
BECKY_GHOST.GHOST_SNAP_SPEED = 1
BECKY_GHOST.GHOST_SNAP_DISTANCE_DIV = 3

local function lerp(first, second, percent)
    return (first + (second - first) * percent)
end

local directionToVector = {
    [Direction.UP] = Vector(0, -1),
    [Direction.DOWN] = Vector(0, 1),
    [Direction.LEFT] = Vector(-1, 0),
    [Direction.RIGHT] = Vector(1, 0),
    [Direction.NO_DIRECTION] = Vector(0, 0)
}

local function getResetCharge(familiar)
    return math.floor(familiar.Player.MaxFireDelay * BECKY_GHOST.GHOST_FIRE_DELAY_MULT)
end

local function getFinished(familiar, name, frameNum)
    local sprite = familiar:GetSprite()
    if (string.match(sprite:GetAnimation(), name))
    and (sprite:IsFinished(sprite:GetAnimation()) 
    or (frameNum and frameNum <= sprite:GetFrame())) then
        return true
    end
    return false
end

local function playGhostAnimation(familiar, animationName, rotation, force)
    local fixedAngle = ((rotation + 360) % 360)
    -- Find Rotation Direction
    familiar.FlipX = false
    local sharpness = (22.5 / 2)
    if fixedAngle > (45 + sharpness) and fixedAngle < (135 - sharpness) then
        animationName = animationName .. "Down"
    elseif fixedAngle > (225 + sharpness) and fixedAngle < (315 - sharpness) then
        animationName = animationName .. "Up"
    else
        if (fixedAngle < 90 and fixedAngle >= 0)
        or (fixedAngle >= 270 and fixedAngle < 360) then
            familiar.FlipX = true
        end
    end
    familiar:GetSprite():Play(animationName, force)
    return animationName
end

-- Cache Check for Familiars
local nullItem = Isaac.GetNullItemIdByName("NULL_BECKY_GHOST")
local nullConfig = Isaac.GetItemConfig():GetNullItem(nullItem)

function BECKY_GHOST:CheckFamiliar(player, cacheFlags)
    if (cacheFlags & CacheFlag.CACHE_FAMILIARS == CacheFlag.CACHE_FAMILIARS
    and (player:GetPlayerType() == BeckyMod.Character.BECKY.PLAYERTYPE)) then
        local rng = RNG()
        rng:SetSeed(math.max(Random(), 1), BeckyMod.RECOMMENDED_SHIFT_IDX)
        local familiarAmount = 1
        player:CheckFamiliar(BECKY_GHOST.BECKY_GHOST_VARIANT, familiarAmount, rng, nullConfig)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BECKY_GHOST.CheckFamiliar, CacheFlag.CACHE_FAMILIARS)

-- Initialize the Familiar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
    if familiar.Variant == BECKY_GHOST.BECKY_GHOST_VARIANT then
        familiar:AddToFollowers()
        familiar.FireCooldown = getResetCharge(familiar)
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, function()
    return (FollowerPriority.INCUBUS + 1)
end, BECKY_GHOST.BECKY_GHOST_VARIANT)

BECKY_GHOST.FamiliarState = {
    IDLE = 0,
    CHARGING = 1,
    READY = 2
}
local familiarState = BECKY_GHOST.FamiliarState

-- jhank u guwah 
local function isNormalRender(skipUpdate)
    local game = Game()
    local isPaused = game:IsPaused() and not skipUpdate
    local renderMode = game:GetRoom():GetRenderMode()
    local isReflected = ((renderMode == RenderMode.RENDER_WATER_REFLECT) 
        or (renderMode == RenderMode.RENDER_WATER_REFRACT))
    return (isPaused or isReflected) == false
end

-- Familiar Update Logic
BeckyMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, familiar)
    local player = familiar.Player
    if player and isNormalRender() then
        local familiarData, playerData = familiar:GetData(), player:GetData()
        familiarData.BeckyGhostDamageCooldown = math.max((familiarData.BeckyGhostDamageCooldown or 0) - 1, 0)

        -- Original Chargebar code that I'm copying over
        local chargeBar = familiarData.chargeBar
        if (not chargeBar) or (chargeBar and not chargeBar.charge) then
            familiarData.chargeBar = BECKY_GHOST.CHARGEBAR
            chargeBar = familiarData.chargeBar
            chargeBar:chargeBarInit()
        elseif chargeBar.initCallbacks then
            BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, chargeBar.chargeBarInit)
            chargeBar:chargeBarInit()
            BeckyMod:AddCallback(ModCallbacks.MC_POST_RENDER, chargeBar.chargeBarRender)
            chargeBar.initCallbacks = false
        else
            chargeBar.charge = familiar.FireCooldown
            chargeBar.maxCharge = getResetCharge(familiar)
            chargeBar.targetOffset = Vector(12, -35)
            if not chargeBar.target then
                chargeBar.target = familiar
                chargeBar.invertChargeSprites = true
            end
        end

        local shootingJoystick = player:GetShootingJoystick()
        if (Options.MouseControl and (player:GetAimDirection():LengthSquared() > player:GetShootingJoystick():LengthSquared())) then
            shootingJoystick = player:GetAimDirection()
        end
        
        local isFiring = (familiarData.isFiring and familiarData.fireDirection)
        local firingInput = (shootingJoystick:LengthSquared() > 0)
        if chargeBar then
            chargeBar.released = isFiring
        end

        if isFiring or firingInput then
            local gridEntity = BeckyMod.Game:GetRoom():GetGridEntityFromPos(familiar.Position)
            if gridEntity and (gridEntity:ToPoop() or gridEntity:ToTNT()) then 
                gridEntity:Hurt(math.floor(familiar.Player.Damage))
            elseif BeckyMod.Game:GetRoom():GetGridCollisionAtPos(familiar.Position) >= 
                (((player.TearFlags & TearFlags.TEAR_SPECTRAL ~= TearFlags.TEAR_SPECTRAL) 
                and GridCollisionClass.COLLISION_SOLID) or GridCollisionClass.COLLISION_WALL) then
                playerData.BeckyGhostReturn = false
                familiarData.isFiring = false
            end
        end

        if isFiring then
            familiar.Velocity = (familiarData.fireDirection 
                * (familiar.Player.ShotSpeed * BECKY_GHOST.GHOST_SHOT_SPEED_MULT) 
                + familiar:GetData().fireInheritance)
            playGhostAnimation(familiar, "Release", familiarData.fireDirection:GetAngleDegrees())
            Isaac.RunCallback(synergyCallbacks.BECKY_GHOST_UPDATE, familiar, familiarData)
            if playerData.BeckyGhostReturn then
                local distanceVector = (player.Position - familiar.Position)
                familiarData.fireDirection:Lerp(distanceVector:Normalized(), playerData.GhostReturnLerp or 0.05)
                playerData.GhostReturnLerp = math.min((playerData.GhostReturnLerp or 0.05) + 0.05, 1)
                if (distanceVector:Length() <= 5) then
                    playerData.BeckyGhostReturn = false
                    familiarData.isFiring = false
                end
            else
                playerData.GhostReturnLerp = 0.05
            end
        else
            if firingInput then
                -- Create Shooting Direction
                local shootingDirection = Vector(shootingJoystick.X, shootingJoystick.Y)
                if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
                    shootingDirection = directionToVector[player:GetFireDirection()]
                end
                local offsetPosition = shootingDirection:Resized(BECKY_GHOST.GHOST_OFFSET)
                local targetPosition = player.Position + offsetPosition
                local movementVelocity = Vector.Zero
                local targetDirection = targetPosition - familiar.Position

                if targetDirection:Length() > 2 then
                    movementVelocity = targetDirection:Normalized():Resized(
                        BECKY_GHOST.GHOST_SNAP_SPEED + (targetDirection:Length() / BECKY_GHOST.GHOST_SNAP_DISTANCE_DIV)
                    ) 
                end

                local directionInheritance = player:GetTearMovementInheritance(shootingDirection)
                familiar.Velocity = lerp(familiar.Velocity, movementVelocity, BECKY_GHOST.GHOST_SNAP_SMOOTHNESS)
                local animationName = "Charge"

                -- Set Familiar's Charging State
                if (getFinished(familiar, "Charge", 11) 
                or familiar.State == familiarState.READY) then 
                    animationName = "ChargeFull"
                    familiar.State = familiarState.READY
                elseif familiar.State == familiarState.IDLE then
                    familiar.State = familiarState.CHARGING
                end

                local shotParameters = player:GetMultiShotParams()

                -- Play Familiar's Animation
                playGhostAnimation(
                    familiar, "Charge" .. ((familiar.State == familiarState.READY and "Full") or ""), 
                    shootingDirection:GetAngleDegrees(), getFinished(familiar, "ChargeFull")
                )
                if (animationName == "Charge") then
                    familiar:GetSprite():SetFrame(math.floor(11 * (1 - (familiar.FireCooldown / getResetCharge(familiar)))))
                end

                familiar.FireCooldown = math.max(familiar.FireCooldown - 1, 0)
                familiarData.fireDirection = shootingDirection:Normalized()
                if directionInheritance then
                    familiarData.fireInheritance = directionInheritance
                end
            else
                -- Fire the Familiar
                playerData.BeckyGhostReturn = false
                if player:IsExtraAnimationFinished()
                and familiar.State == familiarState.READY
                and familiar.FireCooldown < 1 then
                    familiarData.isFiring = true
                    SFXManager():Play(Isaac.GetSoundIdByName("becky_ghost"), 0.8)
                else
                    -- Otherwise follow the parent of the familiar
                    familiar:FollowParent()
                    familiar.State = familiarState.IDLE
                    if familiar.Velocity:LengthSquared() > 0.5 then
                        playGhostAnimation(familiar, "Idle", familiar.Velocity:GetAngleDegrees())
                    end
                end
                -- Reset the firecooldown anyways
                familiar.FireCooldown = getResetCharge(familiar)
            end
        end
    end
end, BECKY_GHOST.BECKY_GHOST_VARIANT)

-- Familiar Collision
BeckyMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, entity, low)
    if familiar.Variant == BECKY_GHOST.BECKY_GHOST_VARIANT then
        if entity and entity:IsEnemy() then
            local familiarData = familiar:GetData()
            if not familiarData.BeckyGhostDamageCooldown then 
                familiarData.BeckyGhostDamageCooldown = 0 
            end
            if familiarData.BeckyGhostDamageCooldown == 0 then
                familiarData.BeckyGhostDamageCooldown = BECKY_GHOST.GHOST_DAMAGE_COOLDOWN

                local damageTaken = familiar.Player.Damage
                entity:TakeDamage(damageTaken, 0, EntityRef(familiar.Player), 0)
                Isaac.RunCallback(synergyCallbacks.BECKY_GHOST_DAMAGE_ENTITY, familiar, familiarData, entity)
            end
        end
    end
end)

-- Load Synergies
include("becky_scripts.becky.characters.ghost.becky_ghost_synergies")