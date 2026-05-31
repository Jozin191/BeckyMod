local function min3(a, b, c)
    return math.min(math.min(a, b), c)
end
local function hueToRGB(h)
    local kr, kg, kb = (5+h*6) % 6, (3+h*6) % 6, (1+h*6) % 6

    local r, g, b = 1 - math.max(min3(kr, 4-kr, 1), 0), 1 - math.max(min3(kg, 4-kg, 1), 0), 1 - math.max(min3(kb, 4-kb, 1), 0)
    return Color(1, 1, 1, 1, r/2, g/2, b/2)
end
---@param familiar EntityFamiliar
---@param offset Vector
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_RENDER_HELPER, function(_, familiar, offset)
    
    local player = familiar.Player
    if player:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE) or player:HasCollectible(CollectibleType.COLLECTIBLE_FRUIT_CAKE) or player:HasCollectible(CollectibleType.COLLECTIBLE_3_DOLLAR_BILL) then
        local gay = hueToRGB((player.FrameCount/255)*2)
        familiar:SetColor(familiar.Color*gay, 2, 100, false, true)
    end
end)