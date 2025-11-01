local BUTCHERS_ID = Isaac.GetItemIdByName("Butcher's Cookbook")
local game = Game()

---@param player EntityPlayer
local function butchersUse(_, collectibleID, rngObj, player, useFlags, activeSlot, varData)
    local room = game:GetRoom()
    local gridIndex = room:GetGridIndex(player.Position)
end
BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, butchersUse, BUTCHERS_ID)