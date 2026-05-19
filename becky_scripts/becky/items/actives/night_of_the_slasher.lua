local NOTS = {}

NOTS.ID = Isaac.GetItemIdByName("Night of the Slasher")
NOTS.NULL_ITEM_ID = Isaac.GetNullItemIdByName("Night of the Slasher_Costume handler")
NOTS.Costume = Isaac.GetCostumeIdByPath("gfx/characters/night_of_the_slasher.anm2")
local NullItemConfig = Isaac.GetItemConfig():GetNullItem(NOTS.NULL_ITEM_ID)

BeckyMod.Item.NIGHT_OF_THE_SLASHER = NOTS

NOTS.SpecialFunctions = {
    [100] = {
        DestroyFunction = function (pickup, player)
            if pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL then
                player:SetFullHearts()
                player:AddBlackHearts(2)
            else
                return true --do not remove the pedestal
            end
        end,
    },
    [300] = { -- Cards
        DestroyFunction = function (_, player)
            player:AddHearts(2)
        end
    },
    [70] = { -- Cards
        DestroyFunction = function (_, player)
            player:AddHearts(2)
        end
    },

    [110] = false, --Shovel

	[41] = false, -- Throwable bombs
	[50] = false, -- Chests (And the ones below as well until specified otherwise)
	[51] = false,
	[52] = false,
	[53] = false,
	[54] = false,
	[55] = false,
	[56] = false,
	[57] = false,
	[58] = false,
	[60] = false,
	[150] = false, -- Shop items
	[340] = false, -- Big Chest
	[350] = false,
	[360] = false, -- Red Chests
	[370] = false, -- Trophy
	[380] = false, -- Bed
	[390] = false, -- Mom's Chest
}

function NOTS:UseItem(type, rng, player, useflags, activeslot)
    for _, entity in ipairs(Isaac.FindInRadius(player.Position, 100)) do
        local pickup = entity:ToPickup()
        if pickup then
            local destroyLater = true
            local specialFunct = NOTS.SpecialFunctions[pickup.Variant]
            if specialFunct ~= nil then
                if specialFunct ~= false then
                    local poop = specialFunct.DestroyFunction(pickup, player, rng)
                    if poop then
                        destroyLater = false
                    end
                else
                    destroyLater = false
                end
            else
                player:AddHearts(1) --Health 1/2 a heart by default
            end
            if destroyLater then
                local pos = pickup.Position

                --Spawn gore and shit

                pickup:Remove()
            end
        end
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end

BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, NOTS.UseItem, NOTS.ID)


function NOTS:AddCollectible(itemID, charge, firstTime, slot, varData, player)
    player:AddNullItemEffect(NOTS.NULL_ITEM_ID, true)
    --player:AddNullCostume(NOTS.NULL_ITEM_ID)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, NOTS.AddCollectible, NOTS.ID)


function NOTS:RemoveCollectible(player, itemID, removePlayerForm, wispOrInnate)
    player:GetEffects():RemoveNullEffect(NOTS.NULL_ITEM_ID, 1)
    --player:RemoveCostume(NullItemConfig)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, NOTS.RemoveCollectible, NOTS.ID)
--[[
function NOTS:HandleCostume(player)
    local save = BeckyMod:RunSave(player)
    if player:HasCollectible(NOTS.ID) then
		if not save.NOTSCostume then
			player:AddNullCostume(NOTS.Costume)
			save.NOTSCostume = true
		end
	else
		if save.NOTSCostume then
			player:TryRemoveNullCostume(NOTS.Costume)
			save.NOTSCostume = nil
		end
	end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, NOTS.HandleCostume)]]