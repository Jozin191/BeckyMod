local ITEM_GHOST_AMULET = Isaac.GetItemIdByName("Ghost Amulet")
local BeckyPlayerType = Isaac.GetPlayerTypeByName("Becky", false)
local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")
local GHOST_BALL_DMG = 1.25


BeckyMod.Callbacks = {}
--- Called every time the ghost hits an enemy
--- * Familiar: The ghost entity
--- * Entity: The entity hit by the ghost
BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY = "BeckyMod_ON_GHOST_HIT_ENEMY"
BeckyMod.Callbacks.ON_GHOST_KILL_ENEMY = "BeckyMod_ON_GHOST_KILL_ENEMY"

---@param npc EntityNPC
---@return boolean
local function IsValidEnemy(npc)
    return (npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy())
end

---@param player EntityPlayer
---@return boolean
local function HasGhostAmulet(player)
    return player:HasCollectible(ITEM_GHOST_AMULET)
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
---@return number
local function Round(n, decimalPlaces)
	decimalPlaces = decimalPlaces or 0
	local mult = 10^(decimalPlaces or 0)
	return math.floor(n * mult + 0.5) / mult
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

    if entData.GhostTrail then return end

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
    if ID ~= ITEM_GHOST_AMULET then return end
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
    local data = player:GetData()

    data.BookWormFlag = data.BookWormFlag or false 

    if data.BookWormFlag == true then return end
    if not player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) then return end
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)

    data.BookWormFlag = true
end)

---@param id CollectibleType
---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function (_, id, _, _, _, _, player)
    StopShooting(id, player)
    if not HasGhostAmulet(player) then return end
    if not MultiShotItems[id] then return end
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, function(player, ID)
    if ID ~= ITEM_GHOST_AMULET then return end
    player:SetCanShoot(true)
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end)

---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player)
    if not HasGhostAmulet(player) then return end
    local rng = RNG()
    local seed = math.max(Random(), 1)
    rng:SetSeed(seed, 35)

    local BookWormExtra = player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) and 1 or 0
    local num = player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() + (player:GetCollectibleNum(ITEM_GHOST_AMULET)-1) + BookWormExtra

    player:CheckFamiliar(GHOST_BALL_VAR, num, rng)
end, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	familiar:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK --[[@as EntityFlag]])
    familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS 
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

    for _, ghost in ipairs(ghosts) do ---@cast ghost EntityFamiliar
        if not ghost then goto continue end

        local ghostData = ghost:GetData()
        local ghostTrail = ghostData.GhostTrail 

        if not ghostTrail then
            ghostTrail = SpawnTrail(ghost)
        end

        local isShooting = IsPlayerShooting(player)
        local famPos = ghost.Position
        local playerPos = player.Position
        local shotSpeed = player.ShotSpeed
        local posDif = famPos - playerPos
        local posDifLenght = posDif:Length()	
        local maxDistMove = ((player.TearRange / 6.5) * 2.5) * (1 / shotSpeed) -- Max distance is affected by shotspeed, by adding that div we stop it from doinf that
        local maxDistIdle = 40
        local room = BeckyMod.Game:GetRoom()
        -- SpawnTrail(familiar)
        
        local color = ghostTrail.Color

        if ghost.State == 1 then
           color.A = math.min(color.A + .05, 1)
        else
           color.A = math.max(color.A - .05, 0)
        end

        ghostTrail.Color = Color(color.R, color.G, color.B, color.A, color.RO, color.GO, color.BO)

        if isShooting then
            if not player:AreOpposingShootDirectionsPressed() then
                ghost.State = 1
                local input = {
                    up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
                    down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex),
                    left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
                    right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
                }

                local MirrorInversor = room:IsMirrorWorld() and -1 or 1

                local VectorX = ((input.left > 0.3 and -input.left) or (input.right > 0.3 and input.right) or 0) * MirrorInversor
                local VectorY = ((input.up > 0.3 and -input.up) or (input.down > 0.3 and input.down) or 0)
                local resizer = 1.5 * shotSpeed

                ghost.Velocity = ghost.Velocity + (Vector(VectorX, VectorY):Normalized():Resized(resizer))


                if not BeckyHasBirthright(player) and (posDifLenght >= maxDistMove) then
                    ghost.Velocity = ghost.Velocity - (posDif:Normalized() * (posDifLenght / maxDistMove)) 
                end

                local dir = (famPos - playerPos):Normalized()
                player:SetHeadDirection(VectorToDirection(dir) or Direction.DOWN, 4, true)
            end
        else
            ghost.State = 0    
            if posDifLenght > maxDistIdle then
                ghost.Velocity = ghost.Velocity - (posDif:Normalized() * (posDifLenght / maxDistIdle)) 
            end
        end

        local sprite = player:GetSprite()

        if sprite:GetAnimation() == "Appear" then
            ghost.Velocity = Vector.Zero
        end

        for _, gh in ipairs(Isaac.FindInCapsule(ghost:GetCollisionCapsule())) do
            if gh.Type == ghost.Type then
                local vel = (ghost.Position - gh.Position):Resized(1)
                ghost.Velocity = ghost.Velocity + vel
                gh.Velocity = gh.Velocity - vel
            end
        end
        ::continue::
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function ()
    for _, ghost in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, GHOST_BALL_VAR)) do
        local fam = ghost:ToFamiliar() ---@cast fam EntityFamiliar
        fam.Position = fam.Player.Position + Vector(3, 0):Rotated(math.random(360))
    end
end)

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
    local GhostSprite = familiar:GetSprite()
    local player = familiar.Player
    local room = BeckyMod.Game:GetRoom()
    local currentAnim = GhostSprite:GetAnimation()
    local IsPlayingRegTear1 = GhostSprite:IsPlaying("RegularTear1")
    local GhostSize = Vector.One * exp((player.Damage / 5), 1, 1.2)
    local gridFromPos = room:GetGridEntityFromPos(familiar.Position)
    
    familiar.SizeMulti = GhostSize
    familiar.SpriteScale = GhostSize

    local playerData = player:GetData()

    playerData.GhostBalls = playerData.GhostBalls or {}
    if not CheckTableForGhost(playerData.GhostBalls, familiar) then
        table.insert(playerData.GhostBalls, familiar)
    end

    for k, v in ipairs(playerData.GhostBalls) do
        if not v:Exists() or v:IsDead() then
            table.remove(playerData.GhostBalls, k)
        end
    end

    if familiar.FrameCount % 90 == 0 and IsPlayingRegTear1 then
        local rng = player:GetCollectibleRNG(ITEM_GHOST_AMULET)
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
    local tearsMult = Round(BeckyMod:toTearsPerSecond(player.MaxFireDelay), 2) / 2.73
    local baseDamage = (GHOST_BALL_DMG * player.Damage) * tearsMult

    if collider.Type == EntityType.ENTITY_MOVABLE_TNT or (collider.Type == EntityType.ENTITY_FIREPLACE and DestroyableFireplaces[collider.Variant]) then
        collider:TakeDamage(baseDamage, 0, EntityRef(familiar), 1)
    end

    if familiar.State == 0 then return true end

    if collider.Type == EntityType.ENTITY_BOMB then
        TriggerPush(collider, familiar, 10)
    end

    if not npc then return end
    if not IsValidEnemy(npc) then return end
    familiar:GetSprite():Play("Hit")
    TriggerPush(npc, familiar, 20 * tearsMult)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
        TriggerPush(familiar, npc, 10)
    end
    SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS, 0.7, 0, false, 1.5)

    Isaac.RunCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, familiar, collider)

    npc:TakeDamage(baseDamage, 0, EntityRef(familiar), 1)

    if npc.HitPoints <= baseDamage then
        Isaac.RunCallback(BeckyMod.Callbacks.ON_GHOST_KILL_ENEMY, familiar, collider)
    end
end, GHOST_BALL_VAR)