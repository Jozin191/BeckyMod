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


---@param npc EntityNPC
---@return boolean
local function IsValidEnemy(npc)
    return (npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() and not npc:IsInvincible())
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
    local BookWormExtra = player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) and 1 or 0
    return player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() + (player:GetCollectibleNum(GHOST_AMULET.ID)-1) + BookWormExtra
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
    local entData = entity:GetData()

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
    local entData = entity:GetData()
    if not entData.GhostTrail then return end

    entData.GhostTrail:Remove()
    entData.GhostTrail = nil
end

---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, function(_, player)
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end)

---@param ID CollectibleType
---@param player EntityPlayer
local function StopShooting(ID, player)
    if ID ~= GHOST_AMULET.ID then return end
    player:SetCanShoot(false)
end 

local MultiShotItems = {
    [CollectibleType.COLLECTIBLE_20_20] = true,
    [CollectibleType.COLLECTIBLE_INNER_EYE] = true,
    [CollectibleType.COLLECTIBLE_MUTANT_SPIDER] = true,
    [CollectibleType.COLLECTIBLE_THE_WIZ] = true,
}

---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    if not HasGhostAmulet(player) then return end

    local data = player:GetData()
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
    if not data.BookWormFlag and player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) then
        updateFamCache = true
        data.BookWormFlag = true
    end

    if player.TearFlags & TearFlags.TEAR_HOMING == TearFlags.TEAR_HOMING then
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
    StopShooting(id, player)
    if not HasGhostAmulet(player) then return end
    if id == CollectibleType.COLLECTIBLE_CONTINUUM then
        local playerData = player:GetData()
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

BeckyMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function(player, ID)
    if ID ~= GHOST_AMULET.ID then return end
    if id == CollectibleType.COLLECTIBLE_CONTINUUM then
        local playerData = player:GetData()
        local ghosts = playerData.GhostBalls

        if not ghosts then return end
        for _, ghost in ipairs(ghosts) do
            if not ghost then goto continue end
            ghost.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            ::continue::
        end
    end
    player:SetCanShoot(true)
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end)

---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player)
    if not HasGhostAmulet(player) then return end
    local rng = RNG()
    local seed = math.max(Random(), 1)
    rng:SetSeed(seed, 35)

    -- respawning ghosts
    player:GetData().LAST_GHOST_CHECK = player:GetData().LAST_GHOST_CHECK or 0
    local num = GHOST_AMULET:GetGhostAmount(player)
    if player:GetData().LAST_GHOST_CHECK < num then
        player:CheckFamiliar(GHOST_BALL_VAR,0,rng)
    end
    player:GetData().LAST_GHOST_CHECK = num
    
    local fams = player:CheckFamiliarEx(GHOST_BALL_VAR, num, rng)
    for i, ghost in pairs(fams) do
        ghost:GetData().GHOST_IDX = i
    end
    if player.TearFlags & TearFlags.TEAR_HOMING == TearFlags.TEAR_HOMING then
        local fams = player:CheckFamiliarEx(GHOST_BALL_VAR, 1, rng, nil, 1)
        for _, ghost in pairs(fams) do
            ghost:GetData().GHOST_IDX = num+1
        end
    end
end, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    local ghostData = familiar:GetData()
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	familiar:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK --[[@as EntityFlag]])
    local player = familiar.Player

    if player then
        local playerData = player:GetData()
        playerData.GhostBalls = playerData.GhostBalls or {}
        table.insert(playerData.GhostBalls, familiar)
    end

    if player and player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM) then
        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    else
        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS 
    end

    if familiar.SubType == 1 then
        familiar.Color = Color(0.4, 0.15, 0.38, 1, 0.27843, 0, 0.4549)
    end
    ghostData.ChocolateMilkMult = 1
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
    local playerData = player:GetData()
    local ghosts = playerData.GhostBalls

    if not ghosts then return end

    local isShooting = IsPlayerShooting(player)
    local marked = player:GetMarkedTarget()
    local shotSpeed = player.ShotSpeed
    local maxDistMove = ((player.TearRange / 6.5) * 2.5) * (1 / shotSpeed) -- Max distance is affected by shotspeed, by adding that div we stop it from doinf that
    local maxDistIdle = 40
    local room = BeckyMod.Game:GetRoom()

    -- epic fetus increases range so you dont kill yourself so easily
    if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
        maxDistMove = maxDistMove+30
    end

    for _, ghost in ipairs(ghosts) do ---@cast ghost EntityFamiliar
        if not ghost then goto continue end

        local ghostData = ghost:GetData()
        local ghostTrail = ghostData.GhostTrail 

        if not ghostTrail or not ghostTrail:Exists() then
            ghostTrail = SpawnTrail(ghost)
        end

        local famPos = ghost.Position
        local playerPos = player.Position
        local posDif = famPos - playerPos
        local posDifLenght = posDif:Length()
        
        local color = ghostTrail.Color

        if ghost.State >= 1 then
           color.A = math.min(color.A + .05, 1)
        else
           color.A = math.max(color.A - .05, 0)
        end

        ghostTrail.Color = Color(color.R, color.G, color.B, color.A, color.RO, color.GO, color.BO)

        if ghost.SubType == 1 then
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
                        if IsValidEnemy(ent) and dis == nil or ent.Position:Distance(ghostPos) < dis then
                            target = ent
                            dis = ent.Position:Distance(ghostPos)
                        end
                    end
                    if target then
                        ghost.State = 2
                        ghost.Target = target
                    end
                end
            else
                ghost.State = 2
                if ghost.FrameCount % 6 == 0 then
                    local dis = 40
                    for _, ent in ipairs(Isaac.FindInRadius(ghostPos, 40, EntityPartition.ENEMY)) do
                        local ent = ent:ToNPC()
                        if IsValidEnemy(ent) and dis == nil or ent.Position:Distance(ghostPos) < dis then
                            target = ent
                            dis = ent.Position:Distance(ghostPos)
                        end
                    end
                    if target then
                        ghost.Target = target
                    end
                elseif ghost.FrameCount % 3 == 0 and target.Position:Distance(ghostPos) >= 120 then
                    target = nil
                    ghost.State = 0
                end
            end
        end

        if ghost.State == 2 then
            local target = ghost.Target
            if target == nil or target:IsDead() or not target:Exists() then
                target = nil
                ghost.State = 0
                return
            end
            local resizer = 1.5 * shotSpeed
            ghost.Velocity = ghost.Velocity + (ghost.Target.Position - ghost.Position):Normalized():Resized(resizer)

            if not BeckyHasBirthright(player) and (posDifLenght >= maxDistMove) then
                ghost.Velocity = ghost.Velocity - (posDif:Normalized() * (posDifLenght / maxDistMove)) 
            end
        elseif marked or isShooting then
            if marked or not player:AreOpposingShootDirectionsPressed() then
                ghost.State = 1
                local targetPos
                if marked then
                    targetPos = marked.Position - ghost.Position
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
                        ghostTrail:Remove()
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
                if player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ) or player:GetEffects():HasNullEffect(NullItemID.ID_WIZARD) then
                    local angle = 45*((ghostData.GHOST_IDX % 2)*2+-1)
                    final = final:Rotated(angle)
                end
                ghost.Velocity = ghost.Velocity + final

                if not BeckyHasBirthright(player) and (posDifLenght >= maxDistMove) then
                    ghost.Velocity = ghost.Velocity - (posDif:Normalized() * (posDifLenght / maxDistMove))
                end

                if not marked then
                    local dir = (famPos - playerPos):Normalized()
                    player:SetHeadDirection(VectorToDirection(dir) or Direction.DOWN, 4, true)
                end
            end
        else
            ghostData.Continuum_X = false
            ghostData.Continuum_RightLoop = false
            ghostData.Continuum_Y = false
            ghostData.Continuum_BottomLoop = false

            ghost.State = 0    
            if posDifLenght > maxDistIdle then
                ghost.Velocity = ghost.Velocity - (posDif:Normalized() * (posDifLenght / maxDistIdle)) 
            end
        end

        local sprite = player:GetSprite()

        if sprite:GetAnimation() == "Appear" then
            ghost.Velocity = Vector.Zero
        end
        ::continue::
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
    local ghostData = familiar:GetData()
    local GhostSprite = familiar:GetSprite()
    local player = familiar.Player
    local room = BeckyMod.Game:GetRoom()
    local currentAnim = GhostSprite:GetAnimation()
    local IsPlayingRegTear1 = GhostSprite:IsPlaying("RegularTear1")
    local GhostSize = Vector.One * exp((player.Damage / 5) * ghostData.ChocolateMilkMult, 1, 1.2)
    local gridFromPos = room:GetGridEntityFromPos(familiar.Position)
    local tearParams = player:GetTearHitParams(WeaponType.WEAPON_TEARS, 4/3, 1, familiar)

    familiar.SizeMulti = GhostSize
    familiar.SpriteScale = GhostSize

    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
        ghostData.ChocolateMilkMult = math.min(ghostData.ChocolateMilkMult +0.035, 2.5)
    else
        ghostData.ChocolateMilkMult = 1
    end

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

    if gridFromPos and familiar.FrameCount % 5 == 0 then
        local hurtVal = 1

        if gridFromPos:ToPoop() and gridFromPos:GetVariant() == 3 then
            hurtVal = gridFromPos:GetRNG():RandomInt(3) + 1 
        end

        gridFromPos:Hurt(hurtVal)
    end

    for _, gh in ipairs(Isaac.FindInCapsule(familiar:GetCollisionCapsule())) do
        if gh.Type == familiar.Type then
            local vel = (familiar.Position - gh.Position):Resized(1)
            if vel:Length() < 1 then vel = Vector(1,0):Rotated(vel:GetAngleDegrees()) end

            familiar.Velocity = familiar.Velocity + vel
            gh.Velocity = gh.Velocity - vel
        end
    end

    Isaac.RunCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, familiar, tearParams)
end, GHOST_BALL_VAR)

---@param familiar EntityFamiliar
---@param offset Vector
BeckyMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function (_, familiar, offset)
    --local tearParams = player:GetTearHitParams(WeaponType.WEAPON_TEARS, 1, 1, familiar)
    Isaac.RunCallback(BeckyMod.Callbacks.GHOST_RENDER_HELPER, familiar, offset--[[, tearParams]])
end, GHOST_BALL_VAR)

local DestroyableFireplaces = {
    [0] = true,
    [1] = true,
    [10] = true,
    [11] = true,
}

---@param familiar EntityFamiliar
---@param collider Entity
BeckyMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, function (_, familiar, collider)
    local npc = collider and collider:ToNPC()
    local player = familiar.Player
    local ghostData = familiar:GetData()
    local tearParams = player:GetTearHitParams(WeaponType.WEAPON_TEARS, 4/3, 1, familiar)
    local baseDamage = GHOST_AMULET:GetGhostDamage(player, tearParams.TearDamage) * ghostData.ChocolateMilkMult

    local multi = 1
    if tearParams.TearFlags & TearFlags.TEAR_KNOCKBACK == TearFlags.TEAR_KNOCKBACK then
        multi = 1.5
    end
    if collider.Type == EntityType.ENTITY_MOVABLE_TNT or (collider.Type == EntityType.ENTITY_FIREPLACE and DestroyableFireplaces[collider.Variant]) then
        collider:TakeDamage(baseDamage, 0, EntityRef(familiar), 1)
    end

    if familiar.State == 0 then return true end

    if collider.Type == EntityType.ENTITY_BOMB then
        TriggerPush(collider, familiar, 8*multi)
    end

    if not npc then return end
    if not IsValidEnemy(npc) then return end

    familiar:GetSprite():Play("Hit")
    TriggerPush(npc, familiar, 20 * GHOST_AMULET:GetGhostTearMult(player)*multi)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
        TriggerPush(familiar, npc, 10)
    end
    BeckyMod.SFX:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.6, 0, false, 1.5)

    Isaac.RunCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, familiar, collider, tearParams)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then ghostData.ChocolateMilkMult = 0.75 end

    npc:TakeDamage(baseDamage, 0, EntityRef(familiar), 1)

    if baseDamage >= npc.HitPoints then
        --print("Triggered kill enemy callback")
        Isaac.RunCallback(BeckyMod.Callbacks.ON_GHOST_KILL_ENEMY, familiar, collider, tearParams)
    end
end, GHOST_BALL_VAR)


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
