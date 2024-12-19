local BURNING_FEATHER = {}

BURNING_FEATHER.ID = Isaac.GetTrinketIdByName("Burning Feather")
local startSeed = BeckyMod.Game:GetSeeds():GetStartSeed() + 1
local rng = RNG()

BeckyMod.Trinket.BURNING_FEATHER = BURNING_FEATHER

rng:SetSeed(startSeed, BeckyMod.RECOMMENDED_SHIFT_IDX) --??? does it work like this??? what the frick

function BURNING_FEATHER:onNewUnclearedRoom()
    BeckyMod:ForEachPlayer(function(player)
        if player:HasTrinket(BURNING_FEATHER.ID) then
            if BeckyMod.Game:GetRoom():IsClear() == false then
                local randomNumber = rng:RandomInt(2) --No need to make it 100, it's basically just 1/2 at the end of the day
                if randomNumber == 0 then
                    player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_FATE, true)

                    BeckyMod:TempSave(player).BurningFeatherFlight = true

                    player:AddCacheFlags(CacheFlag.CACHE_FLYING)
                    player:EvaluateItems()
                else --AKA "randomNumber == 1"
                    player:AddCacheFlags(CacheFlag.CACHE_FLYING)
                    player:EvaluateItems()
                    player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_FATE)

                    Scheduler.Schedule( --Needs to wait for a frame lol
        				1,
        				function()
        					player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
        				end,
        				{ player }
        			)
                end
            elseif BeckyMod.Game:GetRoom():IsClear() then
                player:AddCacheFlags(CacheFlag.CACHE_FLYING)
                player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_FATE)
                player:EvaluateItems()
            end
        end
    end)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BURNING_FEATHER.onNewUnclearedRoom)

function BURNING_FEATHER:canPlayerFly(player, cacheFlags)
    -- If the player can already fly, do nothing lol
    local save = BeckyMod:TempSave(player)
    if not player.CanFly and player:HasTrinket(BURNING_FEATHER.ID) and save.BurningFeatherFlight and cacheFlags & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING then
        player.CanFly = true
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BURNING_FEATHER.canPlayerFly)
