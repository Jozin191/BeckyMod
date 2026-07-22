local GHOST_AMULET = {}
GHOST_AMULET.ID = Isaac.GetItemIdByName("Ghost Amulet")

local BeckyPlayerType = Isaac.GetPlayerTypeByName("Becky", false)
local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")
local GHOST_BALL_DMG = 1.25

BeckyMod.Item.GHOST_AMULET = GHOST_AMULET


BeckyMod.Callbacks = {}
--- Called every time the ghost hits an enemy
--- * Familiar: The ghost entity
--- * Entity: The entity hit by the ghost
--- * TearParam: TearParams
--- * Position: The position of the ghost when it hits
--- * GhostCopy: If the collision comes from a ghost copy created through the piercing synergies
BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY = "BeckyMod_ON_GHOST_HIT_ENEMY"
--- Called every time the ghost kills an enemy
--- * Familiar: The ghost entity
--- * Entity: The entity killed by the ghost
--- * TearParam: TearParams
BeckyMod.Callbacks.ON_GHOST_KILL_ENEMY = "BeckyMod_ON_GHOST_KILL_ENEMY"
--- Called after the ghosts updates, passes frequently used values
--- * Familiar: The ghost entity
--- * TearParam: TearParams
BeckyMod.Callbacks.GHOST_UPDATE_HELPER = "BeckyMod_GHOST_UPDATE_HELPER"
--- Called after the ghosts updates, passes frequently used values
--- * Familiar: The ghost entity
--- * Offset: Render offset
BeckyMod.Callbacks.GHOST_RENDER_HELPER = "BeckyMod_GHOST_RENDER_HELPER"

local RoomLimits = {
    X1 = 0,
    Y1 = 0,
    X2 = 0,
    Y2 = 0,
}
local FamState = {
    IDLE = 0,
    ATTACKING = 1,
    AUTO_ATTACK = 2,
    DISABLE_IDLE = 3,
    DISABLE_MOVE = 4
}
local FamSubType = {
    NORMAL = 0,
    HOMING = 1,
    BOOKWORM = 2,
}


local function MinGhostAmountCalculation(player)
    local innerNum = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE)
    local mutantNum = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
    local _2020Num = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)
    local wizNum = math.min(player:GetCollectibleNum(CollectibleType.COLLECTIBLE_THE_WIZ), 8)

    local pType = player:GetPlayerType()
    local isKeeper = pType == PlayerType.PLAYER_KEEPER or pType == PlayerType.PLAYER_KEEPER_B
    local isWeaponKnife = false
    local isWeaponTech = false
    local maxTears = 16

    local tearNum = 1

    tearNum = tearNum + 5 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)

    if pType == PlayerType.PLAYER_KEEPER then
        tearNum = tearNum + 2
    elseif pType == PlayerType.PLAYER_KEEPER_B then
        tearNum = tearNum + 3
    end
    if _2020Num >0 then
        tearNum = tearNum + _2020Num
        if isKeeper or mutantNum >0 or innerNum >0 then tearNum = tearNum -1 end
    end
    if innerNum >0 then
        tearNum = tearNum + innerNum
        if not isKeeper then tearNum = tearNum +1 end
    end
    if mutantNum >0 then
        tearNum = tearNum + mutantNum *2
        if not isKeeper and innerNum ==0 then tearNum = tearNum +1 end
    end


    if wizNum > 0 then
        if isKeeper or _2020Num >1 then tearNum = tearNum -1 end
        if innerNum >1 then tearNum = tearNum -1 end
        if mutantNum >1 then tearNum = tearNum - mutantNum end

        tearNum = tearNum * (wizNum +1)

        if isKeeper then maxTears = maxTears -1 end
    end
    if tearNum >maxTears then tearNum = maxTears end
    return tearNum
end

---@param npc EntityNPC
---@return boolean
local function IsValidEnemy(npc)
    return (npc and npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() and not npc:IsInvincible())
end

---@param player EntityPlayer
---@return boolean
local function HasGhostAmulet(player)
    return player:HasCollectible(GHOST_AMULET.ID)
end

---@param player EntityPlayer
local function BeckyHasBirthright(player)
    return player:GetPlayerType() == BeckyPlayerType and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

---Triggers a push to `pushed` from `pusher`
---@param pushed Entity
---@param pusher Entity
---@param strength number
local function TriggerPush(pushed, pusher, strength)
	local dir = (pushed.Position - pusher.Position):Normalized() * strength
    pushed.Velocity = dir
end

---@param player EntityPlayer
---@return boolean
local function IsPlayerShooting(player)
	local k_up = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)
    local k_down = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
    local k_left = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)
    local k_right = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)

    return (k_down or k_right or k_left or k_up) or false
end

--- Rounds a number to the closest number of decimal places given.
--- Defaults to rounding to the nearest integer. 
--- (from Library of Isaac)
---@param n number
---@param decimalPlaces integer? @Default: 0
---@return integer
local function Round(n, decimalPlaces)
	decimalPlaces = decimalPlaces or 0
	local mult = 10^(decimalPlaces or 0)
	return math.floor(n * mult + 0.5) / mult
end

---@param player EntityPlayer
---@return number
function GHOST_AMULET:GetGhostTearMult(player)
    return Round(BeckyMod:toTearsPerSecond(player.MaxFireDelay), 2) / 2.73
end

function GHOST_AMULET:GetGhostAmount(player)
    local ghostAmount = player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears()
    if player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) and ghostAmount - MinGhostAmountCalculation(player) == 1 then
        ghostAmount = ghostAmount -1
    end

    return ghostAmount + (player:GetCollectibleNum(GHOST_AMULET.ID)-1)
end

---@param player EntityPlayer
---@param tearParamsDamage number?
---@return number
function GHOST_AMULET:GetGhostDamage(player, tearParamsDamage)
    local dmg = tearParamsDamage or player.Damage
    return (GHOST_BALL_DMG * dmg) * GHOST_AMULET:GetGhostTearMult(player)
end


--- Helper function to convert a given amount of angle degrees into the corresponding `Direction` enum (From Library of Isaac, tweaked a bit)
---@param angleDegrees number
---@return Direction
local function AngleToDirection(angleDegrees)
    local normalizedDegrees = angleDegrees % 360
    if normalizedDegrees < 45 or normalizedDegrees >= 315 then
        return Direction.RIGHT
    elseif normalizedDegrees < 135 then
        return Direction.DOWN
    elseif normalizedDegrees < 225 then
        return Direction.LEFT
    else
        return Direction.UP
    end
end

--- Returns a direction corresponding to the direction the provided vector is pointing (from Library of Isaac)
---@param vector Vector
---@return Direction
local function VectorToDirection(vector)
	return AngleToDirection(vector:GetAngleDegrees())
end

---@param entity Entity
local function SpawnTrail(entity)
    local entData = BeckyMod.GetEntData(entity)

    local entityParent = entity -- Set this to the parent of the trail
    local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, entityParent.Position, Vector.Zero, entityParent):ToEffect() ---@cast trail EntityEffect
    trail:FollowParent(entityParent)
    trail.Color = Color(1, 1, 1, 1)
    trail.MinRadius = 0.1
    trail.SpriteScale = Vector.One * 2
    entData.GhostTrail = trail

    local sprite = trail:GetSprite()
    local blendMode = sprite:GetLayer(0):GetBlendMode()
    blendMode:SetMode(BlendType.NORMAL)

    return trail 
end

local function RemoveTrail(entity)
    local entData = BeckyMod.GetEntData(entity)
    if not entData.GhostTrail then return end

    entData.GhostTrail:Remove()
    entData.GhostTrail = nil
end

local shouldPogCache = false
local function ShouldGhostPog()
    if Poglite == nil then return false end
    if BeckyMod.Game:GetFrameCount() % 5 > 0 then return shouldPogCache end

    if BeckyMod.Game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND == 0 then
        local itemConfig = Isaac.GetItemConfig()

        for _, item in ipairs(Isaac.FindByType(5, 100)) do
            local id = item.SubType
            local pick = item:ToPickup()
            if id > 0 and not pick:IsBlind() then
                --Weird exceptions go first
                if id == 120 or id == 121 then --thin and large odd mushrooms
                    shouldPogCache = true
                    return true
                end
                if itemConfig:GetCollectible(id).Quality >= 3 then
                    shouldPogCache = true
                    return true
                end	
            end
        end
    end
    shouldPogCache = false
    
    return false
end


---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, function(_, player)
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end)


local MultiShotItems = {
    [CollectibleType.COLLECTIBLE_20_20] = true,
    [CollectibleType.COLLECTIBLE_INNER_EYE] = true,
    [CollectibleType.COLLECTIBLE_MUTANT_SPIDER] = true,
    [CollectibleType.COLLECTIBLE_THE_WIZ] = true,
}

---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    if not HasGhostAmulet(player) then return end

    local data = BeckyMod.GetEntData(player)
    local ghostBalls = data.GhostBalls
    if ghostBalls then
        for idx=#ghostBalls, 1, -1 do
            local ghost = ghostBalls[idx]
            if not ghost:Exists() or ghost:IsDead() then
                table.remove(data.GhostBalls, idx)
            end
        end
    end

    data.BookWormFlag = data.BookWormFlag or false 
    data.HomingFlag = data.HomingFlag or false 

    local updateFamCache = false
    if player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) then
        if not data.BookWormFlag then
            updateFamCache = true
            data.BookWormFlag = true
        end
    elseif data.BookWormFlag then
        updateFamCache = true
        data.BookWormFlag = false
    end

    if (player.TearFlags & TearFlags.TEAR_HOMING == TearFlags.TEAR_HOMING) or player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
        if not data.HomingFlag then
            updateFamCache = true
            data.HomingFlag = true
        end
    elseif data.HomingFlag then
        updateFamCache = true
        data.HomingFlag = false
    end

    if IsPlayerShooting(player) or player:GetMarkedTarget() then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_WIG) and Isaac.CountEnemies() > 0 then
            if Isaac.CountEntities(player, 3, FamiliarVariant.BLUE_SPIDER) < 5 then
                data.MomsWigCooldown = data.MomsWigCooldown or 0
                if data.MomsWigCooldown > 0 then
                    data.MomsWigCooldown = data.MomsWigCooldown - 0.5
                else
                    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_WIG)
                    local formula = 1/ math.max(20 - player.Luck *2,1)
                    if rng:RandomFloat() <= formula then
                        player:ThrowBlueSpider(player.Position, player.Position + rng:RandomVector():Resized(30))
                    end
                    data.MomsWigCooldown = player.MaxFireDelay
                end
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_TOOTH) then
            local aura = data.DeadToothEnt
            if not aura then
                aura = Isaac.Spawn(1000, EffectVariant.FART_RING, 0, player.Position, Vector.Zero, player):ToEffect()
                aura:SetTimeout(-1)
                aura.Parent = player
                aura:FollowParent(player)
                aura.SpriteScale = aura.SpriteScale *0.8
                aura.SpriteOffset = Vector(0, -10)
                data.DeadToothEnt = aura
            end
        end
    else
        if data.DeadToothEnt then
            data.DeadToothEnt:Die()
            data.DeadToothEnt = nil
        end
    end


    if not updateFamCache then return end
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end)

---@param id CollectibleType
---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, id, _, _, _, _, player)
    if id == GHOST_AMULET.ID then
        player:SetCanShoot(false)
        return
    end
    if not HasGhostAmulet(player) then return end
    if id == CollectibleType.COLLECTIBLE_CONTINUUM then
        local playerData = BeckyMod.GetEntData(player)
        local ghosts = playerData.GhostBalls

        if not ghosts then return end
        for _, ghost in ipairs(ghosts) do
            if not ghost then goto continue end
            ghost.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            ::continue::
        end
    end
    if not MultiShotItems[id] then return end
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function(_, player, id)
    if id == CollectibleType.COLLECTIBLE_CONTINUUM then
        local playerData = BeckyMod.GetEntData(player)
        local ghosts = playerData.GhostBalls

        if not ghosts then return end
        for _, ghost in ipairs(ghosts) do
            if not ghost then goto continue end
            ghost.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            ::continue::
        end
    end
    if id == GHOST_AMULET.ID and not HasGhostAmulet(player) then
        player:SetCanShoot(true)
        return
    end
    if not MultiShotItems[id] then return end
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end)

---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player)
    local rng = RNG()
    local seed = math.max(Random(), 1)
    rng:SetSeed(seed, 35)
    
    if not HasGhostAmulet(player) then
        player:CheckFamiliar(GHOST_BALL_VAR, 0, rng)
        return
    end
    
    local num = GHOST_AMULET:GetGhostAmount(player)
    player:CheckFamiliar(GHOST_BALL_VAR, num, rng)
    if (player.TearFlags & TearFlags.TEAR_HOMING == TearFlags.TEAR_HOMING) or player:HasTrinket(TrinketType.TRINKET_BABY_BENDER) then
        player:CheckFamiliar(GHOST_BALL_VAR, 1, rng, nil, FamSubType.HOMING)
    end
    if player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) then
        player:CheckFamiliar(GHOST_BALL_VAR, 1, rng, nil, FamSubType.BOOKWORM)
    end
end, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    local ghostData = BeckyMod.GetEntData(familiar)
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	familiar:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK --[[@as EntityFlag]])
    local player = familiar.Player
    
    ghostData.BounceMomentum = 0
    ghostData.ChocolateMilkMult = 1
    ghostData.TEARPARAMS = player:GetTearHitParams(WeaponType.WEAPON_TEARS, 4/3, 1, familiar)
    if player then
        local playerData = BeckyMod.GetEntData(player)
        playerData.GhostBalls = playerData.GhostBalls or {}
        table.insert(playerData.GhostBalls, familiar)
    end

    if player and player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM) then
        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    else
        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS 
    end

    if familiar.SubType == FamSubType.HOMING then
        familiar.Color = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549)
    end

    if familiar.SubType == FamSubType.BOOKWORM then
        if Random() % 2 == 1 then
            familiar.State = FamState.DISABLE_IDLE
            familiar:GetSprite().Color.A = 0.33
        end
        familiar.FireCooldown = 150
    end
end, GHOST_BALL_VAR)

---Expontential function
---@param number number
---@param coeffcient number
---@param power number
---@return integer
local function exp(number, coeffcient, power)
    return number ~= 0 and coeffcient * number ^ (power - 1) or 0
end

local Anims = {
    [1] = "Anim1",
    [2] = "Anim2",
    [3] = "Anim3",
}

---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local playerData = BeckyMod.GetEntData(player)
    local ghosts = playerData.GhostBalls

    if not ghosts or #ghosts <= 0 then return end
    
    local room = BeckyMod.Game:GetRoom()
    local isShooting = IsPlayerShooting(player)
    local ForceTargetPos = nil
    local playerAppear = player:GetSprite():GetAnimation() == "Appear"
    local playerPos = player.Position
    local totalGhostPosition = nil
    
    if Options.MouseControl and player.ControllerIndex == 0 then
        if Input.IsMouseBtnPressed(0) then
            ForceTargetPos = Input.GetMousePosition(true)

            if room:IsMirrorWorld() then -- probably there is a better way to do this. but for now it will be this one.
                local roomHalf = room:GetCenterPos().X*2
                ForceTargetPos.X = roomHalf + (ForceTargetPos.X *-1)
            end
        end
    end
    local marked = player:GetMarkedTarget()
    if marked then ForceTargetPos = marked.Position end

    local shotSpeed = player.ShotSpeed
    local maxDistMove = ((player.TearRange / 6.5) * 2.5) * (1 / shotSpeed) -- Max distance is affected by shotspeed, by adding that div we stop it from doinf that
    local maxDistIdle = 40

    -- epic fetus increases range so you dont kill yourself so easily
    if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
        maxDistMove = maxDistMove+30
    end

    for idx= #ghosts, 1, -1 do
        local ghost = ghosts[idx] ---@cast ghost EntityFamiliar
        if not ghost or not ghost:Exists() then
            table.remove(ghosts, idx)
            goto continue
        end

        local ghostData = BeckyMod.GetEntData(ghost)
        local momentum = ghostData.BounceMomentum or 0
        shotSpeed = shotSpeed + momentum/4
        maxDistMove = maxDistMove + momentum*2
        local uc = ghostData.URETHRACHARGE or 0
        if not ghostData.URETHRABLAST then
            uc = 1
        else
            uc = 1-(math.min(uc,1)*.7)
        end
        local ghostTrail = ghostData.GhostTrail 

        if not ghostTrail or not ghostTrail:Exists() then
            ghostTrail = SpawnTrail(ghost)
        end

        local famPos = ghost.Position
        local posDif = famPos - playerPos
        local posDifLenght = posDif:Length()
        
        local color = ghostTrail.Color

        if ghost.State > FamState.IDLE and ghost.State ~= FamState.DISABLE_IDLE then
           color.A = math.min(color.A + .05, 1)
        else
           color.A = math.max(color.A - .05, 0)
        end
        local testColor = ghost:GetColor()
        
        ghostTrail:GetSprite().Scale = Vector(2,2)+Vector.One*momentum*.5
        ghostTrail.Color = Color(testColor.R, testColor.G, testColor.B, color.A, testColor.RO, testColor.GO, testColor.BO)
        if ghost.SubType == FamSubType.HOMING then
            local target = ghost.Target
            local ghostPos = ghost.Position
            if target and not IsValidEnemy(target) then
                target = nil
                ghost.Target = nil
            end
            if target == nil then
                if ghost.FrameCount % 5 == 0 then
                    local dis = 80
                    for _, ent in ipairs(Isaac.FindInRadius(ghostPos, 80, EntityPartition.ENEMY)) do
                        local ent = ent:ToNPC()
                        if ent and IsValidEnemy(ent) and (dis == nil or ent.Position:Distance(ghostPos) < dis) then
                            target = ent
                            dis = ent.Position:Distance(ghostPos)
                        end
                    end
                    if target then
                        ghost.State = FamState.AUTO_ATTACK
                        ghost.Target = target
                    end
                end
            else
                ghost.State = FamState.AUTO_ATTACK
                if ghost.FrameCount % 6 == 0 then
                    local dis = 40
                    for _, ent in ipairs(Isaac.FindInRadius(ghostPos, 40, EntityPartition.ENEMY)) do
                        local ent = ent:ToNPC()
                        if ent and IsValidEnemy(ent) and (dis == nil or ent.Position:Distance(ghostPos) < dis) then
                            target = ent
                            dis = ent.Position:Distance(ghostPos)
                        end
                    end
                    if target then
                        ghost.Target = target
                    end
                elseif ghost.FrameCount % 3 == 0 and target.Position:Distance(ghostPos) >= 120 then
                    target = nil
                    ghost.State = FamState.IDLE
                end
            end
        end

        if ghost.State == FamState.AUTO_ATTACK then
            local target = ghost.Target
            if target == nil or target:IsDead() or not target:Exists() then
                target = nil
                ghost.State = FamState.IDLE
                return
            end
            local resizer = 1.5 * shotSpeed
            ghost.Velocity = ghost.Velocity + (ghost.Target.Position - ghost.Position):Normalized():Resized(resizer)*uc

            if not BeckyHasBirthright(player) and (posDifLenght >= maxDistMove) then
                ghost.Velocity = ghost.Velocity - (posDif:Normalized() * (posDifLenght / maxDistMove)) *uc
            end
        elseif ForceTargetPos or isShooting then
            if ForceTargetPos or not player:AreOpposingShootDirectionsPressed() then
                if ghost.State == FamState.DISABLE_IDLE or ghost.State == FamState.DISABLE_MOVE then
                    ghost.State = FamState.DISABLE_MOVE
                else
                    ghost.State = FamState.ATTACKING
                end
                local targetPos
                if ForceTargetPos then
                    targetPos = ForceTargetPos - ghost.Position
                else
                    
                    local input = {
                        up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
                        down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex),
                        left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
                        right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
                    }

                    local MirrorInversor = room:IsMirrorWorld() and -1 or 1

                    local VectorX = ((input.left > 0.3 and -input.left) or (input.right > 0.3 and input.right) or 0) * MirrorInversor
                    local VectorY = ((input.up > 0.3 and -input.up) or (input.down > 0.3 and input.down) or 0)
                    
                    targetPos = Vector(VectorX, VectorY)
                end

                if player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM) then
                    local removeTrail = false
                    if not ghostData.Continuum_X then
                        if famPos.X < RoomLimits.X1 then
                            ghostData.Continuum_X = true
                            ghostData.Continuum_RightLoop = true
                            famPos.X = RoomLimits.X2
                            removeTrail = true
                        elseif famPos.X > RoomLimits.X2 then
                            ghostData.Continuum_X = true
                            famPos.X = RoomLimits.X1
                            removeTrail = true
                        end
                    else
                        if not ghostData.Continuum_RightLoop and famPos.X < RoomLimits.X1 then
                            ghostData.Continuum_X = false
                            famPos.X = RoomLimits.X2
                            removeTrail = true
                        elseif ghostData.Continuum_RightLoop and famPos.X > RoomLimits.X2 then
                            ghostData.Continuum_X = false
                            ghostData.Continuum_RightLoop = false
                            famPos.X = RoomLimits.X1
                            removeTrail = true
                        end
                    end
                    if not ghostData.Continuum_Y then
                        if famPos.Y < RoomLimits.Y1 then
                            ghostData.Continuum_Y = true
                            ghostData.Continuum_BottomLoop = true
                            famPos.Y = RoomLimits.Y2
                            removeTrail = true
                        elseif famPos.Y > RoomLimits.Y2 then
                            ghostData.Continuum_Y = true
                            famPos.Y = RoomLimits.Y1
                            removeTrail = true
                        end
                    else
                        if not ghostData.Continuum_BottomLoop and famPos.Y < RoomLimits.Y1 then
                            ghostData.Continuum_Y = false
                            famPos.Y = RoomLimits.Y2
                            removeTrail = true
                        elseif ghostData.Continuum_BottomLoop and famPos.Y > RoomLimits.Y2 then
                            ghostData.Continuum_Y = false
                            ghostData.Continuum_BottomLoop = false
                            famPos.Y = RoomLimits.Y1
                            removeTrail = true
                        end
                    end

                    if removeTrail then
                        ghost.Position = famPos
                        ghostTrail:Remove() -- we remove the trail so it doesn't appear throu the middle of the screen
                    end
                    
                    if ghostData.Continuum_X then
                        if ghostData.Continuum_RightLoop then
                            playerPos.X = RoomLimits.X2 + (playerPos.X - RoomLimits.X1)
                        else
                            playerPos.X = RoomLimits.X1 - (RoomLimits.X2 - playerPos.X)
                        end
                    end
                    if ghostData.Continuum_Y then
                        if ghostData.Continuum_BottomLoop then
                            playerPos.Y = RoomLimits.Y2 + (playerPos.Y - RoomLimits.Y1)
                        else
                            playerPos.Y = RoomLimits.Y1 - (RoomLimits.Y2 - playerPos.Y)
                        end
                    end
                    posDif = famPos - playerPos
                    posDifLenght = posDif:Length()
                end

                local resizer = 1.5 * shotSpeed
                local final = targetPos:Normalized():Resized(resizer)
                if player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ) or (player:GetRUAWizardTimer() > 0) then
                    --local angle = 45*(((ghostData.GHOST_IDX or 1) % 2)*2+-1)
                    local angle = 90*(idx % 2) -45
                    final = final:Rotated(angle)
                end
                ghost.Velocity = ghost.Velocity + final*uc
                
                if not BeckyHasBirthright(player) and (posDifLenght >= maxDistMove) then
                    ghost.Velocity = ghost.Velocity - (posDif:Normalized() * (posDifLenght / maxDistMove))*uc
                end

                if totalGhostPosition then
                    totalGhostPosition = totalGhostPosition + ghost.Position
                else
                    totalGhostPosition = ghost.Position
                end
            end
        else
            ghostData.Continuum_X = false
            ghostData.Continuum_RightLoop = false
            ghostData.Continuum_Y = false
            ghostData.Continuum_BottomLoop = false

            if ghost.State == FamState.DISABLE_MOVE or ghost.State == FamState.DISABLE_IDLE then
                ghost.State = FamState.DISABLE_IDLE
            else
                ghost.State = FamState.IDLE
            end
            if posDifLenght > maxDistIdle then
                ghost.Velocity = ghost.Velocity - (posDif:Normalized() * (posDifLenght / maxDistIdle)) *uc
            end
        end
        

        if playerAppear then
            ghost.Velocity = Vector.Zero
        end
        ::continue::
    end
    
    if not ForceTargetPos and isShooting and totalGhostPosition ~= nil then
        local dir = (totalGhostPosition - (playerPos * #ghosts)):Normalized()
        player:SetHeadDirection(VectorToDirection(dir) or Direction.DOWN, 4, true)
    end
end)


local function RepositionFamiliars()
    for _, ghost in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, GHOST_BALL_VAR)) do
        local fam = ghost:ToFamiliar() ---@cast fam EntityFamiliar
        fam.Position = fam.Player.Position + Vector(3, 0):Rotated(math.random(360))
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, RepositionFamiliars)
BeckyMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, RepositionFamiliars)

local function CheckTableForGhost(tab, ghost)
    for i, gh in ipairs(tab) do
        if gh.InitSeed == ghost.InitSeed then
            return true
        end
    end
    return false
end

---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    local ghostData = BeckyMod.GetEntData(familiar)
    local GhostSprite = familiar:GetSprite()
    local player = familiar.Player
    local room = BeckyMod.Game:GetRoom()
    local currentAnim = GhostSprite:GetAnimation()
    local IsPlayingRegTear1 = GhostSprite:IsPlaying("RegularTear1")
    local GhostSize = Vector.One * exp((player.Damage / 5) * ghostData.ChocolateMilkMult, 1, 1.2)
    local gridFromPos = room:GetGridEntityFromPos(familiar.Position+familiar.Velocity/2)

    if (not ghostData.TEARPARAMS) or (ghostData.TEARPARAMS and familiar.FrameCount % 6 == 0) then
        ghostData.TEARPARAMS = player:GetTearHitParams(WeaponType.WEAPON_TEARS, 4/3, 1, familiar)
    end
    local tearParams = ghostData.TEARPARAMS or player:GetTearHitParams(WeaponType.WEAPON_TEARS, 4/3, 1, familiar)
    local flat = 0
    if tearParams.TearFlags & TearFlags.TEAR_FLAT == TearFlags.TEAR_FLAT then
        flat = math.max(player:GetTrinketMultiplier(TrinketType.TRINKET_FLAT_WORM), 1)
    end
    local wide = (flat+player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PUPULA_DUPLEX))*.5

    local pulse = 0
    if tearParams.TearFlags & TearFlags.TEAR_PULSE == TearFlags.TEAR_PULSE then
        local base = .4*math.max(player:GetTrinketMultiplier(TrinketType.TRINKET_PULSE_WORM), 1)
        pulse = (base/2)+math.sin(familiar.FrameCount/3)*(base/2)
    end
    familiar.SizeMulti = (GhostSize*Vector(1+wide, 1+wide))*(pulse+1) -- making it an oval would probably mess some other stuff up
    familiar.SpriteScale = (GhostSize*Vector(1+wide, 1))*(pulse+1)


    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
        ghostData.ChocolateMilkMult = math.min(ghostData.ChocolateMilkMult +0.035, 2.5)
    else
        ghostData.ChocolateMilkMult = 1
    end


    if ShouldGhostPog() then
        if not GhostSprite:IsPlaying("Pog") or GhostSprite:IsFinished("Pog") then
            GhostSprite:Play("Pog")
        end
    else
        if familiar.FrameCount % 90 == 0 and IsPlayingRegTear1 then
            local rng = player:GetCollectibleRNG(GHOST_AMULET.ID)
            local randomNum = rng:RandomInt(1, 4)

            if randomNum ~= 4 then
                GhostSprite:Play(Anims[randomNum])
            end
        end

        if not IsPlayingRegTear1 and GhostSprite:IsFinished(currentAnim) then
            GhostSprite:Play("RegularTear1")
        end
    end

    if familiar.SubType == FamSubType.HOMING then
        familiar.Color = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549)
    else
        familiar.Color = Color.Default
    end
    if familiar.SubType == FamSubType.BOOKWORM then
        if familiar.FireCooldown > 0 then
            familiar.FireCooldown = familiar.FireCooldown -1
        else
            if Random() % 2 == 0 then
                familiar.State = FamState.IDLE
                familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
                familiar:GetSprite().Color.A = 1
            else
                familiar.State = FamState.DISABLE_IDLE
                familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                familiar:GetSprite().Color.A = 0.33
            end
            familiar.FireCooldown = 150
        end
    end

    if familiar.State == FamState.DISABLE_IDLE or familiar.State == FamState.DISABLE_MOVE then
        familiar:GetSprite().Color.A = 0.33
        
    else
        if gridFromPos and (familiar.FrameCount % 5 == 0 or (tearParams.TearFlags & TearFlags.TEAR_ROCK == TearFlags.TEAR_ROCK)) then
            local hurtVal = 1
    
            if gridFromPos:ToPoop() and gridFromPos:GetVariant() == 3 then
                hurtVal = gridFromPos:GetRNG():RandomInt(3) + 1 
            end
    
            gridFromPos:Hurt(hurtVal)
            if (math.random()<=.45 and (tearParams.TearFlags & TearFlags.TEAR_ACID == TearFlags.TEAR_ACID)) or (tearParams.TearFlags & TearFlags.TEAR_ROCK == TearFlags.TEAR_ROCK) then
                gridFromPos:Destroy()
            end
        end
    end
    ghostData.ANGELICCD = math.max((ghostData.ANGELICCD or 0)-1, 0)

    for _, gh in ipairs(Isaac.FindInCapsule(familiar:GetCollisionCapsule())) do
        if gh.Type == EntityType.ENTITY_FAMILIAR then
            local vel = (familiar.Position - gh.Position):Resized(1)
            if vel:Length() < 1 then vel = Vector(1,0):Rotated(vel:GetAngleDegrees()) end

            familiar.Velocity = familiar.Velocity + vel
            if gh.Variant == familiar.Variant then
                gh.Velocity = gh.Velocity - vel
            elseif gh.Variant == FamiliarVariant.ANGELIC_PRISM and (ghostData.ANGELICCD == 0) then
                ghostData.ANGELICCD = (player.MaxFireDelay+1)*.67
                local colors = {
                    {0.541176, 0.607843, -0.392157},
                    {-0.392157, 0.607843, -0.262745},
                    {-0.392157, 0.403922, 0.607843},
                    {0.607843, -0.392157, -0.392157}
                }
                for i = 1, 4 do
                    local tear = player:FireTear(gh.Position, Vector(1, 0):Rotated((i/4)*360) * (player.ShotSpeed * 10))
                    tear:SetPrismTouched(true)
                    tear.Color = tear.Color*Color(1,1,1,1,colors[i][1], colors[i][2], colors[i][3])
                end
            end
            
        end
    end
    --- Lump of coal and prop
    local distance = (player.Position - familiar.Position):Length()
    local grow = Vector.Zero
    if (tearParams.TearFlags & TearFlags.TEAR_GROW == TearFlags.TEAR_GROW) then
        grow = Vector.One * distance / 550
        ghostData.CoalBonus = distance / 35
    else
        ghostData.CoalBonus = 0
    end
    local shrink = Vector.One
    if (tearParams.TearFlags & TearFlags.TEAR_SHRINK == TearFlags.TEAR_SHRINK) then
        local distance = math.max(distance - 60, 0)
        shrink = (Vector.One * 1.5) * (250 / (distance + 250))
        ghostData.ProptosisMulti = (5 / ((distance / 5) + 5))
    else
        ghostData.ProptosisMulti = 1
    end
    
    if ghostData.BounceMomentum > 0 then
        ghostData.BounceMomentum = math.max((ghostData.BounceMomentum * .997) - .02, 0)
        familiar.Color = familiar.Color * Color( 1,  math.max(1- ghostData.BounceMomentum/30, 0), math.max(1- ghostData.BounceMomentum/6, 0), 1, 0, 0, 0)
    end
    familiar.SpriteScale = (familiar.SpriteScale + grow + Vector.Zero*ghostData.BounceMomentum) * shrink
    familiar.SizeMulti = (familiar.SizeMulti + grow + Vector.Zero*ghostData.BounceMomentum) * shrink

    Isaac.RunCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, familiar, tearParams)
end, GHOST_BALL_VAR)

---@param familiar EntityFamiliar
---@param offset Vector
BeckyMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function (_, familiar, offset)
    local ghostData = BeckyMod.GetEntData(familiar)
    local ghostTrail = ghostData.GhostTrail 
    if ghostTrail then
        ghostTrail.ParentOffset = familiar.PositionOffset
    end
    Isaac.RunCallback(BeckyMod.Callbacks.GHOST_RENDER_HELPER, familiar, offset)
end, GHOST_BALL_VAR)

local DestroyableFireplaces = {
    [0] = true,
    [1] = true,
    [10] = true,
    [11] = true,
}

--- its public so the piercing copies can force a collision with custom properties
---@param familiar EntityFamiliar
---@param collider Entity
---@param low boolean
---@param position Vector?
---@param params TearParams?
---@param damage number?
---@param ghostCopy boolean?
function BeckyMod:GhostBallCollide(familiar, collider, low, position, params, damage, ghostCopy)
    if (familiar.State == FamState.DISABLE_IDLE or familiar.State == FamState.DISABLE_MOVE)  and not ghostCopy then return false end
    local npc = collider and collider:ToNPC()
    
    local player = familiar.Player
    local ghostData = BeckyMod.GetEntData(familiar)
    local sprite = familiar:GetSprite()
    local tearParams = params or ghostData.TEARPARAMS or player:GetTearHitParams(WeaponType.WEAPON_TEARS, 4/3, 1, familiar)
    local baseDamage = (GHOST_AMULET:GetGhostDamage(player, damage or tearParams.TearDamage) + (ghostData.CoalBonus or 0)) * ghostData.ChocolateMilkMult * (ghostData.ProptosisMulti or 1)
    baseDamage = baseDamage*(1+((ghostData.DeadEyeMulti and ghostData.DeadEyeMulti.Multi) or 0)) -- Dead Eye
    local multi = 1

    if tearParams.TearFlags & TearFlags.TEAR_KNOCKBACK == TearFlags.TEAR_KNOCKBACK then
        multi = 1.5
    end
    if collider.Type == EntityType.ENTITY_MOVABLE_TNT or (collider.Type == EntityType.ENTITY_FIREPLACE and DestroyableFireplaces[collider.Variant]) then
        collider:TakeDamage(baseDamage, 0, EntityRef(familiar), 1)
    end

    if familiar.State == FamState.IDLE and not ghostCopy then return true end

    if collider.Type == EntityType.ENTITY_BOMB then
        TriggerPush(collider, familiar, 8*multi)
    end

    if not npc then return end
    if not IsValidEnemy(npc) then return end
    
    if not ghostCopy then
        sprite:Play("Hit",true)
        TriggerPush(npc, familiar, 20 * GHOST_AMULET:GetGhostTearMult(player)*multi)
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
            TriggerPush(familiar, npc, 10+ghostData.BounceMomentum*2)
        end
        if tearParams.TearFlags & TearFlags.TEAR_BOUNCE == TearFlags.TEAR_BOUNCE then
            ghostData.BounceMomentum = math.min(ghostData.BounceMomentum + .7, 6)
        end
        BeckyMod.SFX:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.7, 0, false, 1.5)
    else
        BeckyMod.SFX:Play(SoundEffect.SOUND_MEAT_IMPACTS_OLD, 0.4, 0, false, 1)
    end

    
    
    
    if npc:IsBoss() and npc:HasEntityFlags(EntityFlag.FLAG_AMBUSH) and npc.FrameCount < 29 then baseDamage = baseDamage /3 -- bosses that are spawning on an ambush (challenge and greed waves) takes less damage
    end
    Isaac.RunCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, familiar, collider, tearParams, position or familiar.Position, ghostCopy)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then ghostData.ChocolateMilkMult = 0.75 end

    npc:TakeDamage(baseDamage, 0, EntityRef(familiar), 1)

    if baseDamage >= npc.HitPoints then
        --print("Triggered kill enemy callback")
        Isaac.RunCallback(BeckyMod.Callbacks.ON_GHOST_KILL_ENEMY, familiar, collider, tearParams)
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, BeckyMod.GhostBallCollide, GHOST_BALL_VAR)


BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local room = BeckyMod.Game:GetRoom()
    local width = (room:GetGridWidth() /2 +2) *40
    local height = (room:GetGridHeight() /2 +2) *40
    local center = room:GetCenterPos()
    RoomLimits.X1 = center.X - width
    RoomLimits.Y1 = center.Y - height
    RoomLimits.X2 = center.X + width
    RoomLimits.Y2 = center.Y + height

end)

