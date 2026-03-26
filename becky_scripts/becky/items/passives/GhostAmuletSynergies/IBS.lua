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
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_IBS) then return end

    local damageDone = (GHOST_BALL_DMG * player.Damage) * Round(BeckyMod:toTearsPerSecond(player.MaxFireDelay), 2) / 2.73
    damageDone = math.min(damageDone, enemy.HitPoints)
    
    local charge = player.IBSCharge + damageDone / (40 +13.33 * (BeckyMod.Level():GetStage() -1) )

    player.IBSCharge = math.min(charge, 1.0)
end)