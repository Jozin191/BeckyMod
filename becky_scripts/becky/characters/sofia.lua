local SOFIA = {}

SOFIA.PLAYERTYPE = Isaac.GetPlayerTypeByName("Sofia", false)

SOFIA.HAIR_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/sofia_hair.anm2")
SOFIA.BODY_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/sofia_belt.anm2")

local game = BeckyMod.Game

---@param player EntityPlayer
function SOFIA:OnInit(player)
    if player:GetPlayerType() == SOFIA.PLAYERTYPE then
        player:AddNullCostume(SOFIA.HAIR_COSTUME)
        player:AddNullCostume(SOFIA.BODY_COSTUME)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SOFIA.OnInit, 0)

---@param pickup EntityPickup
---@param collider Entity
function SOFIA:postPickup(pickup, collider, low)
    if collider.Type ~= EntityType.ENTITY_PLAYER or pickup.Variant == PickupVariant.PICKUP_HEART then return end
    local player = collider:ToPlayer()

    if player and player:GetPlayerType() == SOFIA.PLAYERTYPE then 
        player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(pickup), 1)
    end

end
BeckyMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, SOFIA.postPickup)