local t = {}

BeckyMod.Character.BECKY_B = t

t.P_GHOST = Isaac.GetPlayerTypeByName("Becky's Ghost", true)
t.P_HELPER = Isaac.GetPlayerTypeByName("Tainted Becky Helper")
t.F_BECKY = Isaac.GetEntityVariantByName("Tainted Becky")
t.HEART_Y_OFFSET = Vector(0, -1 / 3)
t.WANDER_PICK_POS_FREQ = 90
t.WANDER_PICK_POS_MAX_ATTEMPTS = 100
t.WANDER_PIX_POS_DIST = 120
t.WALK_ANIM_MARGIN = 0.5
t.WALK_SPEED = 0.5
t.HEART_HUD_POS = Vector(432, 243)
t.STANDING_STILL_VEL_MULT = 0.7
t.MUNCH_DURATION = 30 * 3
t.DAMAGE_DELAY = 30
t.TARGET_SEARCH_RADIUS = 40 * 2
t.DASH_SPEED = 9
t.DASH_VEL_MULT = 0.9
t.ATTACK_DELAY = 20

---@type table<CacheFlag, boolean>
t.FOUND_HUD_CACHED_STATS = {
    [CacheFlag.CACHE_SPEED] = true,
    [CacheFlag.CACHE_FIREDELAY] = true,
    [CacheFlag.CACHE_DAMAGE] = true,
    [CacheFlag.CACHE_RANGE] = true,
    [CacheFlag.CACHE_SHOTSPEED] = true,
    [CacheFlag.CACHE_LUCK] = true,
}

---@enum TaintedBeckyState
t.State = {
    IDLE = 0,
    MOUTH_OPEN = 1,
    CHEW = 2,
    PREP_ATTACK = 3,
    ATTACK = 4,
}

---@param entity Entity
function t:GetData(entity)
    local data = entity:GetData()
    data.____BECKY_B = data.____BECKY_B or {}
    return data.____BECKY_B
end

---@param entity Entity
function t:GetSave(entity)
    local save = BeckyMod.SaveManager.GetRunSave(entity)
    save.____BECKY_B = save.____BECKY_B or {}
    return save.____BECKY_B
end

---@param entity Entity
function t:GetGhostData(entity)
    ---@class TaintedGhostData
    ---@field BlockAddCollectible boolean
    return t:GetData(entity)
end

---@param entity Entity
function t:GetGhostSave(entity)
    ---@class TaintedGhostSave
    return t:GetSave(entity)
end

---@param entity Entity
function t:GetHelperData(entity)
    ---@class TaintedBeckyHelperData
    ---@field Familiar EntityFamiliar
    return t:GetData(entity)
end

---@param entity Entity
function t:GetHelperSave(entity)
    ---@class TaintedBeckyHelperSave
    return t:GetSave(entity)
end

---@param entity Entity
function t:GetBeckyData(entity)
    ---@class TaintedBeckyData
    ---@field Helper EntityPlayer
    ---@field State TaintedBeckyState
    ---@field StateFrame integer
    ---@field TargPos Vector
    return t:GetData(entity)
end

---@param data TaintedBeckyData
---@param state TaintedBeckyState
function t:SetState(data, state)
    data.State = state
    data.StateFrame = 0
end

---To display a player's stats on the Found HUD, it must be initialized with `Parent` `nil`.
---
---To prevent the Controller Disconnected warning on alt tab/run continue, `Parent` must be set.
---
---Displayed stats are only updated while `Parent` is `nil`.
---
---@param player EntityPlayer Twin
function t:UpdateHelperHUD(player)
    player.Parent = nil
end

---@param player EntityPlayer
function t:HasEligibleQueuedItem(player)
    return player.QueuedItem.Item and (player.QueuedItem.Item.Type == ItemType.ITEM_PASSIVE or player.QueuedItem.Item.Type == ItemType.ITEM_FAMILIAR)
end

---@param player EntityPlayer
---@param flag CacheFlag
BeckyMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.EARLY, function (_, player, flag)
    ---@type PlayerType?
    local type

    if t.FOUND_HUD_CACHED_STATS[flag] and player.FrameCount > 0 then
        type = player:GetPlayerType()
        if type == t.P_HELPER then
            t:UpdateHelperHUD(player)
        end
    end

    if flag == CacheFlag.CACHE_FLYING then
        type = type or player:GetPlayerType()
        if type == t.P_GHOST then
            player.CanFly = true
        end
    elseif flag == CacheFlag.CACHE_TEARFLAG then
        type = type or player:GetPlayerType()
        if type == t.P_GHOST then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
        end
    elseif flag == CacheFlag.CACHE_FAMILIARS then
        type = type or player:GetPlayerType()
        if type == t.P_GHOST then
            player:CheckFamiliar(
                t.F_BECKY,
                1,
                RNG(player.InitSeed)
            )
        end
    end
end)

---@param player EntityPlayer
---@param flag CacheFlag
BeckyMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, function (_, player, flag)
    if flag == CacheFlag.CACHE_TEARCOLOR then
        local type = player:GetPlayerType()
        if type == t.P_GHOST then
            local color = player.TearColor
            color.R = color.R * 1.5
            color.G = color.G * 2
            color.B = color.B * 2
            color.A = color.A * 0.5
            player.TearColor = color
        end
    elseif flag == CacheFlag.CACHE_SIZE then
        local type = player:GetPlayerType()
        if type == t.P_HELPER then
            player.SpriteScale = t.HEART_Y_OFFSET
        end
    end
end)

---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    ---@type integer?, EntityPlayer?
    local hash, twin

    for _, player in ipairs(PlayerManager.GetPlayers()) do
        if player:GetPlayerType() == t.P_HELPER and player.Parent then
            hash = hash or GetPtrHash(familiar.Player)
            if hash == GetPtrHash(player.Parent) then
                twin = player
                break
            end
        end
    end

    if not twin then
        twin = familiar.Player:InitTwin(t.P_HELPER)
        BeckyMod.Game:GetHUD():AssignPlayerHUDs()
    end

    local helperData = t:GetHelperData(twin)
    local familiarData = t:GetBeckyData(familiar)

    helperData.Familiar = familiar
    familiarData.Helper = twin
end, t.F_BECKY)

---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    local data = t:GetBeckyData(familiar)
    local pathfinder = familiar:GetPathFinder()
    local player = familiar.Player
    local rng = familiar:GetDropRNG()
    local sprite = familiar:GetSprite()
    local room = BeckyMod.Game:GetRoom()

    familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND -- ?

    if not data.State then
        t:SetState(data, t.State.IDLE)
    end

    if data.State == t.State.IDLE then
        if data.StateFrame % t.WANDER_PICK_POS_FREQ == 0 then
            for _ = 1, t.WANDER_PICK_POS_MAX_ATTEMPTS do
                data.TargPos = familiar.Position + rng:RandomVector():Resized(t.WANDER_PIX_POS_DIST)
                if pathfinder:HasPathToPos(data.TargPos, false) then
                    break
                end
            end
        end

        if data.TargPos then
            pathfinder:FindGridPath(data.TargPos, t.WALK_SPEED, 0, true)
        end

        if data.TargPos and familiar.Velocity:Length() > t.WALK_ANIM_MARGIN then
            if math.abs(familiar.Velocity.X) > math.abs(familiar.Velocity.Y) then
                familiar.FlipX = familiar.Velocity.X < 0

                if not sprite:IsPlaying("WalkSides") then
                    sprite:Play("WalkSides", true)
                end
            else
                if not sprite:IsPlaying("Walk") then
                    sprite:Play("Walk", true)
                end
            end
        else
            sprite:Play("Walk", true)
            familiar.Velocity = familiar.Velocity * t.STANDING_STILL_VEL_MULT
        end

        if t:HasEligibleQueuedItem(player) then
            t:SetState(data, t.State.MOUTH_OPEN)
            data.TargPos = nil
        elseif data.StateFrame > t.ATTACK_DELAY then
            local eligible = {}

            for _, v in ipairs(Isaac.FindInRadius(familiar.Position, t.TARGET_SEARCH_RADIUS, EntityPartition.ENEMY)) do
                if v:IsActiveEnemy() and v:IsVulnerableEnemy() and not v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                    eligible[#eligible + 1] = v
                end
            end

            table.sort(eligible, function (a, b)
                return a.Position:Distance(familiar.Position) < b.Position:Distance(familiar.Position)
            end)

            familiar.Target = eligible[1]

            if familiar.Target and room:CheckLine(familiar.Position, familiar.Target.Position, LineCheckMode.ENTITY) then
                t:SetState(data, t.State.PREP_ATTACK)
            end
        end
    end

    if data.State == t.State.PREP_ATTACK then
        if sprite:GetAnimation() ~= "Prepare" then
            sprite:Play("Prepare", true)
        end

        if familiar.Target then
            familiar.FlipX = familiar.Target.Position.X - familiar.Position.X < 0
            data.TargPos = familiar.Target.Position
        end

        if sprite:GetFrame() >= 8 then
            t:SetState(data, t.State.ATTACK)
        end
    end

    if data.State == t.State.ATTACK then
        if sprite:GetAnimation() ~= "Attack" then
            sprite:Play("Attack", true)
        end

        if data.TargPos then
            familiar.Velocity = familiar.Velocity + (data.TargPos - familiar.Position):Resized(t.DASH_SPEED)
            data.TargPos = nil
        else
            familiar.Velocity = familiar.Velocity * t.DASH_VEL_MULT
        end

        -- familiar.Velocity = (data.TargPos - familiar.Position) * 0.1

        if sprite:IsFinished() then
            t:SetState(data, t.State.IDLE)
        end

        ---@type EntityRef?
        local ref

        for _, v in ipairs(Isaac.FindInCapsule(familiar:GetCollisionCapsule())) do
            if v:IsVulnerableEnemy() and v:IsActiveEnemy(true) and not v:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                ref = ref or EntityRef(familiar)
                v:TakeDamage(player.Damage, DamageFlag.DAMAGE_COUNTDOWN, ref, t.DAMAGE_DELAY)
                v.Velocity = v.Velocity + (v.Position - familiar.Position):Resized(familiar.Velocity:Length())
                v.TargetPosition = v.Position + v.Velocity
            end
        end
    end

    if data.State == t.State.MOUTH_OPEN then
        if not sprite:IsPlaying("Mouth") then
            sprite:Play("Mouth", true)
        end

        if not t:HasEligibleQueuedItem(player) then
            t:SetState(data, t.State.IDLE)
        end

        familiar.Velocity = familiar.Velocity * t.STANDING_STILL_VEL_MULT
    end

    if data.State == t.State.CHEW then
        if not sprite:IsPlaying("Munching") then
            sprite:Play("Munching", true)
        end
        familiar.Velocity = familiar.Velocity * t.STANDING_STILL_VEL_MULT
        if data.StateFrame > t.MUNCH_DURATION then
            t:SetState(data, t.State.IDLE)
        end
    end

    data.StateFrame = data.StateFrame + 1
end, t.F_BECKY)

---@param player EntityPlayer
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CallbackPriority.LATE, function (_, player)
    local type = player:GetPlayerType()

    if type == t.P_HELPER then
        local helperData = t:GetHelperData(player)
        local parent = Isaac.GetPlayer(player:GetPlayerIndex() - 1)
        local parentData = t:GetGhostData(parent)

        --[[
            Set parent only after a frame has passed to ensure the player's stats are displayed on the Found HUD,
            set it every frame to prevent the Controller Disconnected warning, as `Parent` is reset to update displayed stats.
        ]]
        if player.FrameCount > 0 then
            player.Parent = parent
        elseif BeckyMod.Game.TimeCounter > 0 then -- Init Found HUD on run continue
            t:UpdateHelperHUD(player)
        end

        player.DepthOffset = 40 * 100
        player.FireDelay = 99

        if t:HasEligibleQueuedItem(parent) and parent.Position:Distance(player.Position) <= helperData.Familiar.Size then
            parentData.BlockAddCollectible = true
            parent:AnimateCollectible(parent.QueuedItem.Item.ID, "HideItem")
            parent:FlushQueueItem()
            parentData.BlockAddCollectible = false
            t:SetState(t:GetBeckyData(helperData.Familiar), t.State.CHEW)
        end
    end
end)

---Follow familiar, for some reason this is the only method I found that works seemingly perfect?
---@param player EntityPlayer
BeckyMod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, CallbackPriority.IMPORTANT, function (_, player)
    if BeckyMod.Game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end

    local type = player:GetPlayerType()

    if type == t.P_HELPER then
        local helperData = t:GetHelperData(player)

        if helperData.Familiar then
            player.Position = helperData.Familiar.Position
            player.Velocity = Vector.Zero
        end
    end
end)

---@param position Vector
---@param player EntityPlayer
BeckyMod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_HEARTS, CallbackPriority.EARLY, function (_, _, _, position, _, player)
    return player:GetPlayerType() == t.P_HELPER
    and (position - t.HEART_HUD_POS):Length() < 0.01
    or nil
end)

---@param entity Entity
---@param hook InputHook
BeckyMod:AddPriorityCallback(ModCallbacks.MC_INPUT_ACTION, CallbackPriority.EARLY, function (_, entity, hook)
    local player = entity and entity:ToPlayer()
    if not player or player:GetPlayerType() ~= t.P_HELPER then return end
    return hook == InputHook.GET_ACTION_VALUE and 0
end)

---@param entity Entity
BeckyMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, function (_, entity)
    local player = entity:ToPlayer() ---@cast player EntityPlayer
    if player:GetPlayerType() ~= t.P_HELPER then return end
    return false
end, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
BeckyMod:AddPriorityCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, CallbackPriority.EARLY, function (_, _, _, _, _, _, player)
    if t:GetGhostData(player).BlockAddCollectible then return false end
end)