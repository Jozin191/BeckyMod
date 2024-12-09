local burningFeather = {}
local BURNING_FEATHER = Isaac.GetTrinketIdByName("Burning Feather")
local RECOMMENDED_SHIFT_IDX = 35
local startSeed = Game():GetSeeds():GetStartSeed()
local rng = RNG()

local playerGetDamage = false
local burningFeatherFlight = false
rng:SetSeed(startSeed, RECOMMENDED_SHIFT_IDX)

--just so the player can't keep the flight on a new run
function burningFeather:onInit()
    local player = Isaac.GetPlayer()
    burningFeatherFlight = false
    player:AddCacheFlags(CacheFlag.CACHE_FLYING)
    player:EvaluateItems()
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, burningFeather.onInit)

function burningFeather:onNewUnclearedRoom()
    local player = Isaac.GetPlayer()
    
    if not player:HasTrinket(BURNING_FEATHER) then
        return
    else
        if Game():GetRoom():IsClear() == false then
            local randomNumber = rng:RandomInt(100)
            if randomNumber >= 50 then
                player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_FATE, true)
                burningFeatherFlight = true
                player:AddCacheFlags(CacheFlag.CACHE_FLYING)
                player:EvaluateItems()
            elseif randomNumber < 50 then
                playerGetDamage = true
                player:AddCacheFlags(CacheFlag.CACHE_FLYING)
                player:EvaluateItems()
                burningFeatherFlight = false
                player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_FATE)
                print("triggou")
            end
        elseif Game():GetRoom():IsClear() then
            burningFeatherFlight = false
            player:AddCacheFlags(CacheFlag.CACHE_FLYING)
            player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_FATE)
            player:EvaluateItems()
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, burningFeather.onNewUnclearedRoom)

function burningFeather:canPlayerFly(player, cacheFlags)
    if cacheFlags & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING then
        player.CanFly = burningFeatherFlight
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, burningFeather.canPlayerFly)

function burningFeather:takeDamageOnRoom()
    local player = Isaac.GetPlayer()
    if playerGetDamage then
        player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
        playerGetDamage = false
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, burningFeather.takeDamageOnRoom)
