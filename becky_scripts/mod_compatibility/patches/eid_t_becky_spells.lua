--[[
                How the spells EID is implemented is in spells.lua
]]

local function parseTableToEIDString (tab)
    if type(tab) ~= "table" then return tab end
    local string = tab[1]
    for idx=2, #tab do
        string = string .."#"..tab[idx]
    end
    return string
end


return function()
local SpellType = BeckyMod.Spells.SpellType


local SpellsIcons = Sprite("gfx/ui/eid/becky_spells_icons.anm2", true)
EID:addIcon("BeckySpell".. SpellType.SPREAD,            "Spells", 0,  11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.BIG,               "Spells", 2,  11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.SHIELD,            "Spells", 1,  11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.SUMMON,            "Spells", 3,  11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.SACRIFICIAL_BUFF,  "Spells", 4,  11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.FIRE_POWER,        "Spells", 13, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.NUKE,              "Spells", 7,  11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.DEVIL,             "Spells", 10, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.SPELL_DMG_UP,      "Spells", 15, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.DASH,              "Spells", 8,  11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.BOOMERANG,         "Spells", 9,  11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.WEAKEN_ENEMIES,    "Spells", 11, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.MANA_REGEN,        "Spells", 16, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.MULTISHOT,         "Spells", 5,  11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.FLY_N_HOMING,      "Spells", 6,  11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.OPEN_SESAMO,       "Spells", 12, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.KNIGHT_ATTACK,     "Spells", 14, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell??", "Spells", 99, 16, 16, -1, 0, SpellsIcons)

EID:addIcon("BeckySpellLeft",   "Directions", 0, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpellUp",     "Directions", 1, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpellRight",  "Directions", 2, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpellDown",   "Directions", 3, 11, 11, -1, 0, SpellsIcons)

EID:addIcon("BeckyMana", "ManaPoints", 0, 11, 11, -1, 0, SpellsIcons)


local SpellDescs = {
    [SpellType.NULL] = {
        en_us = "{{QuestionMark}}",
        spa = "{{QuestionMark}}",
    },
    [SpellType.SPREAD] = {
        en_us = {
            "{{BeckySpell".. SpellType.SPREAD .."}} Isaac shoots 8 tears around",
            "{{BeckyMana}} Cost 15 mana points",
        },
        --spa = ,
    },
    [SpellType.BIG] = {
        en_us = {
            "{{BeckySpell".. SpellType.BIG .."}} On use Isaac can select one of the 4 cardinal directions and shoot a big tear that does x3.5 of Isaac damage",
            "{{BeckyMana}} Cost 30 mana points",
        },
        --spa = ,
    },
    [SpellType.SHIELD] = {
        en_us = {
            "{{BeckySpell".. SpellType.SHIELD .."}} Makes a shield that protect Isaac from any damage source and pushes enemies away",
            "{{BeckyMana}} Consumes mana until is empty or Isaac cancel it",
        },
        --spa = ,
    },
    [SpellType.SUMMON] = {
        en_us = {
            "{{BeckySpell".. SpellType.SUMMON .."}} Can spawn different familiars depending on what is selected",
            "{{BeckySpellUp}} ",
            "{{BeckySpellRight}} ",
            "{{BeckySpellDown}} ",
            "{{BeckySpellLeft}} ",
            "{{BeckyMana}} Cost varies by what is selected",
            "{{!!!}} Only one summon can be active at the time",
        },
        --spa = ,
    },
    [SpellType.SACRIFICIAL_BUFF] = {
        en_us = {
            "{{BeckySpell".. SpellType.SACRIFICIAL_BUFF .."}} On use grants:",
            "{{ArrowUp}} {{Damage}} x1.25 Damage multiplier",
            "{{ArrowUp}} {{Tears}} x1.25 Tears multiplier",
            "{{ArrowUp}} {{Range}} x1.25 Range multiplier",
            "{{!!!}} Will deal one full heart of damage to Isaac",
        },
        --spa = ,
    },
    [SpellType.FIRE_POWER] = {
        en_us = {
            "{{BeckySpell".. SpellType.FIRE_POWER .."}} The current room will spawn fire that can only damage enemies",
            "{{BeckyMana}} Consumes mana until is empty or Isaac cancel it",
        },
        --spa = ,
    },
    [SpellType.NUKE] = {
        en_us = {
            "{{BeckySpell".. SpellType.NUKE .."}} On use removes all non boss enemies and all destructible obstacles",
            "Bosses take 660 points of damage",
            "{{BeckyMana}} Cost 100 mana points",
            "{{!!!}} Isaac takes 6 full hearts of damage",
        },
        --spa = ,
    },
    [SpellType.DEVIL] = {
        en_us = {
            "{{BeckySpell".. SpellType.DEVIL .."}} Every 3.5 seconds spawns a laser that comes from the sky",
            "This laser will target any enemy or Isaac and deal damage to it",
            "The laser deals x3.5 of Isaac damage",
            "Will spawn up to 7 lasers",
            "{{BeckyMana}} Cost 50 mana points",
        },
        --spa = ,
    },
    [SpellType.SPELL_DMG_UP] = {
        en_us = "{{BeckySpell".. SpellType.SPELL_DMG_UP .."}} Passively makes many of Isaac's spells deal more damage",
        --spa = ,
    },
    [SpellType.DASH] = {
        en_us = {
            "{{BeckySpell".. SpellType.DASH .."}} On use will make Isaac dash to the direction is moving",
            "Isaac can go through enemies",
            "{{BeckyMana}} Cost 10 mana points",
        },
        --spa = ,
    },
    [SpellType.BOOMERANG] = {
        en_us = {
            "{{BeckySpell".. SpellType.BOOMERANG .."}} Isaac will shoot an arrow to a random direction",
            "The arrow will try to get back to Isaac and shoot away when is close enough",
            "The arrow deals 84 points of damage per second",
            "{{BeckyMana}} Cost 12 mana points",
        },
        --spa = ,
    },
    [SpellType.WEAKEN_ENEMIES] = {
        en_us = {
            "{{BeckySpell".. SpellType.WEAKEN_ENEMIES .."}} Makes all enemies take double damage for 10 seconds",
            "{{BeckyMana}} Cost 70 mana points",
        },
        --spa = ,
    },
    [SpellType.MANA_REGEN] = {
        en_us = "{{BeckySpell".. SpellType.MANA_REGEN .."}} +50% mana capasity",
        --spa = ,
    },
    [SpellType.MULTISHOT] = {
        en_us = {
            "{{BeckySpell".. SpellType.MULTISHOT .."}} On use:",
            "{{ArrowDown}} {{Tears}} x0.42 Tears multiplier",
            "Isaac shoot 3 tears",
            "{{BeckyMana}} Cost 50 mana points",
            "Can be deactivated at any moment",
        },
        --spa = ,
    },
    [SpellType.FLY_N_HOMING] = {
        en_us = {
            "{{BeckySpell".. SpellType.FLY_N_HOMING .."}} On use:",
            "{{ArrowUp}} {{Speed}} +0.3 Move Speed",
            "{{ArrowUp}} Homing tears",
            "Grant flying",
            "Isaac movement speed can't be lower than 1.25 speed",
            "{{BeckyMana}} Cost 70 mana points",
            "Can be deactivated at any moment",
        },
        --spa = ,
    },
    [SpellType.OPEN_SESAMO] = {
        en_us = {
            "{{BeckySpell".. SpellType.OPEN_SESAMO .."}} On use Isaac can select one of the 4 cardinal directions and shoot a laser that deals 65 points of damage",
            "The laser can open almost any door that hit",
            "{{BeckyMana}} Cost 35 mana points",
        },
        --spa = ,
    },
    [SpellType.KNIGHT_ATTACK] = {
        en_us = {
            "{{BeckySpell".. SpellType.KNIGHT_ATTACK .."}} Spawns a knight on Isaac",
            "The knight will target the closest enemy to it and do 3 slashes",
            "{{BeckyMana}} Cost 45 mana points",
        },
        --spa = ,
    },
}

for k, v in pairs(SpellDescs) do -- making all previous descriptions a big unbeautiful string (for each language)
    for k2, v2 in pairs(v) do
        --print(k, v2)
        SpellDescs[k][k2] = parseTableToEIDString(v2)
    end
end


function BeckyMod.Spells:GetSpellEIDDesc(spellType)
    local leng = EID.getLanguage() or "en_us"
    return (SpellDescs[spellType][leng] or SpellDescs[spellType].en_us) or SpellDescs[SpellType.NULL].en_us
end

end