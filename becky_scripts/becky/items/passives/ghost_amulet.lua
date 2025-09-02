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

---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    if not player:HasCollectible(ITEM_GHOST_AMULET) then return end
    player:SetCanShoot(false)
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)

    if not Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) then return end

    for _, Ghost in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, GHOST_BALL_VAR)) do
        local fam = Ghost:ToFamiliar() ---@cast fam EntityFamiliar
        if GetPtrHash(fam.Player) ~= GetPtrHash(player) then goto continue end
        TriggerPush(fam, player, -(fam.Position:Distance(player.Position)) / 4)

        fam:GetData().IsDraggedByDropPress = true -- Im using vanilla's Entity:GetData() because idk if we have a reimplementation of it, if so, please replace it with that

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

    room:GetCamera():SetFocusPosition(interpolateVector2D(player.Position, familiar.Position, 0.6))

    if familiar.FrameCount % 90 == 0 and IsPlayingRegTear1 then
        local rng = player:GetCollectibleRNG(ITEM_GHOST_AMULET)
        local randomNum = rng:RandomInt(1, 4)

        if randomNum ~= 4 then
            GhostSprite:Play(Anims[randomNum])
        end
    end

    if famData.IsDraggedByDropPress then
        familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end

    if familiar.Velocity:Length() <= 5 and famData.IsDraggedByDropPress then
        famData.IsDraggedByDropPress = false
        familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
    end

    if not IsPlayingRegTear1 and GhostSprite:IsFinished(currentAnim) then
        GhostSprite:Play("RegularTear1")
    end

    local isShooting = IsPlayerShooting(player)

    if isShooting and not player:AreOpposingShootDirectionsPressed() then
        local input = {
			up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex),
			down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex),
			left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex),
			right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex),
		}

        local VectorX = ((input.left > 0.3 and -input.left) or (input.right > 0.3 and input.right) or 0)
		local VectorY = ((input.up > 0.3 and -input.up) or (input.down > 0.3 and input.down) or 0)
        
        familiar:AddVelocity((Vector(VectorX, VectorY) * 1.2):Resized(2.5))
    end

    local gridCollisionAtPos = room:GetGridCollisionAtPos(familiar.Position + familiar.Velocity)
    
    if gridCollisionAtPos == GridCollisionClass.COLLISION_WALL then
        familiar:AddVelocity(-familiar.Velocity * 2.4)
    end
end, GHOST_BALL_VAR)

---@param familiar EntityFamiliar
---@param collider Entity
BeckyMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, function (_, familiar, collider)
    local npc = collider and collider:ToNPC()
    local player = familiar.Player

    if not npc then return end
    if not IsValidEnemy(npc) then return end
    npc:TakeDamage(GHOST_BALL_DMG * player.Damage, 0, EntityRef(familiar), 1)

    familiar:GetSprite():Play("Hit")

    TriggerPush(npc, familiar, 20)
    TriggerPush(familiar, npc, 20)

    SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS, 0.7, 0, false, 1.5)
end, GHOST_BALL_VAR)