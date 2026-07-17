--- oh my god
local GHOSTBALL = Isaac.GetEntityVariantByName("Ghost Ball")

local Lifetime = 40
local Fadeout = 30
---@class GhostClone
---@field Position Vector
---@field Velocity Vector
---@field TearParams TearParams
---@field Hitlist table
---@field Damage number
---@field FrameCount integer
---@field Scale Vector
---@field Updated integer
---@field Rendered integer
---@field Sprite Sprite

---@param fam EntityFamiliar
---@return GhostClone[]
local function GetPiercingClones(fam)
    local data = BeckyMod.GetEntData(fam)
    data.PIERCINGCLONES = data.PIERCINGCLONES or {}
    return data.PIERCINGCLONES
end

---@param fam EntityFamiliar
---@param enemy EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams, position, copy)
    if copy then return end
    local player = fam.Player
    local clones = GetPiercingClones(fam)
    if not player then return end
    local piercing, trisag, belial = tearParams.TearFlags & TearFlags.TEAR_PIERCING == TearFlags.TEAR_PIERCING, tearParams.TearFlags & TearFlags.TEAR_LASERSHOT == TearFlags.TEAR_LASERSHOT,tearParams.TearFlags & TearFlags.TEAR_BELIAL == TearFlags.TEAR_BELIAL
    if piercing or trisag or belial then
        local ghoul = Sprite("gfx/items/GHOST_BALL.anm2", true)
        ghoul:Play("Ghost")
        local damage = tearParams.TearDamage/2
        if belial then
            damage = damage*2
        end
        if trisag then
            damage = damage/3
        end
        local clone = {
            Position = position,
            Velocity = (enemy.Position-fam.Position):Normalized()*9,
            Damage = damage,
            TearParams = tearParams,
            Hitlist = {[GetPtrHash(enemy)]=EntityPtr(enemy)},
            FrameCount = 0,
            Scale = Vector(fam.SpriteScale.X, fam.SpriteScale.Y),
            Sprite = ghoul,
            Updated = Isaac.GetTime(),
            Rendered = Isaac.GetTime()
        }
        table.insert(clones, clone)
    end
end)

---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam)
    local player = fam.Player
    local clones = GetPiercingClones(fam)
    for i, clone in ipairs(clones) do
        if clone.FrameCount <= Lifetime then
            local trisag, belial = clone.TearParams.TearFlags & TearFlags.TEAR_LASERSHOT == TearFlags.TEAR_LASERSHOT,clone.TearParams.TearFlags & TearFlags.TEAR_BELIAL == TearFlags.TEAR_BELIAL
            clone.Position = clone.Position+clone.Velocity
            clone.FrameCount = clone.FrameCount + 1
            if belial then
                local target, closest = nil, 125
                local targets = Isaac.FindInRadius(clone.Position, closest, EntityPartition.ENEMY)
                for _, enemy in pairs(targets) do
                    local dist = clone.Position:Distance(enemy.Position)
                    if BeckyMod.IsEnemy(enemy) and clone.Position:Distance(enemy.Position)<= dist and not clone.Hitlist[GetPtrHash(enemy)] then
                        target = enemy
                        closest = dist
                    end
                end
                if target then
                    clone.Velocity = clone.Velocity + (target.Position-clone.Position):Normalized()*2
                    clone.Velocity = clone.Velocity *.9
                end
            end
            local friends = Isaac.FindInRadius(clone.Position, 17*clone.Scale.X, EntityPartition.ENEMY)
            for _, enemy in pairs(friends) do
                local npc = enemy:ToNPC()
                if npc and ((trisag and clone.FrameCount % 3 == 0) or not clone.Hitlist[GetPtrHash(npc)]) then
                    clone.Hitlist[GetPtrHash(npc)] = EntityPtr(enemy)
                    BeckyMod:GhostBallCollide(fam, npc, false, clone.Position, clone.TearParams, clone.Damage, true)
                end
            end
            clone.Updated = Isaac.GetTime()
        else
            clone.Hitlist = nil
            table.remove(clones, i)
        end
    end
end)


---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_RENDER_HELPER, function(_, fam, offset)
    local player = fam.Player
    local clones = GetPiercingClones(fam)
    for i, clone in ipairs(clones) do
        if clone then
            local trisag, belial = clone.TearParams.TearFlags & TearFlags.TEAR_LASERSHOT == TearFlags.TEAR_LASERSHOT,clone.TearParams.TearFlags & TearFlags.TEAR_BELIAL == TearFlags.TEAR_BELIAL
            clone.Rendered = Isaac.GetTime() 
            local dt = math.abs((clone.Updated-clone.Rendered)/30)

            local pos = clone.Position+clone.Velocity*dt
            local trans = 1
            if clone.FrameCount >= Fadeout then
                trans = 1-((clone.FrameCount-Fadeout)/(Lifetime-Fadeout))
            end
            clone.Sprite.Scale = clone.Scale
            clone.Sprite.Color = Color(.7,.7,.7,trans*.75)
            if belial then
                clone.Sprite.Color = Color(.5,-.4,-.4,trans)
                clone.Sprite.PlaybackSpeed = 2
            elseif trisag then
                clone.Sprite.Color = Color(.8,.8,.9, trans*.6, 0.5, 0.8, 0.9)
                clone.Sprite.PlaybackSpeed = .5
            end

            clone.Sprite:Render(Isaac.WorldToRenderPosition(pos) + offset)
            if not Game():IsPaused() then clone.Sprite:Update() end
        end
    end
end)
--- Clear the ghosts when a new room is entered
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
    local ghosts = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, GHOSTBALL, 0, false)
    for _, v in pairs(ghosts) do
        local ghost = v and v:ToFamiliar()
        if ghost then
            local data = BeckyMod.GetEntData(ghost)
            if data then data.PIERCINGCLONES = {} end
        end
    end
end)