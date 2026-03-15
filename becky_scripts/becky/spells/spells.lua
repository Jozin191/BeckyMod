
local SPELLS = {}

SPELLS.SpellType = {
    NULL = 0,
    -- normal spells
    SPREAD = 1,
    BIG = 2,
    SUMMON = 3,
    SHIELD = 4,
    -- all name from bellow are just placeholders
    -- devil spells 
    SACRIFICIAL_BUFF = 20,
    FIRE_POWER = 21,
    NUKE = 22,
    DEVIL = 23,

    -- angel spells
    DASH = 40,
    IDK_WHAT_TO_CALL_IT = 41,
    WEAKEN_ENEMIES = 42,

    -- unfinish ideas / to polish
    MULTISHOT = 90,
    FLY_N_HOMING = 91,
    OPEN_SESAMO = 92,
    KNIGHT_ATTACK = 93,
}

SPELLS.ENTITIES = {
    MANA_TEAR =     { Type = 2, Variant = Isaac.GetEntityVariantByName("Mana Tear") },
    BIG_MANA_TEAR = { Type = 2, Variant = Isaac.GetEntityVariantByName("Big Mana Tear") },
    POLTY_FAM =     { Type = 3, Variant = Isaac.GetEntityVariantByName("Polty Familiar") },
    SHIELD =        { Type = 1000, Variant = Isaac.GetEntityVariantByName("Mana Shield") },
}


SPELLS.SPELL_FUNC = {}
SPELLS.SPELL_FUNC_CAN_SELECT = {}

local SELECTION_POS = {
    POS = Vector(0, -50),
    OFFSETS = {
        Vector(-24, 0), -- left
        Vector(0, -24), -- top
        Vector( 24, 0), -- right
        Vector( 0, 24), -- down
    },
}

local SPELLS_SPRITE = Sprite("gfx/ui/taintedBecky/spells.anm2", true)

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

    [SPELLS.SpellType.DASH] = 8,
    [SPELLS.SpellType.IDK_WHAT_TO_CALL_IT] = 9,
    [SPELLS.SpellType.WEAKEN_ENEMIES] = 11,

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
    [SPELLS.SpellType.IDK_WHAT_TO_CALL_IT] = 99,
    [SPELLS.SpellType.WEAKEN_ENEMIES] = 99,

    [SPELLS.SpellType.MULTISHOT] = 99,
    [SPELLS.SpellType.FLY_N_HOMING] = 99,
    [SPELLS.SpellType.OPEN_SESAMO] = 99,
    [SPELLS.SpellType.KNIGHT_ATTACK] = 99,

}


BeckyMod.Spells = SPELLS
local game = BeckyMod.Game


function SPELLS:GetSpells(player)
    local save = BeckyMod:RunSave(player)
    save.RunSpells = save.RunSpells or {
        SPELLS.SpellType.SUMMON,
        SPELLS.SpellType.SPREAD,
        SPELLS.SpellType.BIG,
        SPELLS.SpellType.SHIELD,
    }
    return save.RunSpells
end

function SPELLS:SetSpellType(player, slot, spellType)
    if slot <1 or slot > 4 then return end
    local save = BeckyMod:RunSave(player)
    save.RunSpells[slot] = spellType
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
}) do
    local data = include(SPELLS_RUTE .. file)
    local spell = data[1]
    
    SPELLS.SPELL_FUNC[spell] = data.Func
    SPELLS.SPELL_FUNC_CAN_SELECT[spell] = data.CanSelect
    SPELLS_COST[spell] = data.Cost or 30
end



local function renderPlayerSpellSelection(player)
    if not SPELLS:IsPlayerSelectingSpell(player) then return end
    local room = game:GetRoom()
    local pos = (player:GetFlyingOffset() *1.5) + player.Position + (SELECTION_POS.POS * player.SpriteScale.Y)

    local data = player:GetData()
    if data.MagicStaff_SelectSpellDir == nil then
        local playerSpells = SPELLS:GetSpells(player)
        local manaLeft = BeckyMod:RunSave(player).ManaCharge or 0

        for i=1, 4 do
            local spell = playerSpells[i]
            if SPELLS_FRAME[spell] == nil then spell = 0 end
            if SPELLS.SPELL_FUNC_CAN_SELECT[spell](player, manaLeft) then
                SPELLS_SPRITE:SetFrame("Spells", SPELLS_FRAME[spell])
            else
                SPELLS_SPRITE:SetFrame("SpellsNoMana", SPELLS_FRAME[spell])
            end
            SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos + SELECTION_POS.OFFSETS[i]))
        end
    else
        local spell = data.MagicStaff_SelectSpellDir.Type
        if SPELLS_FRAME[spell] == nil then spell = 0 end
        SPELLS_SPRITE:SetFrame("Spells", SPELLS_FRAME[spell])
        SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos))
        for i=1, 4 do
            SPELLS_SPRITE:SetFrame("Directions", i-1)
            SPELLS_SPRITE:Render(room:WorldToScreenPosition(pos + SELECTION_POS.OFFSETS[i]))
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

    local spell
    if data.MagicStaff_SelectSpellDir then
        spell = data.MagicStaff_SelectSpellDir.Type
        data.MagicStaff_SelectSpellDir.Dir = dir
    else
        spell = SPELLS:GetSpells(player)[dir +1]
    end

    local manaLeft = BeckyMod:RunSave(player).ManaCharge or 0
    if SPELLS.SPELL_FUNC_CAN_SELECT[spell](player, manaLeft) then
        SPELLS.SPELL_FUNC[spell](player)
        if data.MagicStaff_SelectSpellDir == nil then
            save.ManaCharge = save.ManaCharge - SPELLS_COST[spell]

            if player:GetItemState() == BeckyMod.Item.MAGIC_STAFF.ID then
                player:AnimateCollectible(BeckyMod.Item.MAGIC_STAFF.ID, "HideItem")
                player:ResetItemState()
            end
            data.MagicStaff_SelectingSpell = false
        else
            data.SpellNoSelect = true
        end
    end
end)


local function resetPlayerSelection(player)
    SPELLS:SetPlayerSelectSpell(player, false)
    local data = player:GetData()
    if data.SpellsData then
        if data.SpellsData.SummonActive then
            SPELLS.SPELL_FUNC[SPELLS.SpellType.SUMMON](player)
        end
        if data.SpellsData.ShieldActive then
            SPELLS.SPELL_FUNC[SPELLS.SpellType.SHIELD](player)
        end
        data.SpellsData = nil
    end
    data.MaxManaOffset = 0
    data.ManaDischarge = 0
    data.NoChargeMana = false
end
BeckyMod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, function()
    BeckyMod:ForEachPlayer(resetPlayerSelection)
end)