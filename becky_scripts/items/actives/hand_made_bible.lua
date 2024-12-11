--[[ to do:
add ghost synergies
organize this script and make it more readable and use a state system familiar.State (maybe)
fix jank with more than one ghost (maybe)
fix bug with more than one ghost not parenting to each other
]]-- 

local hand_made_bible = Isaac.GetItemIdByName("Hand Made Bible")
local beckyGhostVariant = Isaac.GetEntityVariantByName("Becky Ghost")
local synergiesScript = "becky_scripts.items.actives.hand_made_bible_synergies"
local ghostDamageCooldown = 3
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

local function loadGhostCostume(familiar, path, flipAnimations)
    familiar:GetSprite():Load(path, true)
    
    if flipAnimations and not isFlipped[0] then
        for i, flip in pairs(isFlipped) do
            isFlipped[i] = not flip
        end
        for i, name in pairs(animSuffix) do
            if name ~= "" then animSuffix[i] = name == "Up" and "Down" or "Up" end -- a ? b : c
        end
    end
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

        familiar:GetData().ghostsynergies = include(synergiesScript)
        local synergies = familiar:GetData().ghostsynergies
        if synergies.GhostInit then synergies.GhostInit(familiar) end
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, function(_) -- because of luamod breaking things
    local entities = Isaac.GetRoomEntities()
    for i, entity in ipairs(entities) do
        local familiar = entity and entity:ToFamiliar()
        if familiar and familiar.Variant == beckyGhostVariant then
            familiar:GetData().LastBeckyGhostCostume = nil
            familiar:GetData().lastPlayerColNum = -1
        end
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, familiar, entity, low)
    if familiar.Variant == beckyGhostVariant then
        if entity and entity:IsEnemy() then
            if not familiar:GetData().BeckyGhostDamageCooldown then familiar:GetData().BeckyGhostDamageCooldown = 0 end
            if familiar:GetData().BeckyGhostDamageCooldown == 0 then
                familiar:GetData().BeckyGhostDamageCooldown = ghostDamageCooldown
                entity:TakeDamage(familiar.Player.Damage, 0, EntityRef(familiar.Player), 0)
            end
        end
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    if familiar.Variant == beckyGhostVariant and familiar.Player then
        if not familiar:GetData().BeckyGhostDamageCooldown then familiar:GetData().BeckyGhostDamageCooldown = 0 end
        familiar:GetData().BeckyGhostDamageCooldown = math.max(familiar:GetData().BeckyGhostDamageCooldown - 1, 0)
        familiar:GetSprite().PlaybackSpeed = 1

        -- load synergies
        local synergies = familiar:GetData().ghostsynergies
        if synergies.GhostInit == nil then
            synergies = include(synergiesScript)
            familiar:GetData().ghostsynergies = synergies
        elseif synergies.GhostInit and (not familiar:GetData().lastPlayerColNum or familiar:GetData().lastPlayerColNum ~= #familiar.Player:GetEffects():GetEffectsList() + familiar.Player:GetCollectibleCount()) then
            synergies.GhostInit(familiar)
            familiar:GetData().lastPlayerColNum = #familiar.Player:GetEffects():GetEffectsList() + familiar.Player:GetCollectibleCount()
        end

        -- updates ghost costumes
        if familiar:GetData().BeckyGhostCostume and familiar:GetData().BeckyGhostCostume ~= familiar:GetData().LastBeckyGhostCostume then
            local costumeFlipped = false
            if familiar:GetData().BeckyGhostCostumeFlip then costumeFlipped = true end
            loadGhostCostume(familiar, familiar:GetData().BeckyGhostCostume, costumeFlipped)
            familiar:GetData().LastBeckyGhostCostume = familiar:GetData().BeckyGhostCostume
        end
        

        -- chargebar
        local chargeBar = familiar:GetData().chargeBar
        if not chargeBar or (chargeBar and not chargeBar.charge) then
            chargeBar = include("becky_scripts.UI.chargebar")
            familiar:GetData().chargeBar = chargeBar
        elseif chargeBar.initCallbacks then
            BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, chargeBar.chargeBarInit)
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

        -- temporary solution :< 
        -- breaks based on file path. i dont know what else to do right now.
        -- will fix in the future
        if chargeBar.charge == nil or synergies.GhostInit == nil then
            Isaac.ExecuteCommand("luamod BeckyMod")
            return
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
            familiar.Player:GetData().BeckyGhostReturn = false
            synergies.GhostReturn(familiar)
        end

        -- check if can fire
        if familiar.Player:IsExtraAnimationFinished() and familiar.Player:GetFireDirection() == Direction.NO_DIRECTION and familiar.FireCooldown < 1 and not isColliding and not familiar:GetData().firing then
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
                synergies.GhostReturn(familiar)
            else
                familiar.Velocity = familiar:GetData().fireDirection * (familiar.Player.ShotSpeed * ghostShotSpeedMult) + familiar:GetData().fireInheritance
                familiar:GetSprite():Play(getAnim("Release", familiar:GetData().animDirection))
                synergies.GhostFire(familiar)
            end
        -- charging
        elseif familiar.Player:GetFireDirection() > Direction.NO_DIRECTION or (not familiar.Player:IsExtraAnimationFinished() and familiar.State > 0) then
            local ofsPos = dir_to_vec[familiar.Player:GetFireDirection()]:Resized(ghostOffset)
            local whoToFollow = familiar.Player
            if familiar.Parent and familiar.Parent.Variant == beckyGhostVariant then whoToFollow = familiar.Parent end
            local targetPosition = whoToFollow.Position + ofsPos
            local targetDirection = targetPosition - familiar.Position
            local movementVelocity = Vector.Zero

            if targetDirection:Length() > 2 then
                movementVelocity = targetDirection:Normalized():Resized(ghostSnapSpeed + (targetDirection:Length() / ghostSnapDistanceDiv)) 
            end

            if familiar.Player:GetData().BeckyGhostReturn then
                familiar.Player:GetData().BeckyGhostReturn = false
                synergies.GhostReturn(familiar)
            end
            familiar.Velocity = lerp(familiar.Velocity, movementVelocity, ghostSnapSmoothness)
            local animDirectionCheck = familiar.Player:GetFireDirection()
            local directionInheritance = familiar.Player:GetTearMovementInheritance(dir_to_vec[animDirectionCheck])
            local animName = "Charge"
            if getFinished(familiar, "Charge", 11) or getFinished(familiar, "ChargeFull") or familiar.State == 2 then animName = "ChargeFull" end
            if animName == "ChargeFull" then familiar.State = 2 else familiar.State = 1 end
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