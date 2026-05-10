
local SPELLS = {}
SPELLS.SpellType = {}
SPELLS.SpellType.NULL = 0

local SPELLS_NAMES = {
    -- normal spells
    "SPREAD",
    "BIG",
    "SUMMON",
    "SHIELD",
    
    -- devil spells 
    "SACRIFICIAL_BUFF",
    "FIRE_POWER",
    "NUKE",
    "DEVIL",
    "SPELL_DMG_UP",
    
    -- angel spells
    "DASH",
    "BOOMERANG",
    "WEAKEN_ENEMIES",
    "MANA_REGEN",
    
    -- unfinish ideas / to polish
    "MULTISHOT",
    "FLY_N_HOMING",
    "OPEN_SESAMO",
    "KNIGHT_ATTACK",

    "SPELLS_NUM",
}
for i, name in ipairs(SPELLS_NAMES) do
    SPELLS.SpellType[name] = i
end

local DevilSpells = {
    SPELLS.SpellType.SACRIFICIAL_BUFF,
    SPELLS.SpellType.FIRE_POWER,
    SPELLS.SpellType.NUKE,
    SPELLS.SpellType.DEVIL,
    SPELLS.SpellType.SPELL_DMG_UP,
}
local AngelSpells = {
    SPELLS.SpellType.DASH,
    SPELLS.SpellType.BOOMERANG,
    SPELLS.SpellType.WEAKEN_ENEMIES,
    SPELLS.SpellType.MANA_REGEN,
}


SPELLS.ENTITIES = {
    MANA_TEAR =     { Type = 2, Variant = Isaac.GetEntityVariantByName("Mana Tear") },
    BIG_MANA_TEAR = { Type = 2, Variant = Isaac.GetEntityVariantByName("Big Mana Tear") },
}

SPELLS.NULL_ITEMS = {}


SPELLS.SPELL_FUNC = {}
SPELLS.SPELL_FUNC_CAN_SELECT = {}

local SELECTION_POS = {
    POS = Vector(0, -60),
    OFFSETS = {
        Vector(-24, 0), -- left
        Vector(0, -24), -- top
        Vector( 24, 0), -- right
        Vector( 0, 24), -- down
    },
}

local SPELLS_SPRITE = Sprite("gfx/ui/taintedBecky/spells.anm2", true)

-- max frame : 16
local SPELLS_FRAME = {
    [SPELLS.SpellType.NULL] = 99,

    [SPELLS.SpellType.SPREAD] = 0,
    [SPELLS.SpellType.BIG] = 2,
    [SPELLS.SpellType.SUMMON] = 3,
    [SPELLS.SpellType.SHIELD] = 1,

    [SPELLS.SpellType.SACRIFICIAL_BUFF] = 4,
    [SPELLS.SpellType.FIRE_POWER] = 13,
    [SPELLS.SpellType.NUKE] = 7,
    [SPELLS.SpellType.DEVIL] = 10,
    [SPELLS.SpellType.SPELL_DMG_UP] = 15,

    [SPELLS.SpellType.DASH] = 8,
    [SPELLS.SpellType.BOOMERANG] = 9,
    [SPELLS.SpellType.WEAKEN_ENEMIES] = 11,
    [SPELLS.SpellType.MANA_REGEN] = 16,

    [SPELLS.SpellType.MULTISHOT] = 5,
    [SPELLS.SpellType.FLY_N_HOMING] = 6,
    [SPELLS.SpellType.OPEN_SESAMO] = 12,
    [SPELLS.SpellType.KNIGHT_ATTACK] = 14,
}

local SPELLS_COST = {
    [SPELLS.SpellType.SPREAD] = 30,
    [SPELLS.SpellType.BIG] = 50,
    [SPELLS.SpellType.SUMMON] = 0,
    [SPELLS.SpellType.SHIELD] = 0,

    [SPELLS.SpellType.SACRIFICIAL_BUFF] = 0,
    [SPELLS.SpellType.FIRE_POWER] = 10,
    [SPELLS.SpellType.NUKE] = 100,
    [SPELLS.SpellType.DEVIL] = 30,

    [SPELLS.SpellType.DASH] = 99,
    [SPELLS.SpellType.BOOMERANG] = 99,
    [SPELLS.SpellType.WEAKEN_ENEMIES] = 99,

    [SPELLS.SpellType.MULTISHOT] = 99,
    [SPELLS.SpellType.FLY_N_HOMING] = 99,
    [SPELLS.SpellType.OPEN_SESAMO] = 99,
    [SPELLS.SpellType.KNIGHT_ATTACK] = 99,

}


BeckyMod.Spells = SPELLS
local game = BeckyMod.Game

--- BeckyMod.Spells:SetSpellType(Isaac.GetPlayer(), slot, spellType) <- this is for testing on the game
function SPELLS:GetSpells(player)
    local save = BeckyMod:RunSave(player)
    save.RunSpells = save.RunSpells or {
        SPELLS.SpellType.BIG,
        SPELLS.SpellType.NULL,
        SPELLS.SpellType.SUMMON,
        SPELLS.SpellType.NULL,
    }
    save.RunHasSpells = save.RunHasSpells or {
        [tostring(SPELLS.SpellType.NULL)] = true,
        [tostring(SPELLS.SpellType.BIG)] = true,
        [tostring(SPELLS.SpellType.SUMMON)] = true,
    }
    return save.RunSpells
end
function SPELLS:HasSpell(player, spellType)
    local save = BeckyMod:RunSave(player)
    save.RunSpells = save.RunSpells or {
        SPELLS.SpellType.BIG,
        SPELLS.SpellType.NULL,
        SPELLS.SpellType.SUMMON,
        SPELLS.SpellType.NULL,
    }
    save.RunHasSpells = save.RunHasSpells or {
        [tostring(SPELLS.SpellType.NULL)] = true,
        [tostring(SPELLS.SpellType.BIG)] = true,
        [tostring(SPELLS.SpellType.SUMMON)] = true,
    }
    return save.RunHasSpells[tostring(spellType)] == true
end

function SPELLS:SetSpellType(player, slot, spellType)
    slot = slot +1
    if slot <1 or slot > 4 then return end
    local save = BeckyMod:RunSave(player)
    save.RunSpells = save.RunSpells or {
        SPELLS.SpellType.BIG,
        SPELLS.SpellType.NULL,
        SPELLS.SpellType.SUMMON,
        SPELLS.SpellType.NULL,
    }
    save.RunHasSpells = save.RunHasSpells or {
        [tostring(SPELLS.SpellType.NULL)] = true,
        [tostring(SPELLS.SpellType.BIG)] = true,
        [tostring(SPELLS.SpellType.SUMMON)] = true,
    }
    if save.RunSpells[slot] ~= SPELLS.SpellType.NULL then
        save.RunHasSpells[tostring(save.RunSpells[slot])] = nil
    end
    save.RunSpells[slot] = spellType
    save.RunHasSpells[tostring(spellType)] = true
end

function SPELLS:UseSpellType(player, spellType)
    if SPELLS.SPELL_FUNC[spellType] == nil then return end
    SPELLS.SPELL_FUNC[spellType](player)
end


function SPELLS:SetPlayerSelectSpell(player, set)
    local data = player:GetData()
    data.MagicStaff_SelectingSpell = set
    data.MagicStaff_SelectSpellDir = nil
    data.SpellNoSelect = false
end

function SPELLS:IsPlayerSelectingSpell(player)
    return player:GetData().MagicStaff_SelectingSpell == true
end


local SPELLS_RUTE = "becky_scripts.becky.spells.spell."
for _, file in ipairs({
    "spread",
    "big",
    "summon",
    "shield",
    "sacrificial_buff",
    "devil",
    "dash",
    "fire_power",
    "fly_n_homing",
    "knight_attack",
    "mana_regen",
    "multishot",
    "nuke",
    "open_sesamo",
    "spell_dmg_up",
    "boomerang",
    "weaken_enemies",
}) do
    local data = include(SPELLS_RUTE .. file)
    local spell = data[1] or 0
    
    --print("loading spell",SPELLS_NAMES[spell])
    SPELLS.SPELL_FUNC[spell] = data.Func
    SPELLS.SPELL_FUNC_CAN_SELECT[spell] = data.CanSelect
    SPELLS_COST[spell] = data.Cost or 30
    --print("spell loaded!")
end


local DEAL_SPELL_RNG = RNG()
local function renderPlayerSpellSelection(player)
    if not SPELLS:IsPlayerSelectingSpell(player) then
        local dealSpell = player:GetData().ReplaceSpell
        if dealSpell and dealSpell >= 0 then
            local room = game:GetRoom()
            local pos = (player:GetFlyingOffset() *1.5) + player.Position + (SELECTION_POS.POS * player.SpriteScale.Y)
            DEAL_SPELL_RNG:SetSeed(room:GetDecorationSeed() + player.InitSeed, 35)
            
            local spellPool
            if dealSpell == 0 then -- devil statue
                spellPool = BeckyMod:ShuffleTable(DevilSpells, DEAL_SPELL_RNG)
            elseif dealSpell == 1 then -- angel statue
                spellPool = BeckyMod:ShuffleTable(AngelSpells, DEAL_SPELL_RNG)
            end

            local spell = SPELLS.SpellType.NULL
            for i=1, #spellPool do
                if not SPELLS:HasSpell(player, spellPool[i]) then
                    spell = spellPool[i]
                    break
                end
            end

            if game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND >0 then
                spell = SPELLS.SpellType.NULL
            end
            SPELLS_SPRITE:SetFrame("Spells", SPELLS_FRAME[spell])
            SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos))
        end
        return
    end
    local room = game:GetRoom()
    local pos = (player:GetFlyingOffset() *1.5) + player.Position + (SELECTION_POS.POS * player.SpriteScale.Y)

    local data = player:GetData()
    if data.ReplaceSpell and data.ReplaceSpell >= 0 then
        local playerSpells = SPELLS:GetSpells(player)
        local spellSeed = (room:GetDecorationSeed() + player.InitSeed)
        DEAL_SPELL_RNG:SetSeed(room:GetDecorationSeed() + player.InitSeed, 35)
            
        local spellPool
        if data.ReplaceSpell == 0 then -- devil statue
            spellPool = BeckyMod:ShuffleTable(DevilSpells, DEAL_SPELL_RNG)
        elseif data.ReplaceSpell == 1 then -- angel statue
            spellPool = BeckyMod:ShuffleTable(AngelSpells, DEAL_SPELL_RNG)
        end

        local spell = SPELLS.SpellType.NULL
        for i=1, #spellPool do
            if not SPELLS:HasSpell(player, spellPool[i]) then
                spell = spellPool[i]
                break
            end
        end

        if game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND >0 then
            spell = SPELLS.SpellType.NULL
        end
        SPELLS_SPRITE:SetFrame("Spells", SPELLS_FRAME[spell])
        SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos))

        for i=1, 4 do
            local spell = playerSpells[i]
            
            SPELLS_SPRITE:SetFrame("SpellsGreen", SPELLS_FRAME[spell])
            SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos + SELECTION_POS.OFFSETS[i]))
        end
    elseif data.MagicStaff_SelectSpellDir == nil then
        local playerSpells = SPELLS:GetSpells(player)
        local manaLeft = BeckyMod:RunSave(player).ManaCharge or 0

        for i=1, 4 do
            local spell = playerSpells[i]
            if spell == nil or spell == SPELLS.SpellType.NULL then goto continue end
            
            if SPELLS_FRAME[spell] == nil then spell = 0 end
            if SPELLS.SPELL_FUNC_CAN_SELECT[spell](player, manaLeft) then
                SPELLS_SPRITE:SetFrame("Spells", SPELLS_FRAME[spell])
            else
                SPELLS_SPRITE:SetFrame("SpellsNoMana", SPELLS_FRAME[spell])
            end
            SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos + SELECTION_POS.OFFSETS[i]))
            ::continue::
        end
    else
        local selectData = data.MagicStaff_SelectSpellDir
        local spell = selectData.Type
        if SPELLS_FRAME[spell] == nil then spell = 0 end
        SPELLS_SPRITE:SetFrame("Spells", SPELLS_FRAME[spell])
        SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos))
        if selectData.Choices then
            selectData.Choices.Anim = selectData.Choices.Anim or "Spells"
            for i=0, 3 do
                if selectData.Choices[i] then
                    SPELLS_SPRITE:SetFrame("Spells", selectData.Choices[i])
                    SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos + SELECTION_POS.OFFSETS[i+1]))
                end
            end
        else
            for i=1, 4 do
                SPELLS_SPRITE:SetFrame("Directions", i-1)
                SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos + SELECTION_POS.OFFSETS[i]))
            end
        end
    end
end

BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_ROOM_RENDER_ENTITIES, -300, function()
    BeckyMod:ForEachPlayer(renderPlayerSpellSelection)
end)



BeckyMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear, offset)
    if tear.Variant == SPELLS.ENTITIES.MANA_TEAR.Variant or tear.Variant == SPELLS.ENTITIES.BIG_MANA_TEAR.Variant then
        local sp = tear:GetSprite()
        local angle = tear.Velocity:GetAngleDegrees()

        local anim 
        local inverAngles = false
        if angle > 45 and angle < 135 then
            anim = "MoveVert"
            sp.FlipX = false
            sp.FlipY = false
        elseif angle >= 135 or angle <= -135 then
            anim = "MoveHori"
            sp.FlipX = true
            sp.FlipY = false
            inverAngles = true
        elseif angle > -135 and angle < -45 then
            anim = "MoveVert"
            sp.FlipX = false
            sp.FlipY = true
            inverAngles = true
        else
            anim = "MoveHori"
            sp.FlipX = false
            sp.FlipY = false
        end
        sp:SetFrame(anim, tear.FrameCount % 10)
        if inverAngles then
            sp.Rotation = (-angle +720 +45) % 90 -45
        else
            sp.Rotation = (angle +720 +45) % 90 -45
        end
        tear.SpriteScale = Vector(0.66, 0.66)
    end
end)



BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local data = player:GetData()
    if not data.MagicStaff_SelectingSpell then return end
    
    local save = BeckyMod:RunSave(player)
    local joystick = player:GetShootingJoystick()
    if joystick:Length() < 0.4 then
        data.SpellNoSelect = false
        return
    end
    if data.SpellNoSelect then return end
    local angle = joystick:GetAngleDegrees()
    local dir = Direction.RIGHT
    --print(angle)
    if angle > 45 and angle < 135 then
        dir = Direction.DOWN
    elseif angle >= 135 or angle <= -135 then
        dir = Direction.LEFT
    elseif angle > -135 and angle < -45 then
        dir = Direction.UP
    end

    if data.ReplaceSpell and data.ReplaceSpell >= 0 and player:GetPlayerType() == BeckyMod.Character.BECKY_B.PLAYERTYPE then
        DEAL_SPELL_RNG:SetSeed(game:GetRoom():GetDecorationSeed() + player.InitSeed, 35)
        
        local spellPool
        if data.ReplaceSpell == 0 then -- devil statue
            spellPool = BeckyMod:ShuffleTable(DevilSpells, DEAL_SPELL_RNG)
        elseif data.ReplaceSpell == 1 then -- angel statue
            spellPool = BeckyMod:ShuffleTable(AngelSpells, DEAL_SPELL_RNG)
        end

        local spell = SPELLS.SpellType.NULL
        for i=1, #spellPool do
            if not SPELLS:HasSpell(player, spellPool[i]) then
                spell = spellPool[i]
                break
            end
        end
        SPELLS:SetSpellType(player, dir, spell)

        if player:GetItemState() == BeckyMod.Item.MAGIC_STAFF.TAINTED_BECKY_ID then
            player:AnimateCollectible(BeckyMod.Item.MAGIC_STAFF.TAINTED_BECKY_ID, "HideItem")
            player:ResetItemState()
        end
        SPELLS:SetPlayerSelectSpell(player, false)
        BeckyMod:FloorSave(player).DealSpell = true

        data.ReplaceSpell = -1
    else data.ReplaceSpell  =-1 end

    local spell
    if data.MagicStaff_SelectSpellDir then
        spell = data.MagicStaff_SelectSpellDir.Type
        if data.MagicStaff_SelectSpellDir.Choices and data.MagicStaff_SelectSpellDir.Choices[dir] == nil then return end
        data.MagicStaff_SelectSpellDir.Dir = dir
    else
        spell = SPELLS:GetSpells(player)[dir +1]
    end
    if spell == nil or spell == 0 then return end

    local manaLeft = BeckyMod:RunSave(player).ManaCharge or 0
    if SPELLS.SPELL_FUNC_CAN_SELECT[spell](player, manaLeft) then
        if SPELLS.SPELL_FUNC[spell](player) then return end

        if data.MagicStaff_SelectSpellDir == nil then
            save.ManaCharge = save.ManaCharge - SPELLS_COST[spell]

            if player:GetItemState() == BeckyMod.Item.MAGIC_STAFF.ID then
                player:AnimateCollectible(BeckyMod.Item.MAGIC_STAFF.ID, "HideItem")
                player:ResetItemState()
                
            elseif player:GetItemState() == BeckyMod.Item.MAGIC_STAFF.TAINTED_BECKY_ID then
                player:AnimateCollectible(BeckyMod.Item.MAGIC_STAFF.TAINTED_BECKY_ID, "HideItem")
                player:ResetItemState()
            end
            SPELLS:SetPlayerSelectSpell(player, false)
        else
            data.SpellNoSelect = true
        end
    end
end)


local function resetPlayerSelection(player)
    SPELLS:SetPlayerSelectSpell(player, false)
    local data = player:GetData()
    --if data.SpellsData then
    --    if data.SpellsData.SummonActive then
    --        SPELLS.SPELL_FUNC[SPELLS.SpellType.SUMMON](player)
    --    end
    --    if data.SpellsData.ShieldActive then
    --        SPELLS.SPELL_FUNC[SPELLS.SpellType.SHIELD](player)
    --    end
    --    data.SpellsData = nil
    --end
    data.MaxManaOffset = 0
    data.ManaDischarge = 0
    data.NoChargeMana = 0
    --if data.Spell_Sacrificial_Buff and data.Spell_Sacrificial_Buff >0 then
    --    data.Spell_Sacrificial_Buff = 0
    --    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    --end
end
BeckyMod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, function()
    BeckyMod:ForEachPlayer(resetPlayerSelection)
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function(_, ent, dmg, dmgFlags, src, cooldown)
    if ent.Type == 1 then
        SPELLS:SetPlayerSelectSpell(ent, false)
    end
end)

local EFFECTVAR_TO_GRIDVAR = {
    [EffectVariant.DEVIL] = 0,
    [EffectVariant.ANGEL] = 1,
}
local STATUE_MAX_DISTANCE = 2.25 * 40
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, statue)
    if not PlayerManager.AnyoneIsPlayerType(BeckyMod.Character.BECKY_B.PLAYERTYPE) then return end
    if game:GetLevel():GetCurrentRoomIndex() ~= GridRooms.ROOM_DEVIL_IDX then return end
    local var = EFFECTVAR_TO_GRIDVAR[statue.Variant]-- Statue variant. 0 - Devil, 1 - Angel
    if var == nil then return end
    local statuePos = statue.Position

    for i, player in ipairs(PlayerManager.GetPlayers()) do
        local save = BeckyMod:FloorSave(player)
        if not save.DealSpell and player:GetPlayerType() == BeckyMod.Character.BECKY_B.PLAYERTYPE then
            local data = player:GetData()
            if data.MagicStaff_SelectingSpell then return end
            if statuePos:Distance(player.Position) >= STATUE_MAX_DISTANCE then
                data.ReplaceSpell = -1
                return
            end
            data.ReplaceSpell = var
        end
	end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    for i, player in ipairs(PlayerManager.GetPlayers()) do
        local save = BeckyMod:FloorSave(player)
        save.DealSpell = false
	end
end)


--------------------------------------------------------
------------------DEBUG STUFF---------------------------
--------------------------------------------------------

local DEBUG_SPELLS_SPRITE = Sprite("gfx/ui/taintedBecky/spells.anm2", true); DEBUG_SPELLS_SPRITE.Scale = Vector(2,2)
local DEBUG_SELECTION_SPRITE = Sprite("gfx/ui/taintedBecky/spells_select.anm2", true)

local Debug_Active = false
local SPELL_DEBUG_NAME = "BeckySpellsDebug"
local MANA_DEBUG_NAME = "BeckyManaDebug"
local RENDERPOS = Vector(80, 80)
local X_OFFSET = 34
local Y_OFFSET = 34
local SPELLS_ROWS = 6
local Debug_InputCooldown = -1

local SELECTING_Spells = {}
local CURRENT_Spell_Slot = 1
local DEBUG_INPUTCOOLDOWN = 4

local function LockAllPlayers(player) player.ControlsEnabled = false end
local function UnlockAllPlayers(player) player.ControlsEnabled = true end
BeckyMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, args)
    if cmd == SPELL_DEBUG_NAME then
        if game:GetFrameCount() == 0 then
            Console.PrintError(SPELL_DEBUG_NAME.." can only be use on a run")
            return
        end
        if Debug_Active then
            --[[
            BeckyMod:ForEachPlayer(UnlockAllPlayers)
            Debug_Active = false
            local player = PlayerManager.FirstPlayerByType(BeckyMod.Character.BECKY_B.PLAYERTYPE)
            local beckySpells = SPELLS:GetSpells(player)
            for slot=1, 4 do
                if SELECTING_Spells[slot] < SPELLS.SpellType.SPELLS_NUM then
                    SPELLS:SetSpellType(player, slot-1, SELECTING_Spells[slot])
                else 
                    SPELLS:SetSpellType(player, slot-1, SPELLS.SpellType.NULL)
                end
            end]]
        else
            BeckyMod:ForEachPlayer(LockAllPlayers)
            Debug_Active = true
            
            local beckySpells = SPELLS:GetSpells(PlayerManager.FirstPlayerByType(BeckyMod.Character.BECKY_B.PLAYERTYPE))
            for slot=1, 4 do
                if beckySpells[slot] >0 then
                    SELECTING_Spells[slot] = beckySpells[slot]
                else 
                    SELECTING_Spells[slot] = SPELLS.SpellType.SPELLS_NUM
                end
            end
            CURRENT_Spell_Slot = 1
            Debug_InputCooldown = -1
        end
    elseif cmd == MANA_DEBUG_NAME then
        if game:GetFrameCount() == 0 then
            Console.PrintError(MANA_DEBUG_NAME.." can only be use on a run")
            return
        end
        local save = BeckyMod:RunSave(PlayerManager.FirstPlayerByType(BeckyMod.Character.BECKY_B.PLAYERTYPE))
        save.ManaCharge = tonumber(args) or 0
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not Debug_Active then return end

    for i=1, SPELLS.SpellType.SPELLS_NUM -1 do
        DEBUG_SPELLS_SPRITE:SetFrame("Spells", SPELLS_FRAME[i])
        DEBUG_SPELLS_SPRITE:Render(RENDERPOS + Vector(X_OFFSET * ((i-1) % SPELLS_ROWS), Y_OFFSET* ((i-1) // SPELLS_ROWS)))
    end
    DEBUG_SELECTION_SPRITE:SetFrame("trash", 0)
    DEBUG_SELECTION_SPRITE:Render(RENDERPOS + Vector(X_OFFSET * ((SPELLS.SpellType.SPELLS_NUM-1) % SPELLS_ROWS), Y_OFFSET* ((SPELLS.SpellType.SPELLS_NUM-1) // SPELLS_ROWS)))
    for slot =1, 4 do
        if slot ~= CURRENT_Spell_Slot then
            DEBUG_SELECTION_SPRITE:SetFrame("select", slot-1)
            DEBUG_SELECTION_SPRITE:Render(RENDERPOS + Vector(X_OFFSET * ((SELECTING_Spells[slot]-1) % SPELLS_ROWS), Y_OFFSET* ((SELECTING_Spells[slot]-1) // SPELLS_ROWS)))
        end
    end

    DEBUG_SELECTION_SPRITE:SetFrame("selectGreen", CURRENT_Spell_Slot-1)
    DEBUG_SELECTION_SPRITE:Render(RENDERPOS + Vector(X_OFFSET * ((SELECTING_Spells[CURRENT_Spell_Slot]-1) % SPELLS_ROWS), Y_OFFSET* ((SELECTING_Spells[CURRENT_Spell_Slot]-1) // SPELLS_ROWS)))
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if not Debug_Active or player.ControllerIndex > 0 then return end
    if game:IsPaused() then return end

    local frameCount = game:GetFrameCount()
    if Debug_InputCooldown >= frameCount then return end
    if Input.IsActionPressed(ButtonAction.ACTION_DROP, 0) then
        SELECTING_Spells[CURRENT_Spell_Slot] = SPELLS.SpellType.SPELLS_NUM
        Debug_InputCooldown = frameCount + DEBUG_INPUTCOOLDOWN
        return 
    elseif Input.IsActionPressed(ButtonAction.ACTION_ITEM, 0) then
        BeckyMod:ForEachPlayer(UnlockAllPlayers)
        Debug_Active = false
        local player = PlayerManager.FirstPlayerByType(BeckyMod.Character.BECKY_B.PLAYERTYPE)
        local beckySpells = SPELLS:GetSpells(player)
        for slot=1, 4 do
            if SELECTING_Spells[slot] < SPELLS.SpellType.SPELLS_NUM then
                SPELLS:SetSpellType(player, slot-1, SELECTING_Spells[slot])
            else 
                SPELLS:SetSpellType(player, slot-1, SPELLS.SpellType.NULL)
            end
        end
        Debug_InputCooldown = frameCount + DEBUG_INPUTCOOLDOWN
        return
    end
    
    if Input.IsActionPressed(ButtonAction.ACTION_BOMB, 0) then
        CURRENT_Spell_Slot = CURRENT_Spell_Slot -1
        if CURRENT_Spell_Slot < 1 then CURRENT_Spell_Slot =4 end
        Debug_InputCooldown = frameCount + DEBUG_INPUTCOOLDOWN
        return
    elseif Input.IsActionPressed(ButtonAction.ACTION_PILLCARD, 0) then
        CURRENT_Spell_Slot = CURRENT_Spell_Slot +1
        if CURRENT_Spell_Slot > 4 then CURRENT_Spell_Slot =1 end
        Debug_InputCooldown = frameCount + DEBUG_INPUTCOOLDOWN
        return
    end
    local add = 0
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0) then
        add = -1
        Debug_InputCooldown = frameCount + DEBUG_INPUTCOOLDOWN
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0) then
        add = 1
        Debug_InputCooldown = frameCount + DEBUG_INPUTCOOLDOWN
    end
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0) then
        add = add -SPELLS_ROWS
        Debug_InputCooldown = frameCount + DEBUG_INPUTCOOLDOWN
    elseif Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0) then
        add = add+ SPELLS_ROWS
        Debug_InputCooldown = frameCount + DEBUG_INPUTCOOLDOWN
    end
    
    SELECTING_Spells[CURRENT_Spell_Slot] = (SELECTING_Spells[CURRENT_Spell_Slot]+ add -1) % SPELLS.SpellType.SPELLS_NUM +1
end)


BeckyMod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, function()
    Debug_Active = false
end)
Console.RegisterCommand(
    SPELL_DEBUG_NAME,
    [[Lets you select the spells tainted becky holds
    Use the arrow keys to move around
    Use Q or E to swap between slots
    Use Ctrl to empty the current slot
    Use Space to apply the setted spells]],
    "Lets you select the spells tainted becky holds",
    false,
    AutocompleteType.NONE
)
Console.RegisterCommand(
    MANA_DEBUG_NAME,
    "Lets you select the mana of tainted becky",
    "Lets you select the mana of tainted becky",
    false,
    AutocompleteType.NONE
)