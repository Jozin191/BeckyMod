local GHOST_BALL_DMG = 1.25
local function Round(n, decimalPlaces)
	decimalPlaces = decimalPlaces or 0
	local mult = 10^(decimalPlaces or 0)
	return math.floor(n * mult + 0.5) / mult
end

---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_STYE) then return end

    local ghostData = fam:GetData()
    if ghostData.Stye then
        local tearsMult = Round(BeckyMod:toTearsPerSecond(player.MaxFireDelay), 2) / 2.73
        local baseDamage = (GHOST_BALL_DMG * player.Damage) * tearsMult
        enemy:TakeDamage(baseDamage * 0.28, 0, EntityRef(fam), 0)
        ghostData.Stye = false
    else
        ghostData.Stye = true
    end
end)