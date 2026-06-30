local BECKY = {}

BECKY.PLAYERTYPE = Isaac.GetPlayerTypeByName("Becky", false)

BECKY.HAIR_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_hair.anm2")
BECKY.BODY_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_body.anm2")

local ITEM_GHOST_AMULET = Isaac.GetItemIdByName("Ghost Amulet")

local game = BeckyMod.Game

BeckyMod.Character.BECKY = BECKY

---@param player EntityPlayer
function BECKY:OnInit(player)
    if player:GetPlayerType() ~= BECKY.PLAYERTYPE then return end
    PlayerAnimLib:SetDefaultAnm2(player, "gfx/player_becky.anm2")
    player:AddNullCostume(BECKY.HAIR_COSTUME)
    player:AddNullCostume(BECKY.BODY_COSTUME)
    player:AddCollectible(ITEM_GHOST_AMULET)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BECKY.OnInit, 0)



function BECKY:DamageMult(player)
    if player:GetPlayerType() ~= BECKY.PLAYERTYPE then return end
    player.Damage = player.Damage * 1.2
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BECKY.DamageMult, CacheFlag.CACHE_DAMAGE)



--Auri Compat
function BECKY:Onupdate(player)
	if (player:GetName() == "Becky") then
	
	uniqueprogressbar = true
	end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BECKY.Onupdate)