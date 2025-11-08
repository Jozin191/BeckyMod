local mod = BeckyMod

BeckyMod.HasLoadedDSS = true

local DSSModName = "becky Mod DSS Menu"

local BREAK_LINE = {str = "", fsize = 1, nosel = true}

local DSSCoreVersion = 7

local MenuProvider = {}

local function GenerateTooltip(str)
    local endTable = {}
    local currentString = ""
    for w in str:gmatch("%S+") do
        local newString = currentString .. w .. " "
        if newString:len() >= 15 then
            table.insert(endTable, currentString)
            currentString = ""
        end

        currentString = currentString .. w .. " "
    end

    table.insert(endTable, currentString)
    return {strset = endTable}
end

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

        -- for i, item in ipairs(BeckyMod.ACHIEVEMENT) do
        --     if not item.Sprite then
        --         item.Sprite = Sprite()
        --         item.Sprite:Load("gfx/ui/achievement/_becky_achievement.anm2", false)
        --         item.Sprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_" .. string.lower(item.ID) ..".png")
        --         item.Sprite:ReplaceSpritesheet(0, "gfx/nothing.png")
        --         item.extraSpriteID = i
        --         item.Sprite:LoadGraphics()
        --     end
        -- end

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

            Beckycredits = {
                title = 'credits',

                buttons = {
                    {str = 'directors', fsize = 3, nosel = true},
                    BREAK_LINE,
                    {str = 'jozin', fsize=2, tooltip = GenerateTooltip('director, art, design and animation')},
                    {str = 'interstellarnuggo ', fsize=2, tooltip = GenerateTooltip('trailer music and co-director')},

                    BREAK_LINE,
                    {str = 'members', fsize = 3, nosel = true},
                    BREAK_LINE,

                    {str = 'kotry', fsize=2, tooltip = GenerateTooltip('main coder')},
                    {str = 'tiburones', fsize=2, tooltip = GenerateTooltip('coder')},
                    {str = 'ignatz', fsize=2, tooltip = GenerateTooltip('coder')},
                    {str = 'cvs', fsize=2, tooltip = GenerateTooltip('coder')},
                    {str = 'nerfexus', fsize=2, tooltip = GenerateTooltip('artist')},
                    {str = 'darigoat', fsize=2, tooltip = GenerateTooltip('artist')},
                    {str = 'no-name', fsize=2, tooltip = GenerateTooltip('artist')},
                    {str = 'muffintae', fsize=2, tooltip = GenerateTooltip('designer')},
                    {str = 'blender', fsize=2, tooltip = GenerateTooltip('designer')},
                    -- {str = '', fsize=1, nosel = true},    

                    BREAK_LINE,
                    {str = 'contributors', fsize = 3, nosel = true},
                    BREAK_LINE,
                    {str = 'kerkel', fsize=2, tooltip = GenerateTooltip('"sinner" code')},
                    {str = 'benny', fsize=2, tooltip = GenerateTooltip('"dead socket" code')},
                    {str = 'sorrow', fsize=2, tooltip = GenerateTooltip('"corpse tag" code')},
                    {str = 'lunastella', fsize=2, tooltip = GenerateTooltip('part of the ghost code')},
                    {str = 'hellio', fsize=2, tooltip = GenerateTooltip('part of the ghost code')},

                    BREAK_LINE,
                    {str = 'playtesters', fsize = 3, nosel = true},
                    BREAK_LINE,
                    {str = 'burrowingbug', fsize=2},
                    {str = '4head', fsize=2},
                    {str = 'alperenalc', fsize=2},
                    {str = 'kattack', fsize=2},
                }
            },
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
