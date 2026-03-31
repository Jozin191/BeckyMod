---@class ModReference
BeckyMod = RegisterMod("Becky", 1)
BeckyMod.RECOMMENDED_SHIFT_IDX = 35

--FLAGS!!!
BeckyMod.FLAGS = {}
BeckyMod.FLAGS.Debug = true
--End of flags

BeckyMod.SaveManager = include("becky_scripts.utils.save_manager")
BeckyMod.SaveManager.Init(BeckyMod)

include("becky_scripts.utils.lua_overrides")
include("becky_scripts.utils.becky_utils")
include("becky_scripts.utils.saving_system")
include("becky_scripts.utils.table_functions")
include("becky_scripts.utils.bitmask_helper")
include("becky_scripts.utils.hud_helper")
include("becky_scripts.utils.BombLib")
include("becky_scripts.utils.player_anim_lib")
include("becky_scripts.utils.deadseascrolls.dssmain")

Scheduler = include("becky_scripts.utils.schedule_data")

BeckyMod.Game = Game()
BeckyMod.SFX = SFXManager()
BeckyMod.Level = function() return BeckyMod.Game:GetLevel() end
BeckyMod.itemconfig = Isaac.GetItemConfig()
function BeckyMod:RefreshItemConfig()
	BeckyMod.itemconfig = Isaac.GetItemConfig()
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, BeckyMod.RefreshItemConfig)
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BeckyMod.RefreshItemConfig)
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_MODS_LOADED, CallbackPriority.IMPORTANT, BeckyMod.RefreshItemConfig)

BeckyMod.Item = {}
BeckyMod.Trinket = {}
BeckyMod.Character = {}
BeckyMod.Pickup = {}

if not REPENTOGON then
    local f = Font()
    f:Load("font/terminus.fnt")
    BeckyMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        f:DrawString("REPENTOGON isn't installed", 60, 50, KColor(1,1,1,1),0,true)
        f:DrawString("Head to the REPENTOGON mod page for instructions!", 60, 70, KColor(1,1,1,1),0,true)
        f:DrawString("(Becky mod requires repentogon to work)", 60, 90, KColor(1,1,1,1),0,true)
    end)
    
    return
end

--Changed the order since characters need to get actives. If the character loads first and the item later, it errors. 

--collectibles
include("becky_scripts.becky.items.passives.dream_banisher")
include("becky_scripts.becky.items.passives.coxinha")
include("becky_scripts.becky.items.passives.scarecrow")
include("becky_scripts.becky.items.passives.dead_socket")
include("becky_scripts.becky.items.passives.null_bomb")
include("becky_scripts.becky.items.passives.defiled_chalice")
include("becky_scripts.becky.items.passives.dead_battery")
include("becky_scripts.becky.items.passives.sinner")
include("becky_scripts.becky.items.passives.ghost_amulet")

include("becky_scripts.becky.items.actives.hand_made_bible")
include("becky_scripts.becky.items.actives.night_of_the_slasher")
include("becky_scripts.becky.items.actives.butcher's_cookbook")

--trinkets
include("becky_scripts.becky.items.trinkets.sanguine_feather")
include("becky_scripts.becky.items.trinkets.holy_bookmark")
include("becky_scripts.becky.items.trinkets.devilzon_prime")
include("becky_scripts.becky.items.trinkets.corpse_tag")

--characters
include("becky_scripts.becky.characters.becky")
include("becky_scripts.becky.characters.sofia")

--Mod compatibility! (all patches are loaded in this file)
include("becky_scripts.mod_compatibility.load_patches")

--pickups
include("becky_scripts.becky.pickups.dead_battery")

--misc stuff
include("becky_scripts.utils.achievements_revamp")

--ghost synergies
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.CSection")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.DrFetus")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.TechZero")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Brimstone")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.StatusEffects")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.GodHead")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Haemolacria")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Ipecac")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Explosivo")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Booger")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Spore")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.TearSplit")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.SpiritSword")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.TechX")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.BothPeppers")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Techs")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.JacobsLadder")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.LokisHorns")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.MysteriousLiquid")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.HolyLight")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Athame")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Apple")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.ChemicalPeel")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Euthanasia")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Pop")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.IBS")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Stye")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.CommonCold")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.FireMind")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.BallOfTar")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.MomsContact")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.IronBar")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.RottenTomato")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.FearTears")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.MomsKnife")
include("becky_scripts.becky.items.passives.GhostAmuletSynergies.Parasotoid")

--challenges
include("becky_scripts.becky.challenges.path_of_pain")