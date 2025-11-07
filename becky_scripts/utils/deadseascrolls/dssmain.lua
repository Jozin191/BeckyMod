local mod = BeckyMod

BeckyMod.HasLoadedDSS = true

local DSSModName = "becky Mod DSS Menu"

local DSSCoreVersion = 7

local MenuProvider = {}

function MenuProvider.SaveSaveData()
    mod.SaveManager.Save()
end

function MenuProvider.GetPaletteSetting()
	return mod.SaveManager.GetDeadSeaScrollsSave().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
	mod.SaveManager.GetDeadSeaScrollsSave().MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
	if not REPENTANCE then
		return mod.SaveManager.GetDeadSeaScrollsSave().HudOffset
	else
		return Options.HUDOffset * 10
	end
end

function MenuProvider.SaveHudOffsetSetting(var)
	if not REPENTANCE then
		mod.SaveManager.GetDeadSeaScrollsSave().HudOffset = var
	end
end

function MenuProvider.GetGamepadToggleSetting()
	return mod.SaveManager.GetDeadSeaScrollsSave().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
	mod.SaveManager.GetDeadSeaScrollsSave().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
	return mod.SaveManager.GetDeadSeaScrollsSave().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
	mod.SaveManager.GetDeadSeaScrollsSave().MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return BeckyMod.SaveManager.GetDeadSeaScrollsSave().MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
	mod.SaveManager.GetDeadSeaScrollsSave().MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
	return mod.SaveManager.GetDeadSeaScrollsSave().MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
	mod.SaveManager.GetDeadSeaScrollsSave().MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
	return mod.SaveManager.GetDeadSeaScrollsSave().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
	mod.SaveManager.GetDeadSeaScrollsSave().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
	return mod.SaveManager.GetDeadSeaScrollsSave().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
	mod.SaveManager.GetDeadSeaScrollsSave().MenusPoppedUp = var
end
local dssmenucore = include("becky_scripts.utils.deadseascrolls.dssmenucore")
BeckyMod.dssmod = dssmenucore.init(DSSModName, MenuProvider)
local dssmod = BeckyMod.dssmod

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not mod.HasLoadedDSSReal and mod.SaveManager.IsLoaded() then

        -- for achievements

        local function SureFunc(str, var, outcome, tooltip)

            return {str = str, 
            func = function()     
                mod:NestVariable(mod.SaveManager.GetSettingsSave(), str, "DSSSavedata", "YesNo", "Name" )
                mod:NestVariable(mod.SaveManager.GetSettingsSave(), var, "DSSSavedata", "YesNo", "Variable" )
                mod:NestVariable(mod.SaveManager.GetSettingsSave(), outcome, "DSSSavedata", "YesNo", "Outcome" )
                mod:NestVariable(mod.SaveManager.GetSettingsSave(), tooltip, "DSSSavedata", "YesNo", "Tooltip" )

                if BeckyMod.dmdirectory.yesNo then
                    BeckyMod.dmdirectory.yesNo.title = mod:GetNestedVariable(mod.SaveManager.GetSettingsSave(), "DSSSavedata", "YesNo", "Name" )
                    BeckyMod.dmdirectory.yesNo.tooltip = {strset = mod:GetNestedVariable(mod.SaveManager.GetSettingsSave(), "DSSSavedata", "YesNo", "Tooltip" )}
                end
            end, 
            dest = 'yesNo', tooltip = {strset = tooltip}}
        end

        local function CheckVectors(table, element)
            for k, v in ipairs(table) do
                if v:Distance(element) == 0 then
                    return true
                end
            end
            return false
        end

        local buttonAchievements = {}
        local panelFilterOptions = {
            nil,
            "Becky",
            "Character",
            "Item",
        }

        for i, item in ipairs(BeckyMod.ACHIEVEMENT) do
            if not item.Sprite then
                item.Sprite = Sprite()
                item.Sprite:Load("gfx/ui/achievement/_becky_achievement.anm2", false)
                item.Sprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_" .. string.lower(item.ID) ..".png")
                item.Sprite:ReplaceSpritesheet(0, "gfx/nothing.png")
                item.extraSpriteID = i
                item.Sprite:LoadGraphics()
            end
        end

        local selectedAch
        local drawings = {}
        local forceUnpause
        local paused
        local sidePaper = Sprite()
        sidePaper:Load("gfx/ui/achievement/sidenote/_becky_achievement_sidepaper.anm2", true)

        local achievementTooltipSprites = {
            Shadow = "gfx/ui/achievement/sidenote/sidepaper_shadow.png",
            Back = "gfx/ui/achievement/sidenote/sidepaper_back.png",
            Face = "gfx/ui/achievement/sidenote/sidepaper_face.png",
            Border = "gfx/ui/achievement/sidenote/sidepaper_border.png",
            Mask = "gfx/ui/achievement/sidenote/sidepaper_mask.png",
        }

        for k, v in pairs(achievementTooltipSprites) do
            local sprite = Sprite()
            sprite:Load("gfx/ui/achievement/sidenote/_becky_achievement_sidepaper.anm2", false)
            sprite:ReplaceSpritesheet(0, "gfx/nothing.png")
            sprite:LoadGraphics()
            achievementTooltipSprites[k] = sprite
        end

        local coOpSprite = Sprite()
        coOpSprite:Load("gfx/ui/eid_becky_players_icon.anm2", true)
        -- ok done with setting up achievements

        local coOpSpriteList = {
            "Becky"
        }

        local bossSprite = Sprite()
        bossSprite:Load("gfx/ui/hudpickups.anm2", true)

        local coOpBossList = {
            ["Mom"] = 0,
            ["Mom's Heart"] = 1,
            ["Satan"] = 2,
            ["Isaac"] = 3,
            ["Lamb"] = 4,
            ["???"] = 5,
            ["Mega Satan"] = 6,
            ["Hush"] = 8,
            ["Delirium"] = 9,
            ["Witness"] = 11
        }

        local bannedPositions = {}

        BeckyMod.dmdirectory = {
            main = {
                title = 'becky',

                buttons = {
                    {str = 'resume game', action = 'resume'},
                    {str = 'options', dest = 'Beckyoptions',tooltip = {strset = {'---','play around', 'with what', 'you like and', 'do not like', '---'}}},
                    {str = 'credits', dest = 'Beckycredits',tooltip = {strset = {'---','giving thanks', 'to everyone', 'who helped', '---'}}},         
                    BeckyMod.dssmod.changelogsButton,
                    {str = '', fsize=2, nosel = true},
                    {str = 'thanks for playing', fsize = 2, nosel = true},
                    {str = 'the becky mod', fsize = 2, nosel = true},
                },
                tooltip = BeckyMod.dssmod.menuOpenToolTip,
            },

            Beckyoptions =  {
                    title = 'options',
                        buttons = {
                            {str = '', fsize=2, nosel = true},
                            {str = '-----other-----', fsize=2, nosel = true},

                            {str = '', fsize=2, nosel = true},
                            {str = 'achievements',   
                            dest = 'achievementsoptions',
                            tooltip = {strset = {'control', 'locked content', 'and related', 'achievements'}}
                            },                   
                            {str = '', fsize=2, nosel = true},

                            {str = '--------------', fsize=2, nosel = true},
                            {str = '', fsize=2, nosel = true},
                            {
                                str = "reset savedata",
                                fsize = 3,
                                action = "resume",

                                func = function()
                                    DeadSeaScrollsMenu.QueueMenuOpen("becky mod", "resetSavedata", 1, true)
                                end,

                                tooltip = {strset = {'control', 'locked content', 'and related', 'achievements'}}
                            },
                            {str = '', fsize=2, nosel = true},
                        }
            },

            achievementsoptions = {
                title = "achievements",
                buttons = {
                    SureFunc("unlock all", "lockall", 2, {'unlocks all','if desired', '', 'dependant', 'by default', '', 'to update', 'restart run'}),
                    SureFunc("depend all", "lockall", 1, {'sets unlocks','back to','player','dependant', '', 'to update', 'restart run'}),
                    {
                        str = "unlock tooltip",
                        choices = {'on', 'off'},
                        variable = "lockAchTooltip",
                        setting = 1,
                        load = function()
                            return mod.SaveManager.GetSettingsSave().lockAchTooltip or 2
                        end,
                        store = function(var)
                            mod.SaveManager.GetSettingsSave().lockAchTooltip = var
                        end,
                        tooltip = {strset = {'shows tooltip', 'to a unlock', 'while locked', '', 'default', 'is off', '', 'updates on', 'dss close'}}
                    },
                }
            },

            unlockspopup = {
                title = "achievements ?",
                fsize = 1,
                buttons = {
                    {str = "a majority of the becky mod's", nosel = true},
                    {str = "non-character related content", nosel = true},
                    {str = "is locked behind achievements", nosel = true},
                    {str = "", nosel = true},
                    {str = "this is an optional feature", nosel = true},
                    {str = "", nosel = true},
                    {str = "continue with", fsize = 2, nosel = true},
                    {str = "said changes?", fsize = 2, nosel = true},
                    {str = "", nosel = true},
                    {
                        str = "yes",
                        action = "resume",
                        fsize = 3,
                        glowcolor = 3,

                        func = function()
                            mod.SaveManager.GetSettingsSave().lockall = 1
                            mod.SaveManager.GetPersistentSave().shownUnlocksChoicePopup = true
                            BeckyAchievementSystem:Setup()
                        end,
                    },
                    {
                        str = "no",
                        action = "resume",
                        fsize = 3,

                        func = function()
                            mod.SaveManager.GetSettingsSave().lockall = 2
                            mod.SaveManager.GetPersistentSave().shownUnlocksChoicePopup = true
                            BeckyAchievementSystem:Setup()
                        end
                    },

                    {str = "", nosel = true},
                },
                tooltip = {strset = {'you may', 'change options', 'later'}}
            },

            resetSavedata = {
                title = "reset savedata?",
                fsize = 1,
                buttons = {
                    {str = "you cannot undo this", nosel = true},
                    {str = "", nosel = true},
                    {str = "continue with", fsize = 2, nosel = true},
                    {str = "said changes?", fsize = 2, nosel = true},
                    {str = "", nosel = true},
                    {
                        str = "yes",
                        action = "resume",
                        fsize = 3,
                        glowcolor = 3,

                        func = function()
                            --thanks epiph
                            local modSave = mod.SaveManager.GetEntireSave()
                            modSave.file.other = nil
                            modSave = mod.SaveManager.Utility.PatchSaveFile(modSave, mod.SaveManager.DEFAULT_SAVE)
                            mod.SaveManager.GetPersistentSave().SAVE_VERSION = 4
                            mod.SaveManager.Save()
                        end,
                    },
                    {
                        str = "no",
                        action = "resume",
                        fsize = 3,
                    },

                    {str = "", nosel = true},
                },
                tooltip = {strset = {'you cannot', 'undo this'}}
            },
            yesNo = {
                title = mod:GetNestedVariable(mod.SaveManager.GetSettingsSave(), "DSSSavedata", "YesNo", "Name" ),
                fsize = 1,
                buttons = {
                    {str = "would you wish", nosel = true},
                    {str = "to proceed with", nosel = true},
                    {str = "your choice?", fsize = 2, nosel = true},
                    {str = "", nosel = true},
                    {
                        str = "yes",
                        action = "back",
                        fsize = 3,
                        glowcolor = 3,

                        func = function()
                            mod.SaveManager.GetSettingsSave()[mod:GetNestedVariable(mod.SaveManager.GetSettingsSave(), "DSSSavedata", "YesNo", "Variable" )] = mod:GetNestedVariable(mod.SaveManager.GetSettingsSave(), "DSSSavedata", "YesNo", "Outcome" )
                        end,
                    },
                    {
                        str = "no",
                        action = "back",
                        fsize = 3,
                    },

                    {str = "", nosel = true},
                },
                tooltip = {strset = mod:GetNestedVariable(mod.SaveManager.GetSettingsSave(), "DSSSavedata", "YesNo", "Tooltip" )}
            }
        }

        local dmdirectorykey = {
            Item = BeckyMod.dmdirectory.main,
            Main = 'main',
            Idle = false,
            MaskAlpha = 1,
            Settings = {},
            SettingsChanged = false,
            Path = {},
        }

        DeadSeaScrollsMenu.AddMenu("becky mod", {Run = BeckyMod.dssmod.runMenu, Open = BeckyMod.dssmod.openMenu, Close = BeckyMod.dssmod.closeMenu, Directory = BeckyMod.dmdirectory, DirectoryKey = dmdirectorykey})



        function mod:IsSettingOn(setting)
            if setting == 1 then
                return true
            else
                return false
            end
        end

        for hook = InputHook.IS_ACTION_PRESSED, InputHook.IS_ACTION_TRIGGERED do
            mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
                if paused and action ~= ButtonAction.ACTION_CONSOLE then
                    return false
                end
            end, hook)
        end

        mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
            if forceUnpause and action == ButtonAction.ACTION_SHOOTDOWN then
                forceUnpause = false
                return 0.75
            end
        end, InputHook.GET_ACTION_VALUE)

        BeckyMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
            if not mod.SaveManager.GetPersistentSave().shownUnlocksChoicePopup then
                DeadSeaScrollsMenu.QueueMenuOpen("becky mod", "unlockspopup", 1, true) 
            end
        end)

        mod.HasLoadedDSSReal = true
    end
end)
