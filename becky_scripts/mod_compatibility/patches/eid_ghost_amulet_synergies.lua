
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
        Items = {CollectibleType.COLLECTIBLE_THE_WIZ},
        Desc = {
            en_us = "Ghosts are controlled in a v shape",
        }
    },
    {
        Items = {CollectibleType.COLLECTIBLE_SINUS_INFECTION, "5.350."..TrinketType.TRINKET_NOSE_GOBLIN },
        Desc = {
            en_us = "25% chance to randomly shoot a sticky booger tear on hit",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_GHOST_PEPPER,
        Desc = {
            en_us = "1% chance to shoot a blue flame on hit",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_BIRDS_EYE,
        Desc = {
            en_us = "1% chance to shoot a red flame on hit",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_BRIMSTONE,
        Desc = {
            en_us = "Every 3rd ghost hit causes it to shoot out a brimstone ball",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_C_SECTION,
        Desc = {
            en_us = "15% chance to shoot a fetus on hit",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_DR_FETUS,
        Desc = {
            en_us = "15% chance to drop a bomb on hit",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_EXPLOSIVO,
        Desc = {
            en_us = "When the ghost hits an enemy, it has 25% chance to randomly shoot a sticky explosive tear",
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
            en_us = "When the ghost hits an enemy, it has 50% chance to randomly lob a haemolacria tear",
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
            en_us = "On hit has a 25% to shot a mucormycosis tear",
        }
    },
    {
        Items = {CollectibleType.COLLECTIBLE_PARASITE, CollectibleType.COLLECTIBLE_CRICKETS_BODY , CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE},
        Desc = {
            en_us = "The ghost inherits the splitting effects on hit",
        }
    },
    {
        Items = {CollectibleType.COLLECTIBLE_TECHNOLOGY, CollectibleType.COLLECTIBLE_TECHNOLOGY_2 , CollectibleType.COLLECTIBLE_TECH_5},
        Desc = {
            en_us = "On hit a laser is shot on a random direction",
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
            en_us = "On hit cause a laser to spawn that is connected between Isaac and the familiar",
        }
    },

    -- General tear effects that behave how they should
    {
        Items = {CollectibleType.COLLECTIBLE_EUTHANASIA, CollectibleType.COLLECTIBLE_APPLE, CollectibleType.COLLECTIBLE_TOUGH_LOVE, CollectibleType.COLLECTIBLE_MOMS_EYESHADOW, CollectibleType.COLLECTIBLE_GLAUCOMA, CollectibleType.COLLECTIBLE_IRON_BAR, CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS, CollectibleType.COLLECTIBLE_ABADDON, CollectibleType.COLLECTIBLE_MOMS_PERFUME, CollectibleType.COLLECTIBLE_DARK_MATTER, CollectibleType.COLLECTIBLE_URANUS, CollectibleType.COLLECTIBLE_MOMS_CONTACTS, CollectibleType.COLLECTIBLE_COMMON_COLD, CollectibleType.COLLECTIBLE_HOLY_LIGHT, CollectibleType.COLLECTIBLE_SERPENTS_KISS, CollectibleType.COLLECTIBLE_SCORPIO, CollectibleType.COLLECTIBLE_BALL_OF_TAR, CollectibleType.COLLECTIBLE_PARASITOID, CollectibleType.COLLECTIBLE_OCULAR_RIFT, CollectibleType.COLLECTIBLE_SPIDER_BITE, CollectibleType.COLLECTIBLE_GODS_FLESH, CollectibleType.COLLECTIBLE_BACKSTABBER, CollectibleType.COLLECTIBLE_ROTTEN_TOMATO, CollectibleType.COLLECTIBLE_LODESTONE,
                    "5.350."..TrinketType.TRINKET_CHEWED_PEN, "5.350."..TrinketType.TRINKET_JAW_BREAKER, "5.350."..TrinketType.TRINKET_BLACK_TOOTH , "5.350."..TrinketType.TRINKET_PINKY_EYE },
        Desc = {
            en_us = "Tear effect is inherited by the ghost!",
        }
    },

    {
        Items = CollectibleType.COLLECTIBLE_LUMP_OF_COAL,
        Desc = {
            en_us = "The ghost does more damage the farther away it is from Isaac",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_PROPTOSIS,
        Desc = {
            en_us = "The ghost does much more damage but does less the further it is away from Isaac",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_CHOCOLATE_MILK,
        Desc = {
            en_us = "The ghost builds up extra damage that resets when it hits an enemy",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_TERRA,
        Desc = {
            en_us = "The ghost does variable damage and destroy rocks and doors it passes over",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_SULFURIC_ACID,
        Desc = {
            en_us = "The ghost has a chance to destroy rocks and doors it passes over",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_IPECAC,
        Desc = {
            en_us = "The ghost explodes on contact with enemies",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_FIRE_MIND,
        Desc = {
            en_us = "The ghost burns enemies it hits and has a chance to explode",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_FLAT_STONE,
        Desc = {
            en_us = "The ghost bounces off the ground based on tear rate",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_LOST_CONTACT,
        Desc = {
            en_us = "The ghost blocks any projectiles it comes in contact with",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_MOMS_KNIFE,
        Desc = {
            en_us = "A knife orbits around the ghost",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_EPIC_FETUS,
        Desc = {
            en_us = "Marks appear on the ghosts forehead that cause becky to hurl a rocket at it when once it hits an enemy",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_EVIL_EYE,
        Desc = {
            en_us = "Ghost occasionally spawns an evil eye",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_EYE_SORE,
        Desc = {
            en_us = "Ghost occasionally shoots out 1-3 tears in random directions",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_JACOBS_LADDER,
        Desc = {
            en_us = "The ghosts arcs electricity when it hits an enemy",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_KIDNEY_STONE,
        Desc = {
            en_us = "The ghost has to push the kidney stone instead :)",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_LARGE_ZIT,
        Desc = {
            en_us = "Ghost has a chance to randomly shoot creep and a zit tear on hit",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_MOMS_EYE,
        Desc = {
            en_us = "Ghost has a chance to shoot a tear behind it on hit",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_NEPTUNUS,
        Desc = {
            en_us = "Ghost leaves behind a trail of tears with the intensity based on how fast its moving",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_3_DOLLAR_BILL,
        Desc = {
            en_us = "{{ColorRainbow}}Rainbow ghost :D",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE,
        Desc = {
            en_us = "The ghost does a random tear effect from a set list on hit. also {{ColorRainbow}}rainbow :D",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_FRUIT_CAKE,
        Desc = {
            en_us = "The ghost constantly shuffles through completely random tear effects. also {{ColorRainbow}}rainbow :D",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_MONSTROS_LUNG,
        Desc = {
            en_us = "The ghost loses some damage but slowly charges a monstros lung charge. Once it is fully charged, it will shoot it at the next enemy it hits",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_LEAD_PENCIL,
        Desc = {
            en_us = "Every 15th hit causes Isaac to shoot a barrage of tears towards the ghost",
        }
    },
   {
        Items = CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID,
        Desc = {
            en_us = "Ghost leaves a trail of toxic green creep",
        }
    },
   {
        Items = CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR,
        Desc = {
            en_us = "Ghost pulls enemies and pickups towards it",
        }
    },
   {
        Items = {CollectibleType.COLLECTIBLE_PUPULA_DUPLEX, "5.350."..TrinketType.TRINKET_FLAT_WORM},
        Desc = {
            en_us = "Ghost width up!",
        }
    },
   {
        Items = CollectibleType.COLLECTIBLE_EYE_OF_BELIAL,
        Desc = {
            en_us = "Ghost turns {{ColorRed}}red{{BlinkGray}} and can be exorcised by hitting an enemy",
        }
    },
   {
        Items = {CollectibleType.COLLECTIBLE_GODHEAD, CollectibleType.COLLECTIBLE_SPOON_BENDER, CollectibleType.COLLECTIBLE_SACRED_HEART, CollectibleType.COLLECTIBLE_TELEPATHY_BOOK},
        Desc = {
            en_us = "Homing! Spawns a secondary purple ghost that automatically attacks enemies.",
        }
    },
}


return function()
    for _, synergy in ipairs(SYNERGY_LIST) do
        for lang, desc in pairs(synergy.Desc) do
            EID:addSynergyCondition(BeckyMod.Item.GHOST_AMULET.ID, synergy.Items, "{{BlinkGray}}"..desc, nil, lang, nil)
        end
    end
end