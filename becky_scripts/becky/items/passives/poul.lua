local POUL = {}
BeckyMod.Item.POUL = POUL

POUL.ID = Isaac.GetItemIdByName("Poul")
POUL.FAMILIAR = Isaac.GetEntityVariantByName("Polty (Familiar)")

local game = BeckyMod.Game

local GRID_DIS = Vector(40, 0)
local GRID_DIS_BIG = Vector(70, 0)
local GRID_DIS_REALLYBIG = Vector(110, 0)
POUL.SPEED = Vector(10,0)
POUL.COOLDOWN = 120
POUL.ATTACKING_COOLDOWN = 10
POUL.PROJ_SPEED = Vector(15,0)
local FAM_STATES = {
    IDLE = 0,
    SELECT_GRID =1,
    PICKING_GRID = 2,
    HOLDING_GRID = 3,
    TROWING_GRID =4,
    ATTACKING = 5,
    FOLLOW_PLAYER = 6,
}
POUL.STATES = FAM_STATES
POUL.CONTACT_DAMAGE = 3.25
POUL.PROJ_DAMAGE = 15

local CanPickupGridList = {}
local TaintedRocksList = {}

local VALID_GRID_TYPES = {
    [GridEntityType.GRID_ROCK] = true,
    [GridEntityType.GRID_ROCK_ALT] = true,
    [GridEntityType.GRID_ROCK_ALT2] = true,
    [GridEntityType.GRID_ROCK_BOMB] = true,
    [GridEntityType.GRID_ROCKT] = true,
    [GridEntityType.GRID_ROCK_SS] = true,
    [GridEntityType.GRID_ROCK_GOLD] = true,
    [GridEntityType.GRID_ROCK_ALT2] = true,
    [GridEntityType.GRID_POOP] = true,
}


local function GetSpriteSheet(t, v)
    if t == GridEntityType.GRID_POOP then
        if v == GridPoopVariant.RED then
            return "gfx/grid/grid_poop_red_1.png"
        elseif v == GridPoopVariant.CORN then
            return "gfx/grid/grid_poop_corn.png"
        elseif v == GridPoopVariant.GOLDEN then
            return "gfx/grid/grid_poop_gold.png"
        elseif v == GridPoopVariant.RAINBOW then
            return "gfx/grid/grid_poop_rainbow.png"
        elseif v == GridPoopVariant.BLACK then
            return "gfx/grid/grid_poop_black.png"
        elseif v == GridPoopVariant.HOLY then
            return "gfx/grid/grid_poop_white_1.png"
        elseif v == GridPoopVariant.GIANT_TL or v == GridPoopVariant.GIANT_TR or v == GridPoopVariant.GIANT_BL or v == GridPoopVariant.GIANT_BR then
            return "gfx/grid/grid_poop_giant.png"
        elseif v == GridPoopVariant.CHARMING then
            return "gfx/grid/grid_poop_charming.png"
        else
            return "gfx/grid/grid_poop_1.png"
        end
    elseif t == GridEntityType.GRID_TNT then
        return "gfx/grid/grid_tnt.png"
    else
        local xmldata = XMLData.GetEntryByOrder(XMLNode.BACKDROP, game:GetRoom():GetBackdropType())
        if xmldata.rocks == nil or xmldata.rocks == "" then
            return "gfx/grid/rocks_basement.png"
        elseif xmldata.gridgfxroot and xmldata.gridgfxroot ~= "" then
            return xmldata.gridgfxroot..xmldata.rocks
        else
            return xmldata.rocks
        end
    end
    return ""
end

local function SetGridSprite(target, grid, t, v)
    local sp = target:GetSprite()
    local gridSp = grid:GetSprite()
    
    sp:Load(gridSp:GetFilename(), true)
    local anim = gridSp:GetAnimation()
    local frame = gridSp:GetFrame()
    local spritesheet = GetSpriteSheet(t, v)
    
    if t == GridEntityType.GRID_ROCK and anim == "big" then
        anim = "normal"
        v = Random() % 3
        frame = v
    end

    sp:SetFrame(anim, frame)
    sp:ReplaceSpritesheet(0, spritesheet, true)

    --print(anim, frame, spritesheet, t, v)
end

local function ShootGrid(fam, vel)
    local grids = fam:GetData().Grids or {}
    local famPos = fam.Position
    local distace = fam.TargetPosition:Distance(famPos)
    if vel:Length() == 0 then distance = 0 end

    if #grids == 1 then
        local grid = grids[1]
        local gridTypeVar= grid:GetData().GridTypeVar
        local tear = Isaac.Spawn(2, TearVariant.GRIDENT, (gridTypeVar or 0), famPos, vel, grid):ToTear()
        
        local t = gridTypeVar >> 16
        local v = gridTypeVar & ~((~0) <<16)
        SetGridSprite(tear, grid, t, v)
        tear.TearFlags = TearFlags.TEAR_SPECTRAL
        tear.CollisionDamage = POUL.PROJ_DAMAGE
        tear.Height = -25
        tear:GetData().TargetDistance = {Dis = distace, Start = famPos}
        grid:Remove()
    else
        local rng = fam:GetDropRNG()
        for i, grid in ipairs(grids) do
            local rangeOffset = 20 * (i-1)
            if rangeOffset > 30 then rangeOffset = 30 end
            local gridTypeVar= grid:GetData().GridTypeVar
            local tear = Isaac.Spawn(2, TearVariant.GRIDENT, (gridTypeVar or 0), famPos, vel:Rotated( rng:RandomInt(rangeOffset *2) - rangeOffset ), grid):ToTear()
            
            local t = gridTypeVar >> 16
            local v = gridTypeVar & ~((~0) <<16)
            SetGridSprite(tear, grid, t, v)
            tear.TearFlags = TearFlags.TEAR_SPECTRAL
            tear.CollisionDamage = POUL.PROJ_DAMAGE
            tear.Height = -25 - (40 * (i-1))
            tear:GetData().TargetDistance = {Dis = distace, Start = famPos}
            grid:Remove()
        end
    end
    fam:GetData().Grids = {}
end

local function AddTaintedRock(gridIdx)
    table.insert(TaintedRocksList, gridIdx)
    TaintedRocksList.IsTaintedRockGrid = TaintedRocksList.IsTaintedRockGrid or {}
    TaintedRocksList.IsTaintedRockGrid[gridIdx] = #TaintedRocksList
end

local function RemoveTaintedRock(gridIdx)
    if TaintedRocksList.IsTaintedRockGrid and TaintedRocksList.IsTaintedRockGrid[gridIdx] then
        table.remove(TaintedRocksList, TaintedRocksList.IsTaintedRockGrid[gridIdx])
        TaintedRocksList.IsTaintedRockGrid = {}

        for i=1, #TaintedRocksList do
            TaintedRocksList.IsTaintedRockGrid[ TaintedRocksList[i] ] = i
        end
    end
end

local function FindGridTarget(fam, famData, hasBFFS)
    if not hasBFFS then
        famData.GridTarget = -1
        return false
    end
    
    local rng = fam:GetDropRNG()
    local room = game:GetRoom()
    local fromGrid = famData.GridTarget
    local fromPos = room:GetGridPosition( fromGrid )
    local grids = {}
    for i=-180, 135, 45 do
        local grid = room:GetGridEntityFromPos(fromPos + GRID_DIS:Rotated(i))
        if grid and room:CanPickupGridEntity(grid:GetGridIndex()) then table.insert(grids, grid:GetGridIndex()) end
    end
    if #grids == 0 then
        for i=-180, 150, 30 do
            local grid = room:GetGridEntityFromPos(fromPos + GRID_DIS_BIG:Rotated(i))
            if grid and room:CanPickupGridEntity(grid:GetGridIndex()) then table.insert(grids, grid:GetGridIndex()) end
        end
    end
    if #grids == 0 then
        for i=-180, 157.5, 22.5 do
            local grid = room:GetGridEntityFromPos(fromPos + GRID_DIS_REALLYBIG:Rotated(i))
            if grid and room:CanPickupGridEntity(grid:GetGridIndex()) then table.insert(grids, grid:GetGridIndex()) end
        end
    end

    if #grids == 0 then
        famData.GridTarget = -1
        return false
    end
    
    local rocks = 0
    if fam.Target then
        rocks = math.min(math.ceil(fam.Target.HitPoints /POUL.PROJ_DAMAGE), 5)
    else rocks = rng:RandomInt(1, 2) end
    if famData.Grids == nil or #famData.Grids >= rocks then
        famData.GridTarget = -1
        return false
    end

    famData.GridTarget = grids[rng:RandomInt(1, #grids)]
    fam.State = FAM_STATES.SELECT_GRID
    RemoveTaintedRock(famData.GridTarget)
    return true
end

local function GetEnemyTarget(fam)
    if fam.Target and (fam.Target:IsDead() or not fam.Target:Exists()) then fam.Target = nil end
    if not fam.Target then
        local enemiesList = {}
        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if ent:ToNPC() and not ent:IsDead() and ent:GetEntityFlags() & (EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN) == 0 and
                ent:CanShutDoors() and ent:IsActiveEnemy() then
                
                table.insert(enemiesList, ent)
            end
        end
        if #enemiesList > 0 then fam.Target = enemiesList[fam:GetDropRNG():RandomInt(1, #enemiesList)] end
    end
    return fam.Target
end


BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
    fam.FireCooldown = 75 -- 2.5 seconds
    fam.State = FAM_STATES.IDLE
    local famData = fam:GetData()
    famData.Grids = {}
    famData.GridTarget = -1
    fam:GetSprite():Play("Idle", true)
end, POUL.FAMILIAR)

BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local state = fam.State
    local player = fam.Player
    local rng = fam:GetDropRNG()
    local famData = fam:GetData()

    if state == FAM_STATES.SELECT_GRID then
        local room = game:GetRoom()

        if famData.GridTarget < 0 then
            if Isaac.CountEnemies() ==0 then
                if #TaintedRocksList >0 then
                    local tableIdx = rng:RandomInt(1, #TaintedRocksList)
                    famData.GridTarget = TaintedRocksList[ tableIdx ]
                    table.remove(TaintedRocksList, tableIdx)
                    RemoveTaintedRock(famData.GridTarget)
    
                    for i=1, #TaintedRocksList do
                        TaintedRocksList.IsTaintedRockGrid[ TaintedRocksList[i] ] = i
                    end
                    fam.Target = player
                    return
                else
                    fam.State = FAM_STATES.FOLLOW_PLAYER
                    return
                end
            end
            
            while #CanPickupGridList > 0 do
                local tableIdx = rng:RandomInt(1, #CanPickupGridList)
                local idx = CanPickupGridList[ tableIdx ]
                table.remove(CanPickupGridList, tableIdx)
                
                if TaintedRocksList.IsTaintedRockGrid and TaintedRocksList.IsTaintedRockGrid[ idx ] then
                    table.remove(TaintedRocksList, TaintedRocksList.IsTaintedRockGrid[ idx ])
                end
                
                if room:CanPickupGridEntity(idx) then
                    famData.GridTarget = idx
                    break
                end
            end

            if TaintedRocksList.IsTaintedRockGrid and #TaintedRocksList.IsTaintedRockGrid >0 then
                TaintedRocksList.IsTaintedRockGrid = {}
                for i=1, #TaintedRocksList do
                    TaintedRocksList.IsTaintedRockGrid[ TaintedRocksList[i] ] = i
                end
            end

            if famData.GridTarget < 0 then fam.State = FAM_STATES.ATTACKING end
            return
        end
        local gridIdx = famData.GridTarget
        
        if not room:CanPickupGridEntity(gridIdx) then
            famData.GridTarget = -1
            return
        end
        if GetEnemyTarget(fam) == nil then
            fam.State = FAM_STATES.FOLLOW_PLAYER
            return
        end

        local targetPos = room:GetGridPosition(gridIdx)

        if fam.Velocity:Length() < 1.25 and targetPos:Distance(fam.Position) < 7.5 then
            fam.Velocity = Vector.Zero
            fam.State = FAM_STATES.PICKING_GRID
            fam:GetSprite():Play("Pickup", true)
            return
        end
		local angle = (targetPos - fam.Position):GetAngleDegrees()
        fam.Velocity = fam.Velocity:Lerp(POUL.SPEED:Rotated(angle), 0.08)
    elseif state == FAM_STATES.PICKING_GRID then
        local sp = fam:GetSprite()
        if sp:IsFinished() then
            if famData.Grids and #famData.Grids == 0 then
                fam.State = FAM_STATES.IDLE
                fam.FireCooldown = POUL.COOLDOWN
                sp:Play("Idle", true)
                famData.GridTarget = -1
            else
                if not FindGridTarget(fam, famData, player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                    fam.State = FAM_STATES.HOLDING_GRID
                end
                sp:Play("PickupIdle", true)
            end
            return
        end
        if sp:IsEventTriggered("PickupThrow") then
            local gridIdx = famData.GridTarget
            local room = game:GetRoom()
            if room:CanPickupGridEntity(gridIdx) then
                if GetEnemyTarget(fam) == nil then
                    ShootGrid(fam, Vector.Zero)
                    fam:GetSprite():Play("Idle", true)
                    fam.State = FAM_STATES.FOLLOW_PLAYER
                    return
                end
                local grid = room:GetGridEntity(gridIdx)

                local t = grid:GetType()
                local v = grid:GetVariant()
                local subType = (t << 16) | v

                local spriteSheet = GetSpriteSheet(t, v)
                local gridSp = grid:GetSprite()
                local anim = gridSp:GetAnimation()
                local anm2 = gridSp:GetFilename()
                local frame = gridSp:GetFrame()
                if t == GridEntityType.GRID_ROCK and anim == "big" then
                    anim = "normal"
                    v = Random() % 3
                    frame = v
                end

                --Isaac.Spawn(1000, EffectVariant.GRID_ENTITY_PROJECTILE_HELPER, 0, fam.Position, Vector.Zero, fam)
                local eff = room:PickupGridEntity(gridIdx)
                famData.Grids = famData.Grids or {}
                table.insert(famData.Grids, eff)

                eff.Parent = fam
                local sp = eff:GetSprite()

                eff:GetData().GridTypeVar = subType
                eff:ToEffect():FollowParent(fam)
                eff.DepthOffset = 1
                -- using this to update grids around it without doing to much work    
            elseif FindGridTarget(fam, famData, player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                if famData.Grids == nil or #famData.Grids == 0 then
                    sp:Play("Idle", true)
                else
                    sp:Play("PickupIdle", true)
                end
            end
        end
    elseif state == FAM_STATES.HOLDING_GRID or state == FAM_STATES.ATTACKING then
        local target = GetEnemyTarget(fam)
        if target == nil then
            ShootGrid(fam, Vector.Zero)
            fam:GetSprite():Play("Idle", true)
            fam.State = FAM_STATES.FOLLOW_PLAYER
            return
        end

        local targetPos = target.Position
        fam.TargetPosition = targetPos

        if state == FAM_STATES.ATTACKING then
            if fam.FireCooldown > 0 then
                fam.FireCooldown = fam.FireCooldown - 1
            elseif fam.Position:Distance(targetPos) < target.Size *0.75 then
                target:TakeDamage(POUL.CONTACT_DAMAGE, 0, EntityRef(fam), 0)
                fam.FireCooldown = POUL.ATTACKING_COOLDOWN
            end
        elseif fam.Position:Distance(targetPos) < 40 * 4 and target:IsVulnerableEnemy() and target:IsVisible() then
            fam:GetSprite():Play("Throw", true)
            fam.State = FAM_STATES.TROWING_GRID

            fam.Velocity = fam.Velocity * 0.45
            return
        end

		local angle = (targetPos - fam.Position):GetAngleDegrees()
        fam.Velocity = fam.Velocity:Lerp(POUL.SPEED:Rotated(angle), 0.08)

    elseif state == FAM_STATES.FOLLOW_PLAYER then
        local player = fam.Player
        if not player then return end
        if Isaac.CountEnemies() > 0 then
            fam.State = FAM_STATES.SELECT_GRID
            return
        end
		local angle = (player.Position - fam.Position):GetAngleDegrees()
        fam.Velocity = fam.Velocity:Lerp(POUL.SPEED:Rotated(angle), 0.08)

    elseif state == FAM_STATES.TROWING_GRID then
        local sp = fam:GetSprite()
        if sp:IsFinished() then
            fam.State = FAM_STATES.IDLE
            local target = fam.Target
            if not (target and not target:IsDead() and target:Exists()) then
                fam.FireCooldown = POUL.COOLDOWN
            else
                fam.State = FAM_STATES.SELECT_GRID
            end
            sp:Play("Idle", true)
            return
        end
        if sp:IsEventTriggered("PickupThrow") then
            fam.Velocity = fam.Velocity + POUL.SPEED:Rotated(fam.Velocity:GetAngleDegrees() + 180) * 0.35
            local targetPos = fam.TargetPosition
            local angle = (targetPos - fam.Position):GetAngleDegrees()

            ShootGrid(fam, POUL.PROJ_SPEED:Rotated(angle))
        end
    elseif fam.FireCooldown > 0 then
        fam.FireCooldown = fam.FireCooldown - 1

        local player = fam.Player
        if player then
            local angle = (player.Position - fam.Position):GetAngleDegrees()
            fam.Velocity = fam.Velocity:Lerp(POUL.SPEED:Rotated(angle), 0.08)
        end
    else
        fam.State = FAM_STATES.SELECT_GRID
    end
    
end, POUL.FAMILIAR)

local RenderOffset = Vector(0, -20)
BeckyMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, fam, offset)
    local grids = fam:GetData().Grids or {}
    if #grids == 0 then return end

    local sp = fam:GetSprite()
    local nullFrame = sp:GetNullFrame("Item")
    
    if not (nullFrame and nullFrame:IsVisible()) then return end
    local room = game:GetRoom()
    local invertPos = room:GetRenderMode() == RenderMode.RENDER_WATER_REFLECT
    local famPos = fam.Position
    local nullOffset = fam:GetNullOffset("Item")
    if invertPos then
        nullOffset.Y = nullOffset.Y *-1
        nullOffset.X = nullOffset.X -40
    end
    famPos = famPos + nullOffset
    for i, eff in ipairs(grids) do
        eff.Visible = true
        local renderPos = RenderOffset * (i -1)
        if invertPos then
            renderPos.Y = renderPos.Y *-1
            renderPos.X = renderPos.X -40
        end

        eff:GetSprite():Render( room:WorldToScreenPosition(famPos + renderPos) )
        eff.Visible = false
    end

end, POUL.FAMILIAR)

BeckyMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPAWN, function(_, gridEnt)
    local gridType = gridEnt:GetType()
    if VALID_GRID_TYPES[gridType] then
        local idx = gridEnt:GetGridIndex()
        if gridType == GridEntityType.GRID_ROCKT or gridType == GridEntityType.GRID_ROCK_ALT2 then
            AddTaintedRock(idx)
        end
        table.insert(CanPickupGridList, idx)
    end
end)


local function LoadRoom()
    local room = game:GetRoom()
    if room:IsFirstVisit() and #CanPickupGridList >0 then return end

    CanPickupGridList = {}
    TaintedRocksList = {}

    for idx=0, room:GetGridSize()-1 do
        if room:CanPickupGridEntity(idx) then
            local gridType = room:GetGridEntity(idx):GetType()
            if gridType == GridEntityType.GRID_ROCKT or gridType == GridEntityType.GRID_ROCK_ALT2 then
                AddTaintedRock(idx)
            end
            table.insert(CanPickupGridList, idx)
        end
    end

    for _, ent in ipairs(Isaac.FindByType(3, POUL.FAMILIAR)) do
        local fam = ent:ToFamiliar()
        if fam then
            fam.State = FAM_STATES.IDLE
            fam.Velocity = Vector.Zero
            fam.Target = nil
            fam:GetSprite():Play("Idle", true)
            local famData = fam:GetData()
            famData.Grids = {}
            famData.GridTarget = -1
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LoadRoom)
BeckyMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, LoadRoom)

BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    CanPickupGridList = {}
    TaintedRocksList = {}
    local room = game:GetRoom()

    for idx=0, room:GetGridSize()-1 do
        if room:CanPickupGridEntity(idx) then
            local gridType = room:GetGridEntity(idx):GetType()
            if gridType == GridEntityType.GRID_ROCKT or gridType == GridEntityType.GRID_ROCK_ALT2 then
                AddTaintedRock(idx)
            end
            table.insert(CanPickupGridList, idx)
        end
    end
end, CollectibleType.COLLECTIBLE_D12)

BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlags)
    player:CheckFamiliar(POUL.FAMILIAR,
        player:GetCollectibleNum(POUL.ID) + player:GetEffects():GetCollectibleEffectNum(POUL.ID),
        player:GetCollectibleRNG(POUL.ID),
        Isaac.GetItemConfig():GetCollectible(POUL.ID)
    )
end, CacheFlag.CACHE_FAMILIARS)

BeckyMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
    local target = tear:GetData().TargetDistance
    if not target then return end
    if target.Start:Distance(tear.Position) >= target.Dis -9 then
        tear.FallingAcceleration = 2.33
        tear:GetData().TargetDistance = nil
    end
end)


--[[
tint : 1 | 1 | 1 | 1
colorize : 1.8 | 0.9 | 0.3 | 1
offset : 0.3 | 0 | 0
]]