local ITEM_GHOST_AMULET = Isaac.GetItemIdByName("Ghost Amulet")
local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")
local GHOST_BALL_DMG = 1.5

---@param npc EntityNPC
---@return boolean
local function IsValidEnemy(npc)
    return (npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy())
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

local function interpolateVector2D(vectorA, vectorB, t)
	local minT = (1 - t)
    return Vector(minT * vectorA.X + t * vectorB.X, minT * vectorA.Y + t * vectorB.Y)
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

---@param familiar EntityFamiliar
---@param player EntityPlayer
local function TriggerGhostDrag(familiar, player)
    TriggerPush(familiar, player, -(familiar.Position:Distance(player.Position)) / 4)
    familiar:GetData().IsDraggedByDropPress = true -- Im using vanilla's Entity:GetData() because idk if we have a reimplementation of it, if so, please replace it with that
end

---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    if not player:HasCollectible(ITEM_GHOST_AMULET) then return end
    player:SetCanShoot(false)
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)

    if not Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) then return end

    for _, Ghost in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, GHOST_BALL_VAR)) do
        local fam = Ghost:ToFamiliar() ---@cast fam EntityFamiliar
        if GetPtrHash(fam.Player) ~= GetPtrHash(player) then goto continue end
        TriggerGhostDrag(fam, player)
        ::continue::
    end
end)

---@param player EntityPlayer
---@param cacheflag CacheFlag
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, cacheflag)
    if not player:HasCollectible(ITEM_GHOST_AMULET) then return end
    local rng = RNG()
    local seed = math.max(Random(), 1)
    rng:SetSeed(seed, 35)

    player:CheckFamiliar(GHOST_BALL_VAR, 1, rng)
end, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	familiar:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK --[[@as EntityFlag]])
	familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
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
---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    local GhostSprite = familiar:GetSprite()
    local player = familiar.Player
    local room = BeckyMod.Game:GetRoom()
    local currentAnim = GhostSprite:GetAnimation()
    local IsPlayingRegTear1 = GhostSprite:IsPlaying("RegularTear1")
    local famData = familiar:GetData()
    local RangeSizeMult = (player.TearRange / 40) / 6.5 
    local GhostSize = Vector.One * exp(RangeSizeMult, 1, 1.6)
    local isShooting = IsPlayerShooting(player)
    local famVel = familiar.Velocity
    local famPos = familiar.Position
    local playerPos = player.Position

    familiar.SizeMulti = GhostSize
    familiar.SpriteScale = GhostSize

    room:GetCamera():SetFocusPosition(interpolateVector2D(playerPos, famPos, 0.6))

    if familiar.FrameCount % 90 == 0 and IsPlayingRegTear1 then
        local rng = player:GetCollectibleRNG(ITEM_GHOST_AMULET)
        local randomNum = rng:RandomInt(1, 4)

        if randomNum ~= 4 then
            GhostSprite:Play(Anims[randomNum])
        end
    end

    if famData.IsDraggedByDropPress then
        familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        
        if famVel:Length() <= 5 then
            familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
            famData.IsDraggedByDropPress = false
        end
    end

    if not IsPlayingRegTear1 and GhostSprite:IsFinished(currentAnim) then
        GhostSprite:Play("RegularTear1")
    end

    if isShooting and not player:AreOpposingShootDirectionsPressed() then
        local input = {
			up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
			down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex),
			left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
			right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
		}

        local TearsMult = Round(BeckyMod:toTearsPerSecond(player.MaxFireDelay), 2) / 2.73
        local VectorX = ((input.left > 0.3 and -input.left) or (input.right > 0.3 and input.right) or 0)
		local VectorY = ((input.up > 0.3 and -input.up) or (input.down > 0.3 and input.down) or 0)
        local resizer = 4.2 * exp(TearsMult, 0.9, 1.175)

        familiar:AddVelocity((Vector(VectorX, VectorY) * 1.2):Resized(resizer))
        familiar:MultiplyFriction(0.9)

        local dir = (famPos - playerPos):Normalized()
        player:SetHeadDirection(VectorToDirection(dir) or Direction.DOWN, 4, true)
    end

    local gridCollisionAtPos = room:GetGridCollisionAtPos(famPos + famVel)
    
    if gridCollisionAtPos == GridCollisionClass.COLLISION_WALL then
        familiar:AddVelocity(-famVel * 2.4)
    end
end, GHOST_BALL_VAR)

---@param familiar EntityFamiliar
---@param collider Entity
BeckyMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, function (_, familiar, collider)
    local npc = collider and collider:ToNPC()
    local player = familiar.Player
    local baseDamage = GHOST_BALL_DMG * player.Damage

    if not npc then return end
    if not IsValidEnemy(npc) then return end

    familiar:GetSprite():Play("Hit")
    npc:TakeDamage(baseDamage, 0, EntityRef(familiar), 1)
    TriggerPush(npc, familiar, 20 * familiar.Player.ShotSpeed)
    TriggerPush(familiar, npc, 20)
    SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS, 0.7, 0, false, 1.5)
end, GHOST_BALL_VAR)