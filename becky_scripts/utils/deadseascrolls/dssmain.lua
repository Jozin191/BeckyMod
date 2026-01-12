local mod = BeckyMod

BeckyMod.HasLoadedDSS = true

local DSSModName = "becky Mod DSS Menu"

local BREAK_LINE = {str = "", fsize = 1, nosel = true}

local DSSCoreVersion = 7

local MenuProvider = {}

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
                    {spr = {sprite = cvsSprite, anim= "Idle", width = 0, height = 1, center = false, color = Color(1, 1, 1, 1)}, nosel = true, color = 2, pos = Vector(40, 40)},
                    {str = 'kotry', fsize=2, tooltip = GenerateTooltip('main coder')},
                    {str = 'tiburones', fsize=2, tooltip = GenerateTooltip('coder')},
                    {str = 'ignatz', fsize=2, tooltip = GenerateTooltip('coder')},
                    {str = 'cvs', fsize=2, tooltip = GenerateTooltip('coder', '', 'cvs waz here')},
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
