--[[ to do:
add ghost synergies
organize this script and make it more readable and use a state system familiar.State (maybe)
fix jank with more than one ghost (maybe)
]]-- 

local hand_made_bible = Isaac.GetItemIdByName("Hand Made Bible")
local beckyGhostVariant = Isaac.GetEntityVariantByName("Becky Ghost")
local chargeBar = include("becky_scripts.UI.chargebar")
local ghostFireDelayMult = 1
local ghostShotSpeedMult = 10
local ghostOffset = 40
local ghostSnapSmoothness = 0.3
local ghostSnapSpeed = 1
local ghostSnapDistanceDiv = 3
local dir_to_vec = {
    [Direction.UP] = Vector(0, -1),
    [Direction.DOWN] = Vector(0, 1),
    [Direction.LEFT] = Vector(-1, 0),
    [Direction.RIGHT] = Vector(1, 0),
    [Direction.NO_DIRECTION] = Vector(0, 0)
}
local animSuffix = {
    [Direction.UP] = "Up",
    [Direction.DOWN] = "Down",
    [Direction.LEFT] = "",
    [Direction.RIGHT] = "",
    [Direction.NO_DIRECTION] = "Down"
}
local isFlipped = {
    [Direction.UP] = false,
    [Direction.DOWN] = false,
    [Direction.LEFT] = false,
    [Direction.RIGHT] = true,
    [Direction.NO_DIRECTION] = false
}

local function lerp(first, second, percent)
    return (first + (second - first) * percent)
end

local function getAnim(name, direction)
    return name .. animSuffix[direction]
end

local function getFinished(sprite, name, frameNum)
    local isFinished = false
    for i, suffix in pairs(animSuffix) do
        if sprite:GetSprite():IsFinished(name .. suffix) or (frameNum and frameNum <= sprite:GetSprite():GetFrame()) then
            isFinished = true
        end
    end
    return isFinished
end

local function getIsPlaying(sprite, name)
    local isFinished = false
    for i, suffix in pairs(animSuffix) do
        if sprite:GetSprite():IsPlaying(name .. suffix) then
            isFinished = true
        end
    end
    return isFinished
end

local function getResetCharge(familiar)
    return math.floor(familiar.Player.MaxFireDelay * ghostFireDelayMult)
end

-- Active
BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, type, rng, player, useflags, activeslot)
    if type == hand_made_bible then
        player:GetData().BeckyGhostReturn = true
        
        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
    end
end)

-- Familiar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
    if familiar.Variant == beckyGhostVariant then
        familiar:AddToFollowers()
        familiar.FireCooldown = getResetCharge(familiar)
        if familiar.Player then familiar.Player:GetData().BeckyGhostReturn = false end
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, chargeBar.chargeBarInit)
BeckyMod:AddCallback(ModCallbacks.MC_POST_RENDER, chargeBar.chargeBarRender)

BeckyMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, entity, low)
    if familiar.Variant == beckyGhostVariant then
        if entity and entity:IsEnemy() then
            entity:TakeDamage(familiar.Player.Damage, 0, EntityRef(familiar.Player), 0)
        end
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    if familiar.Variant == beckyGhostVariant and familiar.Player then
        familiar:GetSprite().PlaybackSpeed = 1
        chargeBar.charge = familiar.FireCooldown
        chargeBar.maxCharge = getResetCharge(familiar)
        chargeBar.targetOffset = Vector(12, -35) + (Vector(7, 11) * chargeBar.getAmountOfChargeBarItems(familiar.Player))
        if not chargeBar.target then
            chargeBar.target = familiar.Player
            chargeBar.invertChargeSprites = true
        end

        -- destroying poop attack go! also works for tnt
        local poop = Game():GetRoom():GetGridEntityFromPos(familiar.Position)
        local isColliding = false
        local isPoop = false
        if poop and (poop:ToPoop() or poop:ToTNT()) then isPoop = true end
        if isPoop then
            poop:Hurt(math.floor(familiar.Player.Damage))
        elseif Game():GetRoom():GetGridCollisionAtPos(familiar.Position) > GridCollisionClass.COLLISION_OBJECT then
            familiar:GetData().firing = false
            isColliding = true
        end
        --print(Game():GetRoom():GetGridCollisionAtPos(familiar.Position))

        -- check if can fire
        if familiar.Player:GetFireDirection() == Direction.NO_DIRECTION and familiar.FireCooldown < 1 and not isColliding then
            familiar:GetData().firing = true
            familiar.FireCooldown = getResetCharge(familiar)
            SFXManager():Play(Isaac.GetSoundIdByName("becky_ghost"))
        end
        local doFire = false
        if familiar:GetData().firing then doFire = true end
        chargeBar.released = doFire

        -- firing
        if doFire then
            -- check if player used active
            if familiar.Player:GetData().BeckyGhostReturn or not familiar:GetData().fireDirection or not familiar:GetData().fireInheritance then
                familiar:GetData().firing = false
                familiar.Player:GetData().BeckyGhostReturn = false
            else
                familiar.Velocity = familiar:GetData().fireDirection * (familiar.Player.ShotSpeed * ghostShotSpeedMult) + familiar:GetData().fireInheritance
                familiar:GetSprite():Play(getAnim("Release", familiar:GetData().animDirection))
            end
        -- charging
        elseif familiar.Player:GetFireDirection() > Direction.NO_DIRECTION then
            local ofsPos = dir_to_vec[familiar.Player:GetFireDirection()]:Resized(ghostOffset)
            local whoToFollow = familiar.Player
            if familiar.Parent and familiar.Parent.Variant == beckyGhostVariant then whoToFollow = familiar.Parent end
            local targetPosition = whoToFollow.Position + ofsPos
            local targetDirection = targetPosition - familiar.Position
            local movementVelocity = Vector.Zero

            if targetDirection:Length() > 2 then
                movementVelocity = targetDirection:Normalized():Resized(ghostSnapSpeed + (targetDirection:Length() / ghostSnapDistanceDiv)) 
            end
            
            familiar.Player:GetData().BeckyGhostReturn = false
            familiar.Velocity = lerp(familiar.Velocity, movementVelocity, ghostSnapSmoothness)
            local animDirectionCheck = familiar.Player:GetFireDirection()
            local directionInheritance = familiar.Player:GetTearMovementInheritance(dir_to_vec[animDirectionCheck])
            local animName = "Charge"
            if getFinished(familiar, "Charge", 11) or getFinished(familiar, "ChargeFull") or familiar.State == 1 then animName = "ChargeFull" end
            if animName == "ChargeFull" then familiar.State = 1 end
            familiar:GetSprite():Play(getAnim(animName, animDirectionCheck), getFinished(familiar, "ChargeFull"))
            if animName == "Charge" then
                familiar:GetSprite():SetFrame(math.floor(11 * (1 - (familiar.FireCooldown / getResetCharge(familiar)))))
                --familiar:GetSprite().PlaybackSpeed = 13 / getResetCharge(familiar)
            end

            familiar.FlipX = isFlipped[animDirectionCheck]
            familiar.FireCooldown = math.max(familiar.FireCooldown - 1, 0)
            familiar:GetData().fireDirection = dir_to_vec[animDirectionCheck]
            familiar:GetData().animDirection = animDirectionCheck
            if directionInheritance then
                familiar:GetData().fireInheritance = directionInheritance
            end
        -- follow normally
        else
            chargeBar.released = true
            familiar:FollowParent()
            familiar.State = 0
            local animDirectionCheck = familiar.Player:GetMovementDirection()
            familiar:GetSprite():Play(getAnim("Idle", animDirectionCheck))
            familiar.FlipX = isFlipped[animDirectionCheck]
            familiar.FireCooldown = getResetCharge(familiar)
        end
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlags)
    if cacheFlags == CacheFlag.CACHE_FAMILIARS then
        --player:GetEffects():GetCollectibleEffectNum(hand_made_bible)
        local itemCount = player:GetCollectibleNum(hand_made_bible)
        
        local rng = RNG()
        rng:SetSeed(math.max(Random(), 1), RECOMMENDED_SHIFT_IDX)
    
        player:CheckFamiliar(beckyGhostVariant, itemCount, rng, Isaac.GetItemConfig():GetCollectible(hand_made_bible))
    end
end)