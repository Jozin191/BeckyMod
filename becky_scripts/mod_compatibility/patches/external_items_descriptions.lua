--luacheck: no max line length
-- Markdown guide https://github.com/wofsauge/External-Item-Descriptions/wiki
local Mod = BeckyMod
local BECKY_EID = {}

BECKY_EID.EID_Support = BECKY_EID

if not EID then
    return
end

local Item = BeckyMod.Item
local Trinket = BeckyMod.Trinket
local Character = BeckyMod.Character

function BECKY_EID:ClosestPlayerTo(entity) --This seems to error for some people sooo yeah
	if not entity then return EID.player end

	if EID.ClosestPlayerTo then
		return EID:ClosestPlayerTo(entity)
	else
		return EID.player
	end
end

--[[
local player_icons = Sprite()
player_icons:Load("gfx/ui/eid_character_icons.anm2", true)

local offsetX, offsetY = 6, 6

EID:addIcon("Becky", "Main", 1, 16, 16, offsetX, offsetY, player_icons)

EID.InlineIcons["Player" .. Character.BECKY.PLAYERTYPE] = EID.InlineIcons["Becky"]
]]