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
---@param flag CacheFlag
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flag)
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
    elseif flag == CacheFlag.CACHE_TEARCOLOR then
        type = type or player:GetPlayerType()
        if type == t.P_GHOST then
            local color = player.TearColor
            color.R = color.R * 1.5
            color.G = color.G * 2
            color.B = color.B * 2
            color.A = color.A * 0.5
            player.TearColor = color
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
    elseif flag == CacheFlag.CACHE_SIZE then
        type = type or player:GetPlayerType()
        if type == t.P_HELPER then
            player.SpriteScale = t.HEART_Y_OFFSET
        end
    end
end)

---@param familiar EntityFamiliar
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
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
            if familiar.Velocity:Length() > t.WALK_ANIM_MARGIN then
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
            end
            pathfinder:FindGridPath(data.TargPos, t.WALK_SPEED, 0, true)
        end
    end

    data.StateFrame = data.StateFrame + 1
end, t.F_BECKY)

---@param player EntityPlayer
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CallbackPriority.LATE, function (_, player)
    local type = player:GetPlayerType()

    if type == t.P_HELPER then
        --[[
            Set parent only after a frame has passed to ensure the player's stats are displayed on the Found HUD,
            set it every frame to prevent the Controller Disconnected warning, as `Parent` is reset to update displayed stats.
        ]]
        if player.FrameCount > 0 then
            player.Parent = Isaac.GetPlayer(player:GetPlayerIndex() - 1)
        elseif BeckyMod.Game.TimeCounter > 0 then -- Init Found HUD on run continue
            t:UpdateHelperHUD(player)
        end

        player.DepthOffset = 40 * 100
        player.FireDelay = 99
    end
end)

---Follow familiar, for some reason this is the only method I found that works seemingly perfect?
---@param player EntityPlayer
BeckyMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, function (_, player)
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

-- ---@param offset Vector
-- ---@param position Vector
-- ---@param unknown number
-- ---@param player EntityPlayer
-- BeckyMod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_HEARTS, function (_, offset, _, position, unknown, player)
--     if player:GetPlayerType() ~= t.P_HELPER then return end
-- end)

---@param entity Entity
---@param hook InputHook
BeckyMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function (_, entity, hook)
    local player = entity and entity:ToPlayer()
    if not player or player:GetPlayerType() ~= t.P_HELPER then return end
    return hook == InputHook.GET_ACTION_VALUE and 0
end)