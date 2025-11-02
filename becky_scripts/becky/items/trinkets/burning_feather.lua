--[[
    CREDTIS:
        ITEM IDEA: InterstellarNuggo
        ART: Nerfexus
        CODE: Tiburones202 and Nerfexus
]]
local mod = BeckyMod
local enums = mod.Enums
local utils = enums.Utils
local game = utils.Game
local trinkets = enums.TrinketType

local BURNING_FEATHER = {}
local startSeed = game:GetSeeds():GetStartSeed() -- afaik, game start seeds can't be 0
local rng = RNG()

BeckyMod.Trinket.BURNING_FEATHER = BURNING_FEATHER

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    rng:SetSeed(startSeed, 35) 
end)

function BURNING_FEATHER:onNewUnclearedRoom()
    ---@param player EntityPlayer
    BeckyMod:ForEachPlayer(function(player)
        if not player:HasTrinket(trinkets.BURNING_FEATHER) then return end

        local room = game:GetRoom()
        local isRoomClear = room:IsClear()
        local playerFX = player:GetEffects()
        
        if isRoomClear then
            playerFX:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_FATE)
        else
            local roll = mod:RandomBoolean(rng)

            if roll then
                playerFX:AddCollectibleEffect(CollectibleType.COLLECTIBLE_FATE, true)
                BeckyMod:TempSave(player).BurningFeatherFlight = true
            else
                playerFX:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_FATE)
                Scheduler.Schedule( --Needs to wait for a frame lol
                    1,
                    function()
                        player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
                    end,
                    { player }
                )
            end
        end
        player:AddCacheFlags(CacheFlag.CACHE_FLYING, true)
    end)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BURNING_FEATHER.onNewUnclearedRoom)

function BURNING_FEATHER:canPlayerFly(player)
    -- If the player can already fly, do nothing lol
    local save = BeckyMod:TempSave(player)
    
    if not player:HasTrinket(trinkets.BURNING_FEATHER) then return end
    if not save.BurningFeatherFlight then return end
    if player.CanFly then return end
    
    player.CanFly = true
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BURNING_FEATHER.canPlayerFly, CacheFlag.CACHE_FLYING)