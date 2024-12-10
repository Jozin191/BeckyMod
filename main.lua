BeckyMod = RegisterMod("Becky", 1)

local f = Font()
f:Load("font/terminus.fnt")
local function requireRepentogon()
    if not REPENTOGON then
        f:DrawString("REPENTOGON isn't installed", 60, 50, KColor(1,1,1,1,0,0,0),0,true)
        f:DrawString("Head to the REPENTOGON mod page for instructions!", 60, 70, KColor(1,1,1,1,0,0,0),0,true)
        f:DrawString("(Becky mod requires repentogon to work)", 60, 90, KColor(1,1,1,1,0,0,0),0,true)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_RENDER, requireRepentogon)
if not REPENTOGON then return end

--characters
include("becky_scripts.characters.becky")

--collectibles
include("becky_scripts.items.passives.dream_banisher")

--trinkets
include("becky_scripts.items.trinkets.burning_feather")

--custom texture for items (such as custom mr dolly)
include("becky_scripts.misc.custom_items")
