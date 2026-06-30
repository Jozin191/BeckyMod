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
EID:addIcon("BeckySpell".. SpellType.VINE,              "Spells", 17, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.AETHER_CIRCLE,     "Spells", 18, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.GILDED_SPEAR,      "Spells", 19, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.HAUNT,             "Spells", 20, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.TIMEFREEZE,        "Spells", 21, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell".. SpellType.BOTTLE_WITH_WATER, "Spells", 22, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpell??", "Spells", 99, 16, 16, -1, 0, SpellsIcons)

EID:addIcon("BeckySpellLeft",   "Directions", 0, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpellUp",     "Directions", 1, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpellRight",  "Directions", 2, 11, 11, -1, 0, SpellsIcons)
EID:addIcon("BeckySpellDown",   "Directions", 3, 11, 11, -1, 0, SpellsIcons)

EID:addIcon("BeckyMana", "ManaPoints", 0, 11, 11, -1, 0, SpellsIcons)

EID:addIcon("BeckySpellSummon_1", "SummonSpellFams", 0, 11, 11, -1, 0, SpellsIcons) --Follower familiar
EID:addIcon("BeckySpellSummon_2", "SummonSpellFams", 1, 11, 11, -1, 0, SpellsIcons) --Shooting familiar
EID:addIcon("BeckySpellSummon_3", "SummonSpellFams", 2, 11, 11, -1, 0, SpellsIcons) --Chase familiar
EID:addIcon("BeckySpellSummon_4", "SummonSpellFams", 3, 11, 11, -1, 0, SpellsIcons) --Charge familiar


local SpellDescs = {
    [SpellType.NULL] = {
        en_us = "{{QuestionMark}}",
        spa = "{{QuestionMark}}",
    },
    [SpellType.SPREAD] = {
        en_us = {
            "{{BeckySpell".. SpellType.SPREAD .."}} Isaac shoots 4 tears on a cross shape",
            "{{BeckyMana}} Cost 15 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.SPREAD .."}} Isaac dispara 4 lágrimas en forma de cruz",
            "{{BeckyMana}} Cuesta 15 puntos de mana",
        },
    },
    [SpellType.BIG] = {
        en_us = {
            "{{BeckySpell".. SpellType.BIG .."}} On use, Isaac can shoot a big tear that does x4 of Isaac damage",
            "{{BeckyMana}} Cost 30 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.BIG .."}} Al usarlo, Isaac puede disparar una gran lágrima que hace x4 veces el daño de Isaac",
            "{{BeckyMana}} Cuesta 30 puntos de mana",
        },
    },
    [SpellType.SHIELD] = {
        en_us = {
            "{{BeckySpell".. SpellType.SHIELD .."}} Makes a shield that protect Isaac from any damage source and pushes enemies away",
            "{{BeckyMana}} Consumes mana until is empty or Isaac cancel it",
        },
        spa = {
            "{{BeckySpell".. SpellType.SHIELD .."}} Crea un escudo que proteje a Isaac de cualquier tipo daño y repele a enemigos",
            "{{BeckyMana}} Consume mana hastá que quede vacio o Isaac lo cancele",
        },
    },
    [SpellType.SUMMON] = {
        en_us = {
            "{{BeckySpell".. SpellType.SUMMON .."}} Spawn different familiars depending on what is selected",
            "{{BeckySpellSummon_1}} Familiar that follow Isaac behind. Tears that pass through it will be double",
            "{{BeckySpellSummon_2}} Familiar that shoots",
            "{{BeckySpellSummon_3}} Familiar that chases enemies. It can takes damage and die",
            "{{BeckySpellSummon_4}} Familiar that can be charge. On release the familiar will be throw",
            "{{BeckyMana}} Cost varies by what is selected",
            "{{!!!}} Only one summon can be active at the time",
        },
        spa = {
            "{{BeckySpell".. SpellType.SUMMON .."}} Invocar diferentes familiares dependiendo de que se elijá",
            "{{BeckySpellSummon_1}} Familiar que sigue a Isaac. Las lágrimas que pasen por este serán duplicados",
            "{{BeckySpellSummon_2}} Familiar que dispara",
            "{{BeckySpellSummon_3}} Familiar que persigue enemigos. Puede recibir daño y morir",
            "{{BeckySpellSummon_4}} Familiar que se puede cargar. Al largarlo, este es lazado",
            "{{BeckyMana}} El costo varia en lo que se elija",
            "{{!!!}} Solo uno puede ser invocado a la vez",
        },
    },
    [SpellType.SACRIFICIAL_BUFF] = {
        en_us = {
            "{{BeckySpell".. SpellType.SACRIFICIAL_BUFF .."}} On use grants:",
            "{{ArrowUp}} {{Damage}} x1.25 Damage multiplier",
            "{{ArrowUp}} {{Tears}} x1.25 Tears multiplier",
            "{{ArrowUp}} {{Range}} x1.25 Range multiplier",
            "{{!!!}} Will deal one full heart of damage to Isaac",
        },
        spa = {
            "{{BeckySpell".. SpellType.SACRIFICIAL_BUFF .."}} Al usarlo, dará:",
            "{{ArrowUp}} {{Damage}} x1.25 multiplicador de Daño",
            "{{ArrowUp}} {{Tears}} x1.25 multiplicador de Lágrimas",
            "{{ArrowUp}} {{Range}} x1.25 multiplicador de Rango",
            "{{!!!}} Le hará un corazón entero de daño a Isaac",
        },
    },
    [SpellType.FIRE_POWER] = {
        en_us = {
            "{{BeckySpell".. SpellType.FIRE_POWER .."}} The current room will spawn fire that can only damage enemies",
            "{{BeckyMana}} Consumes mana until is empty or Isaac cancel it",
        },
        spa = {
            "{{BeckySpell".. SpellType.FIRE_POWER .."}} El cuarto actual generará fuego que solamente dañara enemigos",
            "{{BeckyMana}} Consume mana hastá que quede vacio o Isaac lo cancele",
        },
    },
    [SpellType.NUKE] = {
        en_us = {
            "{{BeckySpell".. SpellType.NUKE .."}} On use removes all non boss enemies and all destructible obstacles",
            "Bosses take 660 points of damage",
            "{{BeckyMana}} Cost 100 mana points",
            "{{!!!}} Isaac takes 6 full hearts of damage",
        },
        spa = {
            "{{BeckySpell".. SpellType.NUKE .."}} Al usarlo remueve todos los enemigos normales y todos los obstaculos destructibles",
            "Jefes recibiran 660 puntos de daño",
            "{{BeckyMana}} Cuesta 100 punto de mana",
            "{{!!!}} Isaac recibira 6 corazones de daño",
        },
    },
    [SpellType.DEVIL] = {
        en_us = {
            "{{BeckySpell".. SpellType.DEVIL .."}} Every 3.5 seconds spawns a laser that comes from the sky",
            "This laser will target any enemy or Isaac and deal damage to it",
            "The laser deals x3.5 of Isaac damage",
            "Will spawn up to 7 lasers",
            "{{BeckyMana}} Cost 50 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.DEVIL .."}} Cada 3.5 segundos genera un láser que viene del cielo",
            "Este láser perseguira cualquier enemigo o a Isaac y los dañara",
            "El láser hace x3.5 del daño de Isaac",
            "Generará hasta 7 lásers",
            "{{BeckyMana}} Cuesta 50 puntos de mana",
        },
    },
    [SpellType.SPELL_DMG_UP] = {
        en_us = "{{BeckySpell".. SpellType.SPELL_DMG_UP .."}} Passively makes many of Isaac's spells deal more damage",
        spa = "{{BeckySpell".. SpellType.SPELL_DMG_UP .."}} De forma pasiva hace que vario de los hechizos de Isaac hagan más daño",
    },
    [SpellType.DASH] = {
        en_us = {
            "{{BeckySpell".. SpellType.DASH .."}} On use will make Isaac dash to the direction is moving",
            "Isaac can go through and damage enemies",
            "{{BeckyMana}} Cost 15 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.DASH .."}} Al usarlo hará que Isaac dashee en la diracción en la que se mueve",
            "Isaac puede ir atravez y dañar enemigos",
            "{{BeckyMana}} Cuesta 15 puntos de mana",
        },
    },
    [SpellType.BOOMERANG] = {
        en_us = {
            "{{BeckySpell".. SpellType.BOOMERANG .."}} On use, Isaac can shoot an arrow",
            "The arrow will try to get back to Isaac and shoot away when is close enough",
            "The arrow deals 84 points of damage per second",
            "{{BeckyMana}} Cost 12 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.BOOMERANG .."}} Al usarlo, Isaac puede disparar una flecha",
            "La flecha intentara de volver a Isaac y se vá volando si se acerca lo suficiente",
            "La flecha hace 84 puntos de daño por segundo",
            "{{BeckyMana}} Cuesta 12 puntos de mana",
        },
    },
    [SpellType.WEAKEN_ENEMIES] = {
        en_us = {
            "{{BeckySpell".. SpellType.WEAKEN_ENEMIES .."}} Slows all enemies in the room for 10 seconds",
            "{{BeckyMana}} Cost 70 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.WEAKEN_ENEMIES .."}} Relentiza a todos los enemigos en el cuarto por 10 segundos",
            "{{BeckyMana}} Cuesta 70 puntos de mana",
        },
    },
    [SpellType.MANA_REGEN] = {
        en_us = "{{BeckySpell".. SpellType.MANA_REGEN .."}} +50% mana capasity",
        spa = "{{BeckySpell".. SpellType.MANA_REGEN .."}} +50% capacidad de mana",
    },
    [SpellType.MULTISHOT] = {
        en_us = {
            "{{BeckySpell".. SpellType.MULTISHOT .."}} On use:",
            "{{ArrowDown}} {{Tears}} x0.42 Tears multiplier",
            "Isaac shoot 3 tears",
            "{{BeckyMana}} Cost 50 mana points",
            "Can be deactivated at any moment",
        },
        spa = {
            "{{BeckySpell".. SpellType.MULTISHOT .."}} Al usarlo:",
            "{{ArrowDown}} {{Tears}} x0.42 multiplicador de Lágrimas",
            "Isaac dispara 3 lágrimas",
            "{{BeckyMana}} Cuesta 50 puntos de mana",
            "Puede ser desactivado en cualquier momento",
        },
    },
    [SpellType.FLY_N_HOMING] = {
        en_us = {
            "{{BeckySpell".. SpellType.FLY_N_HOMING .."}} On use:",
            "{{ArrowUp}} {{Speed}} +0.3 Speed",
            "{{ArrowUp}} Homing tears",
            "Grant flying",
            "Isaac movement speed can't be lower than 1.25 speed",
            "{{BeckyMana}} Cost 70 mana points",
            "Can be deactivated at any moment",
        },
        spa = {
            "{{BeckySpell".. SpellType.FLY_N_HOMING .."}} Al usarlo:",
            "{{ArrowUp}} {{Speed}} +0.3 Velocidad",
            "{{ArrowUp}} Lágrimas teledirigidas",
            "Da vuelo",
            "El movimiento de Isaac no puede ir por debajo de 1.25 de velocidad",
            "{{BeckyMana}} Cuesta 70 puntos de mana",
            "Puede ser desactivado en cualquier momento",
        },
    },
    [SpellType.OPEN_SESAMO] = {
        en_us = {
            "{{BeckySpell".. SpellType.OPEN_SESAMO .."}} On use, Isaac can shoot a laser that deals 24 points of damage",
            "The laser can open almost any door that hit",
            "{{BeckyMana}} Cost 35 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.OPEN_SESAMO .."}} Al usarlo, Isaac puede disparar un láser que hace 24 puntos de daño",
            "El láser pude abrir casi cualquier puerta que le pegue",
            "{{BeckyMana}} Cuesta 35 puntos de mana",
        },
    },
    [SpellType.KNIGHT_ATTACK] = {
        en_us = {
            "{{BeckySpell".. SpellType.KNIGHT_ATTACK .."}} Spawns a knight on Isaac",
            "The knight will target the closest enemy to it and do 3 slashes",
            "{{BeckyMana}} Cost 45 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.KNIGHT_ATTACK .."}} Invoca un caballero en Isaac",
            "El caballero apuntara al enemigo mas cercano a este y hará 3 cortes",
            "{{BeckyMana}} Cuesta 45 puntos de mana",
        },
    },
    [SpellType.VINE] = {
        en_us = {
            "{{BeckySpell".. SpellType.VINE .."}} Spawns various vines around enemies",
            "{{BeckyMana}} Cost 14 mana points each vine spawned",
        },
        spa = {
            "{{BeckySpell".. SpellType.VINE .."}} Genera varias enredaderas alrededor de los enemigos",
            "{{BeckyMana}} Cuesta 14 puntos de mana por cada enredadera generada",
        },
    },
    [SpellType.AETHER_CIRCLE] = {
        en_us = {
            "{{BeckySpell".. SpellType.AETHER_CIRCLE .."}} Isaac shoots 8 fires around him",
            "{{BeckyMana}} Cost 35 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.AETHER_CIRCLE .."}} Isaac dispara 8 fuegos alrededor de él",
            "{{BeckyMana}} Cuesta 35 puntos de mana",
        },
    },
    [SpellType.GILDED_SPEAR] = {
        en_us = {
            "{{BeckySpell".. SpellType.GILDED_SPEAR .."}} Spawns 5-7 spears around the edge of the room",
            "{{BeckyMana}} Cost 40 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.GILDED_SPEAR .."}} Invoca 5-7 lanzas por el borde del cuarto",
            "{{BeckyMana}} Cuesta 40 puntos de mana",
        },
    },
    [SpellType.HAUNT] = {
        en_us = {
            "{{BeckySpell".. SpellType.HAUNT .."}} On use, lets Isaac shoot a tear",
            "If this tears hits an enemy will let him move all enemies of the same type for 5 seconds",
            "If hits a boss it will confuse them for 2.5 seconds",
            "{{BeckyMana}} Cost 50 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.HAUNT .."}} Al usarlo, deja a Isaac disparar una lágrima",
            "Si esta lágrima le pega a un enemigo, todos los enemigos de ese tipo podran ser controlados por 5 segundos",
            "Si le pega a un jefe, lo confundirá por 2.5 segundos",
            "{{BeckyMana}} Cuesta 50 puntos de mana",
        },
    },
    [SpellType.TIMEFREEZE] = {
        en_us = {
            "{{BeckySpell".. SpellType.TIMEFREEZE .."}} Freezes all enemies in the room for 3 seconds",
            "{{BeckyMana}} Cost 60 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.TIMEFREEZE .."}} Congelá a todos los enemigos en el cuarto por 3 segundos",
            "{{BeckyMana}} Cuesta 60 puntos de mana",
        },
    },
    [SpellType.BOTTLE_WITH_WATER] = {
        en_us = {
            "{{BeckySpell".. SpellType.BOTTLE_WITH_WATER .."}} Isaac shoot a bottle that makes a puddle that damage enemies",
            "{{BeckyMana}} Cost 50 mana points",
        },
        spa = {
            "{{BeckySpell".. SpellType.BOTTLE_WITH_WATER .."}} Isaac dispara una botella que hace un charco que daña a enemigos",
            "{{BeckyMana}} Cuesta 50 puntos de mana",
        },
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