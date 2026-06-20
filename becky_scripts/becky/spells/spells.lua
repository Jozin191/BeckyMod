
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
    

    "MULTISHOT",
    "FLY_N_HOMING",
    "OPEN_SESAMO",
    "KNIGHT_ATTACK",
    
    "VINE",
    "AETHER_CIRCLE",
    "GILDED_SPEAR",
    "HAUNT",
    "TIMEFREEZE",
    "BOTTLE_WITH_WATER",

    "SPELLS_NUM",
}
for i, name in ipairs(SPELLS_NAMES) do
    SPELLS.SpellType[name] = i
end
SPELLS.SpellType.SPELLS_NUM = SPELLS.SpellType.SPELLS_NUM -1

local DevilSpellsPool = {
    SPELLS.SpellType.SPREAD,
    SPELLS.SpellType.BIG,
    SPELLS.SpellType.SACRIFICIAL_BUFF,
    SPELLS.SpellType.FIRE_POWER,
    SPELLS.SpellType.NUKE,
    SPELLS.SpellType.DEVIL,
    SPELLS.SpellType.SPELL_DMG_UP,
    SPELLS.SpellType.MULTISHOT,
    SPELLS.SpellType.KNIGHT_ATTACK,
    SPELLS.SpellType.AETHER_CIRCLE,
    SPELLS.SpellType.HAUNT,
    SPELLS.SpellType.TIMEFREEZE,
}
local AngelSpellsPool = {
    SPELLS.SpellType.SPREAD,
    SPELLS.SpellType.SUMMON,
    SPELLS.SpellType.SHIELD,
    SPELLS.SpellType.DASH,
    SPELLS.SpellType.BOOMERANG,
    SPELLS.SpellType.WEAKEN_ENEMIES,
    SPELLS.SpellType.MANA_REGEN,
    SPELLS.SpellType.FLY_N_HOMING,
    SPELLS.SpellType.OPEN_SESAMO,
    SPELLS.SpellType.VINE,
    SPELLS.SpellType.GILDED_SPEAR,
    SPELLS.SpellType.BOTTLE_WITH_WATER,
}

local RandomSpellsPool = {
    SPELLS.SpellType.SACRIFICIAL_BUFF,
    SPELLS.SpellType.DASH,
    SPELLS.SpellType.WEAKEN_ENEMIES,
    SPELLS.SpellType.BOOMERANG,
    SPELLS.SpellType.SPREAD,
    SPELLS.SpellType.BIG,
    SPELLS.SpellType.MULTISHOT,
    SPELLS.SpellType.FLY_N_HOMING,
    SPELLS.SpellType.OPEN_SESAMO,
    SPELLS.SpellType.AETHER_CIRCLE,
    SPELLS.SpellType.GILDED_SPEAR,
    SPELLS.SpellType.TIMEFREEZE,
    SPELLS.SpellType.BOTTLE_WITH_WATER,
}

local StartingSpellsPool = {
    SPELLS.SpellType.SACRIFICIAL_BUFF,
    SPELLS.SpellType.DASH,
    SPELLS.SpellType.BOOMERANG,
    SPELLS.SpellType.SPREAD,
    SPELLS.SpellType.BIG,
    SPELLS.SpellType.SHIELD,
    SPELLS.SpellType.OPEN_SESAMO,
    SPELLS.SpellType.SUMMON,
    SPELLS.SpellType.AETHER_CIRCLE,
    SPELLS.SpellType.TIMEFREEZE,
    SPELLS.SpellType.BOTTLE_WITH_WATER,
}


SPELLS.SpellSelectType = {
    NONE = 0,
    NORMAL = 1,
    RANDOM_SPELLS = 2,
    RANDOM_NO_UNSELECT = 3,
    RUN_INIT_SELECT = 4,
}


SPELLS.ENTITIES = {
    MANA_TEAR =     { Type = 2, Variant = Isaac.GetEntityVariantByName("Mana Tear") },
    BIG_MANA_TEAR = { Type = 2, Variant = Isaac.GetEntityVariantByName("Big Mana Tear") },
    EID_ENT = {Type =1000, Variant = Isaac.GetEntityVariantByName("John Becky - Spell EID")}
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

-- last highest frame : 22
local SPELLS_FRAME = {
    [SPELLS.SpellType.NULL] = 99,
}

local SPELLS_COST = {}

local DEFAULT_SPELLS = {
    Spells = {
        SPELLS.SpellType.NULL,
        SPELLS.SpellType.NULL,
        SPELLS.SpellType.NULL,
        SPELLS.SpellType.NULL,
    },
    HasSpells = {}
}

for i=1, 4 do DEFAULT_SPELLS.HasSpells[ tostring(DEFAULT_SPELLS.Spells[i]) ] = true end



BeckyMod.Spells = SPELLS
local game = BeckyMod.Game


function SPELLS:GetSpells(player)
    local save = BeckyMod:RunSave(player)
    save.RunSpells = save.RunSpells or BeckyMod:ShallowCopy(DEFAULT_SPELLS.Spells)
    save.RunHasSpells = save.RunHasSpells or BeckyMod:ShallowCopy(DEFAULT_SPELLS.HasSpells)
    return save.RunSpells
end
function SPELLS:HasSpell(player, spellType)
    local save = BeckyMod:RunSave(player)
    save.RunSpells = save.RunSpells or BeckyMod:ShallowCopy(DEFAULT_SPELLS.Spells)
    save.RunHasSpells = save.RunHasSpells or BeckyMod:ShallowCopy(DEFAULT_SPELLS.HasSpells)
    return save.RunHasSpells[tostring(spellType)] == true
end

function SPELLS:SetSpellType(player, slot, spellType)
    slot = slot +1
    if slot <1 or slot > 4 then return end
    local save = BeckyMod:RunSave(player)
    save.RunSpells = save.RunSpells or BeckyMod:ShallowCopy(DEFAULT_SPELLS.Spells)
    save.RunHasSpells = save.RunHasSpells or BeckyMod:ShallowCopy(DEFAULT_SPELLS.HasSpells)
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
    local data = BeckyMod.GetEntData(player)
    data.MagicStaff_SelectingSpell = set
    data.MagicStaff_SelectSpellDir = nil
    data.SpellNoSelect = false
end

function SPELLS:IsPlayerSelectingSpell(player, spellType)
    local data = BeckyMod.GetEntData(player)
    if not data.MagicStaff_SelectingSpell then return false end
    if spellType ~= nil then
        return data.MagicStaff_SelectingSpell == spellType
    end
    return data.MagicStaff_SelectingSpell > SPELLS.SpellSelectType.NONE
end

local DEAL_SPELL_RNG = RNG()
function SPELLS:GetDealSpellFromPlayer(player)
    local data = BeckyMod.GetEntData(player)
    
    if data.CachedDealPool == nil then
        local dealSpell = data.ReplaceSpell
        DEAL_SPELL_RNG:SetSeed(game:GetRoom():GetDecorationSeed() + player.InitSeed, 35)
                
        if dealSpell == 0 then -- devil statue
            data.CachedDealPool = BeckyMod:ShuffleTable(DevilSpellsPool, DEAL_SPELL_RNG)
        elseif dealSpell == 1 then -- angel statue
            data.CachedDealPool = BeckyMod:ShuffleTable(AngelSpellsPool, DEAL_SPELL_RNG)
        else data.CachedDealPool = {} end
    end
    local spellPool= data.CachedDealPool

    local spell = SPELLS.SpellType.NULL
    for i=1, #spellPool do
        if not SPELLS:HasSpell(player, spellPool[i]) then
            spell = spellPool[i]
            break
        end
    end
    return spell
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        BeckyMod.GetEntData(player).CachedDealPool = nil
    end
end)

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

    "vines",
    "aether_circle",
    "gilded_spear",
    "haunt",
    "timefreeze",
    "bottle_with_water",
}) do
    local data = include(SPELLS_RUTE .. file)
    local spell = data[1] or 0
    
    --print("loading spell",SPELLS_NAMES[spell])
    SPELLS.SPELL_FUNC[spell] = data.Func
    SPELLS.SPELL_FUNC_CAN_SELECT[spell] = data.CanSelect
    SPELLS_COST[spell] = data.Cost or 30
    SPELLS_FRAME[spell] = data.Frame or 99
    --print("spell loaded!")
end


local function renderPlayerSpellSelection(player)
    local data = BeckyMod.GetEntData(player)
    local save = BeckyMod:RunSave(player)
    local selectType = data.MagicStaff_SelectingSpell or SPELLS.SpellSelectType.NONE
    --if not save.SelectedSpells then selectType = SPELLS.SpellSelectType.RUN_INIT_SELECT
    --end
    
    if selectType == SPELLS.SpellSelectType.NONE then
        local dealSpell = data.ReplaceSpell
        if dealSpell and dealSpell >= 0 then
            local room = game:GetRoom()
            local pos = (player:GetFlyingOffset() *1.5) + player.Position + (SELECTION_POS.POS * player.SpriteScale.Y)
            local spell = SPELLS:GetDealSpellFromPlayer(player)
    
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

    --[[
    if selectType == SPELLS.SpellSelectType.RUN_INIT_SELECT then
        DEAL_SPELL_RNG:SetSeed(game:GetLevel():GetDungeonPlacementSeed() + player.InitSeed, 20 - (save.ForceSelectSpells or 2) )
        local spellPool = BeckyMod:ShuffleTable(StartingSpellsPool, DEAL_SPELL_RNG)
        local show = {}

        for i=1, #spellPool do
            if #show == 4 then break end
            if not SPELLS:HasSpell(player, spellPool[i]) then
                show[#show+1] = spellPool[i]
            end
        end

        --if not data.HasShowTable then
        --    print("-- Spell Sprite Selection")
        --    BeckyMod:PrintTable(show)
        --    print("-----")
        --    data.HasShowTable = true
        --end

        local isBlind = game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND >0
        
        for i=1, 4 do
            local spell = show[i]
            if isBlind then
                SPELLS_SPRITE:SetFrame("UnknownSpellGreen", 0)
            else
                SPELLS_SPRITE:SetFrame("SpellsGreen", SPELLS_FRAME[spell])
            end
            
            SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos + SELECTION_POS.OFFSETS[i]))
        end

    else]] if data.ReplaceSpell and data.ReplaceSpell >= 0 then
        local playerSpells = SPELLS:GetSpells(player)

        local spell = SPELLS:GetDealSpellFromPlayer(player)

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

        if selectType == SPELLS.SpellSelectType.RANDOM_SPELLS then
            local itemRNG = player:GetCollectibleRNG(BeckyMod.Item.MAGIC_STAFF.ID)
            DEAL_SPELL_RNG:SetSeed(itemRNG:GetSeed(), 30)
            local spellPool = BeckyMod:ShuffleTable(RandomSpellsPool, DEAL_SPELL_RNG)
                
             
            for i=1, 4 do
                local spell = spellPool[i]

                SPELLS_SPRITE:SetFrame("Spells", SPELLS_FRAME[spell])
                SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos + SELECTION_POS.OFFSETS[i]))
            end
            return
        elseif selectType == SPELLS.SpellSelectType.RANDOM_NO_UNSELECT then
            local cardRNG = player:GetCardRNG(BeckyMod.Pickup.SOUL_OF_BECKY.ID)
            DEAL_SPELL_RNG:SetSeed(cardRNG:GetSeed(), 30)
            local spellPool = BeckyMod:ShuffleTable(RandomSpellsPool, DEAL_SPELL_RNG)
             
            for i=1, 4 do
                local spell = spellPool[i]

                SPELLS_SPRITE:SetFrame("Spells", SPELLS_FRAME[spell])
                SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos + SELECTION_POS.OFFSETS[i]))
            end
            return
        end

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
                    SPELLS_SPRITE:SetFrame(selectData.Choices.Anim, selectData.Choices[i])
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

---- TAINTED BECKY BIRTHRIGHT HERE BECAUSE IM LAZYYYY
BeckyMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, itemID, charge, firstTime, slot, varData, player)
    if player:GetPlayerType() == BeckyMod.Character.BECKY_B.PLAYERTYPE then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BIRTHRIGHT)

        local isInDevilPool = BeckyMod:Set(DevilSpellsPool)
        local isInAngelPool = BeckyMod:Set(AngelSpellsPool)
        local playerSpells = BeckyMod:CopyTable(SPELLS:GetSpells(player))
        
        for slot=0, 3 do SPELLS:SetSpellType(player, slot, SPELLS.SpellType.NULL) end--- clears t. becky spell slots

        for slot=0, 3 do
            local spell = playerSpells[slot +1]
            if spell == SPELLS.SpellType.SPREAD then -- spread spell is in both devil and angel pools
                local shuffleSpells = BeckyMod:ShuffleTable( BeckyMod:CombineTables(DevilSpellsPool, AngelSpellsPool) , rng)
                for idx=1, #shuffleSpells do
                    local newSpell = shuffleSpells[idx]
                    if not SPELLS:HasSpell(player, newSpell) then
                        SPELLS:SetSpellType(player, slot, newSpell)
                    end
                end

            elseif isInDevilPool[spell] then
                local shuffleSpells = BeckyMod:ShuffleTable(DevilSpellsPool, rng)
                for idx=1, #shuffleSpells do
                    local newSpell = shuffleSpells[idx]
                    if not SPELLS:HasSpell(player, newSpell) then
                        SPELLS:SetSpellType(player, slot, newSpell)
                    end
                end

            elseif isInAngelPool[spell] then
                local shuffleSpells = BeckyMod:ShuffleTable(AngelSpellsPool, rng)
                for idx=1, #shuffleSpells do
                    local newSpell = shuffleSpells[idx]
                    if not SPELLS:HasSpell(player, newSpell) then
                        SPELLS:SetSpellType(player, slot, newSpell)
                    end
                end

            else
                SPELLS:SetSpellType(player, slot, SPELLS.SpellType.NULL)
            end
        end
    end
end, CollectibleType.COLLECTIBLE_BIRTHRIGHT)


--BeckyMod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
--    local sp = tear:GetSprite()
--    sp:Load("gfx/beckyMagic/mana_tear 1.anm2", true)
--end, SPELLS.ENTITIES.MANA_TEAR.Variant)

BeckyMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear, offset)
    
    if tear.Variant == SPELLS.ENTITIES.MANA_TEAR.Variant then
    --or tear.Variant == SPELLS.ENTITIES.BIG_MANA_TEAR.Variant then
        local sp = tear:GetSprite()
        local angle = tear.Velocity:GetAngleDegrees()

        local anim 
        
        local scale = tear.Scale
        local sizeMulti = tear.SizeMulti
        local flags = tear.TearFlags
        local anim
        if scale <= 0.3 then
            anim = "RegularTear1"
        elseif scale <= 0.55 then
            anim = "RegularTear2"
        elseif scale <= 0.675 then
            anim = "RegularTear3"
        elseif scale <= 0.8 then
            anim = "RegularTear4"
        elseif scale <= 0.925 then
            anim = "RegularTear5"
        elseif scale <= 1.05 then
            anim = "RegularTear6"
        elseif scale <= 1.175 then
            anim = "RegularTear7"
        elseif scale <= 1.425 then
            anim = "RegularTear8"
        elseif scale <= 1.675 then
            anim = "RegularTear9"
        elseif scale <= 1.925 then
            anim = "RegularTear10"
        elseif scale <= 2.175 then
            anim = "RegularTear11"
        elseif scale <= 2.55 then
            anim = "RegularTear12"
        else
            anim = "RegularTear13"
        end
        sp:SetFrame(anim, 0)
        if scale > 2.55 then
            tear.SpriteScale = Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
        elseif flags & TearFlags.TEAR_GROW == TearFlags.TEAR_GROW or flags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO then
            if scale <= 0.3 then
                tear.SpriteScale = Vector((scale * sizeMulti.X) / 0.25, (scale * sizeMulti.Y) / 0.25)
            elseif scale <= 0.55 then
                local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
                tear.SpriteScale = Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
            elseif scale <= 1.175 then
                local adjustedBase = math.ceil((scale - 0.175) / 0.125) * 0.125 + 0.175
                tear.SpriteScale = Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
            elseif scale <= 2.175 then
                local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
                tear.SpriteScale = Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
            else
                tear.SpriteScale = Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
            end
        else
            tear.SpriteScale = sizeMulti
        end
    end
end)



BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if game:GetFrameCount() == 0 then return end
    local data = BeckyMod.GetEntData(player)
    local selectType = data.MagicStaff_SelectingSpell or SPELLS.SpellSelectType.NONE
    local save = BeckyMod:RunSave(player)
    --if not save.SelectedSpells then selectType = SPELLS.SpellSelectType.RUN_INIT_SELECT
    --end
    if selectType == SPELLS.SpellSelectType.NONE then return end
    
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

    --[[
    if selectType == SPELLS.SpellSelectType.RUN_INIT_SELECT then
        DEAL_SPELL_RNG:SetSeed(game:GetLevel():GetDungeonPlacementSeed() + player.InitSeed, 20 - (save.ForceSelectSpells or 2))
        local spellPool = BeckyMod:ShuffleTable(StartingSpellsPool, DEAL_SPELL_RNG)
        
        local selectionPool = {}
        local slot = ((save.ForceSelectSpells or 2) == 2 and Direction.LEFT) or Direction.RIGHT
        for i=1, #spellPool do
            if #selectionPool == 4 then break end
            if not SPELLS:HasSpell(player, spellPool[i]) then
                selectionPool[#selectionPool+1] = spellPool[i]
            end
        end
        
        --print("-- Spell Select")
        --BeckyMod:PrintTable(selectionPool)
        --print("------")
        --print(selectionPool[dir+1])
        --data.HasShowTable = false

        SPELLS:SetSpellType(player, slot, selectionPool[dir+1])

        data.SpellNoSelect = true
        save.ForceSelectSpells = (save.ForceSelectSpells or 2) -1
        if save.ForceSelectSpells <=0 then
            save.SelectedSpells = true
            data.MagicStaff_SelectingSpell = SPELLS.SpellSelectType.NONE
        end
        return
    end]]


    if data.ReplaceSpell and data.ReplaceSpell >= 0 and player:GetPlayerType() == BeckyMod.Character.BECKY_B.PLAYERTYPE then
        SPELLS:SetSpellType(player, dir, SPELLS:GetDealSpellFromPlayer(player))

        if player:GetItemState() == BeckyMod.Item.MAGIC_STAFF.TAINTED_BECKY_ID then
            player:AnimateCollectible(BeckyMod.Item.MAGIC_STAFF.SPELLING_ID, "HideItem")
            player:ResetItemState()
        end
        SPELLS:SetPlayerSelectSpell(player, SPELLS.SpellSelectType.NONE)
        BeckyMod:FloorSave(player).DealSpell = true

        data.ReplaceSpell = -1
        return
    else data.ReplaceSpell  =-1 end

    local spell
    if data.MagicStaff_SelectSpellDir then
        spell = data.MagicStaff_SelectSpellDir.Type
        if data.MagicStaff_SelectSpellDir.Choices and data.MagicStaff_SelectSpellDir.Choices[dir] == nil then return end
        data.MagicStaff_SelectSpellDir.Dir = dir
    else
        if selectType == SPELLS.SpellSelectType.RANDOM_SPELLS then
            local itemRNG = player:GetCollectibleRNG(BeckyMod.Item.MAGIC_STAFF.ID)
            DEAL_SPELL_RNG:SetSeed(itemRNG:GetSeed(), 30)
            spell = BeckyMod:ShuffleTable(RandomSpellsPool, DEAL_SPELL_RNG)[dir +1]
        elseif selectType == SPELLS.SpellSelectType.RANDOM_NO_UNSELECT then
            local cardRNG = player:GetCardRNG(BeckyMod.Pickup.SOUL_OF_BECKY.ID)
            --print(cardRNG:GetSeed())
            DEAL_SPELL_RNG:SetSeed(cardRNG:GetSeed(), 30)
            spell = BeckyMod:ShuffleTable(RandomSpellsPool, DEAL_SPELL_RNG)[dir +1]
            cardRNG:Next()
        else
            spell = SPELLS:GetSpells(player)[dir +1]
        end
    end
    if spell == nil or spell == 0 then return end

    local playerData = BeckyMod:RunSave(player)
    local manaLeft = playerData.ManaCharge or 0
    if selectType ~= SPELLS.SpellSelectType.NORMAL or SPELLS.SPELL_FUNC_CAN_SELECT[spell](player, manaLeft) then
        if SPELLS.SPELL_FUNC[spell](player) then return end

        if data.MagicStaff_SelectSpellDir == nil then
            if selectType == SPELLS.SpellSelectType.NORMAL and SPELLS_COST[spell] > 0 then playerData.ManaCharge = manaLeft - SPELLS_COST[spell] end

            local soundType = Random() % 2 +1
            --if soundType == 1 then -- this wasn't added yet :(
                --BeckyMod.SFX:Play(SoundEffect.SOUND_YO_LISTEN, 1, 5) 
            --else
                if soundType == 1 then
                BeckyMod.SFX:Play(SoundEffect.SOUND_BATTERYCHARGE, 0.75, 1, false, 1.35 )
            elseif soundType == 2 then
                BeckyMod.SFX:Play(SoundEffect.SOUND_BATTERYDISCHARGE, 0.75, 1, false, 1.5 )
            end
            

            if player:GetEffects():HasNullEffect(BeckyMod.Pickup.SOUL_OF_BECKY.NULL_ITEM_ID) then
                player:GetEffects():RemoveNullEffect(BeckyMod.Pickup.SOUL_OF_BECKY.NULL_ITEM_ID, -1)
                return
                
            elseif player:GetItemState() == BeckyMod.Item.MAGIC_STAFF.ID then
                player:AnimateCollectible(BeckyMod.Item.MAGIC_STAFF.SPELLING_ID, "HideItem")
                player:ResetItemState()
                for slot = 0, 2 do
                    if player:GetActiveItem(slot) == BeckyMod.Item.MAGIC_STAFF.ID then
                        local charge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
                        player:SetActiveCharge(charge - player:GetActiveMaxCharge(slot), slot)
                        player:GetCollectibleRNG(BeckyMod.Item.MAGIC_STAFF.ID):Next()
                        break
                    end
                end
                
            elseif player:GetItemState() == BeckyMod.Item.MAGIC_STAFF.TAINTED_BECKY_ID then
                player:AnimateCollectible(BeckyMod.Item.MAGIC_STAFF.SPELLING_ID, "HideItem")
                player:ResetItemState()
            end
            SPELLS:SetPlayerSelectSpell(player, SPELLS.SpellSelectType.NONE)
        else
            data.SpellNoSelect = true
        end
    end
end)


local function resetPlayerSelection(player)
    SPELLS:SetPlayerSelectSpell(player, SPELLS.SpellSelectType.NONE)
    local data = BeckyMod.GetEntData(player)
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
        SPELLS:SetPlayerSelectSpell(ent, SPELLS.SpellSelectType.NONE)
    end
end)

local EFFECTVAR_TO_GRIDVAR = {
    [EffectVariant.DEVIL] = 0,
    [EffectVariant.ANGEL] = 1,
}
local STATUE_MAX_DISTANCE = 2.25 * 40
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, statue)
    if not PlayerManager.AnyoneIsPlayerType(BeckyMod.Character.BECKY_B.PLAYERTYPE) then return end
    local level = game:GetLevel()
    if level:GetCurrentRoomIndex() ~= GridRooms.ROOM_DEVIL_IDX then return end
    if Epiphany and Epiphany.Item.BROKEN_HALO:isBrokenHaloRoom() then -- broken halo is a devil room. we avoid them grating spells :)
        return
    end

    local var = EFFECTVAR_TO_GRIDVAR[statue.Variant]-- Statue variant. 0 - Devil, 1 - Angel
    if var == nil then return end
    local statuePos = statue.Position

    local room = game:GetRoom()
    for i, player in ipairs(PlayerManager.GetPlayers()) do
        local save = BeckyMod:FloorSave(player)
        if not save.DealSpell and player:GetPlayerType() == BeckyMod.Character.BECKY_B.PLAYERTYPE then
            local data = BeckyMod.GetEntData(player)
            if data.MagicStaff_SelectingSpell and data.MagicStaff_SelectingSpell > SPELLS.SpellSelectType.NONE then
                if data.MagicStaff_SelectingSpell ~= SPELLS.SpellSelectType.NORMAL then
                    data.ReplaceSpell = -1
                end
                return
            end
            local playerDis = statuePos:Distance(player.Position)
            if playerDis >= STATUE_MAX_DISTANCE then
                data.ReplaceSpell = -1
                return
            end
            data.ReplaceSpell = var
            local eff = Isaac.Spawn(SPELLS.ENTITIES.EID_ENT.Type, SPELLS.ENTITIES.EID_ENT.Variant, 0, player.Position, Vector.Zero, player):ToEffect()
            eff:FollowParent(player)
        end
	end
end)
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eidEnt)
    local player = eidEnt.Parent and eidEnt.Parent:ToPlayer()
    if player == nil then
        eidEnt:Remove()
        return
    end
    local save = BeckyMod:FloorSave(player)
    local data = BeckyMod.GetEntData(player)

    if save.DealSpell or data.ReplaceSpell == nil or data.ReplaceSpell < 0 then
        eidEnt:Remove()
    end
end, SPELLS.ENTITIES.EID_ENT.Variant)

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    for i, player in ipairs(PlayerManager.GetPlayers()) do
        local save = BeckyMod:FloorSave(player)
        save.DealSpell = false
	end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
    
    if player:GetPlayerType() ~= BeckyMod.Character.BECKY_B.PLAYERTYPE then return end
    local save = BeckyMod:RunSave(player)
    if not save.SelectedSpells then
        DEAL_SPELL_RNG:SetSeed(game:GetLevel():GetDungeonPlacementSeed() + player.InitSeed, 20)
        local spellPool = BeckyMod:ShuffleTable(StartingSpellsPool, DEAL_SPELL_RNG)
        
        for i=1, 2 do
            SPELLS:SetSpellType(player, ((i == 2 and Direction.LEFT) or Direction.RIGHT), spellPool[i])
        end
        save.SelectedSpells = true
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
            BeckyMod:ForEachPlayer(UnlockAllPlayers)
            Debug_Active = false
            --[[
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
                    SELECTING_Spells[slot] = SPELLS.SpellType.SPELLS_NUM +1
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

    for i=1, SPELLS.SpellType.SPELLS_NUM do
        DEBUG_SPELLS_SPRITE:SetFrame("Spells", SPELLS_FRAME[i])
        DEBUG_SPELLS_SPRITE:Render(RENDERPOS + Vector(X_OFFSET * ((i-1) % SPELLS_ROWS), Y_OFFSET* ((i-1) // SPELLS_ROWS)))
    end
    DEBUG_SELECTION_SPRITE:SetFrame("trash", 0)
    DEBUG_SELECTION_SPRITE:Render(RENDERPOS + Vector(X_OFFSET * (SPELLS.SpellType.SPELLS_NUM % SPELLS_ROWS), Y_OFFSET* (SPELLS.SpellType.SPELLS_NUM // SPELLS_ROWS)))
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
        SELECTING_Spells[CURRENT_Spell_Slot] = SPELLS.SpellType.SPELLS_NUM +1
        Debug_InputCooldown = frameCount + DEBUG_INPUTCOOLDOWN
        return 
    elseif Input.IsActionPressed(ButtonAction.ACTION_ITEM, 0) then
        BeckyMod:ForEachPlayer(UnlockAllPlayers)
        Debug_Active = false
        local player = PlayerManager.FirstPlayerByType(BeckyMod.Character.BECKY_B.PLAYERTYPE)
        local beckySpells = SPELLS:GetSpells(player)
        for slot=1, 4 do
            if SELECTING_Spells[slot] <= SPELLS.SpellType.SPELLS_NUM then
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
    
    SELECTING_Spells[CURRENT_Spell_Slot] = (SELECTING_Spells[CURRENT_Spell_Slot]+ add -1) % (SPELLS.SpellType.SPELLS_NUM +1) +1
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