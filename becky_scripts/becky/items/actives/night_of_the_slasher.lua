local NOTS = {}

NOTS.ID = Isaac.GetItemIdByName("Night of the Slasher")

BeckyMod.Item.NIGHT_OF_THE_SLASHER = NOTS

NOTS.SpecialFunctions = {
    [100] = {
        DestroyFunction = function (pickup, player, rng)
            player:SetFullHearts()
            player:AddBlackHearts(2)
        end
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
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local pickup = entity:ToPickup()
        if pickup then
            local destroyLater = true
            local specialFunct = NOTS.SpecialFunctions[pickup.Variant]
            if specialFunct ~= nil then
                if specialFunct ~= false then
                    specialFunct.DestroyFunction(pickup, player, rng)
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