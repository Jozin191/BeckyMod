BeckyMod = RegisterMod("Becky", 1)
RECOMMENDED_SHIFT_IDX = 35

--characters
include("becky_scripts.characters.becky")

--collectibles
include("becky_scripts.items.passives.dream_banisher")
include("becky_scripts.items.actives.hand_made_bible")

--trinkets
include("becky_scripts.items.trinkets.burning_feather")

--custom texture for items (such as custom mr dolly)
include("becky_scripts.misc.custom_items")
