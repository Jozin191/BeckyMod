
--[[
    {
        Items = CollectibleType.COLLECTIBLE_,
        Desc = {
            en_us = "",
        }
    },
]]

local SYNERGY_LIST = {
    {
        Items = {CollectibleType.COLLECTIBLE_INNER_EYE, CollectibleType.COLLECTIBLE_MUTANT_SPIDER, CollectibleType.COLLECTIBLE_20_20, CollectibleType.COLLECTIBLE_THE_WIZ},
        Desc = {
            en_us = "Isaac controls multiple ghots",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_APPLE,
        Desc = {
            en_us = "On hit may shot a razon blade to a random direction",
        }
    },
    {
        Items = {CollectibleType.COLLECTIBLE_SINUS_INFECTION, "5.350."..TrinketType.TRINKET_NOSE_GOBLIN },
        Desc = {
            en_us = "On hit has 25% to shot a booger tear to a random direction",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_GHOST_PEPPER,
        Desc = {
            en_us = "On hit has 1% to shot a blue flame",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_BIRDS_EYE,
        Desc = {
            en_us = "On hit has 1% to shot a flame",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_BRIMSTONE,
        Desc = {
            en_us = "Every 3 hits spawns a brimstone ball",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_CHEMICAL_PEEL,
        Desc = {
            en_us = "Every even hit does +2 flat damage",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_C_SECTION,
        Desc = {
            en_us = "On hit has a 15% to shot a fetus",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_DR_FETUS,
        Desc = {
            en_us = "On hit has a 15% to spawn a bomb",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_EUTHANASIA,
        Desc = {
            en_us = "May shot a needle when killing an enemy",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_EXPLOSIVO,
        Desc = {
            en_us = "On hit has a 25% to shot a sticky tear that explodes",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_GODHEAD,
        Desc = {
            en_us = "The familiar gains an aura that damage enemies",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_HAEMOLACRIA,
        Desc = {
            en_us = "On hit has a 50% to shot a haemplacria tear",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_HOLY_LIGHT,
        Desc = {
            en_us = "On hit may spawn a beam of light",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_LOKIS_HORNS,
        Desc = {
            en_us = "On hit may shot 4 tears on the cardinal directions of the familiar",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_POP,
        Desc = {
            en_us = "On hit has a 20% to shot a pop tear",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_SPIRIT_SWORD,
        Desc = {
            en_us = "On hit spins a sword around the familiar",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_MUCORMYCOSIS,
        Desc = {
            en_us = "On hit has a 25% to shot a murcormycosis tear",
        }
    },
    {
        Items = {CollectibleType.COLLECTIBLE_PARASITE, CollectibleType.COLLECTIBLE_CRICKETS_BODY , CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE},
        Desc = {
            en_us = "On hit shot a tear that can split",
        }
    },
    {
        Items = {CollectibleType.COLLECTIBLE_TECHNOLOGY, CollectibleType.COLLECTIBLE_TECHNOLOGY_2 , CollectibleType.COLLECTIBLE_TECH_5},
        Desc = {
            en_us = "On hit shot a laser on a random direction",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_TECH_X,
        Desc = {
            en_us = "The familiar has a laser ring around it",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO,
        Desc = {
            en_us = "On hit shot a laser between the Isaac and the familiar",
        }
    },
}


return function()
    for _, synergy in ipairs(SYNERGY_LIST) do
        for lang, desc in pairs(synergy.Desc) do
            EID:addSynergyCondition(BeckyMod.Item.GHOST_AMULET.ID, synergy.Items, desc, nil, lang, nil)
        end
    end
end