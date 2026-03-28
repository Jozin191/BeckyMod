
local SYNERGY_LIST = {
    {
        Items = {CollectibleType.COLLECTIBLE_TECHNOLOGY, CollectibleType.COLLECTIBLE_TECHNOLOGY_2 , CollectibleType.COLLECTIBLE_TECH_5},
        Desc = {
            en_us = "On hit shot a laser on a random direction",
        }
    },
    {
        Items = {CollectibleType.COLLECTIBLE_INNER_EYE, CollectibleType.COLLECTIBLE_MUTANT_SPIDER, CollectibleType.COLLECTIBLE_20_20, CollectibleType.COLLECTIBLE_THE_WIZ},
        Desc = {
            en_us = "Isaac controls multiple ghots",
        }
    },
    {
        Items = CollectibleType.COLLECTIBLE_APPLE,
        Desc = {
            en_us = "On hit may shoot a razon blade to a random direction",
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