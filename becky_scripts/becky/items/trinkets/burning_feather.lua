--Lowkey I think the code is kinda ass (I didn't code it) -Tibu

local BURNING_FEATHER = {}

BURNING_FEATHER.ID = Isaac.GetTrinketIdByName("Burning Feather")
local startSeed = Game():GetSeeds():GetStartSeed() + 1
local rng = RNG()

BURNING_FEATHER.PLAYER_GET_DAMAGE = false --100% sure this means no local co-op support LOL
BURNING_FEATHER.BURNING_FEATHER_FLIGHT = false

BeckyMod.Trinket.BURNING_FEATHER = BURNING_FEATHER

rng:SetSeed(startSeed, BeckyMod.RECOMMENDED_SHIFT_IDX) --??? does it work like this??? what the fuck

--just so the player can't keep the flight on a new run
function BURNING_FEATHER:onInit()
    local player = Isaac.GetPlayer()
    BURNING_FEATHER.BURNING_FEATHER_FLIGHT = false
    player:AddCacheFlags(CacheFlag.CACHE_FLYING)
    player:EvaluateItems()
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BURNING_FEATHER.onInit)

function BURNING_FEATHER:onNewUnclearedRoom()
    local player = Isaac.GetPlayer()
    
    if player:HasTrinket(BURNING_FEATHER.ID) then
        if Game():GetRoom():IsClear() == false then
            local randomNumber = rng:RandomInt(2) --No need to make it 100, it's basically just 1/2 at the end of the day
            if randomNumber == 0 then
                player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_FATE, true)
                BURNING_FEATHER.BURNING_FEATHER_FLIGHT = true
                player:AddCacheFlags(CacheFlag.CACHE_FLYING)
                player:EvaluateItems()
            elseif randomNumber == 1 then
                BURNING_FEATHER.PLAYER_GET_DAMAGE = true
                player:AddCacheFlags(CacheFlag.CACHE_FLYING)
                player:EvaluateItems()
                BURNING_FEATHER.BURNING_FEATHER_FLIGHT = false
                player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_FATE)
            end
        elseif Game():GetRoom():IsClear() then
            BURNING_FEATHER.BURNING_FEATHER_FLIGHT = false
            player:AddCacheFlags(CacheFlag.CACHE_FLYING)
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_FATE)
            player:EvaluateItems()
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BURNING_FEATHER.onNewUnclearedRoom)

function BURNING_FEATHER:canPlayerFly(player, cacheFlags)
    -- If the player can already fly, do nothing lol
    if not player.CanFly and player:HasTrinket(BURNING_FEATHER.ID) and cacheFlags & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING then
        player.CanFly = BURNING_FEATHER.BURNING_FEATHER_FLIGHT
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BURNING_FEATHER.canPlayerFly)

function BURNING_FEATHER:takeDamageOnRoom()
    local player = Isaac.GetPlayer()
    if BURNING_FEATHER.PLAYER_GET_DAMAGE then
        player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
        BURNING_FEATHER.PLAYER_GET_DAMAGE = false
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BURNING_FEATHER.takeDamageOnRoom)
