BeckyMod = RegisterMod("Becky", 1)
BeckyMod.RECOMMENDED_SHIFT_IDX = 35

BeckyMod.SaveManager = include("becky_scripts.utils.save_manager")
BeckyMod.SaveManager.Init(BeckyMod)

include("becky_scripts.utils.saving_system")

BeckyMod.Scheduler = include("becky_scripts.utils.schedule_data")

BeckyMod.Game = Game()

BeckyMod.Item = {}
BeckyMod.Trinket = {}
BeckyMod.Character = {}

local f = Font()
f:Load("font/terminus.fnt")
BeckyMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not REPENTOGON then
        f:DrawString("REPENTOGON isn't installed", 60, 50, KColor(1,1,1,1),0,true)
        f:DrawString("Head to the REPENTOGON mod page for instructions!", 60, 70, KColor(1,1,1,1),0,true)
        f:DrawString("(Becky mod requires repentogon to work)", 60, 90, KColor(1,1,1,1),0,true)
    end
end)
if not REPENTOGON then return end

--Changed the order since characters need to get actives. If the character loads first and the item later, it errors. 

--collectibles
include("becky_scripts.becky.items.passives.dream_banisher")
include("becky_scripts.becky.items.actives.hand_made_bible")

--trinkets
include("becky_scripts.becky.items.trinkets.burning_feather")

--characters
include("becky_scripts.becky.characters.becky")

--custom texture for items (such as custom mr dolly)
include("becky_scripts.mod_compatibility.external_items_descriptions")
include("becky_scripts.mod_compatibility.custom_items")
