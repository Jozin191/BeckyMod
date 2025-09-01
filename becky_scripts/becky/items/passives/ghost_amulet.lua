

    local ITEM_GHOST_AMULET = Isaac.GetItemIdByName("Ghost Amulet")
    local itemconfig = Isaac.GetItemConfig()
    local CONFIG_GHOST_BALL = itemconfig:GetCollectible(ITEM_GHOST_AMULET)

    local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")

    local GHOST_BALL_DMG = 1.5

---@param npc EntityNPC
---@return boolean
local function IsValidEnemy(npc)
    if npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
        return true
    end
    return false
end

---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    if player:HasCollectible(ITEM_GHOST_AMULET) then
        player:SetCanShoot(false)
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
    end
end)


---@param player EntityPlayer
---@param cacheflag CacheFlag
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, cacheflag)

    if player:HasCollectible(ITEM_GHOST_AMULET) then
        local rng = RNG()
        local seed = math.max(Random(), 1)
        rng:SetSeed(seed, 35)

        player:CheckFamiliar(GHOST_BALL_VAR, 1, rng)
    end
    
end, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	familiar:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
	familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
    familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS 
end, GHOST_BALL_VAR)

---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    local GhostSprite = familiar:GetSprite()
    local player = familiar.Player
    local playerFireDirection = player:GetFireDirection()
    local room = Game():GetRoom()

    if not GhostSprite:IsPlaying("RegularTear1") then
        GhostSprite:Play("RegularTear1")
    end

    if playerFireDirection == Direction.LEFT then
        familiar:AddVelocity((Vector(-1, 0)  * 1.2):Resized(2.5))
    elseif playerFireDirection == Direction.RIGHT then
        familiar:AddVelocity((Vector(1, 0)  * 1.2):Resized(2.5))
    elseif playerFireDirection == Direction.UP then
        familiar:AddVelocity((Vector(0, -1) * 1.2):Resized(2.5))
    elseif playerFireDirection == Direction.DOWN then
        familiar:AddVelocity((Vector(0, 1)  * 1.2):Resized(2.5))
    end

    local gridCollisionAtPos = room:GetGridCollisionAtPos(familiar.Position + familiar.Velocity)
    
    if gridCollisionAtPos == GridCollisionClass.COLLISION_WALL then
        familiar:AddVelocity(-familiar.Velocity * 2.4)
    end
    

end, GHOST_BALL_VAR)

---@param familiar EntityFamiliar
---@param collider Entity
---@param low boolean
BeckyMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, function (_, familiar, collider, low)
    local npc = collider and collider:ToNPC()
    local player = familiar.Player

    if npc then
        print("beep")
        if IsValidEnemy(npc) then
            npc:TakeDamage(GHOST_BALL_DMG * player.Damage, 0, EntityRef(familiar), 1)

            familiar:AddVelocity(-familiar.Velocity * 2.6)

            npc:AddVelocity(-familiar.Velocity * 0.8)
        end
    end
end, GHOST_BALL_VAR)