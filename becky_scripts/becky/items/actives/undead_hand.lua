--[[
Undead Hand [Active]
You spawn a Zombie familiar that comes out of the ground 
Zombie act likes a Charmed Enemy, but if it gets killed, it'll be downed and recover itself after a few seconds when it kills an enemy it has a chance of turning it into another Zombie Familiar 
they go away after clearing the room
]]
local UNDEAD_HAND = {}

BeckyMod.Item.UNDEAD_HAND = UNDEAD_HAND
UNDEAD_HAND.ID = Isaac.GetItemIdByName("Undead Hand")

BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, rng, player, useFlags, slot)

    
end, UNDEAD_HAND.ID)