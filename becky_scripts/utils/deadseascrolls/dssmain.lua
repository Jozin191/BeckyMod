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

            achievements = {
                format = {
                    Panels = {
                        {
                            Panel = {
                                StartAppear = function(panel) --universal
                                    panel.SmallPanelFrame = 0
                                    panel.Idle = false
                                    Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, UseFlag.USE_NOANIM)
                                    paused = true
                                end,
                                UpdateAppear = function(panel) --universal
                                        panel.SmallPanelFrame = panel.SmallPanelFrame + 1
                                        bannedPositions = {}
                                        if panel.SmallPanelFrame >= 10 then
                                            panel.Idle = true
                                            return true
                                        end
                                end,
                                StartDisappear = function(panel) --universal
                                    dssmod.playSound(dssmod.menusounds.Close)
                                    bannedPositions = {}
                                    panel.SmallPanelFrame = 32
                                    forceUnpause = true
                                    paused = false
                                end,
                                UpdateDisappear = function(panel) --universal
                                    panel.SmallPanelFrame = panel.SmallPanelFrame + 1
                                    if panel.SmallPanelFrame >= 40 then
                                        return true
                                    end
                                end,
                                RenderBack = function(panel, panelPos, tbl) --Becky specific

                                    if not panel.PanInit then --coding like a enemy for some unholy reason
                                        panel.Filter = nil
                                        panel.xPosPan = 0
                                        panel.OuterOffset = 0
                                        panel.PanInit = true
                                    end

                                    local achList = {}

                                    for _, thing in ipairs(BeckyMod.ACHIEVEMENT) do
                                        if (not panel.Filter or mod:CheckTableContents(thing.Tags, panel.Filter)) and not thing.Hidden then
                                            table.insert(achList, thing)
                                        end
                                    end

                                    if panel.MoveDown then
                                        if panel.OuterOffset+9 < #achList then
                                            panel.OuterOffset = panel.OuterOffset + 9
                                        end
                                        panel.MoveDown = false
                                    end

                                    if panel.MoveUp then
                                        if panel.OuterOffset-9 >= 0 then
                                            panel.OuterOffset = panel.OuterOffset - 9
                                        end
                                        panel.MoveUp = false
                                    end

                                    local mousePlacement

                                    if panel.MouseIconPos then
                                        local xPosPan = 0
                                        for i = 1, 9 do
                                            xPosPan = xPosPan + 1

                                            if panel.MouseIconPos:Distance(Vector(xPosPan-1, (math.floor((i-1)/3)))) < 1 then
                                                mousePlacement = i
                                            end
                                            if i%3 == 0 then
                                                xPosPan = 0                                        
                                            end
                                        end
                                    end

                                    local NEWxPosPan = 0
                                    local mouseIconT = {}
                                    panel.xPosPan = 0
                                    for i = 1, 9 do -- i split these becauuuuseeee (uh) i hate myself probably
                                    
                                        NEWxPosPan = NEWxPosPan + 1
                                        if (i-1)%3 == 0 then
                                            NEWxPosPan = 0                                        
                                        end
                                    
                                        local realNum = i + panel.OuterOffset

                                        local placement = Vector(NEWxPosPan, (math.floor((i-1)/3)))

                                        if panel.MouseIconPos and not achList[realNum] then
                                            table.insert(bannedPositions, placement)
                                        end
                                    
                                        if achList[realNum] and (realNum-1) < 9 + panel.OuterOffset and panel.SmallPanelFrame ~= 40 then

                                            local butt = {}

                                            SmallPanelFrame = panel.SmallPanelFrame

                                            panel.xPosPan = panel.xPosPan + 1
                                            if not BeckyAchievementSystem:IsUnlocked(achList[realNum].extraSpriteID) then 
                                                achList[i].Sprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_locked.png")
                                            else
                                                achList[i].Sprite:ReplaceSpritesheet(2, "gfx/ui/achievement/achievement_" .. string.lower(achList[realNum].ID) ..".png")
                                            end
                                            achList[i].Sprite:LoadGraphics()
                                            achList[i].Sprite:Play("Idle")
                                            achList[i].Sprite:SetFrame(panel.SmallPanelFrame)
                                            achList[i].Sprite.Scale = Vector(0.35, 0.35)
                                            if i == mousePlacement then
                                                achList[i].Sprite.Color = DeadSeaScrollsMenu.GetPalette()[1]
                                                selectedAch = achList[realNum]
                                                if REPENTOGON then
                                                    achList[i].Sprite.Color:SetOffset(0.1, 0.1, 0.1, 1)  
                                                else
                                                    achList[i].Sprite:ReplaceSpritesheet(1, "gfx/ui/achievement/paperlite.png")
                                                end
                                            else
                                                achList[i].Sprite.Color = DeadSeaScrollsMenu.GetPalette()[1]
                                                if REPENTOGON then
                                                    achList[i].Sprite.Color:SetColorize(0, 0, 0, 0.1)  
                                                else
                                                    achList[i].Sprite:ReplaceSpritesheet(1, "gfx/ui/achievement/paper.png")
                                                end
                                            end
                                            achList[i].Sprite:Render(panelPos + Vector((panel.xPosPan-1)*100, (math.floor((i-1)/3) * 80)) - Vector(190, 70), Vector.Zero, Vector.Zero)-- panelPos + Vector(panel.MouseIconPos.X*32, panel.MouseIconPos.Y*32), Vector.Zero, Vector.Zero)
                                            if i%3 == 0 then
                                                panel.xPosPan = 0                                        
                                            end

                                            butt.tooltip = achList[realNum].Tooltip
                                            butt.Position = panelPos + Vector((panel.xPosPan-1)*100, (math.floor((i-1)/3) * 80)) - Vector(190, 70)
                                            table.insert(mouseIconT, achList[realNum].Sprite)
                                            table.insert(buttonAchievements, butt)
                                        end
                                    end

                                    sidePaper:Play("Idle")
                                    sidePaper.Scale = Vector(0.8, 0.8)
                                    sidePaper:Render(panelPos + Vector(80, 0), Vector.Zero, Vector.Zero)
                                    sidePaper:SetFrame(panel.SmallPanelFrame)
                                    sidePaper.Color = DeadSeaScrollsMenu.GetPalette()[1]

                                end,
                                HandleInputs = function(panel, input, item, itemswitched, tbl) -- Becky specific
                                    if not itemswitched then
                                        local menuinput = input.menu
                                        local rawinput = input.raw --left, right, up, down

                                        panel.MouseIconPos = panel.MouseIconPos or Vector(0, 0)

                                        panel.InputtedInput = panel.InputtedInput or nil

                                        if rawinput.right > 0 and panel.InputtedInput~="right" then --im sure theres a better way to dthis i js cant come up with oneeeee
                                            if panel.MouseIconPos.X < 2 and not CheckVectors(bannedPositions, Vector(panel.MouseIconPos.X+1,panel.MouseIconPos.Y )) then
                                                panel.MouseIconPos.X = panel.MouseIconPos.X + 1
                                            end
                                            panel.InputtedInput = "right"
                                        elseif rawinput.right == 0 and panel.InputtedInput=="right" then
                                            panel.InputtedInput = nil
                                        end
                                        if rawinput.left > 0 and panel.InputtedInput~="left" then
                                            if panel.MouseIconPos.X > 0  and not CheckVectors(bannedPositions, Vector(panel.MouseIconPos.X-1,panel.MouseIconPos.Y )) then
                                                panel.MouseIconPos.X = panel.MouseIconPos.X - 1
                                            end
                                            panel.InputtedInput = "left"
                                        elseif rawinput.left == 0 and panel.InputtedInput=="left" then
                                            panel.InputtedInput = nil
                                        end
                                        if rawinput.up > 0 and panel.InputtedInput~="up" then
                                            if panel.MouseIconPos.Y < 1 and panel.OuterOffset ~= 0 then
                                                panel.MoveUp = true
                                                bannedPositions = {}
                                                panel.MouseIconPos.Y = panel.MouseIconPos.Y + 2
                                            elseif not CheckVectors(bannedPositions, Vector(panel.MouseIconPos.X,panel.MouseIconPos.Y-1)) and panel.MouseIconPos.Y > 0 then
                                                panel.MouseIconPos.Y = panel.MouseIconPos.Y - 1                                                
                                            end
                                            panel.InputtedInput = "up"
                                        elseif rawinput.up == 0 and panel.InputtedInput=="up" then
                                            panel.InputtedInput = nil
                                        end
                                        if rawinput.down > 0 and panel.InputtedInput~="down" then
                                            if panel.MouseIconPos.Y > 1 then
                                                panel.MoveDown = true
                                                bannedPositions = {}
                                                panel.MouseIconPos.Y = panel.MouseIconPos.Y - 2
                                            elseif not CheckVectors(bannedPositions, Vector(panel.MouseIconPos.X,panel.MouseIconPos.Y+1)) then
                                                panel.MouseIconPos.Y = panel.MouseIconPos.Y + 1
                                            end
                                            panel.InputtedInput = "down"
                                        elseif rawinput.down == 0 and panel.InputtedInput=="down" then
                                            panel.InputtedInput = nil
                                        end
                                    end
                                end,
                            },
                            Offset = Vector.Zero,
                            Color = Color.Default,
                        },
                        {
                            Panel = {
                                Sprites = achievementTooltipSprites,
                                Bounds = {-115, -70, 115, 115},
                                Height = 44,
                                TopSpacing = 2,
                                BottomSpacing = 0,
                                DefaultFontSize = 2,
                                DrawPositionOffset = Vector(0, 2),
                                Draw = function(panel, panelPos, item, tbl)

                                    if selectedAch then
                                        local buttons = {}

                                        if type(selectedAch.Note) == "table" then
                                            for _, str in ipairs(selectedAch.Note) do
                                                table.insert(buttons, {str = tostring(str), fsize = 2})
                                            end      
                                        else
                                            table.insert(buttons, {str = selectedAch.Note, fsize = 2}) 
                                        end
                                        buttons[#buttons + 1] = {str = "", fsize = 2}

                                        for _, str in ipairs(selectedAch.Tooltip) do
                                            table.insert(buttons, {str = tostring(str), fsize = 2})
                                        end

                                        if not BeckyAchievementSystem:IsUnlocked(selectedAch.ID) then
                                            if not mod.SaveManager.GetSettingsSave().lockAchTooltip or mod.SaveManager.GetSettingsSave().lockAchTooltip == 2 then
                                                buttons = {}
                                            end
                                            buttons[#buttons + 1] = {str = "", fsize = 2}
                                            buttons[#buttons + 1] = {str = "currently", fsize = 2}
                                            buttons[#buttons + 1] = {str = "locked", fsize = 2}
                                        end

                                        local drawItem = {
                                            valign = -1,
                                            buttons = buttons
                                        }

                                        drawings = dssmod.generateMenuDraw(drawItem, drawItem.buttons, panelPos, panel.Panel)

                                        if selectedAch.Tags and (mod.SaveManager.GetSettingsSave().lockAchTooltip == 1 or BeckyAchievementSystem:IsUnlocked(selectedAch.ID)) then
                                            local actNum = {}
                                            for i = 1, #selectedAch.Tags do
                                                if coOpBossList[selectedAch.Tags[i]] or mod:CheckTableContents(coOpSpriteList, selectedAch.Tags[i]) then
                                                    actNum[#actNum+1] = selectedAch.Tags[i]
                                                end
                                            end
                                            for i = 1, #actNum do
                                                if coOpBossList[selectedAch.Tags[i]] then
                                                    bossSprite:SetFrame("Destination", coOpBossList[actNum[i]])
                                                    bossSprite:Render(panelPos + Vector((-20*#actNum)+(20*i), 67))
                                                elseif mod:CheckTableContents(coOpSpriteList, actNum[i]) then
                                                    coOpSprite:Play(actNum[i])
                                                    coOpSprite:Render(panelPos + Vector((-20*#actNum)+(20*i), 70), Vector.Zero, Vector.Zero)
                                                end
                                            end
                                        end

                                        for _, drawing in ipairs(drawings) do
                                            dssmod.drawMenu(tbl, drawing)
                                        end
                                    end
                                end,
                                DefaultRendering = true
                            },
                            Offset = Vector(180, -2),
                            Color = 1
                        }
                    }
                },
            buttons = {buttonAchievements},
            generate = function(item, tbl) -- Becky specific
            
            end,
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
