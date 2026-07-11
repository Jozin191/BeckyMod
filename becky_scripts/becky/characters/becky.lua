local BECKY = {}

BECKY.PLAYERTYPE = Isaac.GetPlayerTypeByName("Becky", false)

BECKY.HAIR_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_hair.anm2")
BECKY.BODY_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_body.anm2")

local game = BeckyMod.Game

BeckyMod.Character.BECKY = BECKY

---@param player EntityPlayer
function BECKY:OnInit(player)
    if player:GetPlayerType() ~= BECKY.PLAYERTYPE then return end
    PlayerAnimLib:SetDefaultAnm2(player, "gfx/player_becky.anm2")
    player:AddNullCostume(BECKY.HAIR_COSTUME)
    player:AddNullCostume(BECKY.BODY_COSTUME)
    player:AddCollectible(BeckyMod.Item.GHOST_AMULET.ID)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BECKY.OnInit, 0)

---@param player EntityPlayer
function BECKY:PostPlayerUpdate(player) -- "clog" kidney stone to prevent it firing from becky
    if player:GetPlayerType() == BECKY.PLAYERTYPE then
        player:SetUrethraBlock(false)
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BECKY.PostPlayerUpdate)

function BECKY:BeckyStats(player, flag)
    if player:GetPlayerType() ~= BECKY.PLAYERTYPE then return end

    if flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage * 1.3
    elseif flag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + 0.2
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BECKY.BeckyStats)



--Auri Compat
function BECKY:Onupdate(player)
	if (player:GetName() == "Becky") then
	
	uniqueprogressbar = true
	end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BECKY.Onupdate)