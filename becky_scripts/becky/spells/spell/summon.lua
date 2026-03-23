local SPELL_COST = 50
local CanPickupGridList = {}

local game = BeckyMod.Game

local SPEED = Vector(10,0)
local COOLDOWN = 90
local ATTACKING_COOLDOWN = 7
local PROJ_SPEED = Vector(15,0)
local FAM_STATES = {
    IDLE = 0,
    SELECT_GRID =1,
    PICKING_GRID = 2,
    HOLDING_GRID = 3,
    TROWING_GRID =4,
    ATTACKING = 5,
}

local VALID_GRID_TYPES = {
    [GridEntityType.GRID_ROCK] = true,
    [GridEntityType.GRID_ROCK_ALT] = true,
    [GridEntityType.GRID_ROCK_ALT2] = true,
    [GridEntityType.GRID_ROCK_BOMB] = true,
    [GridEntityType.GRID_ROCKT] = true,
    [GridEntityType.GRID_ROCK_SS] = true,
    [GridEntityType.GRID_ROCK_GOLD] = true,
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


BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
    fam.FireCooldown = 75 -- 2.5 seconds
    fam.State = FAM_STATES.IDLE
    fam.Coins = -1
    fam:GetSprite():Play("Idle", true)
end, BeckyMod.Spells.ENTITIES.POLTY_FAM.Variant)

BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    --print("fam")

    local state = fam.State
    local rng = fam:GetDropRNG()
    if state == FAM_STATES.SELECT_GRID then
        local room = game:GetRoom()

        local gridIdx = fam.Coins

        if gridIdx < 0 then
            while #CanPickupGridList > 0 do
                local tableIdx = rng:RandomInt(1, #CanPickupGridList)
                local idx = CanPickupGridList[ tableIdx ]
                table.remove(CanPickupGridList, tableIdx)
                
                if room:CanPickupGridEntity(idx) then
                    fam.Coins = idx
                    --print("Target grid", idx)
                    break
                end
            end

            if fam.Coins < 0 then fam.State = FAM_STATES.ATTACKING end
            return
        end
        if not room:CanPickupGridEntity(gridIdx) then
            fam.Coins = -1
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
        fam.Velocity = fam.Velocity:Lerp(SPEED:Rotated(angle), 0.08)
    elseif state == FAM_STATES.PICKING_GRID then
        local sp = fam:GetSprite()
        if sp:IsFinished() then
            if not fam.Child then
                fam.State = FAM_STATES.IDLE
                fam.FireCooldown = COOLDOWN
                sp:Play("Idle", true)
            else
                fam.State = FAM_STATES.HOLDING_GRID
                sp:Play("PickupIdle", true)
            end
            return
        end
        if sp:IsEventTriggered("PickupThrow") then
            local gridIdx = fam.Coins
            local room = game:GetRoom()
            if room:CanPickupGridEntity(gridIdx) then
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
                fam.Child = eff
                eff.Parent = fam
                local sp = eff:GetSprite()

                --sp:Load(anm2, true)
                --sp:SetFrame(anim, frame)
                --sp:ReplaceSpritesheet(0, spritesheet, true)

                eff:GetData().GridTypeVar = subType
                eff:ToEffect():FollowParent(fam)
                eff.DepthOffset = 1
                
                 -- using this to update grids around it without doing to much work
            end
            fam.Coins = -1
        end
    elseif state == FAM_STATES.HOLDING_GRID or state == FAM_STATES.ATTACKING then
        if not fam.Target then
            local enemiesList = {}
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                if ent:ToNPC() and ent:GetEntityFlags() & (EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN) == 0 and
                    ent:CanShutDoors() and ent:IsActiveEnemy() then
                    
                    table.insert(enemiesList, ent)
                end
            end
            if #enemiesList > 0 then
                fam.Target = enemiesList[rng:RandomInt(1, #enemiesList)]
            else
                fam.Target = fam.Player
            end
            return
        end

        local target = fam.Target
        if target == nil or target:IsDead() or not target:Exists() then
            fam.Target = nil
            return
        end
        local targetPos = target.Position
        fam.TargetPosition = targetPos

        if state == FAM_STATES.ATTACKING then
            if fam.FireCooldown > 0 then
                fam.FireCooldown = fam.FireCooldown - 1
            elseif fam.Position:Distance(targetPos) < target.Size *0.75 and target.Type ~= 1 then
                target:TakeDamage(2.5, 0, EntityRef(fam), 0)
                fam.FireCooldown = ATTACKING_COOLDOWN
            end
        elseif fam.Position:Distance(targetPos) < 40 * 4 then
            fam:GetSprite():Play("Throw", true)
            fam.State = FAM_STATES.TROWING_GRID

            fam.Velocity = fam.Velocity * 0.6666
            return
        end

		local angle = (targetPos - fam.Position):GetAngleDegrees()
        fam.Velocity = fam.Velocity:Lerp(SPEED:Rotated(angle), 0.08)

    elseif state == FAM_STATES.TROWING_GRID then
        local sp = fam:GetSprite()
        if sp:IsFinished() then
            fam.State = FAM_STATES.IDLE
            fam.FireCooldown = COOLDOWN
            sp:Play("Idle", true)
            return
        end
        if sp:IsEventTriggered("PickupThrow") then
            local targetPos = fam.TargetPosition
            local angle = (targetPos - fam.Position):GetAngleDegrees()
            
            local grid = fam.Child
            local gridTypeVar= grid:GetData().GridTypeVar
            local tear = Isaac.Spawn(2, TearVariant.GRIDENT, (gridTypeVar or 0), fam.Position, PROJ_SPEED:Rotated(angle), fam):ToTear()
            
            local t = gridTypeVar >> 16
            local v = gridTypeVar & ~((~0) <<16)
            SetGridSprite(tear, grid, t, v)
            tear.CollisionDamage = 10
            grid:Remove()
        end
    elseif fam.FireCooldown > 0 then
        fam.FireCooldown = fam.FireCooldown - 1

        local player = fam.Player
        if player then
            local angle = (player.Position - fam.Position):GetAngleDegrees()
            fam.Velocity = fam.Velocity:Lerp(SPEED:Rotated(angle), 0.08)
        end
    else
        fam.State = FAM_STATES.SELECT_GRID
    end
    
end, BeckyMod.Spells.ENTITIES.POLTY_FAM.Variant)

BeckyMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, fam)
    local eff = fam.Child and fam.Child:ToEffect()
    if not eff then return end
    local sp = fam:GetSprite()
    local nullFrame = sp:GetNullFrame("Item")
    
    if not (nullFrame and nullFrame:IsVisible()) then return end
    eff.Visible = true
    eff:GetSprite():Render(game:GetRoom():WorldToScreenPosition( fam.Position + fam:GetNullOffset("Item") ))
    eff.Visible = false

end, BeckyMod.Spells.ENTITIES.POLTY_FAM.Variant)

BeckyMod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function()
    CanPickupGridList = {}
end)
BeckyMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPAWN, function(_, gridEnt)
    if VALID_GRID_TYPES[gridEnt:GetType()] then
        table.insert(CanPickupGridList, gridEnt:GetGridIndex())
    end
end)
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local room = game:GetRoom()
    if room:IsFirstVisit() then return end

    for idx=0, room:GetGridSize()-1 do
        if room:CanPickupGridEntity(idx) then
            table.insert(CanPickupGridList, idx)
        end
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
    CanPickupGridList = {}
end, CollectibleType.COLLECTIBLE_D12)
BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    local room = game:GetRoom()

    for idx=0, room:GetGridSize()-1 do
        if room:CanPickupGridEntity(idx) then
            table.insert(CanPickupGridList, idx)
        end
    end
end, CollectibleType.COLLECTIBLE_D12)


local function clearGhosts(player) 
    player:CheckFamiliar(BeckyMod.Spells.ENTITIES.POLTY_FAM.Variant, 0, player:GetCollectibleRNG(BeckyMod.Item.MAGIC_STAFF.ID))
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    BeckyMod:ForEachPlayer(clearGhosts)
end)


local function fun(player)
    local data = player:GetData()
    data.SpellsData = data.SpellsData or {}

    data.SpellsData.SummonActive = (not data.SpellsData.SummonActive)
    if data.SpellsData.SummonActive then
        player:CheckFamiliar(BeckyMod.Spells.ENTITIES.POLTY_FAM.Variant, 1, player:GetCollectibleRNG(BeckyMod.Item.MAGIC_STAFF.ID))
        data.MaxManaOffset = (data.MaxManaOffset or 0) + SPELL_COST
    else
        player:CheckFamiliar(BeckyMod.Spells.ENTITIES.POLTY_FAM.Variant, 0, player:GetCollectibleRNG(BeckyMod.Item.MAGIC_STAFF.ID))
        data.MaxManaOffset = data.MaxManaOffset -SPELL_COST
    end
end

local function canSelectFun(player)
    local data = player:GetData()
    return (data.SpellsData and data.SpellsData.SummonActive) or 100 - (data.MaxManaOffset or 0) > SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.SUMMON,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = 0
}



--[[
tint : 1 | 1 | 1 | 1
colorize : 1.8 | 0.9 | 0.3 | 1
offset : 0.3 | 0 | 0
]]