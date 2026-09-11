local mod = BeckyMod

BeckyMod.HasLoadedDSS = true

local achievement = {
    DEVILZONE_PRIME = Isaac.GetAchievementIdByName("Devilzon Prime"),
    NIGHT_OF_THE_SLASHER = Isaac.GetAchievementIdByName("Night of the Slasher"),
    DREAM_BANISHER = Isaac.GetAchievementIdByName("Dream Banisher"),
    SINNER = Isaac.GetAchievementIdByName("Sinner"),
    HOLY_BOOKMARK = Isaac.GetAchievementIdByName("Holy Bookmark"),
    CHALICE = Isaac.GetAchievementIdByName("Defiled Chalice"),
    COXINHA = Isaac.GetAchievementIdByName("Coxinha"),
    CORPSE_TAG = Isaac.GetAchievementIdByName("Corpse Tag"),
    SCARECROW = Isaac.GetAchievementIdByName("Scarecrow"),
    NULL_BOMBS = Isaac.GetAchievementIdByName("Null Bombs"),
    GHOST_AMULET = Isaac.GetAchievementIdByName("Ghost Amulet"),
    DEAD_SOCKET = Isaac.GetAchievementIdByName("Dead Socket"),
    DEAD_BATTERY = Isaac.GetAchievementIdByName("Dead Battery"),
    BUTCHERS_COOKBOOK = Isaac.GetAchievementIdByName("Butcher's Cookbook"),

    TAINTED_BECKY = Isaac.GetAchievementIdByName("Tainted Becky"),

    SOUL_OF_BECKY = Isaac.GetAchievementIdByName("Soul of Becky"),
    MAGIC_STAFF = Isaac.GetAchievementIdByName("Magic Staff"),
    UNDEAD_HAND = Isaac.GetAchievementIdByName("Undead Hand"),
    RIPPED_CARD = Isaac.GetAchievementIdByName("Ripped Card"),
    ALARM_CLOCK = Isaac.GetAchievementIdByName("Alarm Clock"),
    BUG_SPRAY = Isaac.GetAchievementIdByName("Bug Spray"),
    SKETCHY_BEGGAR = Isaac.GetAchievementIdByName("Sketchy Beggar"),

    POLTERGEIST_CHALLENGE = Isaac.GetAchievementIdByName("Poltergeist Challenge"),
    SANGUINE_FEATHER = Isaac.GetAchievementIdByName("Sanguine Feather"),
    POUL = Isaac.GetAchievementIdByName("Poul"),
}



local DSSModName = "becky Mod DSS Menu"

local BREAK_LINE = {str = "", fsize = 1, nosel = true}

local DSSCoreVersion = 7

local MenuProvider = {}

local MARKS_TO_STRING = {
    [CompletionType.MOMS_HEART] ="MomsHeart",
    [CompletionType.BOSS_RUSH] ="BossRush",
    [CompletionType.SATAN] ="Satan",
    [CompletionType.ISAAC] ="Isaac",
    [CompletionType.BLUE_BABY] ="BlueBaby",
    [CompletionType.LAMB] ="Lamb",
    [CompletionType.ULTRA_GREED]="UltraGreed",
    [CompletionType.ULTRA_GREEDIER]="UltraGreed",
    [CompletionType.MOTHER] ="Mother",
    [CompletionType.BEAST] ="Beast",
    [CompletionType.HUSH] ="Hush",
    [CompletionType.MEGA_SATAN] ="MegaSatan",
    [CompletionType.DELIRIUM] ="Delirium",
}

local function GenerateTooltip( ... )
    local endTable = {}

    for _, str in ipairs({...}) do
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
    end
    return {strset = endTable}
end


local function UpdateUnlock(state, unlockdata, playerId)
    local pgd = Isaac.GetPersistentGameData()

    if playerId and unlockdata.marks then
        local val = 1
        if not state then val = 0
        elseif unlockdata.marks.hardMode then val = 2
        end

        for _, mark in ipairs(unlockdata.marks) do
            Isaac.SetCompletionMark(playerId, mark, val)
        end
    end

    if state then
        Isaac.GetPersistentGameData():Unlock(unlockdata[1], false)
    else
        Isaac.ExecuteCommand("lockachievement "..unlockdata[1])
    end
end


local function GenerateUnlockTable(tab, data)
    local pgd = Isaac.GetPersistentGameData()
    tab.buttons = {}
    table.insert(tab.buttons, {
        str = "unlock all", fsize = 2,
        func = function() for _, unlockdata in ipairs(data.unlocks) do UpdateUnlock(true, unlockdata, data.playerId) end end,
        tooltip = GenerateTooltip("sync the unlocks with the character marks")
    })
    table.insert(tab.buttons, {
        str = "lock all", fsize = 2,
        func = function() for _, unlockdata in ipairs(data.unlocks) do UpdateUnlock(false, unlockdata, data.playerId) end end,
        tooltip = GenerateTooltip("sync the unlocks with the character marks")
    })

    if data.playerId ~= nil then
        table.insert(tab.buttons, { str = "", nosel = true })
        table.insert(tab.buttons, {
            str = "sync unlocks to marks", fsize = 2,
            func = function()
                for _, unlockdata in ipairs(data.unlocks) do
                    if unlockdata.marks then
                        local unlocked = true
                        for _, mark in ipairs(unlockdata.marks) do
                            local minVal = unlockdata.marks.hardMode and 2 or 1
                            if minVal > Isaac.GetCompletionMark(data.playerId, mark) then
                                unlocked = false
                                break
                            end
                        end
                        if unlocked then pgd:Unlock(unlockdata[1], false)
                        else Isaac.ExecuteCommand("lockachievement "..unlockdata[1])
                        end
                    end
                end
            end,
            tooltip = GenerateTooltip("sync the unlocks with the character marks")
        })
        table.insert(tab.buttons, {
            str = "sync marks to unlocks", fsize = 2,
            func = function()
                local marks = { PlayerType = data.playerId, UltraGreedier = 0 }
                for _, unlockdata in ipairs(data.unlocks) do
                    if unlockdata.marks then
                        local val = 0
                        if pgd:Unlocked(unlockdata[1]) then
                            if unlockdata.marks.hardMode then
                                val = 2
                            else val = 1
                            end
                        end
                        for _, mark in ipairs(unlockdata.marks) do
                            if val == 1 and mark == CompletionType.ULTRA_GREEDIER then
                                marks[ MARKS_TO_STRING[mark] ] = 2
                            else marks[ MARKS_TO_STRING[mark] ] = math.max((marks[ MARKS_TO_STRING[mark] ] or 0), val)
                            end
                        end
                    end
                end
                
                Isaac.SetCompletionMarks(marks)
            end,
            tooltip = GenerateTooltip("sync the marks with character unlocks")
        })
    end

    for _, unlockdata in ipairs(data.unlocks) do
        table.insert(tab.buttons, { str = "", nosel = true })
        
        table.insert(tab.buttons, {
            str = unlockdata.name, fsize = 2,
            tooltip = GenerateTooltip(unlockdata.tip),
            func = function()
                UpdateUnlock(not pgd:Unlocked(unlockdata[1]), unlockdata, data.playerId)
            end,
        })

        table.insert(tab.buttons, { str = "na", nosel = true, fsize = 2,
            update = function(b, i, t)
                if pgd:Unlocked(unlockdata[1]) then
                    b.str = "unlocked"
                else
                    b.str = "locked"
                end
            end
        })
    end
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

local cvsSprite = Sprite()
cvsSprite:Load("gfx/ui/deadseascrolls/newslettersprites.anm2", true)
cvsSprite:ReplaceSpritesheet(0, "gfx/ui/deadseascrolls/cvs.png")
cvsSprite:LoadGraphics()
cvsSprite:Play("Idle")

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if not mod.HasLoadedDSSReal and mod.SaveManager.IsLoaded() then

        BeckyMod.dmdirectory = {
            main = {
                title = 'becky',

                buttons = {
                    {str = 'resume game', action = 'resume'},
                    {str = 'manage unlocks', dest = 'ManUnlocks'},
                    {str = 'credits', dest = 'Beckycredits',tooltip = {strset = {'---','giving thanks', 'to everyone', 'who helped', '---'}}},         
                    BeckyMod.dssmod.changelogsButton,
                    {str = '', fsize=2, nosel = true},
                    {str = 'thanks for playing', fsize = 2, nosel = true},
                    {str = 'the becky mod', fsize = 2, nosel = true},
                },
                tooltip = BeckyMod.dssmod.menuOpenToolTip,
            },

            ManUnlocks = {
                title = 'manage unlocks',

                buttons = {
                    {
                        str = "unlock all", fsize = 2,
                        func = function()
                            local pgd = Isaac.GetPersistentGameData()
                            for _, achievId in ipairs(achievement) do pgd:Unlock(achievId, false) end
                            Isaac.FillCompletionMarks(mod.Character.BECKY.PLAYERTYPE)
                            Isaac.FillCompletionMarks(mod.Character.BECKY_B.PLAYERTYPE)
                        end,
                    },
                    {
                        str = "lock all", fsize = 2,
                        func = function()
                            for _, achievId in ipairs(achievement) do Isaac.ExecuteCommand("lockachievement "..achievId) end
                            Isaac.ClearCompletionMarks(mod.Character.BECKY.PLAYERTYPE)
                            Isaac.ClearCompletionMarks(mod.Character.BECKY_B.PLAYERTYPE)
                        end,
                    },
                    BREAK_LINE,
                    {str = 'becky unlocks', fsize = 2, dest = 'BeckyUnlocks'},
                    {str = 'tainted becky unlocks', fsize = 2, displayif = function() return not Isaac.GetPersistentGameData():Unlocked(achievement.TAINTED_BECKY) end},
                    {str = 'tainted becky unlocks', fsize = 2, dest = 'tBeckyUnlocks', displayif = function() return Isaac.GetPersistentGameData():Unlocked(achievement.TAINTED_BECKY) end},

                    {str = 'challenge unlocks', fsize = 2, dest = 'ChallengeUnlocks'},
                },
            },


            BeckyUnlocks = {
                generate = function(tab)
                    GenerateUnlockTable(tab, {
                        playerId = mod.Character.BECKY.PLAYERTYPE,
                        unlocks = {
                            {   
                                name = "devilzone prime",
                                marks = {CompletionType.MOMS_HEART},
                                achievement.DEVILZONE_PRIME,
                                tip="unlocked by deafeating mom's heart"
                            },
                            {
                                name = "night of the slasher",
                                marks = {CompletionType.BOSS_RUSH},
                                achievement.NIGHT_OF_THE_SLASHER,
                                tip="unlocked by completing boss rush"
                            },
                            {
                                name = "dream banisher",
                                marks = {CompletionType.SATAN},
                                achievement.DREAM_BANISHER,
                                tip="unlocked by deafeating satan"
                            },
                            {
                                name = "sinner",
                                marks = {CompletionType.ISAAC},
                                achievement.SINNER,
                                tip="unlocked by deafeating isaac"
                            },
                            {
                                name = "holy bookmark",
                                marks = {CompletionType.BLUE_BABY},
                                achievement.HOLY_BOOKMARK,
                                tip="unlocked by deafeating ???"
                            },
                            {
                                name = "chalice",
                                marks = {CompletionType.LAMB},
                                achievement.CHALICE,
                                tip="unlocked by deafeating the lamb"
                            },
                            {
                                name = "coxinha",
                                marks = {CompletionType.ULTRA_GREED},
                                achievement.COXINHA,
                                tip="unlocked by deafeating ultra greed"
                            },
                            {
                                name = "corpse tag",
                                marks = {CompletionType.ULTRA_GREEDIER},
                                achievement.CORPSE_TAG,
                                tip="unlocked by deafeating ultra greedier"
                            },
                            {
                                name = "scarecrow",
                                marks = {CompletionType.MOTHER},
                                achievement.SCARECROW,
                                tip="unlocked by deafeating mother"
                            },
                            {
                                name = "null bombs",
                                marks = {CompletionType.BEAST},
                                achievement.NULL_BOMBS,
                                tip="unlocked by deafeating the beast"
                            },
                            {
                                name = "ghost amulet",
                                marks = {hardMode = true, CompletionType.MOMS_HEART,CompletionType.BOSS_RUSH,CompletionType.SATAN,CompletionType.ISAAC,CompletionType.BLUE_BABY,CompletionType.LAMB,CompletionType.ULTRA_GREEDIER,CompletionType.MOTHER,CompletionType.BEAST,CompletionType.HUSH,CompletionType.MEGA_SATAN,CompletionType.DELIRIUM},
                                achievement.GHOST_AMULET,
                                tip="unlocked by getting all completion marks on hard mode"
                            },
                            {
                                name = "dead socket",
                                marks = {CompletionType.HUSH},
                                achievement.DEAD_SOCKET,
                                tip="unlocked by deafeating hush"
                            },
                            {
                                name = "dead battery",
                                marks = {CompletionType.MEGA_SATAN},
                                achievement.DEAD_BATTERY,
                                tip="unlocked by deafeating mega satan"
                            },
                            {
                                name = "butcher's cookbook",
                                marks = {CompletionType.DELIRIUM},
                                achievement.BUTCHERS_COOKBOOK,
                                tip="unlocked by deafeating delirium"
                            },
                            {
                                name = "tainted becky",
                                achievement.TAINTED_BECKY,
                                tip="unlocked by opening the secret closet"
                            },
                        }
                    })
                end
            },
            tBeckyUnlocks = {
                generate = function(tab)
                    
                    GenerateUnlockTable(tab, {
                        playerId = mod.Character.BECKY_B.PLAYERTYPE,
                        unlocks = {
                            {
                                name = "soul of becky",
                                marks = {CompletionType.BOSS_RUSH, CompletionType.HUSH},
                                achievement.SOUL_OF_BECKY,
                                tip="unlocked by deafeating hush and completing boss rush"
                            },
                            {
                                name = "bug spray",
                                marks = {CompletionType.SATAN,CompletionType.ISAAC,CompletionType.BLUE_BABY,CompletionType.LAMB},
                                achievement.BUG_SPRAY,
                                tip="unlocked by deafeating sata, isaac, the lamb and ???"
                            },
                            {
                                name = "ripped card",
                                marks = {CompletionType.ULTRA_GREEDIER},
                                achievement.RIPPED_CARD,
                                tip="unlocked by deafeating ultra greedier"
                            },
                            {
                                name = "alarm clock",
                                marks = {CompletionType.MOTHER},
                                achievement.ALARM_CLOCK,
                                tip="unlocked by deafeating mother"
                            },
                            {
                                name = "undead hand",
                                marks = {CompletionType.BEAST},
                                achievement.UNDEAD_HAND,
                                tip="unlocked by deafeating the beast"
                            },
                            {
                                name = "sketchy beggar",
                                marks = {CompletionType.MEGA_SATAN},
                                achievement.SKETCHY_BEGGAR,
                                tip="unlocked by deafeating maga satan"
                            },
                            {
                                name = "magic staff",
                                marks = {CompletionType.DELIRIUM},
                                achievement.MAGIC_STAFF,
                                tip="unlocked by deafeating delirium"
                            },
                        }
                    })
                end
            },
            ChallengeUnlocks = {
                generate = function(tab)
                    
                    GenerateUnlockTable(tab, {
                        unlocks = {
                            {
                                name = "sanguine feather",
                                achievement.SANGUINE_FEATHER,
                                tip="unlocked by beating the 'path of pain' challenge"
                            },
                            {
                                name = "poltergeist challenge",
                                achievement.POLTERGEIST_CHALLENGE,
                                tip="unlocked by unlocking the 'secret exit'"
                            },
                            {
                                name = "poul",
                                achievement.POUL,
                                tip="unlocked by beating the 'poltergeist' challenge"
                            },
                        }
                    })
                end
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
                    {spr = {sprite = cvsSprite, anim= "Idle", width = 0, height = 1, center = false, color = Color(1, 1, 1, 1)}, nosel = true, color = 2, pos = Vector(40, 40)},
                    {str = 'kotry', fsize=2, tooltip = GenerateTooltip('coder')},
                    {str = 'nomaxart', fsize=2, tooltip = GenerateTooltip('coder')},
                    {str = 'noopimdumb', fsize=2, tooltip = GenerateTooltip('coder')},
                    {str = 'tiburones', fsize=2, tooltip = GenerateTooltip('coder')},
                    {str = 'ignatz', fsize=2, tooltip = GenerateTooltip('coder')},
                    {str = 'cvs', fsize=2, tooltip = GenerateTooltip('coder', '', 'cvs waz here')},
                    {str = 'nerfexus', fsize=2, tooltip = GenerateTooltip('artist')},
                    {str = 'darigoat', fsize=2, tooltip = GenerateTooltip('artist')},
                    {str = 'no-name', fsize=2, tooltip = GenerateTooltip('artist')},
                    {str = 'onxc', fsize=2, tooltip = GenerateTooltip('artist')},
                    {str = 'burrowingbug', fsize=2, tooltip = GenerateTooltip('artist')},
                    {str = 'muffintae', fsize=2, tooltip = GenerateTooltip('designer')},
                    {str = 'blender', fsize=2, tooltip = GenerateTooltip('designer')},
                    {str = 'necrodancy', fsize=2, tooltip = GenerateTooltip('designer')},
                    -- {str = '', fsize=1, nosel = true},

                    BREAK_LINE,
                    {str = 'contributors', fsize = 3, nosel = true},
                    BREAK_LINE,
                    {str = 'kerkel', fsize=2, tooltip = GenerateTooltip('"sinner" code')},
                    {str = 'benny', fsize=2, tooltip = GenerateTooltip('"dead socket" code')},
                    {str = 'sorrow', fsize=2, tooltip = GenerateTooltip('"corpse tag" code')},
                    {str = 'lunastella', fsize=2, tooltip = GenerateTooltip('part of the ghost code')},
                    {str = 'hellio', fsize=2, tooltip = GenerateTooltip('part of the ghost code')},
                    {str = 'ferpe', fsize=2, tooltip = GenerateTooltip('tainted becky visual design')},
                    {str = 'pipstarmoth', fsize=2, tooltip = GenerateTooltip('soul of becky voiceline')},

                    BREAK_LINE,
                    {str = 'playtesters', fsize = 3, nosel = true},
                    BREAK_LINE,
                    {str = 'alperenalc', fsize=2},
                    {str = 'kattack', fsize=2},
                    {str = '4head', fsize=2},
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

        mod.HasLoadedDSSReal = true
    end
end)
